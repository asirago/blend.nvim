local M = {}

local map = vim.keymap.set

-- map("n", "<leader>tag", "<cmd>GoAddStructTag<cr>", { desc = "Adds struct tags to go structs [blend]" })

function M.create_user_cmd(name, rhs, cmd_opts, keymap, opts)
	vim.api.nvim_create_user_command(name, rhs, cmd_opts)

	if not opts.disable_default_keymaps then
		map("n", keymap, "<cmd>" .. name .. "<cr>", { desc = cmd_opts.desc })
	end
end

return M
