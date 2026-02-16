import type { Plugin, PluginInput, Hooks, ToolDefinition } from "@opencode-ai/plugin"
import { tool } from "@opencode-ai/plugin"

// ═══════════════════════════════════════════════════════════════════════════════
// Logging
// ═══════════════════════════════════════════════════════════════════════════════

function log(message: string, extra?: unknown): void {
  if (process.env.DEBUG || process.env.OPENCODE_DEBUG) {
    console.error(`[background-tasks] ${message}`, extra ?? "")
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Types
// ═══════════════════════════════════════════════════════════════════════════════

type BackgroundTaskStatus =
  | "pending"
  | "running"
  | "completed"
  | "error"
  | "cancelled"
  | "interrupt"

interface TaskProgress {
  toolCalls: number
  lastTool?: string
  lastUpdate: Date
  lastMessage?: string
  lastMessageAt?: Date
}

interface BackgroundTask {
  id: string
  sessionID?: string
  parentSessionID: string
  parentMessageID: string
  description: string
  prompt: string
  agent: string
  status: BackgroundTaskStatus
  queuedAt?: Date
  startedAt?: Date
  completedAt?: Date
  result?: string
  error?: string
  progress?: TaskProgress
  concurrencyKey?: string
  concurrencyGroup?: string
  parentAgent?: string
  lastMsgCount?: number
  stablePolls?: number
}

interface LaunchInput {
  description: string
  prompt: string
  agent: string
  parentSessionID: string
  parentMessageID: string
  parentAgent?: string
}

interface ResumeInput {
  sessionId: string
  prompt: string
  parentSessionID: string
  parentMessageID: string
  parentAgent?: string
}

interface QueueItem {
  task: BackgroundTask
  input: LaunchInput
}

type OpencodeClient = PluginInput["client"]

// ═══════════════════════════════════════════════════════════════════════════════
// Constants
// ═══════════════════════════════════════════════════════════════════════════════

const TASK_TTL_MS = 30 * 60 * 1000
const MIN_STABILITY_TIME_MS = 10 * 1000
const DEFAULT_STALE_TIMEOUT_MS = 180_000
const MIN_RUNTIME_BEFORE_STALE_MS = 30_000
const MIN_IDLE_TIME_MS = 5000
const POLLING_INTERVAL_MS = 3000
const TASK_CLEANUP_DELAY_MS = 10 * 60 * 1000
const DEFAULT_CONCURRENCY = 5

// ═══════════════════════════════════════════════════════════════════════════════
// Config
// ═══════════════════════════════════════════════════════════════════════════════

interface BackgroundTaskConfig {
  defaultConcurrency?: number
  providerConcurrency?: Record<string, number>
  modelConcurrency?: Record<string, number>
  staleTimeoutMs?: number
}

// ═══════════════════════════════════════════════════════════════════════════════
// ConcurrencyManager
// ═══════════════════════════════════════════════════════════════════════════════

interface ConcurrencyQueueEntry {
  resolve: () => void
  rawReject: (error: Error) => void
  settled: boolean
}

class ConcurrencyManager {
  private config: BackgroundTaskConfig
  private counts: Map<string, number> = new Map()
  private queues: Map<string, ConcurrencyQueueEntry[]> = new Map()

  constructor(config: BackgroundTaskConfig) {
    this.config = config
  }

  getConcurrencyLimit(key: string): number {
    const modelLimit = this.config.modelConcurrency?.[key]
    if (modelLimit !== undefined) return modelLimit === 0 ? Infinity : modelLimit

    const provider = key.split("/")[0]
    const providerLimit = this.config.providerConcurrency?.[provider]
    if (providerLimit !== undefined) return providerLimit === 0 ? Infinity : providerLimit

    const defaultLimit = this.config.defaultConcurrency
    if (defaultLimit !== undefined) return defaultLimit === 0 ? Infinity : defaultLimit

    return DEFAULT_CONCURRENCY
  }

  async acquire(key: string): Promise<void> {
    const limit = this.getConcurrencyLimit(key)
    if (limit === Infinity) return

    const current = this.counts.get(key) ?? 0
    if (current < limit) {
      this.counts.set(key, current + 1)
      return
    }

    return new Promise<void>((resolve, reject) => {
      const queue = this.queues.get(key) ?? []
      const entry: ConcurrencyQueueEntry = {
        resolve: () => {
          if (entry.settled) return
          entry.settled = true
          resolve()
        },
        rawReject: reject,
        settled: false,
      }
      queue.push(entry)
      this.queues.set(key, queue)
    })
  }

  release(key: string): void {
    const limit = this.getConcurrencyLimit(key)
    if (limit === Infinity) return

    const queue = this.queues.get(key)
    while (queue && queue.length > 0) {
      const next = queue.shift()!
      if (!next.settled) {
        next.resolve()
        return
      }
    }

    const current = this.counts.get(key) ?? 0
    if (current > 0) this.counts.set(key, current - 1)
  }

  cancelWaiters(key: string): void {
    const queue = this.queues.get(key)
    if (!queue) return
    for (const entry of queue) {
      if (!entry.settled) {
        entry.settled = true
        entry.rawReject(new Error(`Concurrency queue cancelled for: ${key}`))
      }
    }
    this.queues.delete(key)
  }

  clear(): void {
    for (const [key] of this.queues) this.cancelWaiters(key)
    this.counts.clear()
    this.queues.clear()
  }

  getCount(key: string): number {
    return this.counts.get(key) ?? 0
  }

  getQueueLength(key: string): number {
    return this.queues.get(key)?.length ?? 0
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TaskHistory
// ═══════════════════════════════════════════════════════════════════════════════

const MAX_HISTORY_ENTRIES = 100

interface TaskHistoryEntry {
  id: string
  sessionID?: string
  agent: string
  description: string
  status: BackgroundTaskStatus
  startedAt?: Date
  completedAt?: Date
}

class TaskHistory {
  private entries: Map<string, TaskHistoryEntry[]> = new Map()

  record(parentSessionID: string | undefined, entry: TaskHistoryEntry): void {
    if (!parentSessionID) return
    const list = this.entries.get(parentSessionID) ?? []
    const existing = list.findIndex((e) => e.id === entry.id)

    if (existing !== -1) {
      list[existing] = { ...list[existing], ...entry }
    } else {
      if (list.length >= MAX_HISTORY_ENTRIES) list.shift()
      list.push({ ...entry })
    }
    this.entries.set(parentSessionID, list)
  }

  getByParentSession(parentSessionID: string): TaskHistoryEntry[] {
    return (this.entries.get(parentSessionID) ?? []).map((e) => ({ ...e }))
  }

  clearSession(parentSessionID: string): void {
    this.entries.delete(parentSessionID)
  }

  formatForCompaction(parentSessionID: string): string | null {
    const list = this.getByParentSession(parentSessionID)
    if (list.length === 0) return null
    return list
      .map(
        (e) =>
          `- **${e.agent}** (${e.status}): ${e.description.replace(/[\n\r]+/g, " ").trim()}`,
      )
      .join("\n")
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TaskToastManager
// ═══════════════════════════════════════════════════════════════════════════════

type TaskToastStatus = "running" | "queued" | "completed" | "error"

interface TrackedTask {
  id: string
  description: string
  agent: string
  status: TaskToastStatus
  startedAt: Date
  isBackground: boolean
}

class TaskToastManager {
  private tasks: Map<string, TrackedTask> = new Map()
  private client: OpencodeClient

  constructor(client: OpencodeClient) {
    this.client = client
  }

  addTask(task: {
    id: string
    description: string
    agent: string
    isBackground: boolean
    status?: TaskToastStatus
  }): void {
    const tracked: TrackedTask = {
      id: task.id,
      description: task.description,
      agent: task.agent,
      status: task.status ?? "running",
      startedAt: new Date(),
      isBackground: task.isBackground,
    }
    this.tasks.set(task.id, tracked)
    this.showTaskListToast(tracked)
  }

  updateTask(id: string, status: TaskToastStatus): void {
    const task = this.tasks.get(id)
    if (task) task.status = status
  }

  removeTask(id: string): void {
    this.tasks.delete(id)
  }

  showCompletionToast(task: {
    id: string
    description: string
    duration: string
  }): void {
    this.removeTask(task.id)
    const remaining = this.getRunningTasks()
    let message = `"${task.description}" finished in ${task.duration}`
    if (remaining.length > 0)
      message += `\n\nStill running: ${remaining.length}`
    this.toast("Task Completed", message, "success", 5000)
  }

  private getRunningTasks(): TrackedTask[] {
    return Array.from(this.tasks.values())
      .filter((t) => t.status === "running")
      .sort((a, b) => b.startedAt.getTime() - a.startedAt.getTime())
  }

  private getQueuedTasks(): TrackedTask[] {
    return Array.from(this.tasks.values())
      .filter((t) => t.status === "queued")
      .sort((a, b) => a.startedAt.getTime() - b.startedAt.getTime())
  }

  private formatDuration(startedAt: Date): string {
    const seconds = Math.floor((Date.now() - startedAt.getTime()) / 1000)
    if (seconds < 60) return `${seconds}s`
    const minutes = Math.floor(seconds / 60)
    if (minutes < 60) return `${minutes}m ${seconds % 60}s`
    const hours = Math.floor(minutes / 60)
    return `${hours}h ${minutes % 60}m`
  }

  private showTaskListToast(newTask: TrackedTask): void {
    const running = this.getRunningTasks()
    const queued = this.getQueuedTasks()
    const lines: string[] = []
    if (running.length > 0) {
      lines.push(`Running (${running.length}):`)
      for (const t of running) {
        const dur = this.formatDuration(t.startedAt)
        const isNew = t.id === newTask.id ? " <- NEW" : ""
        lines.push(`[BG] ${t.description} (${t.agent}) - ${dur}${isNew}`)
      }
    }
    if (queued.length > 0) {
      if (lines.length > 0) lines.push("")
      lines.push(`Queued (${queued.length}):`)
      for (const t of queued) {
        const isNew = t.id === newTask.id ? " <- NEW" : ""
        lines.push(`[Q] ${t.description} (${t.agent}) - Queued${isNew}`)
      }
    }
    this.toast(
      "New Background Task",
      lines.join("\n") || `${newTask.description} (${newTask.agent})`,
      "info",
      running.length + queued.length > 2 ? 5000 : 3000,
    )
  }

  private toast(
    title: string,
    message: string,
    variant: string,
    duration: number,
  ): void {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const tuiClient = this.client as any
    if (!tuiClient.tui?.showToast) return
    tuiClient.tui
      .showToast({ body: { title, message, variant, duration } })
      .catch(() => {})
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BackgroundManager
// ═══════════════════════════════════════════════════════════════════════════════

interface EventProperties {
  sessionID?: string
  info?: { id?: string }
  [key: string]: unknown
}

interface ManagerEvent {
  type: string
  properties?: EventProperties
}

interface Todo {
  content: string
  status: string
  priority: string
  id: string
}

class BackgroundManager {
  private tasks: Map<string, BackgroundTask> = new Map()
  private notifications: Map<string, BackgroundTask[]> = new Map()
  private pendingByParent: Map<string, Set<string>> = new Map()
  private queuesByKey: Map<string, QueueItem[]> = new Map()
  private processingKeys: Set<string> = new Set()
  private completionTimers: Map<string, ReturnType<typeof setTimeout>> =
    new Map()
  private idleDeferralTimers: Map<string, ReturnType<typeof setTimeout>> =
    new Map()
  private notificationQueueByParent: Map<string, Promise<void>> = new Map()
  private pollingInterval?: ReturnType<typeof setInterval>
  private shutdownTriggered = false

  private client: OpencodeClient
  private directory: string
  private config: BackgroundTaskConfig
  private concurrencyManager: ConcurrencyManager
  readonly taskHistory = new TaskHistory()
  private toastManager: TaskToastManager

  constructor(
    client: OpencodeClient,
    directory: string,
    config: BackgroundTaskConfig,
  ) {
    this.client = client
    this.directory = directory
    this.config = config
    this.concurrencyManager = new ConcurrencyManager(config)
    this.toastManager = new TaskToastManager(client)
  }

  // ─── Launch ──────────────────────────────────────────────────────────────

  async launch(input: LaunchInput): Promise<BackgroundTask> {
    log("launch() called", {
      agent: input.agent,
      description: input.description,
      parentSessionID: input.parentSessionID,
    })

    if (!input.agent || input.agent.trim() === "") {
      throw new Error("Agent parameter is required")
    }

    const task: BackgroundTask = {
      id: `bg_${crypto.randomUUID().slice(0, 8)}`,
      status: "pending",
      queuedAt: new Date(),
      description: input.description,
      prompt: input.prompt,
      agent: input.agent,
      parentSessionID: input.parentSessionID,
      parentMessageID: input.parentMessageID,
      parentAgent: input.parentAgent,
    }

    this.tasks.set(task.id, task)
    this.taskHistory.record(input.parentSessionID, {
      id: task.id,
      agent: input.agent,
      description: input.description,
      status: "pending",
    })

    if (input.parentSessionID) {
      const pending =
        this.pendingByParent.get(input.parentSessionID) ?? new Set()
      pending.add(task.id)
      this.pendingByParent.set(input.parentSessionID, pending)
    }

    const key = input.agent
    const queue = this.queuesByKey.get(key) ?? []
    queue.push({ task, input })
    this.queuesByKey.set(key, queue)

    log("Task queued", { taskId: task.id, key, queueLength: queue.length })

    this.toastManager.addTask({
      id: task.id,
      description: input.description,
      agent: input.agent,
      isBackground: true,
      status: "queued",
    })

    this.processKey(key)
    return task
  }

  private async processKey(key: string): Promise<void> {
    if (this.processingKeys.has(key)) return
    this.processingKeys.add(key)

    try {
      const queue = this.queuesByKey.get(key)
      while (queue && queue.length > 0) {
        const item = queue[0]

        await this.concurrencyManager.acquire(key)

        if (
          item.task.status === "cancelled" ||
          item.task.status === "error"
        ) {
          this.concurrencyManager.release(key)
          queue.shift()
          continue
        }

        try {
          await this.startTask(item)
        } catch (error) {
          log("Error starting task", error)
          if (!item.task.concurrencyKey) {
            this.concurrencyManager.release(key)
          }
        }

        queue.shift()
      }
    } finally {
      this.processingKeys.delete(key)
    }
  }

  private async startTask(item: QueueItem): Promise<void> {
    const { task, input } = item

    log("Starting task", { taskId: task.id, agent: input.agent })

    const concurrencyKey = input.agent

    const parentSession = await this.client.session
      .get({ path: { id: input.parentSessionID } })
      .catch((err: unknown) => {
        log(`Failed to get parent session: ${err}`)
        return null
      })
    const parentDirectory =
      (parentSession?.data as { directory?: string } | undefined)
        ?.directory ?? this.directory

    const createResult = await this.client.session.create({
      body: {
        parentID: input.parentSessionID,
        title: `Background: ${input.description}`,
      } as any,
      query: { directory: parentDirectory },
    })

    if (createResult.error) {
      throw new Error(
        `Failed to create background session: ${createResult.error}`,
      )
    }

    const sessionID = (createResult.data as { id: string }).id
    if (!sessionID) {
      throw new Error(
        "Failed to create background session: no session ID returned",
      )
    }

    task.status = "running"
    task.startedAt = new Date()
    task.sessionID = sessionID
    task.progress = { toolCalls: 0, lastUpdate: new Date() }
    task.concurrencyKey = concurrencyKey
    task.concurrencyGroup = concurrencyKey

    this.taskHistory.record(input.parentSessionID, {
      id: task.id,
      sessionID,
      agent: input.agent,
      description: input.description,
      status: "running",
      startedAt: task.startedAt,
    })

    this.startPolling()
    this.toastManager.updateTask(task.id, "running")

    log("Sending prompt fire-and-forget", {
      sessionID,
      agent: input.agent,
      promptLength: input.prompt.length,
    })

    this.client.session
      .promptAsync({
        path: { id: sessionID },
        body: {
          agent: input.agent,
          parts: [{ type: "text", text: input.prompt }],
        },
      })
      .catch((error: unknown) => {
        log("promptAsync error", error)
        const t = this.findBySession(sessionID)
        if (!t) return
        t.status = "interrupt"
        t.error =
          error instanceof Error ? error.message : String(error)
        t.completedAt = new Date()
        if (t.concurrencyKey) {
          this.concurrencyManager.release(t.concurrencyKey)
          t.concurrencyKey = undefined
        }
        this.client.session
          .abort({ path: { id: sessionID } })
          .catch(() => {})
        this.cleanupPendingByParent(t)
        this.enqueueNotification(t.parentSessionID, () =>
          this.notifyParentSession(t),
        ).catch((err: unknown) => log("Failed to notify on error", err))
      })
  }

  // ─── Resume ──────────────────────────────────────────────────────────────

  async resume(input: ResumeInput): Promise<BackgroundTask> {
    const task = this.findBySession(input.sessionId)
    if (!task) throw new Error(`Task not found for session: ${input.sessionId}`)
    if (!task.sessionID)
      throw new Error(`Task has no sessionID: ${task.id}`)
    if (task.status === "running") return task

    const concurrencyKey = task.concurrencyGroup ?? task.agent
    await this.concurrencyManager.acquire(concurrencyKey)
    task.concurrencyKey = concurrencyKey
    task.concurrencyGroup = concurrencyKey

    task.status = "running"
    task.completedAt = undefined
    task.error = undefined
    task.parentSessionID = input.parentSessionID
    task.parentMessageID = input.parentMessageID
    task.parentAgent = input.parentAgent
    task.startedAt = new Date()
    task.progress = {
      toolCalls: task.progress?.toolCalls ?? 0,
      lastUpdate: new Date(),
    }

    this.startPolling()

    if (input.parentSessionID) {
      const pending =
        this.pendingByParent.get(input.parentSessionID) ?? new Set()
      pending.add(task.id)
      this.pendingByParent.set(input.parentSessionID, pending)
    }

    this.toastManager.addTask({
      id: task.id,
      description: task.description,
      agent: task.agent,
      isBackground: true,
    })

    log("Resuming task", {
      taskId: task.id,
      sessionID: task.sessionID,
    })

    this.client.session
      .promptAsync({
        path: { id: task.sessionID },
        body: {
          agent: task.agent,
          parts: [{ type: "text", text: input.prompt }],
        },
      })
      .catch((error: unknown) => {
        log("resume prompt error", error)
        task.status = "interrupt"
        task.error =
          error instanceof Error ? error.message : String(error)
        task.completedAt = new Date()
        if (task.concurrencyKey) {
          this.concurrencyManager.release(task.concurrencyKey)
          task.concurrencyKey = undefined
        }
        if (task.sessionID) {
          this.client.session
            .abort({ path: { id: task.sessionID } })
            .catch(() => {})
        }
        this.cleanupPendingByParent(task)
        this.enqueueNotification(task.parentSessionID, () =>
          this.notifyParentSession(task),
        ).catch((err: unknown) => log("Failed to notify on resume error", err))
      })

    return task
  }

  // ─── Cancel ──────────────────────────────────────────────────────────────

  async cancelTask(
    taskId: string,
    options?: {
      source?: string
      reason?: string
      abortSession?: boolean
      skipNotification?: boolean
    },
  ): Promise<boolean> {
    const task = this.tasks.get(taskId)
    if (!task || (task.status !== "running" && task.status !== "pending"))
      return false

    const abortSession = options?.abortSession !== false

    if (task.status === "pending") {
      const key = task.agent
      const queue = this.queuesByKey.get(key)
      if (queue) {
        const index = queue.findIndex((item) => item.task.id === taskId)
        if (index !== -1) {
          queue.splice(index, 1)
          if (queue.length === 0) this.queuesByKey.delete(key)
        }
      }
    }

    task.status = "cancelled"
    task.completedAt = new Date()
    if (options?.reason) task.error = options.reason

    this.taskHistory.record(task.parentSessionID, {
      id: task.id,
      sessionID: task.sessionID,
      agent: task.agent,
      description: task.description,
      status: "cancelled",
      startedAt: task.startedAt,
      completedAt: task.completedAt,
    })

    if (task.concurrencyKey) {
      this.concurrencyManager.release(task.concurrencyKey)
      task.concurrencyKey = undefined
    }

    this.clearTimers(task.id)
    this.cleanupPendingByParent(task)

    if (abortSession && task.sessionID) {
      this.client.session
        .abort({ path: { id: task.sessionID } })
        .catch(() => {})
    }

    if (options?.skipNotification) {
      log(`Task cancelled (notification skipped)`, task.id)
      return true
    }

    try {
      await this.enqueueNotification(task.parentSessionID, () =>
        this.notifyParentSession(task),
      )
    } catch (err) {
      log("Error notifying on cancel", err)
    }

    return true
  }

  // ─── Queries ─────────────────────────────────────────────────────────────

  getTask(id: string): BackgroundTask | undefined {
    return this.tasks.get(id)
  }

  findBySession(sessionID: string): BackgroundTask | undefined {
    for (const task of this.tasks.values()) {
      if (task.sessionID === sessionID) return task
    }
    return undefined
  }

  getTasksByParentSession(sessionID: string): BackgroundTask[] {
    return Array.from(this.tasks.values()).filter(
      (t) => t.parentSessionID === sessionID,
    )
  }

  getAllDescendantTasks(sessionID: string): BackgroundTask[] {
    const result: BackgroundTask[] = []
    for (const child of this.getTasksByParentSession(sessionID)) {
      result.push(child)
      if (child.sessionID)
        result.push(...this.getAllDescendantTasks(child.sessionID))
    }
    return result
  }

  getRunningTasks(): BackgroundTask[] {
    return Array.from(this.tasks.values()).filter(
      (t) => t.status === "running",
    )
  }

  getPendingNotifications(sessionID: string): BackgroundTask[] {
    return this.notifications.get(sessionID) ?? []
  }

  clearNotifications(sessionID: string): void {
    this.notifications.delete(sessionID)
  }

  // ─── Event Handling ──────────────────────────────────────────────────────

  handleEvent(event: ManagerEvent): void {
    const props = event.properties

    // Progress tracking
    if (
      event.type === "message.part.updated" ||
      event.type === "message.part.delta"
    ) {
      const sessionID =
        typeof props?.sessionID === "string" ? props.sessionID : undefined
      if (!sessionID) return

      const task = this.findBySession(sessionID)
      if (!task) return

      // Clear idle deferral — task is still active
      const existingTimer = this.idleDeferralTimers.get(task.id)
      if (existingTimer) {
        clearTimeout(existingTimer)
        this.idleDeferralTimers.delete(task.id)
      }

      if (!task.progress)
        task.progress = { toolCalls: 0, lastUpdate: new Date() }
      task.progress.lastUpdate = new Date()

      const type =
        typeof props?.type === "string" ? props.type : undefined
      const toolName =
        typeof props?.tool === "string" ? props.tool : undefined
      if (type === "tool" || toolName) {
        task.progress.toolCalls += 1
        task.progress.lastTool = toolName
      }
    }

    // Session idle — attempt completion
    if (event.type === "session.idle") {
      const sessionID =
        typeof props?.sessionID === "string" ? props.sessionID : undefined
      if (!sessionID) return

      const task = this.findBySession(sessionID)
      if (!task || task.status !== "running" || !task.startedAt) return

      const elapsedMs = Date.now() - task.startedAt.getTime()
      if (elapsedMs < MIN_IDLE_TIME_MS) {
        const remainingMs = MIN_IDLE_TIME_MS - elapsedMs
        if (!this.idleDeferralTimers.has(task.id)) {
          log("Deferring early session.idle", {
            elapsedMs,
            remainingMs,
            taskId: task.id,
          })
          const timer = setTimeout(() => {
            this.idleDeferralTimers.delete(task.id)
            this.handleEvent({
              type: "session.idle",
              properties: { sessionID },
            })
          }, remainingMs)
          this.idleDeferralTimers.set(task.id, timer)
        }
        return
      }

      this.validateSessionHasOutput(sessionID)
        .then(async (hasValidOutput) => {
          if (task.status !== "running") return
          if (!hasValidOutput) {
            log("session.idle but no valid output yet, waiting", task.id)
            return
          }

          const hasIncompleteTodos =
            await this.checkSessionTodos(sessionID)
          if (task.status !== "running") return
          if (hasIncompleteTodos) {
            log("Task has incomplete todos, waiting", task.id)
            return
          }

          await this.tryCompleteTask(task, "session.idle event")
        })
        .catch((err: unknown) =>
          log("Error in session.idle handler", err),
        )
    }

    // Session error
    if (event.type === "session.error") {
      const sessionID =
        typeof props?.sessionID === "string" ? props.sessionID : undefined
      if (!sessionID) return

      const task = this.findBySession(sessionID)
      if (!task || task.status !== "running") return

      task.status = "error"
      task.error = this.extractErrorMessage(props) ?? "Session error"
      task.completedAt = new Date()

      this.taskHistory.record(task.parentSessionID, {
        id: task.id,
        sessionID: task.sessionID,
        agent: task.agent,
        description: task.description,
        status: "error",
        startedAt: task.startedAt,
        completedAt: task.completedAt,
      })

      this.releaseConcurrency(task)
      this.clearTimers(task.id)
      this.cleanupPendingByParent(task)
      this.clearNotificationsForTask(task.id)
      this.enqueueNotification(task.parentSessionID, () =>
        this.notifyParentSession(task),
      ).catch((err: unknown) => log("Failed to notify on session.error", err))
      this.tasks.delete(task.id)
    }

    // Session deleted — cancel task + descendants
    if (event.type === "session.deleted") {
      const info = props?.info
      const sessionID =
        typeof info?.id === "string" ? info.id : undefined
      if (!sessionID) return

      const tasksToCancel = new Map<string, BackgroundTask>()
      const directTask = this.findBySession(sessionID)
      if (directTask) tasksToCancel.set(directTask.id, directTask)
      for (const d of this.getAllDescendantTasks(sessionID)) {
        tasksToCancel.set(d.id, d)
      }
      if (tasksToCancel.size === 0) return

      for (const task of tasksToCancel.values()) {
        if (task.status === "running" || task.status === "pending") {
          void this.cancelTask(task.id, {
            source: "session.deleted",
            reason: "Session deleted",
            skipNotification: true,
          }).catch((err: unknown) =>
            log("Failed to cancel on session.deleted", err),
          )
        }

        this.clearTimers(task.id)
        this.cleanupPendingByParent(task)
        this.clearNotificationsForTask(task.id)
        this.tasks.delete(task.id)
      }
    }
  }

  // ─── Polling ─────────────────────────────────────────────────────────────

  private startPolling(): void {
    if (this.pollingInterval) return
    this.pollingInterval = setInterval(() => {
      this.pollRunningTasks()
    }, POLLING_INTERVAL_MS)
    this.pollingInterval.unref?.()
  }

  private stopPolling(): void {
    if (this.pollingInterval) {
      clearInterval(this.pollingInterval)
      this.pollingInterval = undefined
    }
  }

  private async pollRunningTasks(): Promise<void> {
    this.pruneStaleTasksAndNotifications()

    let allStatuses: Record<string, { type: string }> = {}
    try {
      const statusResult = await this.client.session.status()
      allStatuses = ((statusResult as { data?: unknown }).data ??
        {}) as Record<string, { type: string }>
    } catch (error) {
      log("Failed to fetch session statuses", error)
      return
    }

    await this.checkAndInterruptStaleTasks(allStatuses)

    for (const task of this.tasks.values()) {
      if (task.status !== "running") continue
      const sessionID = task.sessionID
      if (!sessionID) continue

      try {
        const sessionStatus = allStatuses[sessionID]

        if (sessionStatus?.type === "idle") {
          const hasValidOutput =
            await this.validateSessionHasOutput(sessionID)
          if (!hasValidOutput) {
            log("Polling idle but no valid output yet, waiting", task.id)
            continue
          }
          if (task.status !== "running") continue

          const hasIncompleteTodos =
            await this.checkSessionTodos(sessionID)
          if (hasIncompleteTodos) {
            log("Task has incomplete todos via polling, waiting", task.id)
            continue
          }

          await this.tryCompleteTask(task, "polling (idle status)")
          continue
        }

        // Session still running — progress tracked via events
      } catch (error) {
        log("Poll error for task", { taskId: task.id, error })
      }
    }

    if (!this.hasRunningTasks()) this.stopPolling()
  }

  // ─── Completion ──────────────────────────────────────────────────────────

  private async tryCompleteTask(
    task: BackgroundTask,
    source: string,
  ): Promise<boolean> {
    if (task.status !== "running") {
      log("Task already completed, skipping", {
        taskId: task.id,
        status: task.status,
        source,
      })
      return false
    }

    task.status = "completed"
    task.completedAt = new Date()

    this.taskHistory.record(task.parentSessionID, {
      id: task.id,
      sessionID: task.sessionID,
      agent: task.agent,
      description: task.description,
      status: "completed",
      startedAt: task.startedAt,
      completedAt: task.completedAt,
    })

    this.releaseConcurrency(task)
    this.markForNotification(task)
    this.cleanupPendingByParent(task)
    this.clearTimers(task.id)

    if (task.sessionID) {
      this.client.session
        .abort({ path: { id: task.sessionID } })
        .catch(() => {})
    }

    try {
      await this.enqueueNotification(task.parentSessionID, () =>
        this.notifyParentSession(task),
      )
      log(`Task completed via ${source}`, task.id)
    } catch (err) {
      log("Error in notifyParentSession", { taskId: task.id, error: err })
    }

    return true
  }

  // ─── Parent Notification ─────────────────────────────────────────────────

  private async notifyParentSession(task: BackgroundTask): Promise<void> {
    const duration = formatDuration(
      task.startedAt ?? new Date(),
      task.completedAt,
    )

    log("notifyParentSession called", task.id)

    this.toastManager.showCompletionToast({
      id: task.id,
      description: task.description,
      duration,
    })

    // Check if all tasks for this parent are complete
    const pendingSet = this.pendingByParent.get(task.parentSessionID)
    if (pendingSet) pendingSet.delete(task.id)
    const remainingCount = pendingSet?.size ?? 0
    const allComplete = remainingCount === 0
    if (allComplete && pendingSet) {
      this.pendingByParent.delete(task.parentSessionID)
    }

    const statusText =
      task.status === "completed"
        ? "COMPLETED"
        : task.status === "interrupt"
          ? "INTERRUPTED"
          : task.status === "error"
            ? "ERROR"
            : "CANCELLED"
    const errorInfo = task.error ? `\n**Error:** ${task.error}` : ""

    let notification: string
    let completedTasks: BackgroundTask[] = []

    if (allComplete) {
      completedTasks = Array.from(this.tasks.values()).filter(
        (t) =>
          t.parentSessionID === task.parentSessionID &&
          t.status !== "running" &&
          t.status !== "pending",
      )
      const completedTasksText =
        completedTasks.map((t) => `- \`${t.id}\`: ${t.description}`).join("\n") ||
        `- \`${task.id}\`: ${task.description}`

      notification = `<system-reminder>
[ALL BACKGROUND TASKS COMPLETE]

**Completed:**
${completedTasksText}

Use \`background_output(task_id="<id>")\` to retrieve each result.
</system-reminder>`
    } else {
      notification = `<system-reminder>
[BACKGROUND TASK ${statusText}]
**ID:** \`${task.id}\`
**Description:** ${task.description}
**Duration:** ${duration}${errorInfo}

**${remainingCount} task${remainingCount === 1 ? "" : "s"} still in progress.** You WILL be notified when ALL complete.
Do NOT poll - continue productive work.

Use \`background_output(task_id="${task.id}")\` to retrieve this result when ready.
</system-reminder>`
    }

    // Resolve parent agent/model from recent messages
    let agent: string | undefined = task.parentAgent
    let model: { providerID: string; modelID: string } | undefined

    try {
      const messagesResp = await this.client.session.messages({
        path: { id: task.parentSessionID },
      })
      const messages = ((messagesResp as { data?: unknown }).data ??
        []) as Array<{
        info?: {
          agent?: string
          model?: { providerID: string; modelID: string }
          providerID?: string
          modelID?: string
        }
      }>
      for (let i = messages.length - 1; i >= 0; i--) {
        const info = messages[i].info
        if (info?.agent || info?.model) {
          agent = info.agent ?? task.parentAgent
          model =
            info.model ??
            (info.providerID && info.modelID
              ? {
                  providerID: info.providerID,
                  modelID: info.modelID,
                }
              : undefined)
          break
        }
      }
    } catch (error) {
      if (isAbortedSessionError(error)) {
        log("Parent session aborted, skipping notification", task.id)
        return
      }
      // Fallback to task's stored parent agent
    }

    try {
      await this.client.session.promptAsync({
        path: { id: task.parentSessionID },
        body: {
          noReply: !allComplete,
          ...(agent !== undefined ? { agent } : {}),
          ...(model !== undefined ? { model } : {}),
          parts: [{ type: "text", text: notification }],
        } as any,
      })
      log("Sent notification to parent", {
        taskId: task.id,
        allComplete,
        noReply: !allComplete,
      })
    } catch (error) {
      if (isAbortedSessionError(error)) {
        log("Parent session aborted, skipping notification", task.id)
        return
      }
      log("Failed to send notification", error)
    }

    // Schedule cleanup of completed tasks after delay
    if (allComplete) {
      for (const ct of completedTasks) {
        const existingTimer = this.completionTimers.get(ct.id)
        if (existingTimer) {
          clearTimeout(existingTimer)
          this.completionTimers.delete(ct.id)
        }
        const timer = setTimeout(() => {
          this.completionTimers.delete(ct.id)
          if (this.tasks.has(ct.id)) {
            this.clearNotificationsForTask(ct.id)
            this.tasks.delete(ct.id)
            log("Removed completed task from memory", ct.id)
          }
        }, TASK_CLEANUP_DELAY_MS)
        this.completionTimers.set(ct.id, timer)
      }
    }
  }

  // ─── Stale Detection ─────────────────────────────────────────────────────

  private pruneStaleTasksAndNotifications(): void {
    const now = Date.now()

    for (const [taskId, task] of this.tasks.entries()) {
      const previousStatus = task.status
      const timestamp =
        task.status === "pending"
          ? task.queuedAt?.getTime()
          : task.startedAt?.getTime()
      if (!timestamp) continue
      if (now - timestamp <= TASK_TTL_MS) continue

      const errorMessage =
        task.status === "pending"
          ? "Task timed out while queued (30 minutes)"
          : "Task timed out after 30 minutes"

      log("Pruning stale task", { taskId, status: task.status })
      task.status = "error"
      task.error = errorMessage
      task.completedAt = new Date()
      this.releaseConcurrency(task)
      this.cleanupPendingByParent(task)

      if (previousStatus === "pending") {
        const queue = this.queuesByKey.get(task.agent)
        if (queue) {
          const idx = queue.findIndex((i) => i.task.id === taskId)
          if (idx !== -1) {
            queue.splice(idx, 1)
            if (queue.length === 0) this.queuesByKey.delete(task.agent)
          }
        }
      }

      this.clearNotificationsForTask(taskId)
      this.tasks.delete(taskId)
    }

    for (const [sessionID, notifs] of this.notifications.entries()) {
      if (notifs.length === 0) {
        this.notifications.delete(sessionID)
        continue
      }
      const valid = notifs.filter((t) => {
        if (!t.startedAt) return false
        return now - t.startedAt.getTime() <= TASK_TTL_MS
      })
      if (valid.length === 0) this.notifications.delete(sessionID)
      else if (valid.length !== notifs.length)
        this.notifications.set(sessionID, valid)
    }
  }

  private async checkAndInterruptStaleTasks(
    allStatuses: Record<string, { type: string }>,
  ): Promise<void> {
    const staleTimeoutMs =
      this.config.staleTimeoutMs ?? DEFAULT_STALE_TIMEOUT_MS
    const now = Date.now()

    for (const task of this.tasks.values()) {
      if (task.status !== "running") continue
      const { startedAt, sessionID } = task
      if (!startedAt || !sessionID) continue

      const sessionStatus = allStatuses[sessionID]?.type
      const sessionIsRunning =
        sessionStatus !== undefined && sessionStatus !== "idle"
      const runtime = now - startedAt.getTime()

      // No progress ever recorded
      if (!task.progress?.lastUpdate) {
        if (sessionIsRunning) continue
        if (runtime <= staleTimeoutMs * 2) continue

        task.status = "cancelled"
        task.error = `Stale timeout (no activity for ${Math.round(runtime / 60000)}min since start)`
        task.completedAt = new Date()
        this.releaseConcurrency(task)
        this.client.session
          .abort({ path: { id: sessionID } })
          .catch(() => {})
        log(`Task ${task.id} interrupted: no progress since start`)

        try {
          await this.enqueueNotification(task.parentSessionID, () =>
            this.notifyParentSession(task),
          )
        } catch (err) {
          log("Error notifying for stale task", err)
        }
        continue
      }

      if (sessionIsRunning) continue
      if (runtime < MIN_RUNTIME_BEFORE_STALE_MS) continue

      const timeSinceLastUpdate =
        now - task.progress.lastUpdate.getTime()
      if (timeSinceLastUpdate <= staleTimeoutMs) continue
      if (task.status !== "running") continue

      task.status = "cancelled"
      task.error = `Stale timeout (no activity for ${Math.round(timeSinceLastUpdate / 60000)}min)`
      task.completedAt = new Date()
      this.releaseConcurrency(task)
      this.client.session
        .abort({ path: { id: sessionID } })
        .catch(() => {})
      log(`Task ${task.id} interrupted: stale timeout`)

      try {
        await this.enqueueNotification(task.parentSessionID, () =>
          this.notifyParentSession(task),
        )
      } catch (err) {
        log("Error notifying for stale task", err)
      }
    }
  }

  // ─── Validation Helpers ──────────────────────────────────────────────────

  private async validateSessionHasOutput(
    sessionID: string,
  ): Promise<boolean> {
    try {
      const response = await this.client.session.messages({
        path: { id: sessionID },
      })
      const messages = ((response as { data?: unknown }).data ??
        []) as Array<{
        info?: { role?: string }
        parts?: Array<{ type?: string; text?: string }>
      }>

      const hasAssistantMsg = messages.some(
        (m) =>
          m.info?.role === "assistant" || m.info?.role === "tool",
      )
      if (!hasAssistantMsg) return false

      return messages.some((m) => {
        if (
          m.info?.role !== "assistant" &&
          m.info?.role !== "tool"
        )
          return false
        return (m.parts ?? []).some(
          (p) =>
            (p.type === "text" && p.text && p.text.trim().length > 0) ||
            (p.type === "reasoning" &&
              p.text &&
              p.text.trim().length > 0) ||
            p.type === "tool",
        )
      })
    } catch (error) {
      log("Failed to validate session output", error)
      return false
    }
  }

  private async checkSessionTodos(
    sessionID: string,
  ): Promise<boolean> {
    try {
      const response = await this.client.session.todo({
        path: { id: sessionID },
      })
      const todos = ((response as { data?: unknown }).data ??
        response) as Todo[]
      if (!todos || todos.length === 0) return false
      return todos.some(
        (t) => t.status !== "completed" && t.status !== "cancelled",
      )
    } catch {
      return false
    }
  }

  // ─── Internal Helpers ────────────────────────────────────────────────────

  private releaseConcurrency(task: BackgroundTask): void {
    if (task.concurrencyKey) {
      this.concurrencyManager.release(task.concurrencyKey)
      task.concurrencyKey = undefined
    }
  }

  private clearTimers(taskId: string): void {
    const ct = this.completionTimers.get(taskId)
    if (ct) {
      clearTimeout(ct)
      this.completionTimers.delete(taskId)
    }
    const it = this.idleDeferralTimers.get(taskId)
    if (it) {
      clearTimeout(it)
      this.idleDeferralTimers.delete(taskId)
    }
  }

  private cleanupPendingByParent(task: BackgroundTask): void {
    if (!task.parentSessionID) return
    const pending = this.pendingByParent.get(task.parentSessionID)
    if (!pending) return
    pending.delete(task.id)
    if (pending.size === 0)
      this.pendingByParent.delete(task.parentSessionID)
  }

  private markForNotification(task: BackgroundTask): void {
    const queue = this.notifications.get(task.parentSessionID) ?? []
    queue.push(task)
    this.notifications.set(task.parentSessionID, queue)
  }

  private clearNotificationsForTask(taskId: string): void {
    for (const [sessionID, tasks] of this.notifications.entries()) {
      const filtered = tasks.filter((t) => t.id !== taskId)
      if (filtered.length === 0) this.notifications.delete(sessionID)
      else this.notifications.set(sessionID, filtered)
    }
  }

  private hasRunningTasks(): boolean {
    for (const task of this.tasks.values()) {
      if (task.status === "running") return true
    }
    return false
  }

  private extractErrorMessage(
    props: EventProperties | undefined,
  ): string | undefined {
    if (!props) return undefined
    const errorRaw = props["error"]
    if (typeof errorRaw !== "object" || errorRaw === null) return undefined
    const err = errorRaw as Record<string, unknown>
    const data = err["data"]
    if (typeof data === "object" && data !== null) {
      const msg = (data as Record<string, unknown>)["message"]
      if (typeof msg === "string") return msg
    }
    const msg = err["message"]
    return typeof msg === "string" ? msg : undefined
  }

  private enqueueNotification(
    parentSessionID: string | undefined,
    operation: () => Promise<void>,
  ): Promise<void> {
    if (!parentSessionID) return operation()

    const previous =
      this.notificationQueueByParent.get(parentSessionID) ??
      Promise.resolve()
    const current = previous.catch(() => {}).then(operation)

    this.notificationQueueByParent.set(parentSessionID, current)

    void current
      .finally(() => {
        if (
          this.notificationQueueByParent.get(parentSessionID) ===
          current
        )
          this.notificationQueueByParent.delete(parentSessionID)
      })
      .catch(() => {})

    return current
  }

  // ─── Shutdown ────────────────────────────────────────────────────────────

  shutdown(): void {
    if (this.shutdownTriggered) return
    this.shutdownTriggered = true
    log("Shutting down BackgroundManager")
    this.stopPolling()

    for (const task of this.tasks.values()) {
      if (task.status === "running" && task.sessionID) {
        this.client.session
          .abort({ path: { id: task.sessionID } })
          .catch(() => {})
      }
    }

    for (const task of this.tasks.values()) this.releaseConcurrency(task)
    for (const timer of this.completionTimers.values()) clearTimeout(timer)
    this.completionTimers.clear()
    for (const timer of this.idleDeferralTimers.values())
      clearTimeout(timer)
    this.idleDeferralTimers.clear()
    this.concurrencyManager.clear()
    this.tasks.clear()
    this.notifications.clear()
    this.pendingByParent.clear()
    this.notificationQueueByParent.clear()
    this.queuesByKey.clear()
    this.processingKeys.clear()
    log("Shutdown complete")
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared Helpers
// ═══════════════════════════════════════════════════════════════════════════════

function formatDuration(start: Date, end?: Date): string {
  const duration = (end ?? new Date()).getTime() - start.getTime()
  const seconds = Math.floor(duration / 1000)
  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  if (hours > 0) return `${hours}h ${minutes % 60}m ${seconds % 60}s`
  if (minutes > 0) return `${minutes}m ${seconds % 60}s`
  return `${seconds}s`
}

function isAbortedSessionError(error: unknown): boolean {
  if (!error) return false
  const message =
    error instanceof Error
      ? error.message
      : typeof error === "string"
        ? error
        : ""
  return message.toLowerCase().includes("aborted")
}

// ═══════════════════════════════════════════════════════════════════════════════
// Tools (stubs — will be completed in Tasks 9-10)
// ═══════════════════════════════════════════════════════════════════════════════

function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text
  return text.slice(0, maxLength) + "..."
}

function formatTaskStatus(task: BackgroundTask): string {
  let duration: string
  if (task.status === "pending" && task.queuedAt) {
    duration = formatDuration(task.queuedAt, undefined)
  } else if (task.startedAt) {
    duration = formatDuration(task.startedAt, task.completedAt)
  } else {
    duration = "N/A"
  }

  const promptPreview = truncateText(task.prompt, 500)

  let progressSection = ""
  if (task.progress?.lastTool) {
    progressSection = `\n| Last tool | ${task.progress.lastTool} |`
  }

  let statusNote = ""
  if (task.status === "pending") {
    statusNote = `\n\n> **Queued**: Task is waiting for a concurrency slot to become available.`
  } else if (task.status === "running") {
    statusNote = `\n\n> **Note**: No need to wait explicitly - the system will notify you when this task completes.`
  } else if (task.status === "error") {
    statusNote = `\n\n> **Failed**: The task encountered an error.`
  } else if (task.status === "interrupt") {
    statusNote = `\n\n> **Interrupted**: The task was interrupted by a prompt error. The session may contain partial results.`
  }

  const durationLabel = task.status === "pending" ? "Queued for" : "Duration"

  return `# Task Status

| Field | Value |
|-------|-------|
| Task ID | \`${task.id}\` |
| Description | ${task.description} |
| Agent | ${task.agent} |
| Status | **${task.status}** |
| ${durationLabel} | ${duration} |
| Session ID | \`${task.sessionID}\` |${progressSection}
${statusNote}
## Original Prompt

\`\`\`
${promptPreview}
\`\`\``
}

async function formatTaskResult(
  task: BackgroundTask,
  client: OpencodeClient,
): Promise<string> {
  if (!task.sessionID) return `Error: Task has no sessionID`

  const messagesResp = await client.session.messages({
    path: { id: task.sessionID },
  })
  const messages = ((messagesResp as { data?: unknown }).data ?? []) as Array<{
    info?: { role?: string; time?: string }
    parts?: Array<{ type?: string; text?: string; content?: string | Array<{ type: string; text?: string }> }>
  }>

  if (!Array.isArray(messages) || messages.length === 0) {
    return `Task Result

Task ID: ${task.id}
Description: ${task.description}
Duration: ${formatDuration(task.startedAt ?? new Date(), task.completedAt)}
Session ID: ${task.sessionID}

---

(No messages found)`
  }

  const relevantMessages = messages.filter(
    (m) => m.info?.role === "assistant" || m.info?.role === "tool",
  )
  if (relevantMessages.length === 0) {
    return `Task Result

Task ID: ${task.id}
Description: ${task.description}
Duration: ${formatDuration(task.startedAt ?? new Date(), task.completedAt)}
Session ID: ${task.sessionID}

---

(No assistant or tool response found)`
  }

  const sorted = [...relevantMessages].sort((a, b) => {
    const timeA = typeof a.info?.time === "string" ? a.info.time : ""
    const timeB = typeof b.info?.time === "string" ? b.info.time : ""
    return timeA.localeCompare(timeB)
  })

  const extractedContent: string[] = []
  for (const message of sorted) {
    for (const part of message.parts ?? []) {
      if ((part.type === "text" || part.type === "reasoning") && part.text) {
        extractedContent.push(part.text)
        continue
      }
      if (part.type === "tool_result") {
        if (typeof part.content === "string" && part.content) {
          extractedContent.push(part.content)
          continue
        }
        if (Array.isArray(part.content)) {
          for (const block of part.content) {
            if ((block.type === "text" || block.type === "reasoning") && block.text) {
              extractedContent.push(block.text)
            }
          }
        }
      }
    }
  }

  const textContent = extractedContent.filter((t) => t.length > 0).join("\n\n")
  const duration = formatDuration(task.startedAt ?? new Date(), task.completedAt)

  return `Task Result

Task ID: ${task.id}
Description: ${task.description}
Duration: ${duration}
Session ID: ${task.sessionID}

---

${textContent || "(No text output)"}`
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

function createBackgroundOutput(
  manager: BackgroundManager,
  client: OpencodeClient,
): ToolDefinition {
  return tool({
    description:
      "Retrieve output from a background task. Returns the final result if completed, current status if still running. Use block=true to wait for completion.",
    args: {
      task_id: tool.schema.string().describe("Task ID to get output from"),
      block: tool.schema
        .boolean()
        .optional()
        .describe(
          "Wait for completion (default: false). System notifies when done, so blocking is rarely needed.",
        ),
      timeout: tool.schema
        .number()
        .optional()
        .describe("Max wait time in ms (default: 60000, max: 600000)"),
    },
    async execute(args) {
      const task = manager.getTask(args.task_id)
      if (!task) return `Task not found: ${args.task_id}`

      if (task.status === "completed") {
        return await formatTaskResult(task, client)
      }

      if (
        task.status === "error" ||
        task.status === "cancelled" ||
        task.status === "interrupt"
      ) {
        return formatTaskStatus(task)
      }

      if (!args.block) {
        return formatTaskStatus(task)
      }

      const timeoutMs = Math.min(args.timeout ?? 60000, 600000)
      const startTime = Date.now()

      while (Date.now() - startTime < timeoutMs) {
        await delay(1000)

        const currentTask = manager.getTask(args.task_id)
        if (!currentTask) return `Task was deleted: ${args.task_id}`

        if (currentTask.status === "completed") {
          return await formatTaskResult(currentTask, client)
        }

        if (
          currentTask.status === "error" ||
          currentTask.status === "cancelled" ||
          currentTask.status === "interrupt"
        ) {
          return formatTaskStatus(currentTask)
        }
      }

      const finalTask = manager.getTask(args.task_id)
      if (!finalTask) return `Task was deleted: ${args.task_id}`
      return `Timeout exceeded (${timeoutMs}ms). Task still ${finalTask.status}.\n\n${formatTaskStatus(finalTask)}`
    },
  })
}

function createBackgroundCancel(
  manager: BackgroundManager,
  _client: OpencodeClient,
): ToolDefinition {
  return tool({
    description:
      "Cancel running or pending background tasks. Provide taskId for a specific task, or all=true to cancel all.",
    args: {
      taskId: tool.schema
        .string()
        .optional()
        .describe("Task ID to cancel (required if all=false)"),
      all: tool.schema
        .boolean()
        .optional()
        .describe("Cancel all running background tasks (default: false)"),
    },
    async execute(args, toolContext) {
      const cancelAll = args.all === true

      if (!cancelAll && !args.taskId) {
        return `[ERROR] Invalid arguments: Either provide a taskId or set all=true to cancel all running tasks.`
      }

      if (cancelAll) {
        const tasks = manager.getAllDescendantTasks(toolContext.sessionID)
        const cancellable = tasks.filter(
          (t) => t.status === "running" || t.status === "pending",
        )

        if (cancellable.length === 0) {
          return `No running or pending background tasks to cancel.`
        }

        const cancelledInfo: Array<{
          id: string
          description: string
          status: string
          sessionID?: string
        }> = []

        for (const task of cancellable) {
          const originalStatus = task.status
          const cancelled = await manager.cancelTask(task.id, {
            source: "background_cancel",
            abortSession: originalStatus === "running",
            skipNotification: true,
          })
          if (!cancelled) continue
          cancelledInfo.push({
            id: task.id,
            description: task.description,
            status: originalStatus === "pending" ? "pending" : "running",
            sessionID: task.sessionID,
          })
        }

        const tableRows = cancelledInfo
          .map(
            (t) =>
              `| \`${t.id}\` | ${t.description} | ${t.status} | ${t.sessionID ? `\`${t.sessionID}\`` : "(not started)"} |`,
          )
          .join("\n")

        const resumable = cancelledInfo.filter((t) => t.sessionID)
        const resumeSection =
          resumable.length > 0
            ? `\n## Continue Instructions

To continue a cancelled task, use:
\`\`\`
task(session_id="<session_id>", prompt="Continue: <your follow-up>")
\`\`\`

Continuable sessions:
${resumable.map((t) => `- \`${t.sessionID}\` (${t.description})`).join("\n")}`
            : ""

        return `Cancelled ${cancelledInfo.length} background task(s):

| Task ID | Description | Status | Session ID |
|---------|-------------|--------|------------|
${tableRows}
${resumeSection}`
      }

      const task = manager.getTask(args.taskId!)
      if (!task) return `[ERROR] Task not found: ${args.taskId}`

      if (task.status !== "running" && task.status !== "pending") {
        return `[ERROR] Cannot cancel task: current status is "${task.status}".
Only running or pending tasks can be cancelled.`
      }

      const cancelled = await manager.cancelTask(task.id, {
        source: "background_cancel",
        abortSession: task.status === "running",
        skipNotification: true,
      })
      if (!cancelled) return `[ERROR] Failed to cancel task: ${task.id}`

      if (task.status === "pending") {
        return `Pending task cancelled successfully

Task ID: ${task.id}
Description: ${task.description}
Status: ${task.status}`
      }

      return `Task cancelled successfully

Task ID: ${task.id}
Description: ${task.description}
Session ID: ${task.sessionID}
Status: ${task.status}`
    },
  })
}

// ═══════════════════════════════════════════════════════════════════════════════
// Plugin entry point
// ═══════════════════════════════════════════════════════════════════════════════

export const BackgroundTasksPlugin: Plugin = async (
  input: PluginInput,
): Promise<Hooks> => {
  const { client, directory } = input

  const config: BackgroundTaskConfig = {}
  const manager = new BackgroundManager(client, directory, config)

  const tools: Record<string, ToolDefinition> = {
    background_output: createBackgroundOutput(manager, client),
    background_cancel: createBackgroundCancel(manager, client),
  }

  log("Background tasks plugin loaded", {
    directory,
    tools: Object.keys(tools),
  })

  return {
    tool: tools,
    event: async ({ event }) => {
      manager.handleEvent(event)
    },
  }
}
