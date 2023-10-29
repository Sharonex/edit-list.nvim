M = {}

M.jumps = function ()
	local jumplist = vim.fn.getjumplist()
	if #jumplist == 0 then
		return
	end
end
M.jumps()
