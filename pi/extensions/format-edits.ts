import { unlink } from "node:fs/promises";
import { homedir } from "node:os";
import { resolve } from "node:path";

interface ExtensionContext {
  cwd: string;
}

interface SessionStartEvent {
  reason: "startup" | "reload" | "new" | "resume" | "fork";
}

interface ToolResultEvent {
  input: Record<string, unknown>;
  isError: boolean;
  toolName: string;
}

interface PiExtensionApi {
  exec(command: string, args: string[]): Promise<unknown>;
  on(
    event: "session_start",
    handler: (
      event: SessionStartEvent,
      context: ExtensionContext,
    ) => Promise<void>,
  ): void;
  on(
    event: "tool_result",
    handler: (
      event: ToolResultEvent,
      context: ExtensionContext,
    ) => Promise<void>,
  ): void;
}

const configsRoot = process.env.CONFIGS_ROOT ?? resolve(homedir(), "configs");
const formatHook = resolve(configsRoot, "agents/hooks/format-edits.sh");

export default function formatEdits(pi: PiExtensionApi) {
  pi.on("session_start", async (event) => {
    const pane = process.env.TMUX_PANE;
    const startsNewHistory = event.reason === "startup" || event.reason === "new";
    if (!startsNewHistory || !pane) return;

    const editList = resolve(homedir(), ".cache/agent-edits", pane);
    await unlink(editList).catch(() => undefined);
  });

  pi.on("tool_result", async (event, context) => {
    if (event.isError) return;
    if (event.toolName !== "edit" && event.toolName !== "write") return;

    const path = event.input.path;
    if (typeof path !== "string" || path.length === 0) return;

    await pi.exec("sh", [formatHook, resolve(context.cwd, path)]);
  });
}
