local M = {}

local rsync_nvim = vim.api.nvim_create_augroup("rsync_nvim", { clear = true })

local config = require("rsync.config")
local project = require("rsync.project")

local sync = function(command)
    vim.b.rsync_status = nil

    local res = vim.fn.jobstart(command, {
        on_stderr = function(_, output, _)
            -- skip when function reports no error
            if vim.inspect(output) ~= vim.inspect({ "" }) then
                -- TODO print save output to temporary log file
                vim.api.nvim_err_writeln("Error executing: " .. command)
            end
        end,

        -- job done executing
        on_exit = function(_, code, _)
            vim.b.rsync_status = code
            if code ~= 0 then
                vim.api.nvim_err_writeln("rsync execute with result code: " .. code)
            end
        end,
        stdout_buffered = true,
        stderr_buffered = true,
    })

    if res == -1 then
        error("Could not execute rsync. Make sure that rsync in on your path")
    elseif res == 0 then
        print("Invalid command: " .. command)
    end
end

local sync_project = function(source_path, destination_path)
    local command = "rsync -varz -f':- .gitignore' -f'- .nvim' " .. source_path .. " " .. destination_path
    sync(command)
end

local sync_remote = function(source_path, destination_path, include_extra)
    local filters = ""
    if type(include_extra) == "table" then
        local filter_template = "-f'+ %s' "
        for _, value in pairs(include_extra) do
            filters = filters .. filter_template:format(value)
        end
    elseif type(include_extra) == "string" then
        filters = "-f'+ " .. include_extra .. "' "
    end
    local command = "rsync -varz "
        .. filters
        .. "-f':- .gitignore' -f'- .nvim' "
        .. source_path
        .. " "
        .. destination_path
    sync(command)
end

vim.api.nvim_create_autocmd({ "BufEnter" }, {
    callback = function()
        -- only initialize once per buffer
        if vim.b.rsync_init == nil then
            -- get config as table if present
            local config_table = project.get_config_table()
            if config_table == nil then
                return
            end
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    sync_project(config_table["project_path"], config_table["remote_path"])
                end,
                group = rsync_nvim,
                buffer = vim.api.nvim_get_current_buf(),
            })
            vim.b.rsync_init = 1
        end
    end,
    group = rsync_nvim,
})

-- sync all files from remote
vim.api.nvim_create_user_command("RsyncDown", function()
    local config_table = config.get_project()
    if config_table ~= nil then
        sync_remote(config_table["remote_path"], config_table["project_path"], config_table["remote_includes"])
    else
        vim.api.nvim_err_writeln("Could not find rsync.toml")
    end
end, {})

-- sync all files to remote
vim.api.nvim_create_user_command("RsyncUp", function()
    local config_table = config.get_project()
    if config_table ~= nil then
        sync_project(config_table["project_path"], config_table["remote_path"])
    else
        vim.api.nvim_err_writeln("Could not find rsync.toml")
    end
end, {})

-- Return status of syncing
M.status = function()
    if vim.b.rsync_status == nil then
        return "Syncing files"
    elseif vim.b.rsync_status ~= 0 then
        return "Failed to sync"
    else
        return "Up to date"
    end
end

M.setup = function(user_config)
    require("rsync.config").set_defaults(user_config)
end

return M
