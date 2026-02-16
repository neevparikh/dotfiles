import type { Plugin } from "@opencode-ai/plugin"
import type { AgentConfig } from "@opencode-ai/sdk"
import yaml from "js-yaml"
import { homedir } from "node:os"
import { join, basename } from "node:path"
import { existsSync, readFileSync, readdirSync, realpathSync, mkdirSync, writeFileSync, appendFileSync, promises as fsPromises, type Dirent } from "node:fs"
import { spawn } from "node:child_process"

// ═══════════════════════════════════════════════════════════════════════════════
// Utils
// ═══════════════════════════════════════════════════════════════════════════════

function getClaudeConfigDir(): string {
  return process.env.CLAUDE_CONFIG_DIR || join(homedir(), ".claude")
}

function getHomeDirectory(): string {
  return process.env.HOME || process.env.USERPROFILE || homedir()
}

function log(message: string, extra?: unknown): void {
  if (process.env.DEBUG || process.env.OPENCODE_DEBUG) {
    console.error(`[claude-code-compat] ${message}`, extra ?? "")
  }
}

// ── Frontmatter parser ──

interface FrontmatterResult<T = Record<string, unknown>> {
  data: T
  body: string
}

function parseFrontmatter<T = Record<string, unknown>>(content: string): FrontmatterResult<T> {
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n?---\r?\n([\s\S]*)$/)
  if (!match) return { data: {} as T, body: content }
  try {
    const parsed = yaml.load(match[1], { schema: yaml.JSON_SCHEMA })
    return { data: (parsed ?? {}) as T, body: match[2] }
  } catch {
    return { data: {} as T, body: match[2] }
  }
}

// ── Env var expansion ──

function expandEnvVars(value: string): string {
  return value.replace(
    /\$\{([^}:]+)(?::-([^}]*))?\}/g,
    (_, varName: string, defaultValue?: string) => {
      const envValue = process.env[varName]
      if (envValue !== undefined) return envValue
      if (defaultValue !== undefined) return defaultValue
      return ""
    },
  )
}

function expandEnvVarsInObject<T>(obj: T): T {
  if (obj === null || obj === undefined) return obj
  if (typeof obj === "string") return expandEnvVars(obj) as T
  if (Array.isArray(obj)) return obj.map((item) => expandEnvVarsInObject(item)) as T
  if (typeof obj === "object") {
    const result: Record<string, unknown> = {}
    for (const [key, value] of Object.entries(obj)) {
      result[key] = expandEnvVarsInObject(value)
    }
    return result as T
  }
  return obj
}

// ── Tool name transform (OpenCode -> Claude Code PascalCase) ──

const SPECIAL_TOOL_MAPPINGS: Record<string, string> = {
  webfetch: "WebFetch",
  websearch: "WebSearch",
  todoread: "TodoRead",
  todowrite: "TodoWrite",
}

function toPascalCase(str: string): string {
  return str
    .split(/[-_\s]+/)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join("")
}

function transformToolName(toolName: string): string {
  const trimmed = toolName.trim()
  const lower = trimmed.toLowerCase()
  if (lower in SPECIAL_TOOL_MAPPINGS) return SPECIAL_TOOL_MAPPINGS[lower]
  if (trimmed.includes("-") || trimmed.includes("_")) return toPascalCase(trimmed)
  return trimmed.charAt(0).toUpperCase() + trimmed.slice(1)
}

// ── Snake case conversion ──

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value) && Object.prototype.toString.call(value) === "[object Object]"
}

function camelToSnake(str: string): string {
  return str.replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`)
}

function transformObjectKeys(obj: Record<string, unknown>, transformer: (key: string) => string): Record<string, unknown> {
  const result: Record<string, unknown> = {}
  for (const [key, value] of Object.entries(obj)) {
    const k = transformer(key)
    if (isPlainObject(value)) {
      result[k] = transformObjectKeys(value, transformer)
    } else if (Array.isArray(value)) {
      result[k] = value.map((item) => (isPlainObject(item) ? transformObjectKeys(item, transformer) : item))
    } else {
      result[k] = value
    }
  }
  return result
}

function objectToSnakeCase(obj: Record<string, unknown>): Record<string, unknown> {
  return transformObjectKeys(obj, camelToSnake)
}

// ── Pattern matcher ──

function escapeRegexExceptAsterisk(str: string): string {
  return str.replace(/[.+?^${}()|[\]\\]/g, "\\$&")
}

function matchesToolMatcher(toolName: string, matcher: string): boolean {
  if (!matcher) return true
  const patterns = matcher.split("|").map((p) => p.trim())
  return patterns.some((p) => {
    if (p.includes("*")) {
      const escaped = escapeRegexExceptAsterisk(p)
      const regex = new RegExp(`^${escaped.replace(/\*/g, ".*")}$`, "i")
      return regex.test(toolName)
    }
    return p.toLowerCase() === toolName.toLowerCase()
  })
}

// ── Shell command execution ──

interface CommandResult {
  exitCode: number
  stdout?: string
  stderr?: string
}

const DEFAULT_ZSH_PATHS = ["/bin/zsh", "/usr/bin/zsh", "/usr/local/bin/zsh"]
const DEFAULT_BASH_PATHS = ["/bin/bash", "/usr/bin/bash", "/usr/local/bin/bash"]

function findShellPath(paths: string[], custom?: string): string | null {
  if (custom && existsSync(custom)) return custom
  for (const p of paths) {
    if (existsSync(p)) return p
  }
  return null
}

async function executeHookCommand(command: string, stdin: string, cwd: string): Promise<CommandResult> {
  const home = getHomeDirectory()
  const expanded = command
    .replace(/^~(?=\/|$)/g, home)
    .replace(/\s~(?=\/)/g, ` ${home}`)
    .replace(/\$CLAUDE_PROJECT_DIR/g, cwd)
    .replace(/\$\{CLAUDE_PROJECT_DIR\}/g, cwd)

  let finalCommand = expanded
  if (process.platform !== "win32") {
    const zsh = findShellPath(DEFAULT_ZSH_PATHS)
    const bash = findShellPath(DEFAULT_BASH_PATHS)
    const escapedCommand = expanded.replace(/'/g, "'\\''")
    if (zsh) {
      finalCommand = `${zsh} -lc '${escapedCommand}'`
    } else if (bash) {
      finalCommand = `${bash} -lc '${escapedCommand}'`
    }
  }

  return new Promise((resolve) => {
    const proc = spawn(finalCommand, {
      cwd,
      shell: true,
      env: { ...process.env, HOME: home, CLAUDE_PROJECT_DIR: cwd },
    })

    let stdout = ""
    let stderr = ""
    proc.stdout?.on("data", (d: Buffer) => { stdout += d.toString() })
    proc.stderr?.on("data", (d: Buffer) => { stderr += d.toString() })
    proc.stdin?.write(stdin)
    proc.stdin?.end()

    proc.on("close", (code: number | null) => {
      resolve({ exitCode: code ?? 0, stdout: stdout.trim(), stderr: stderr.trim() })
    })
    proc.on("error", (err: Error) => {
      resolve({ exitCode: 1, stderr: err.message })
    })
  })
}

// ── File helpers ──

function isMarkdownFile(entry: { name: string; isFile: () => boolean }): boolean {
  return !entry.name.startsWith(".") && entry.name.endsWith(".md") && entry.isFile()
}

// ═══════════════════════════════════════════════════════════════════════════════
// Storage (todos, transcripts, tool input cache)
// ═══════════════════════════════════════════════════════════════════════════════

const TODO_DIR = join(getClaudeConfigDir(), "todos")
const TRANSCRIPT_DIR = join(getClaudeConfigDir(), "transcripts")

interface OpenCodeTodo {
  content: string
  status: string
  priority: string
  id: string
}

function ensureDir(dir: string): void {
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true })
}

function getTodoPath(sessionId: string): string {
  return join(TODO_DIR, `${sessionId}-agent-${sessionId}.json`)
}

function saveOpenCodeTodos(sessionId: string, todos: OpenCodeTodo[]): void {
  ensureDir(TODO_DIR)
  const path = getTodoPath(sessionId)
  const claudeFormat = todos.map((item) => ({
    content: item.content,
    status: item.status === "cancelled" ? "completed" : item.status,
    activeForm: item.content,
  }))
  writeFileSync(path, JSON.stringify(claudeFormat, null, 2))
}

interface TranscriptEntry {
  type: "tool_use" | "tool_result" | "user" | "assistant"
  timestamp: string
  tool_name?: string
  tool_input?: Record<string, unknown>
  tool_output?: Record<string, unknown>
  content?: string
}

function appendTranscriptEntry(sessionId: string, entry: TranscriptEntry): void {
  ensureDir(TRANSCRIPT_DIR)
  appendFileSync(join(TRANSCRIPT_DIR, `${sessionId}.jsonl`), JSON.stringify(entry) + "\n")
}

function recordToolUse(sessionId: string, toolName: string, toolInput: Record<string, unknown>): void {
  appendTranscriptEntry(sessionId, { type: "tool_use", timestamp: new Date().toISOString(), tool_name: transformToolName(toolName), tool_input: toolInput })
}

function recordToolResult(sessionId: string, toolName: string, toolInput: Record<string, unknown>, toolOutput: Record<string, unknown>): void {
  appendTranscriptEntry(sessionId, { type: "tool_result", timestamp: new Date().toISOString(), tool_name: transformToolName(toolName), tool_input: toolInput, tool_output: toolOutput })
}

function recordUserMessage(sessionId: string, content: string): void {
  appendTranscriptEntry(sessionId, { type: "user", timestamp: new Date().toISOString(), content })
}

// Tool input cache (for PostToolUse to access original input)
const toolInputCache = new Map<string, { toolInput: Record<string, unknown>; timestamp: number }>()
const CACHE_TTL = 60_000

function cacheToolInput(sessionId: string, toolName: string, callId: string, toolInput: Record<string, unknown>): void {
  toolInputCache.set(`${sessionId}:${toolName}:${callId}`, { toolInput, timestamp: Date.now() })
}

function getToolInput(sessionId: string, toolName: string, callId: string): Record<string, unknown> | null {
  const key = `${sessionId}:${toolName}:${callId}`
  const entry = toolInputCache.get(key)
  if (!entry) return null
  toolInputCache.delete(key)
  if (Date.now() - entry.timestamp > CACHE_TTL) return null
  return entry.toolInput
}

const cleanup = setInterval(() => {
  const now = Date.now()
  for (const [key, entry] of toolInputCache) {
    if (now - entry.timestamp > CACHE_TTL) toolInputCache.delete(key)
  }
}, CACHE_TTL)
if (typeof cleanup === "object" && "unref" in cleanup) cleanup.unref()

// ═══════════════════════════════════════════════════════════════════════════════
// Hooks (Claude Code settings.json hooks)
// ═══════════════════════════════════════════════════════════════════════════════

interface HookCommand {
  type: "command"
  command: string
}

interface HookMatcher {
  matcher: string
  hooks: HookCommand[]
}

interface ClaudeHooksConfig {
  PreToolUse?: HookMatcher[]
  PostToolUse?: HookMatcher[]
  UserPromptSubmit?: HookMatcher[]
  Stop?: HookMatcher[]
}

type HookEvent = keyof ClaudeHooksConfig

interface RawHookMatcher {
  matcher?: string
  pattern?: string
  hooks: HookCommand[]
}

function normalizeHookMatcher(raw: RawHookMatcher): HookMatcher {
  return {
    matcher: raw.matcher ?? raw.pattern ?? "*",
    hooks: Array.isArray(raw.hooks) ? raw.hooks : [],
  }
}

function getSettingsPaths(directory: string): string[] {
  const claudeDir = getClaudeConfigDir()
  return [...new Set([
    join(claudeDir, "settings.json"),
    join(directory, ".claude", "settings.json"),
    join(directory, ".claude", "settings.local.json"),
  ])]
}

function mergeHooksConfig(base: ClaudeHooksConfig, override: ClaudeHooksConfig): ClaudeHooksConfig {
  const result: ClaudeHooksConfig = { ...base }
  const events: HookEvent[] = ["PreToolUse", "PostToolUse", "UserPromptSubmit", "Stop"]
  for (const event of events) {
    if (override[event]) {
      result[event] = [...(base[event] || []), ...override[event]]
    }
  }
  return result
}

function loadClaudeHooksConfig(directory: string): ClaudeHooksConfig | null {
  const paths = getSettingsPaths(directory)
  let merged: ClaudeHooksConfig = {}

  for (const settingsPath of paths) {
    if (!existsSync(settingsPath)) continue
    try {
      const content = readFileSync(settingsPath, "utf-8")
      const settings = JSON.parse(content) as { hooks?: Record<string, RawHookMatcher[]> }
      if (settings.hooks) {
        const normalized: ClaudeHooksConfig = {}
        for (const event of ["PreToolUse", "PostToolUse", "UserPromptSubmit", "Stop"] as HookEvent[]) {
          if (settings.hooks[event]) {
            normalized[event] = settings.hooks[event].map(normalizeHookMatcher)
          }
        }
        merged = mergeHooksConfig(merged, normalized)
      }
    } catch {
      continue
    }
  }

  return Object.keys(merged).length > 0 ? merged : null
}

// ── Merge marketplace plugin hooks into config ──

interface PluginHooksConfig {
  [event: string]: Array<{ matcher?: string; pattern?: string; hooks: HookCommand[] }>
}

function mergePluginHooksIntoConfig(
  settingsConfig: ClaudeHooksConfig | null,
  pluginHooksConfigs: PluginHooksConfig[],
): ClaudeHooksConfig | null {
  if (pluginHooksConfigs.length === 0) return settingsConfig

  let merged: ClaudeHooksConfig = settingsConfig ? { ...settingsConfig } : {}

  for (const pluginConfig of pluginHooksConfigs) {
    for (const [event, matchers] of Object.entries(pluginConfig)) {
      if (!["PreToolUse", "PostToolUse", "UserPromptSubmit", "Stop"].includes(event)) continue
      const hookEvent = event as HookEvent
      const normalized = matchers.map(normalizeHookMatcher)
      merged[hookEvent] = [...(merged[hookEvent] || []), ...normalized]
    }
  }

  return Object.keys(merged).length > 0 ? merged : null
}

// ── Hook matching ──

function findMatchingHooks(config: ClaudeHooksConfig, event: HookEvent, toolName?: string): HookMatcher[] {
  const matchers = config[event]
  if (!matchers) return []
  return matchers.filter((m) => !toolName || matchesToolMatcher(toolName, m.matcher))
}

// ── PreToolUse ──

interface PreToolUseResult {
  decision: "allow" | "deny" | "ask"
  reason?: string
  modifiedInput?: Record<string, unknown>
}

async function executePreToolUseHooks(
  config: ClaudeHooksConfig | null,
  sessionId: string,
  toolName: string,
  toolInput: Record<string, unknown>,
  cwd: string,
  callId?: string,
): Promise<PreToolUseResult> {
  if (!config) return { decision: "allow" }

  const transformed = transformToolName(toolName)
  const matchers = findMatchingHooks(config, "PreToolUse", transformed)
  if (matchers.length === 0) return { decision: "allow" }

  const stdinData = {
    session_id: sessionId, cwd, permission_mode: "bypassPermissions",
    hook_event_name: "PreToolUse", tool_name: transformed,
    tool_input: objectToSnakeCase(toolInput), tool_use_id: callId,
    hook_source: "opencode-plugin",
  }

  for (const matcher of matchers) {
    for (const hook of matcher.hooks) {
      if (hook.type !== "command") continue

      const result = await executeHookCommand(hook.command, JSON.stringify(stdinData), cwd)

      if (result.exitCode === 2) {
        return { decision: "deny", reason: result.stderr || result.stdout || "Hook blocked the operation" }
      }
      if (result.exitCode === 1) {
        return { decision: "ask", reason: result.stderr || result.stdout }
      }

      if (result.stdout) {
        try {
          const output = JSON.parse(result.stdout)
          let decision: "allow" | "deny" | "ask" | undefined
          let reason: string | undefined
          let modifiedInput: Record<string, unknown> | undefined

          if (output.hookSpecificOutput?.permissionDecision) {
            decision = output.hookSpecificOutput.permissionDecision
            reason = output.hookSpecificOutput.permissionDecisionReason
            modifiedInput = output.hookSpecificOutput.updatedInput
          } else if (output.decision) {
            const d = output.decision
            if (d === "approve" || d === "allow") decision = "allow"
            else if (d === "block" || d === "deny") decision = "deny"
            else if (d === "ask") decision = "ask"
            reason = output.reason
          }

          if (decision) return { decision, reason, modifiedInput }
        } catch { /* non-JSON output is ok */ }
      }
    }
  }

  return { decision: "allow" }
}

// ── PostToolUse ──

interface PostToolUseResult {
  block: boolean
  reason?: string
  message?: string
  warnings?: string[]
}

async function executePostToolUseHooks(
  config: ClaudeHooksConfig | null,
  sessionId: string,
  toolName: string,
  toolInput: Record<string, unknown>,
  toolOutput: Record<string, unknown>,
  cwd: string,
  callId?: string,
): Promise<PostToolUseResult> {
  if (!config) return { block: false }

  const transformed = transformToolName(toolName)
  const matchers = findMatchingHooks(config, "PostToolUse", transformed)
  if (matchers.length === 0) return { block: false }

  const stdinData = {
    session_id: sessionId, cwd, permission_mode: "bypassPermissions",
    hook_event_name: "PostToolUse", tool_name: transformed,
    tool_input: objectToSnakeCase(toolInput), tool_response: objectToSnakeCase(toolOutput),
    tool_use_id: callId, hook_source: "opencode-plugin",
  }

  const messages: string[] = []
  const warnings: string[] = []

  for (const matcher of matchers) {
    for (const hook of matcher.hooks) {
      if (hook.type !== "command") continue

      const result = await executeHookCommand(hook.command, JSON.stringify(stdinData), cwd)

      if (result.stdout) messages.push(result.stdout)
      if (result.exitCode === 2 && result.stderr) warnings.push(result.stderr.trim())

      if (result.stdout) {
        try {
          const output = JSON.parse(result.stdout)
          if (output.decision === "block") {
            return { block: true, reason: output.reason, message: messages.join("\n"), warnings }
          }
        } catch { /* non-JSON is ok */ }
      }
    }
  }

  return {
    block: false,
    message: messages.length > 0 ? messages.join("\n") : undefined,
    warnings: warnings.length > 0 ? warnings : undefined,
  }
}

// ── UserPromptSubmit ──

interface UserPromptSubmitResult {
  block: boolean
  reason?: string
  messages: string[]
}

async function executeUserPromptSubmitHooks(
  config: ClaudeHooksConfig | null,
  sessionId: string,
  prompt: string,
  cwd: string,
): Promise<UserPromptSubmitResult> {
  const messages: string[] = []
  if (!config) return { block: false, messages }

  const matchers = findMatchingHooks(config, "UserPromptSubmit")
  if (matchers.length === 0) return { block: false, messages }

  const TAG_OPEN = "<user-prompt-submit-hook>"
  const TAG_CLOSE = "</user-prompt-submit-hook>"

  const stdinData = {
    session_id: sessionId, cwd, permission_mode: "bypassPermissions",
    hook_event_name: "UserPromptSubmit", prompt,
    session: { id: sessionId }, hook_source: "opencode-plugin",
  }

  for (const matcher of matchers) {
    for (const hook of matcher.hooks) {
      if (hook.type !== "command") continue

      const result = await executeHookCommand(hook.command, JSON.stringify(stdinData), cwd)

      if (result.stdout) {
        const output = result.stdout.trim()
        if (output.startsWith(TAG_OPEN)) {
          messages.push(output)
        } else {
          messages.push(`${TAG_OPEN}\n${output}\n${TAG_CLOSE}`)
        }
      }

      if (result.exitCode !== 0) {
        try {
          const output = JSON.parse(result.stdout || "{}")
          if (output.decision === "block") {
            return { block: true, reason: output.reason, messages }
          }
        } catch { /* ok */ }
      }
    }
  }

  return { block: false, messages }
}

// ── Stop ──

interface StopResult {
  block: boolean
  reason?: string
  injectPrompt?: string
}

const stopHookActiveState = new Map<string, boolean>()

async function executeStopHooks(
  config: ClaudeHooksConfig | null,
  sessionId: string,
  cwd: string,
  todoPath?: string,
): Promise<StopResult> {
  if (!config) return { block: false }

  const matchers = findMatchingHooks(config, "Stop")
  if (matchers.length === 0) return { block: false }

  const stdinData = {
    session_id: sessionId, cwd, permission_mode: "bypassPermissions",
    hook_event_name: "Stop", stop_hook_active: stopHookActiveState.get(sessionId) ?? false,
    todo_path: todoPath, hook_source: "opencode-plugin",
  }

  for (const matcher of matchers) {
    for (const hook of matcher.hooks) {
      if (hook.type !== "command") continue

      const result = await executeHookCommand(hook.command, JSON.stringify(stdinData), cwd)

      if (result.exitCode === 2) {
        const reason = result.stderr || result.stdout || "Blocked by stop hook"
        return { block: true, reason, injectPrompt: reason }
      }

      if (result.stdout) {
        try {
          const output = JSON.parse(result.stdout)
          if (output.stop_hook_active !== undefined) {
            stopHookActiveState.set(sessionId, output.stop_hook_active)
          }
          if (output.decision === "block") {
            return { block: true, reason: output.reason, injectPrompt: output.inject_prompt ?? output.reason }
          }
        } catch { /* non-JSON is ok */ }
      }
    }
  }

  return { block: false }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Commands (from .claude/commands/)
// ═══════════════════════════════════════════════════════════════════════════════

interface CommandDefinition {
  description?: string
  template: string
  agent?: string
  model?: string
  subtask?: boolean
}

interface CommandFrontmatter {
  description?: string
  "argument-hint"?: string
  agent?: string
  model?: string
  subtask?: boolean
}

type CommandScope = "user" | "project"

async function loadCommandsFromDir(
  commandsDir: string,
  scope: CommandScope,
  visited = new Set<string>(),
  prefix = "",
): Promise<Array<{ name: string; definition: CommandDefinition }>> {
  try {
    await fsPromises.access(commandsDir)
  } catch {
    return []
  }

  let realPath: string
  try {
    realPath = await fsPromises.realpath(commandsDir)
  } catch {
    return []
  }

  if (visited.has(realPath)) return []
  visited.add(realPath)

  let entries: Dirent[]
  try {
    entries = await fsPromises.readdir(commandsDir, { withFileTypes: true })
  } catch {
    return []
  }

  const commands: Array<{ name: string; definition: CommandDefinition }> = []

  for (const entry of entries) {
    if (entry.isDirectory()) {
      if (entry.name.startsWith(".")) continue
      const subPrefix = prefix ? `${prefix}:${entry.name}` : entry.name
      const sub = await loadCommandsFromDir(join(commandsDir, entry.name), scope, visited, subPrefix)
      commands.push(...sub)
      continue
    }

    if (!isMarkdownFile(entry)) continue

    const commandPath = join(commandsDir, entry.name)
    const baseCommandName = basename(entry.name, ".md")
    const commandName = prefix ? `${prefix}:${baseCommandName}` : baseCommandName

    try {
      const content = await fsPromises.readFile(commandPath, "utf-8")
      const { data, body } = parseFrontmatter<CommandFrontmatter>(content)

      commands.push({
        name: commandName,
        definition: {
          description: `(${scope}) ${data.description || ""}`,
          template: `<command-instruction>\n${body.trim()}\n</command-instruction>\n\n<user-request>\n$ARGUMENTS\n</user-request>`,
          agent: data.agent,
          subtask: data.subtask,
        },
      })
    } catch (error) {
      log(`Failed to parse command: ${commandPath}`, error)
    }
  }

  return commands
}

async function loadAllCommands(directory: string): Promise<Record<string, CommandDefinition>> {
  const claudeDir = getClaudeConfigDir()

  const [user, project] = await Promise.all([
    loadCommandsFromDir(join(claudeDir, "commands"), "user"),
    loadCommandsFromDir(join(directory, ".claude", "commands"), "project"),
  ])

  const result: Record<string, CommandDefinition> = {}
  for (const cmd of user) result[cmd.name] = cmd.definition
  for (const cmd of project) result[cmd.name] = cmd.definition
  return result
}

// ═══════════════════════════════════════════════════════════════════════════════
// Agents (from .claude/agents/)
// ═══════════════════════════════════════════════════════════════════════════════

interface AgentFrontmatter {
  name?: string
  description?: string
  tools?: string
}

type AgentScope = "user" | "project"

function parseToolsConfig(toolsStr?: string): Record<string, boolean> | undefined {
  if (!toolsStr) return undefined
  const tools = toolsStr.split(",").map((t) => t.trim()).filter(Boolean)
  if (tools.length === 0) return undefined
  const result: Record<string, boolean> = {}
  for (const tool of tools) result[tool.toLowerCase()] = true
  return result
}

function loadAgentsFromDir(agentsDir: string, scope: AgentScope): Array<{ name: string; config: AgentConfig }> {
  if (!existsSync(agentsDir)) return []

  const entries = readdirSync(agentsDir, { withFileTypes: true })
  const agents: Array<{ name: string; config: AgentConfig }> = []

  for (const entry of entries) {
    if (!isMarkdownFile(entry)) continue

    const agentPath = join(agentsDir, entry.name)
    const agentName = basename(entry.name, ".md")

    try {
      const content = readFileSync(agentPath, "utf-8")
      const { data, body } = parseFrontmatter<AgentFrontmatter>(content)

      const config: AgentConfig = {
        description: `(${scope}) ${data.description || ""}`,
        mode: "subagent",
        prompt: body.trim(),
      }

      const toolsConfig = parseToolsConfig(data.tools)
      if (toolsConfig) config.tools = toolsConfig

      agents.push({ name: data.name || agentName, config })
    } catch {
      continue
    }
  }

  return agents
}

function loadAllAgents(directory: string): Record<string, AgentConfig> {
  const claudeDir = getClaudeConfigDir()

  const user = loadAgentsFromDir(join(claudeDir, "agents"), "user")
  const project = loadAgentsFromDir(join(directory, ".claude", "agents"), "project")

  const result: Record<string, AgentConfig> = {}
  for (const agent of user) result[agent.name] = agent.config
  for (const agent of project) result[agent.name] = agent.config
  return result
}

// ═══════════════════════════════════════════════════════════════════════════════
// MCP servers (from .mcp.json files)
// ═══════════════════════════════════════════════════════════════════════════════

interface ClaudeCodeMcpServer {
  type?: "http" | "sse" | "stdio"
  url?: string
  command?: string
  args?: string[]
  env?: Record<string, string>
  headers?: Record<string, string>
  disabled?: boolean
}

interface McpLocalConfig {
  type: "local"
  command: string[]
  environment?: Record<string, string>
  enabled?: boolean
}

interface McpRemoteConfig {
  type: "remote"
  url: string
  headers?: Record<string, string>
  enabled?: boolean
}

type McpServerConfig = McpLocalConfig | McpRemoteConfig

function transformMcpServer(name: string, server: ClaudeCodeMcpServer): McpServerConfig {
  const expanded = expandEnvVarsInObject(server)
  const serverType = expanded.type ?? "stdio"

  if (serverType === "http" || serverType === "sse") {
    if (!expanded.url) throw new Error(`MCP server "${name}" requires url for type "${serverType}"`)
    const config: McpRemoteConfig = { type: "remote", url: expanded.url, enabled: true }
    if (expanded.headers && Object.keys(expanded.headers).length > 0) config.headers = expanded.headers
    return config
  }

  if (!expanded.command) throw new Error(`MCP server "${name}" requires command for stdio type`)

  const config: McpLocalConfig = {
    type: "local",
    command: [expanded.command, ...(expanded.args ?? [])],
    enabled: true,
  }
  if (expanded.env && Object.keys(expanded.env).length > 0) config.environment = expanded.env
  return config
}

function loadAllMcpConfigs(directory: string): Record<string, McpServerConfig> {
  const claudeConfigDir = getClaudeConfigDir()
  const paths = [
    { path: join(homedir(), ".claude.json"), scope: "user" },
    { path: join(claudeConfigDir, ".mcp.json"), scope: "user" },
    { path: join(directory, ".mcp.json"), scope: "project" },
    { path: join(directory, ".claude", ".mcp.json"), scope: "local" },
  ]

  const servers: Record<string, McpServerConfig> = {}

  for (const { path, scope } of paths) {
    if (!existsSync(path)) continue
    let config: { mcpServers?: Record<string, ClaudeCodeMcpServer> } | null = null
    try {
      config = JSON.parse(readFileSync(path, "utf-8"))
    } catch (error) {
      log(`Failed to load MCP config from ${path}`, error)
      continue
    }
    if (!config?.mcpServers) continue

    for (const [name, serverConfig] of Object.entries(config.mcpServers)) {
      if (serverConfig.disabled) {
        delete servers[name]
        log(`Disabling MCP server "${name}"`, { path })
        continue
      }
      try {
        servers[name] = transformMcpServer(name, serverConfig)
        log(`Loaded MCP server "${name}" from ${scope}`, { path })
      } catch (error) {
        log(`Failed to transform MCP server "${name}"`, error)
      }
    }
  }

  return servers
}

// ═══════════════════════════════════════════════════════════════════════════════
// Marketplace plugins (from ~/.claude/plugins/installed_plugins.json)
// ═══════════════════════════════════════════════════════════════════════════════

interface PluginInstallation {
  scope: string
  installPath: string
  version: string
}

interface InstalledPluginsDB {
  version: number
  plugins: Record<string, PluginInstallation | PluginInstallation[]>
}

interface PluginManifest {
  name?: string
  version?: string
}

interface LoadedPlugin {
  name: string
  pluginKey: string
  installPath: string
  commandsDir?: string
  agentsDir?: string
  skillsDir?: string
  hooksPath?: string
  mcpPath?: string
}

interface SkillFrontmatter {
  name?: string
  description?: string
  model?: string
}

interface MarketplacePluginResult {
  commands: Record<string, CommandDefinition>
  agents: Record<string, AgentConfig>
  mcpServers: Record<string, McpServerConfig>
  hooksConfigs: PluginHooksConfig[]
}

// ── Path resolution ──

function resolvePluginPaths<T>(obj: T, pluginRoot: string): T {
  if (obj === null || obj === undefined) return obj
  if (typeof obj === "string") return obj.replaceAll("${CLAUDE_PLUGIN_ROOT}", pluginRoot) as T
  if (Array.isArray(obj)) return obj.map((item) => resolvePluginPaths(item, pluginRoot)) as T
  if (typeof obj === "object") {
    const result: Record<string, unknown> = {}
    for (const [key, value] of Object.entries(obj)) {
      result[key] = resolvePluginPaths(value, pluginRoot)
    }
    return result as T
  }
  return obj
}

function resolveSkillPathReferences(content: string, basePath: string): string {
  const normalizedBase = basePath.endsWith("/") ? basePath.slice(0, -1) : basePath
  return content.replace(
    /(?<![a-zA-Z0-9])@([a-zA-Z0-9_-]+\/[a-zA-Z0-9_.\-/]*)/g,
    (_, relativePath: string) => join(normalizedBase, relativePath),
  )
}

// ── Discovery ──

function discoverPlugins(): LoadedPlugin[] {
  const claudeDir = getClaudeConfigDir()
  const dbPath = join(claudeDir, "plugins", "installed_plugins.json")
  if (!existsSync(dbPath)) return []

  let db: InstalledPluginsDB
  try {
    db = JSON.parse(readFileSync(dbPath, "utf-8")) as InstalledPluginsDB
  } catch {
    log("Failed to parse installed_plugins.json")
    return []
  }

  if (!db.plugins) return []

  // Load settings for enabledPlugins
  const settingsPath = join(claudeDir, "settings.json")
  let enabledPlugins: Record<string, boolean> | undefined
  try {
    if (existsSync(settingsPath)) {
      const settings = JSON.parse(readFileSync(settingsPath, "utf-8")) as { enabledPlugins?: Record<string, boolean> }
      enabledPlugins = settings.enabledPlugins
    }
  } catch {
    log("Failed to parse settings.json for enabledPlugins")
  }

  const plugins: LoadedPlugin[] = []

  for (const [pluginKey, value] of Object.entries(db.plugins)) {
    if (enabledPlugins && pluginKey in enabledPlugins && !enabledPlugins[pluginKey]) {
      log(`Plugin disabled: ${pluginKey}`)
      continue
    }

    const installation = Array.isArray(value) ? value[0] : value
    if (!installation) continue

    const { installPath } = installation
    if (!existsSync(installPath)) {
      log(`Plugin install path missing: ${installPath}`)
      continue
    }

    let name = pluginKey.indexOf("@") > 0 ? pluginKey.substring(0, pluginKey.indexOf("@")) : pluginKey
    const manifestPath = join(installPath, ".claude-plugin", "plugin.json")
    if (existsSync(manifestPath)) {
      try {
        const manifest = JSON.parse(readFileSync(manifestPath, "utf-8")) as PluginManifest
        if (manifest.name) name = manifest.name
      } catch { /* use derived name */ }
    }

    const plugin: LoadedPlugin = { name, pluginKey, installPath }

    if (existsSync(join(installPath, "commands"))) plugin.commandsDir = join(installPath, "commands")
    if (existsSync(join(installPath, "agents"))) plugin.agentsDir = join(installPath, "agents")
    if (existsSync(join(installPath, "skills"))) plugin.skillsDir = join(installPath, "skills")

    const hooksPath = join(installPath, "hooks", "hooks.json")
    if (existsSync(hooksPath)) plugin.hooksPath = hooksPath

    const mcpPath = join(installPath, ".mcp.json")
    if (existsSync(mcpPath)) plugin.mcpPath = mcpPath

    plugins.push(plugin)
    log(`Discovered plugin: ${name} (${pluginKey})`)
  }

  return plugins
}

// ── Plugin command loading ──

function loadPluginCommands(plugins: LoadedPlugin[]): Record<string, CommandDefinition> {
  const commands: Record<string, CommandDefinition> = {}

  for (const plugin of plugins) {
    if (!plugin.commandsDir) continue

    const entries = readdirSync(plugin.commandsDir, { withFileTypes: true })
    for (const entry of entries) {
      if (!isMarkdownFile(entry)) continue

      const commandPath = join(plugin.commandsDir, entry.name)
      const namespacedName = `${plugin.name}:${basename(entry.name, ".md")}`

      try {
        const content = readFileSync(commandPath, "utf-8")
        const { data, body } = parseFrontmatter<CommandFrontmatter>(content)

        commands[namespacedName] = {
          description: `(plugin: ${plugin.name}) ${data.description || ""}`,
          template: `<command-instruction>\n${body.trim()}\n</command-instruction>\n\n<user-request>\n$ARGUMENTS\n</user-request>`,
          agent: data.agent,
          subtask: data.subtask,
        }
        log(`Loaded plugin command: ${namespacedName}`)
      } catch (error) {
        log(`Failed to load plugin command: ${commandPath}`, error)
      }
    }
  }

  return commands
}

// ── Plugin skill loading (skills become commands) ──

function loadPluginSkills(plugins: LoadedPlugin[]): Record<string, CommandDefinition> {
  const skills: Record<string, CommandDefinition> = {}

  for (const plugin of plugins) {
    if (!plugin.skillsDir) continue

    const entries = readdirSync(plugin.skillsDir, { withFileTypes: true })
    for (const entry of entries) {
      if (entry.name.startsWith(".")) continue

      const skillPath = join(plugin.skillsDir, entry.name)
      if (!entry.isDirectory() && !entry.isSymbolicLink()) continue

      let resolvedPath = skillPath
      try { resolvedPath = realpathSync(skillPath) } catch { /* use original */ }

      const skillMdPath = join(resolvedPath, "SKILL.md")
      if (!existsSync(skillMdPath)) continue

      try {
        const content = readFileSync(skillMdPath, "utf-8")
        const { data, body } = parseFrontmatter<SkillFrontmatter>(content)

        const skillName = data.name || entry.name
        const namespacedName = `${plugin.name}:${skillName}`
        const resolvedBody = resolveSkillPathReferences(body.trim(), resolvedPath)

        skills[namespacedName] = {
          description: `(plugin: ${plugin.name} - Skill) ${data.description || ""}`,
          template: `<skill-instruction>\nBase directory for this skill: ${resolvedPath}/\nFile references (@path) in this skill are relative to this directory.\n\n${resolvedBody}\n</skill-instruction>\n\n<user-request>\n$ARGUMENTS\n</user-request>`,
        }
        log(`Loaded plugin skill: ${namespacedName}`)
      } catch (error) {
        log(`Failed to load plugin skill: ${skillPath}`, error)
      }
    }
  }

  return skills
}

// ── Plugin agent loading ──

function loadPluginAgents(plugins: LoadedPlugin[]): Record<string, AgentConfig> {
  const agents: Record<string, AgentConfig> = {}

  for (const plugin of plugins) {
    if (!plugin.agentsDir) continue

    const entries = readdirSync(plugin.agentsDir, { withFileTypes: true })
    for (const entry of entries) {
      if (!isMarkdownFile(entry)) continue

      const agentPath = join(plugin.agentsDir, entry.name)
      const namespacedName = `${plugin.name}:${basename(entry.name, ".md")}`

      try {
        const content = readFileSync(agentPath, "utf-8")
        const { data, body } = parseFrontmatter<AgentFrontmatter>(content)

        const config: AgentConfig = {
          description: `(plugin: ${plugin.name}) ${data.description || ""}`,
          mode: "subagent",
          prompt: body.trim(),
        }

        const toolsConfig = parseToolsConfig(data.tools)
        if (toolsConfig) config.tools = toolsConfig

        agents[namespacedName] = config
        log(`Loaded plugin agent: ${namespacedName}`)
      } catch (error) {
        log(`Failed to load plugin agent: ${agentPath}`, error)
      }
    }
  }

  return agents
}

// ── Plugin hook loading ──

function loadPluginHooks(plugins: LoadedPlugin[]): PluginHooksConfig[] {
  const configs: PluginHooksConfig[] = []

  for (const plugin of plugins) {
    if (!plugin.hooksPath) continue

    try {
      const content = readFileSync(plugin.hooksPath, "utf-8")
      const raw = JSON.parse(content) as { hooks?: PluginHooksConfig }
      if (!raw.hooks) continue

      const resolved = resolvePluginPaths(raw.hooks, plugin.installPath)
      configs.push(resolved)
      log(`Loaded plugin hooks from ${plugin.name}`)
    } catch (error) {
      log(`Failed to load plugin hooks: ${plugin.hooksPath}`, error)
    }
  }

  return configs
}

// ── Plugin MCP loading ──

function loadPluginMcps(plugins: LoadedPlugin[]): Record<string, McpServerConfig> {
  const servers: Record<string, McpServerConfig> = {}

  for (const plugin of plugins) {
    if (!plugin.mcpPath) continue

    try {
      const content = readFileSync(plugin.mcpPath, "utf-8")
      let config = JSON.parse(content) as { mcpServers?: Record<string, ClaudeCodeMcpServer> }

      config = resolvePluginPaths(config, plugin.installPath)
      config = expandEnvVarsInObject(config)

      if (!config.mcpServers) continue

      for (const [name, serverConfig] of Object.entries(config.mcpServers)) {
        if (serverConfig.disabled) continue

        const namespacedName = `${plugin.name}:${name}`
        const serverType = serverConfig.type ?? "stdio"

        if (serverType === "http" || serverType === "sse") {
          if (!serverConfig.url) continue
          const remote: McpRemoteConfig = { type: "remote", url: serverConfig.url, enabled: true }
          if (serverConfig.headers && Object.keys(serverConfig.headers).length > 0) remote.headers = serverConfig.headers
          servers[namespacedName] = remote
        } else {
          if (!serverConfig.command) continue
          const local: McpLocalConfig = {
            type: "local",
            command: [serverConfig.command, ...(serverConfig.args ?? [])],
            enabled: true,
          }
          if (serverConfig.env && Object.keys(serverConfig.env).length > 0) local.environment = serverConfig.env
          servers[namespacedName] = local
        }
        log(`Loaded plugin MCP server: ${namespacedName}`)
      }
    } catch (error) {
      log(`Failed to load plugin MCP: ${plugin.mcpPath}`, error)
    }
  }

  return servers
}

// ── Marketplace main entry ──

function loadAllMarketplacePlugins(): MarketplacePluginResult {
  const plugins = discoverPlugins()

  if (plugins.length === 0) {
    return { commands: {}, agents: {}, mcpServers: {}, hooksConfigs: [] }
  }

  const commands = loadPluginCommands(plugins)
  const skills = loadPluginSkills(plugins)
  const agents = loadPluginAgents(plugins)
  const hooksConfigs = loadPluginHooks(plugins)
  const mcpServers = loadPluginMcps(plugins)

  const allCommands = { ...commands, ...skills }

  log(`Marketplace plugins: ${Object.keys(allCommands).length} commands/skills, ${Object.keys(agents).length} agents, ${Object.keys(mcpServers).length} MCPs, ${hooksConfigs.length} hook configs`)

  return { commands: allCommands, agents, mcpServers, hooksConfigs }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Plugin export
// ═══════════════════════════════════════════════════════════════════════════════

export const ClaudeCodeCompat: Plugin = async (ctx) => {
  log("Plugin loading", { directory: ctx.directory })

  const [commands, agents, mcpServers, marketplace] = await Promise.all([
    loadAllCommands(ctx.directory),
    Promise.resolve(loadAllAgents(ctx.directory)),
    Promise.resolve(loadAllMcpConfigs(ctx.directory)),
    Promise.resolve(loadAllMarketplacePlugins()),
  ])

  const allCommands: Record<string, CommandDefinition> = { ...marketplace.commands, ...commands }
  const allAgents = { ...marketplace.agents, ...agents }
  const allMcpServers = { ...marketplace.mcpServers, ...mcpServers }

  const commandCount = Object.keys(allCommands).length
  const agentCount = Object.keys(allAgents).length
  const mcpCount = Object.keys(allMcpServers).length

  log(`Loaded: ${commandCount} commands, ${agentCount} agents, ${mcpCount} MCP servers`)

  const sessionErrorState = new Map<string, boolean>()
  const sessionInterruptState = new Map<string, boolean>()

  return {
    config: async (config) => {
      if (commandCount > 0) {
        config.command = { ...config.command, ...allCommands }
        log(`Injected ${commandCount} commands/skills`)
      }
      if (agentCount > 0) {
        config.agent = { ...config.agent, ...allAgents }
        log(`Injected ${agentCount} agents`)
      }
      if (mcpCount > 0) {
        config.mcp = { ...config.mcp, ...allMcpServers }
        log(`Injected ${mcpCount} MCP servers`)
      }
    },

    "chat.message": async (input, output) => {
      const prompt = output.parts
        .filter((p): p is typeof p & { text: string } => p.type === "text" && "text" in p && !!p.text)
        .map((p) => p.text)
        .join("\n")

      recordUserMessage(input.sessionID, prompt)

      const hooksConfig = loadClaudeHooksConfig(ctx.directory)
      const merged = mergePluginHooksIntoConfig(hooksConfig, marketplace.hooksConfigs)
      const result = await executeUserPromptSubmitHooks(merged, input.sessionID, prompt, ctx.directory)

      if (result.block) {
        throw new Error(result.reason ?? "Hook blocked the prompt")
      }

      if (result.messages.length > 0) {
        ;(output.parts as Array<Record<string, unknown>>).push({ type: "text", text: result.messages.join("\n\n") })
      }
    },

    "tool.execute.before": async (input, output) => {
      // Fix todowrite string args (common LLM error)
      if (input.tool.trim() === "todowrite" && typeof output.args.todos === "string") {
        try {
          const parsed = JSON.parse(output.args.todos)
          if (Array.isArray(parsed)) output.args.todos = parsed
        } catch {
          throw new Error(`[todowrite ERROR] Failed to parse todos string as JSON. Pass todos as an array, not a string.`)
        }
      }

      recordToolUse(input.sessionID, input.tool, output.args)
      cacheToolInput(input.sessionID, input.tool, input.callID, output.args)

      const hooksConfig = loadClaudeHooksConfig(ctx.directory)
      const merged = mergePluginHooksIntoConfig(hooksConfig, marketplace.hooksConfigs)
      const result = await executePreToolUseHooks(merged, input.sessionID, input.tool, output.args, ctx.directory, input.callID)

      if (result.decision === "deny") {
        throw new Error(result.reason ?? "Hook blocked the operation")
      }
      if (result.modifiedInput) {
        Object.assign(output.args, result.modifiedInput)
      }
    },

    "tool.execute.after": async (input, output) => {
      if (!output) return

      const cachedInput = getToolInput(input.sessionID, input.tool, input.callID) || {}
      const metadata = output.metadata as Record<string, unknown> | undefined
      const hasMetadata = metadata && typeof metadata === "object" && Object.keys(metadata).length > 0
      const toolOutput = hasMetadata ? metadata : { output: output.output }

      recordToolResult(input.sessionID, input.tool, cachedInput, toolOutput)

      const hooksConfig = loadClaudeHooksConfig(ctx.directory)
      const merged = mergePluginHooksIntoConfig(hooksConfig, marketplace.hooksConfigs)
      const result = await executePostToolUseHooks(
        merged, input.sessionID, input.tool, cachedInput,
        { title: input.tool, output: output.output, metadata: output.metadata as Record<string, unknown> },
        ctx.directory, input.callID,
      )

      if (result.warnings && result.warnings.length > 0) {
        output.output = `${output.output}\n\n${result.warnings.join("\n")}`
      }
      if (result.message) {
        output.output = `${output.output}\n\n${result.message}`
      }
    },

    event: async ({ event }) => {
      if (event.type === "session.error") {
        const sessionID = event.properties?.sessionID as string | undefined
        if (sessionID) sessionErrorState.set(sessionID, true)
        return
      }

      if (event.type === "session.deleted") {
        const info = event.properties?.info as { id?: string } | undefined
        if (info?.id) {
          sessionErrorState.delete(info.id)
          sessionInterruptState.delete(info.id)
        }
        return
      }

      if (event.type === "todo.updated") {
        const sessionID = event.properties?.sessionID as string | undefined
        const todos = event.properties?.todos as OpenCodeTodo[] | undefined
        if (sessionID && todos) {
          try { saveOpenCodeTodos(sessionID, todos) } catch (err) { log("Failed to save todos", err) }
        }
        return
      }

      if (event.type === "session.idle") {
        const sessionID = event.properties?.sessionID as string | undefined
        if (!sessionID) return

        if (sessionErrorState.get(sessionID) || sessionInterruptState.get(sessionID)) {
          sessionErrorState.delete(sessionID)
          sessionInterruptState.delete(sessionID)
          return
        }

        const hooksConfig = loadClaudeHooksConfig(ctx.directory)
        const merged = mergePluginHooksIntoConfig(hooksConfig, marketplace.hooksConfigs)

        const stopResult = await executeStopHooks(merged, sessionID, ctx.directory, getTodoPath(sessionID))

        if (stopResult.block && stopResult.injectPrompt) {
          log("Stop hook returned block with inject_prompt", { sessionID })
          ctx.client.session
            .prompt({
              path: { id: sessionID },
              body: { parts: [{ type: "text", text: stopResult.injectPrompt }] },
              query: { directory: ctx.directory },
            })
            .catch((err: unknown) => log("Failed to inject prompt from Stop hook", String(err)))
        }

        sessionErrorState.delete(sessionID)
        sessionInterruptState.delete(sessionID)
      }
    },
  }
}
