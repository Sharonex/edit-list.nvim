local config = require("edit-list.config")

local M = {
    opts = {
        distanceTillConsiderdSame = 25,
        maxLinesInList = 11,
    },

    EditTable = {}
}

function M.NewCursorPos()
    local BufName = vim.fn.expand("%:.")
    if BufName == "" then
        return nil
    end

    local curPos = vim.fn.getcurpos()
    local curLine = curPos[2]
    local curCol = curPos[3]
    return {
        filename = BufName,
        row = curLine,
        col  = curCol,
    }
end

function M.GetEditTable()
    local reversedTable = {}
    local itemCount = #M.get_project_history()
    for k, v in ipairs(M.get_project_history()) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

function M.appendNewCursorPos()
    if M._appendNewCursorPos() then
        config.save(M.EditTable)
    end
end

-- Returns true if a change was made. False otherwise.
function M._appendNewCursorPos()
    -- Go over all positions in table and remove all positions within 10 lines of the new position
    local curr_pos = M.NewCursorPos()
    if curr_pos == nil or next(curr_pos) == nil then
        return false
    end

    proj_hist = M.get_project_history()

    if #proj_hist == 0 then
        table.insert(proj_hist, curr_pos)
        return true
    end

    local to_delete = {}
    for i, pos in ipairs(proj_hist) do
        if i > M.opts.maxLinesInList or curr_pos == nil or pos.filename == curr_pos.filename and
                math.abs(pos.row - curr_pos.row) < M.opts.distanceTillConsiderdSame then
            table.insert(to_delete,i)
            end
    end

    for _, index in ipairs(to_delete) do
        table.remove(proj_hist, index)
    end

    table.insert(proj_hist, curr_pos)
    return true
end

function M.CallEditList()
    require("edit-list.ui").EditListTelescope(M.GetEditTable, M.opts)
end

function M.get_project_history()
    return config.get_project_history(M.EditTable).edits
end

function M.setup(opts)
    M.opts = vim.tbl_extend("force", M.opts, opts or {})

    M.EditTable = require("edit-list.config").read_config()

    require("telescope").load_extension("edit-list")
    vim.api.nvim_create_user_command('EditList', "lua require(\"edit-list\").CallEditList()", {})
    vim.api.nvim_create_autocmd({"TextChangedI", "TextChanged"}, {
        pattern = {"*.*"},
        callback = M.appendNewCursorPos
    })
end

return M
