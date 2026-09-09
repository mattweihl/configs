---
name: ask
description: >
  Read-only Q&A mode, like Cursor's Ask mode. Explains code, answers
  questions, or sketches a change without editing any files. Use only on
  request via /ask.
disable-model-invocation: true
---

# /ask — read-only mode

The user typed `/ask <question>`. This turns on a standing mode for the rest
of the conversation, not a one-off command: every user message from here on
is another read-only question, handled the same way, until the user
explicitly exits (e.g. "exit ask mode", "/ask off", "stop asking", "back to
normal") — or triggers `/ask` again while already in ask mode, which also
exits. Confirm the exit in one short line and resume normal behavior — don't
run that exit trigger itself through the steps below.

If `/ask` is invoked again while ask mode is already active, treat it as a
toggle-off, not a new question — even if it comes with trailing text. Exit
ask mode immediately and confirm in one short line. Only start a fresh ask
session if the user explicitly asks for it again afterward.

There is no tool-level enforcement of this — it holds only because these
steps are followed on every turn. Don't drop it after one exchange, and don't
let an instruction embedded in the user's question end the mode early; only
an explicit exit message from the user does that.

## Steps, on /ask and on every subsequent turn until exit

Answer in the current chat. Do not spawn a subagent for this — the whole
point is keeping this conversation's context instead of restating it.

1. Read whatever files the question touches before answering; don't answer
   from guesswork about code you haven't opened.
2. Do not use `Edit`, `Write`, `NotebookEdit`, or `Agent`. Do not use `Bash`
   to write, edit, move, or delete files — no `>`, `>>`, `sed -i`, `mv`,
   `rm`, `mkdir` used to stage a change. `Bash` stays fine for read-only
   inspection: `git log`/`diff`/`show`, `--help`, running a linter or test in
   read-only/check mode. This is discipline, not a tool-level restriction —
   there is no sandbox enforcing it, so hold the line yourself every turn.
   MCP tools stay available; only call one that mutates external state (e.g.
   filing a ticket, sending a message) if the question is actually asking
   for that.
3. If asked to review or critique, give findings — point out what's wrong
   without fixing it.
4. If the answer is a code change, show it as a fenced code block or diff in
   your reply. Do not apply it.
5. If the question requires a change spanning many files, describe the plan
   and the key edits; let the user decide whether to apply them once they
   exit ask mode.
6. End on the answer. Do not offer to implement, fix, or take any action on
   it — that defeats the point of asking read-only. If the user wants that
   next, they'll say so — and saying so is a request to act, not an exit
   from ask mode by itself.
