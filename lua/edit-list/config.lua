local Path = require("plenary.path")
local Dev = require("edit-list.dev")
local log = Dev.log

local cache_path = vim.fn.stdpath("cache")
local cache_config = string.format("%s/edit-list.json", cache_path)

local M = {}

--[[
{
    projects = {
        ["/path/to/director"] = {
        }
    },
    ... high level settings
}
--]]

local function get_proj_key()
    return vim.loop.cwd()
end

-- tbl_deep_extend does not work the way you would think
local function merge_table_impl(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k]) == "table" then
                merge_table_impl(t1[k], v)
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
end

local function merge_tables(...)
    log.trace("_merge_tables()")
    local out = {}
    for i = 1, select("#", ...) do
        merge_table_impl(out, select(i, ...))
    end
    return out
end

function M.save(history_list)
    -- first refresh from disk everything but our project
    local full_list = M.refresh_projects_b4update(history_list)

    log.trace("save(): Saving cache config to", cache_config)
    Path:new(cache_config):write(vim.fn.json_encode(full_list), "w")
end

local function _read_config(local_config)
    log.trace("_read_config():", local_config)
    return vim.json.decode(Path:new(local_config):read())
end

function M.read_config()
    return _read_config(cache_config)
end

function M.get_project_history(conf)
    log.trace("get_project_history()")
    return ensure_correct_config(conf).projects[get_proj_key()]
end

function ensure_correct_config(config)
    log.trace("_ensure_correct_config()")

    local projects = config.projects
    local proj_key = get_proj_key()
    if projects[proj_key] == nil then
        log.debug("ensure_correct_config(): No config found for:", proj_key)
        projects[proj_key] = {
            edits = {} ,
        }
    end

    local proj = projects[proj_key]
    if proj.edits == nil then
        log.debug("ensure_correct_config(): No edits found for", proj_key)
        proj.edits = {}
    end

    return config
end

local function expand_dir(config)
    log.trace("_expand_dir(): Config pre-expansion:", config)

    local projects = config.projects or {}
    for k in pairs(projects) do
        local expanded_path = Path.new(k):expand()
        projects[expanded_path] = projects[k]
        if expanded_path ~= k then
            projects[k] = nil
        end
    end

    log.trace("_expand_dir(): Config post-expansion:", config)
    return config
end

-- refresh all projects from disk, except our current one
function M.refresh_projects_b4update(current_p_config)
    log.trace(
        "refresh_projects_b4update(): refreshing other projects",
        cache_config
    )
    -- save current runtime version of our project config for merging back in later
    local cwd = get_proj_key()

    -- this reads a stale version of our project but up-to-date versions
    -- of all other projects
    local ok2, c_config = pcall(M.read_config, cache_config)

    if not ok2 then
        log.debug(
            "refresh_projects_b4update(): No cache config present at",
            cache_config
        )
        c_config = { projects = {} }
    end
    -- don't override non-project config in later
    c_config = { projects = c_config.projects }

    -- erase our own project, will be merged in from current_p_config later
    c_config.projects[cwd] = nil

    local complete_config = merge_tables(
        expand_dir(c_config),
        expand_dir(current_p_config)
    )

    -- There was this issue where the vim.loop.cwd() didn't have marks or term, but had
    -- an object for vim.loop.cwd()
    ensure_correct_config(complete_config)

    log.trace("refresh_projects_b4update(): log_key", Dev.get_log_key())
    return complete_config
end

return M
