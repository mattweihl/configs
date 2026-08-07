#!/usr/bin/env bash

# Syncs skill directories from their canonical source roots into every editor's
# skills directory (Cursor, Claude Code), so a new skill only needs to be added
# once and this re-run to pick it up everywhere.
#
# Source roots: ~/configs/skills (public/personal) and ~/code/work-configs/skills
# (work-specific, may not exist on every machine). Target dirs: ~/.cursor/skills
# and ~/.claude/skills.

LINK_SKILLS_SOURCES=(
  "$HOME/configs/skills"
  "$HOME/code/work-configs/skills"
)

LINK_SKILLS_TARGETS=(
  "$HOME/.cursor/skills"
  "$HOME/.claude/skills"
)

link-skills() {
  local source_root target_root skill_dir skill_name target_path linked=0

  for source_root in "${LINK_SKILLS_SOURCES[@]}"; do
    [[ -d "$source_root" ]] || continue

    for skill_dir in "$source_root"/*/; do
      [[ -d "$skill_dir" ]] || continue
      skill_name="$(basename "$skill_dir")"

      for target_root in "${LINK_SKILLS_TARGETS[@]}"; do
        mkdir -p "$target_root"
        target_path="$target_root/$skill_name"

        if [[ -L "$target_path" ]]; then
          [[ "$(readlink "$target_path")" == "${skill_dir%/}" ]] && continue
          rm "$target_path"
        elif [[ -e "$target_path" ]]; then
          echo "link-skills: skipping $target_path (exists and is not a symlink)" >&2
          continue
        fi

        ln -s "${skill_dir%/}" "$target_path"
        echo "linked $skill_name -> $target_root"
        ((linked++))
      done
    done
  done

  ((linked == 0)) && echo "link-skills: nothing new to link"
  return 0
}
