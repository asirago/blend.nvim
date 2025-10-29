local M = {}

local map = vim.keymap.set

function M.create_user_cmd(name, rhs, cmd_opts, keymap, opts)
	vim.api.nvim_create_user_command(name, rhs, cmd_opts)

	if not opts.disable_default then
		map("n", keymap, "<cmd>" .. name .. "<cr>", { desc = cmd_opts.desc })
	end
end

function M.is_go_file()
	local ft = vim.api.nvim_get_option_value("ft", { buf = 0 })

	if ft ~= "go" then
		vim.notify("not a go file", vim.log.levels.ERROR, { title = "GoAddStructTag" })
		return false
	end

	return true
end

return M
