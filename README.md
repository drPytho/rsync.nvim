# rsync.nvim

Asynchronously transfer your files with `rsync` on save.

## Dependencies

- rsync

## Installation

```lua
-- packer.nvim
use {
    'drPytho/rsync.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    config = function()
        require("rsync").setup({})
    end
}
-- lazy.nvim
{
    'drPytho/rsync.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
        require("rsync").setup({})
    end,
}
```

## Usage

**rsync.nvim** looks for `.rsync.toml` file by default in the root of your
project. The path can also be set with the `project_config_path` key in the
plugin configuration.

The current options available:

```toml
# this is the path to the remote. Can be either a local/remote filepath.
remote_path = "user@host:/home/user/path/" # Or a local path like `../copy`

# specifying a file(s) which should be synced "down" but are on ignore files.
# this is a workaround to sync down files which are included on ignore files.
# **WARNING** ALL OTHER FILES IN THE REMOTE WILL BE DELETED!!
remote_includes = ["build.log", "build/generated.json"]

# specifying an gitignore file(s). Files matching patterns in ignore files are
# excluded from "SyncUp" and "SyncDown" except ones specified in `remote_includes`.
# For example, to exclude file(s) in the global gitignore and the project gitignore:
ignorefile_paths = ["~/.gitignore", ".gitignore"]
```

## Commands

| Name               | Action                                                                                    |
| ------------------ | ----------------------------------------------------------------------------------------- |
| RsyncDown          | Sync all files from remote\* to local folder.                                             |
| RsyncDownFile      | Sync specified or current file from remote to local folder.                               |
| RsyncUp            | Sync all files from local\* to remote folder.                                             |
| RsyncUpFile        | Sync specified or current file from local to remote. This requires rsync version >= 3.2.3 |
| RsyncLog           | Open log file for rsync.nvim.                                                             |
| RsyncConfig        | Print out user config.                                                                    |
| RsyncProjectConfig | Print or reload current project config.                                                   |
| RsyncSaveSync      | Temporarily disable/enable/toggle sync when saving.                                       |

\*: Files which are excluded are, everything in .gitignore and .nvim folder.

## Configuration

Global configuration settings with the default values

```lua
---@type RsyncConfig
{
    -- triggers `RsyncUp` when fugitive thinks something might have changed in the repo.
    fugitive_sync = false,
    -- triggers `RsyncUp` when you save a file.
    sync_on_save = true,
    -- the path to the project configuration
    project_config_path = ".nvim/rsync.toml",
    -- called when the rsync command exits, provides the exit code and the used command
    on_exit = function(code, command)
    end,
    -- called when the rsync command prints to stderr, provides the data and the used command
    on_stderr = function(data, command)
    end,
}
```

## Similar projects

- [coffebar/transfer.nvim](https://github.com/coffebar/transfer.nvim)
- [KenN7/vim-arsync](https://github.com/KenN7/vim-arsync)
