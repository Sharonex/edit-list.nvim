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
    local itemCount = #M.EditTable
    for k, v in ipairs(M.EditTable) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

function M.appendNewCursorPos()
    -- Go over all positions in table and remove all positions within 10 lines of the new position
    local curr_pos = M.NewCursorPos()
    if curr_pos == nil or next(curr_pos) == nil then
        return
    end

    if #M.EditTable == 0 then
        table.insert(M.EditTable, curr_pos)
        return
    end

    local to_delete = {}
    for i, pos in ipairs(M.EditTable) do
        if i > M.opts.maxLinesInList or curr_pos == nil or pos.filename == curr_pos.filename and
                math.abs(pos.row - curr_pos.row) < M.opts.distanceTillConsiderdSame then
            table.insert(to_delete,i)
            end
    end

    for _, index in ipairs(to_delete) do
        table.remove(M.EditTable, index)
    end

    table.insert(M.EditTable, curr_pos)
end

function M.setup(opts)
    M.opts = vim.tbl_extend("force", M.opts, opts or {})

    vim.api.nvim_create_user_command('EditList', "lua local mod=require(\"edit-list\"); require(\"edit-list.ui\").EditListTelescope(mod.GetEditTable, mod.opts)", {})
    vim.api.nvim_create_autocmd({"TextChangedI", "TextChanged"}, {
        pattern = {"*.*"},
        callback = M.appendNewCursorPos
    })

end

return M
