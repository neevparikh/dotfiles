import { describe, it, expect } from "bun:test"

// ═══════════════════════════════════════════════════════════════════════════════
// ConcurrencyManager
// ═══════════════════════════════════════════════════════════════════════════════

describe("ConcurrencyManager", () => {
  it("allows up to limit concurrent acquires", async () => {
    const { ConcurrencyManager } = await import("./background-tasks")
    const cm = new ConcurrencyManager({ defaultConcurrency: 2 })

    await cm.acquire("test-key")
    await cm.acquire("test-key")
    expect(cm.getCount("test-key")).toBe(2)
  })

  it("blocks when at capacity and unblocks on release", async () => {
    const { ConcurrencyManager } = await import("./background-tasks")
    const cm = new ConcurrencyManager({ defaultConcurrency: 1 })

    await cm.acquire("k")
    expect(cm.getCount("k")).toBe(1)

    let resolved = false
    const pending = cm.acquire("k").then(() => {
      resolved = true
    })

    await new Promise((r) => setTimeout(r, 50))
    expect(resolved).toBe(false)

    cm.release("k")
    await pending
    expect(resolved).toBe(true)
  })

  it("defaults to limit of 5", async () => {
    const { ConcurrencyManager } = await import("./background-tasks")
    const cm = new ConcurrencyManager({})
    expect(cm.getConcurrencyLimit("anything")).toBe(5)
  })

  it("respects model-specific concurrency", async () => {
    const { ConcurrencyManager } = await import("./background-tasks")
    const cm = new ConcurrencyManager({
      defaultConcurrency: 5,
      modelConcurrency: { "anthropic/claude-sonnet": 2 },
    })
    expect(cm.getConcurrencyLimit("anthropic/claude-sonnet")).toBe(2)
    expect(cm.getConcurrencyLimit("other-model")).toBe(5)
  })

  it("respects provider-level concurrency", async () => {
    const { ConcurrencyManager } = await import("./background-tasks")
    const cm = new ConcurrencyManager({
      providerConcurrency: { anthropic: 3 },
    })
    expect(cm.getConcurrencyLimit("anthropic/claude-sonnet")).toBe(3)
  })

  it("cancelWaiters rejects pending acquires", async () => {
    const { ConcurrencyManager } = await import("./background-tasks")
    const cm = new ConcurrencyManager({ defaultConcurrency: 1 })

    await cm.acquire("k")

    let rejected = false
    cm.acquire("k").catch(() => {
      rejected = true
    })

    await new Promise((r) => setTimeout(r, 10))
    cm.cancelWaiters("k")
    await new Promise((r) => setTimeout(r, 10))
    expect(rejected).toBe(true)
  })
})

// ═══════════════════════════════════════════════════════════════════════════════
// TaskHistory
// ═══════════════════════════════════════════════════════════════════════════════

describe("TaskHistory", () => {
  it("records and retrieves entries", async () => {
    const { TaskHistory } = await import("./background-tasks")
    const history = new TaskHistory()
    history.record("parent-1", {
      id: "t1",
      agent: "explore",
      description: "test",
      status: "running",
    })
    const entries = history.getByParentSession("parent-1")
    expect(entries).toHaveLength(1)
    expect(entries[0].agent).toBe("explore")
  })

  it("updates existing entries by id", async () => {
    const { TaskHistory } = await import("./background-tasks")
    const history = new TaskHistory()
    history.record("p1", {
      id: "t1",
      agent: "explore",
      description: "test",
      status: "pending",
    })
    history.record("p1", {
      id: "t1",
      agent: "explore",
      description: "test",
      status: "completed",
    })
    const entries = history.getByParentSession("p1")
    expect(entries).toHaveLength(1)
    expect(entries[0].status).toBe("completed")
  })

  it("caps at 100 entries per parent", async () => {
    const { TaskHistory } = await import("./background-tasks")
    const history = new TaskHistory()
    for (let i = 0; i < 105; i++) {
      history.record("p1", {
        id: `t${i}`,
        agent: "a",
        description: "d",
        status: "completed",
      })
    }
    expect(history.getByParentSession("p1")).toHaveLength(100)
  })

  it("returns copies, not references", async () => {
    const { TaskHistory } = await import("./background-tasks")
    const history = new TaskHistory()
    history.record("p1", {
      id: "t1",
      agent: "explore",
      description: "test",
      status: "running",
    })
    const entries = history.getByParentSession("p1")
    entries[0].status = "completed" as any
    const fresh = history.getByParentSession("p1")
    expect(fresh[0].status).toBe("running")
  })

  it("formatForCompaction returns null for empty", async () => {
    const { TaskHistory } = await import("./background-tasks")
    const history = new TaskHistory()
    expect(history.formatForCompaction("nonexistent")).toBeNull()
  })

  it("formatForCompaction returns formatted string", async () => {
    const { TaskHistory } = await import("./background-tasks")
    const history = new TaskHistory()
    history.record("p1", {
      id: "t1",
      agent: "explore",
      description: "find files",
      status: "completed",
    })
    const result = history.formatForCompaction("p1")
    expect(result).toContain("**explore**")
    expect(result).toContain("(completed)")
    expect(result).toContain("find files")
  })

  it("clearSession removes all entries", async () => {
    const { TaskHistory } = await import("./background-tasks")
    const history = new TaskHistory()
    history.record("p1", {
      id: "t1",
      agent: "a",
      description: "d",
      status: "running",
    })
    history.clearSession("p1")
    expect(history.getByParentSession("p1")).toHaveLength(0)
  })
})

// ═══════════════════════════════════════════════════════════════════════════════
// BackgroundManager
// ═══════════════════════════════════════════════════════════════════════════════

function createMockClient(overrides?: Record<string, any>) {
  return {
    session: {
      get: async () => ({ data: { directory: "/tmp" } }),
      create: async () => ({ data: { id: `sess_${Date.now()}` } }),
      promptAsync: async () => ({}),
      messages: async () => ({ data: [] }),
      status: async () => ({ data: {} }),
      abort: async () => ({}),
      todo: async () => ({ data: [] }),
      ...overrides?.session,
    },
    tui: { showToast: async () => ({}) },
    ...overrides,
  } as any
}

describe("BackgroundManager", () => {
  it("launch creates a pending task with bg_ prefix", async () => {
    const { BackgroundManager } = await import("./background-tasks")
    const manager = new BackgroundManager(createMockClient(), "/tmp", {})
    const task = await manager.launch({
      description: "Test",
      prompt: "Do it",
      agent: "explore",
      parentSessionID: "p1",
      parentMessageID: "m1",
    })
    expect(task.id).toMatch(/^bg_/)
    expect(task.description).toBe("Test")
    // Task should be pending or running by now (processKey runs async)
    expect(["pending", "running"]).toContain(task.status)
    manager.shutdown()
  })

  it("launch throws on empty agent", async () => {
    const { BackgroundManager } = await import("./background-tasks")
    const manager = new BackgroundManager(createMockClient(), "/tmp", {})
    await expect(
      manager.launch({
        description: "Test",
        prompt: "Do it",
        agent: "",
        parentSessionID: "p1",
        parentMessageID: "m1",
      }),
    ).rejects.toThrow("Agent parameter is required")
    manager.shutdown()
  })

  it("getTask returns the launched task", async () => {
    const { BackgroundManager } = await import("./background-tasks")
    const manager = new BackgroundManager(createMockClient(), "/tmp", {})
    const task = await manager.launch({
      description: "Test",
      prompt: "Do it",
      agent: "explore",
      parentSessionID: "p1",
      parentMessageID: "m1",
    })
    expect(manager.getTask(task.id)).toBe(task)
    manager.shutdown()
  })

  it("cancelTask marks running task as cancelled", async () => {
    const { BackgroundManager } = await import("./background-tasks")
    const manager = new BackgroundManager(createMockClient(), "/tmp", {})
    const task = await manager.launch({
      description: "Test",
      prompt: "p",
      agent: "a",
      parentSessionID: "ps",
      parentMessageID: "pm",
    })
    // Wait for task to move to running
    await new Promise((r) => setTimeout(r, 100))
    const cancelled = await manager.cancelTask(task.id, {
      skipNotification: true,
    })
    expect(cancelled).toBe(true)
    expect(task.status).toBe("cancelled")
    manager.shutdown()
  })

  it("handles session.deleted by cancelling tasks", async () => {
    const { BackgroundManager } = await import("./background-tasks")
    const manager = new BackgroundManager(createMockClient(), "/tmp", {})
    const task = await manager.launch({
      description: "t",
      prompt: "p",
      agent: "a",
      parentSessionID: "ps",
      parentMessageID: "pm",
    })
    // Wait for task to start and get a sessionID
    await new Promise((r) => setTimeout(r, 200))
    if (task.sessionID) {
      manager.handleEvent({
        type: "session.deleted",
        properties: { info: { id: task.sessionID } },
      })
      await new Promise((r) => setTimeout(r, 100))
      // Task should be removed from the manager after session.deleted
      expect(manager.getTask(task.id)).toBeUndefined()
    }
    manager.shutdown()
  })

  it("updates progress on message.part.updated", async () => {
    const { BackgroundManager } = await import("./background-tasks")
    const manager = new BackgroundManager(createMockClient(), "/tmp", {})
    const task = await manager.launch({
      description: "t",
      prompt: "p",
      agent: "a",
      parentSessionID: "ps",
      parentMessageID: "pm",
    })
    await new Promise((r) => setTimeout(r, 200))
    if (task.sessionID) {
      manager.handleEvent({
        type: "message.part.updated",
        properties: {
          sessionID: task.sessionID,
          type: "tool",
          tool: "bash",
        },
      })
      expect(task.progress!.toolCalls).toBeGreaterThanOrEqual(1)
      expect(task.progress!.lastTool).toBe("bash")
    }
    manager.shutdown()
  })

  it("getAllDescendantTasks returns nested children", async () => {
    const { BackgroundManager } = await import("./background-tasks")
    const manager = new BackgroundManager(createMockClient(), "/tmp", {})
    // Launch parent task
    const parent = await manager.launch({
      description: "parent",
      prompt: "p",
      agent: "a",
      parentSessionID: "root",
      parentMessageID: "m",
    })
    await new Promise((r) => setTimeout(r, 200))
    if (parent.sessionID) {
      // Launch child under parent's session
      const child = await manager.launch({
        description: "child",
        prompt: "p",
        agent: "a",
        parentSessionID: parent.sessionID,
        parentMessageID: "m",
      })
      const descendants = manager.getAllDescendantTasks("root")
      expect(descendants.some((t) => t.id === parent.id)).toBe(true)
    }
    manager.shutdown()
  })
})

// ═══════════════════════════════════════════════════════════════════════════════
// Integration: full lifecycle (launch → idle → complete → notification)
// ═══════════════════════════════════════════════════════════════════════════════

describe("Integration: full lifecycle", () => {
  it("launch → session.idle with output → completion → parent notified", async () => {
    const { BackgroundManager } = await import("./background-tasks")

    let notifiedParent = false
    let notifiedNoReply: boolean | undefined
    const sessionID = "child-sess-1"

    const client = createMockClient({
      session: {
        get: async () => ({ data: { directory: "/tmp" } }),
        create: async () => ({ data: { id: sessionID } }),
        promptAsync: async (opts: any) => {
          // Detect notification to parent (second call, to parent session)
          if (opts.path?.id === "parent-1") {
            notifiedParent = true
            notifiedNoReply = opts.body?.noReply
          }
          return {}
        },
        messages: async (opts: any) => {
          // Return assistant output for the child session
          if (opts.path?.id === sessionID) {
            return {
              data: [
                {
                  info: { role: "assistant", time: "2026-01-01T00:00:00Z" },
                  parts: [{ type: "text", text: "Task completed successfully" }],
                },
              ],
            }
          }
          // Parent session messages (for agent resolution)
          return { data: [] }
        },
        status: async () => ({ data: { [sessionID]: { type: "idle" } } }),
        abort: async () => ({}),
        todo: async () => ({ data: [] }),
      },
    })

    const manager = new BackgroundManager(client, "/tmp", {})
    const task = await manager.launch({
      description: "Integration test task",
      prompt: "Do something",
      agent: "explore",
      parentSessionID: "parent-1",
      parentMessageID: "msg-1",
    })

    // Wait for startTask to complete
    await new Promise((r) => setTimeout(r, 200))
    expect(task.status).toBe("running")
    expect(task.sessionID).toBe(sessionID)

    // Simulate session.idle event (after MIN_IDLE_TIME_MS passes)
    // Override startedAt to make it old enough
    task.startedAt = new Date(Date.now() - 10000)

    manager.handleEvent({
      type: "session.idle",
      properties: { sessionID },
    })

    // Wait for async completion + notification
    await new Promise((r) => setTimeout(r, 500))

    expect(task.status).toBe("completed")
    expect(task.completedAt).toBeDefined()
    expect(notifiedParent).toBe(true)
    // Since this is the only task for parent-1, allComplete=true, so noReply=false
    expect(notifiedNoReply).toBe(false)

    manager.shutdown()
  })

  it("polling detects idle session and completes task", async () => {
    const { BackgroundManager } = await import("./background-tasks")

    const sessionID = "poll-sess-1"

    const client = createMockClient({
      session: {
        get: async () => ({ data: { directory: "/tmp" } }),
        create: async () => ({ data: { id: sessionID } }),
        promptAsync: async () => ({}),
        messages: async (opts: any) => {
          if (opts.path?.id === sessionID) {
            return {
              data: [
                {
                  info: { role: "assistant", time: "2026-01-01T00:00:00Z" },
                  parts: [{ type: "text", text: "Done" }],
                },
              ],
            }
          }
          return { data: [] }
        },
        status: async () => ({ data: { [sessionID]: { type: "idle" } } }),
        abort: async () => ({}),
        todo: async () => ({ data: [] }),
      },
    })

    const manager = new BackgroundManager(client, "/tmp", {})
    const task = await manager.launch({
      description: "Polling test",
      prompt: "p",
      agent: "a",
      parentSessionID: "parent-2",
      parentMessageID: "m",
    })

    // Wait for task to start
    await new Promise((r) => setTimeout(r, 200))
    expect(task.sessionID).toBe(sessionID)

    // Polling runs every 3s, but we can wait for it
    // First ensure task has been running long enough
    task.startedAt = new Date(Date.now() - 10000)

    // Wait for polling cycle
    await new Promise((r) => setTimeout(r, 4000))

    expect(task.status).toBe("completed")
    manager.shutdown()
  })
})
