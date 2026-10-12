# Zsh configuration

`zsh/config.zsh` loads from a `~/.zshrc` wrapper.

## Worktree workflow

`zsh/worktree.sh` defines the shared worktree helpers and commands.

Its source block in `zsh/config.zsh` is currently disabled.

Source the file explicitly before using its commands.

`cwt` aliases `create-worktree`.

`rwt` aliases `remove-worktree`.

By default, both commands use the current Git checkout.

The default worktree root is `~/code/worktrees`.

`cwt <branch> [base-branch]` creates or reuses a worktree.

The `--base <base-branch>` option provides the same base value.

After creation, `cwt` runs `wt_post_create_hook` when that function exists.

`rwt <worktree> [<worktree>...]` removes worktrees and their matching tmux sessions.

Use `--keep-session` or `--no-kill-session` to preserve those sessions.

Both commands accept `--repo <path>` and `--root <dir>`.

Configuration precedence is explicit option, environment variable, and default.

The environment variables are `WT_REPO`, `WT_ROOT`, and `WT_BASE_BRANCH`.

`~/code/work-configs/config.zsh` sets repository-specific values for the dashboards repository.

That file also defines a hook for environment files and dependency installation.

Keep repository-specific paths outside this public repository.
