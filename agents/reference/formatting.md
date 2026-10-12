# Formatter configuration

Read this file before adding or changing an agent formatter or Neovim formatter.

Keep these formatter lists synchronized:

- `nvim/lua/plugins/format.lua`
- `agents/hooks/format-edits.sh`

Keep each binary name and argument list identical.

Verify that each formatter binary resolves before adding it.

Conform uses the `sql-formatter` binary for `sql_formatter`.

Prettier and Ruff run only when the project contains matching configuration.

Terraform has no configuration gate.

Terraform formatting uses standard input with `terraform fmt -no-color -`.

`terraform fmt <file>` treats the positional argument as a directory.

Run the formatter against realistic input before documenting its behavior.
