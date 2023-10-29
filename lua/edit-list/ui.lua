local entry_display = require("telescope.pickers.entry_display")
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local M = {}

local generate_new_finder = function(edit_list)
    if edit_list == nil then
        return nil
    end
    return finders.new_table({
        results = edit_list,
        entry_maker = function(entry)
            local line = entry.filename .. ":" .. entry.row .. ":" .. entry.col
            local displayer = entry_display.create({
                separator = " - ",
                items = {
                    { width = 2 },
                    { width = 50 },
                    { remaining = true },
                },
            })
            local make_display = function()
                local index_str = type(entry.index) == "number" and tostring(entry.index) or ""
                return displayer({
                    index_str,
                    line,
                })
            end
            return {
                value = entry,
                ordinal = line,
                display = make_display,
                lnum = entry.row,
                col = entry.col,
                filename = entry.filename,
            }
        end,
    })
end

-- our picker function: jumBumTelescope
function M.EditListTelescope(editListCallback, opts)
    opts = opts or {}
    local editList = editListCallback()
    if editList == nil or not next(editList) then
        return
    end

    pickers.new(opts, {
        prompt_title = "EditList",
        finder = generate_new_finder(editList),
        sorter = conf.generic_sorter(opts),
        previewer = conf.grep_previewer(opts),
    }):find()
end

return M
