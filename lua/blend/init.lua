local go = require("blend.go")
local utils = require("blend.utils")
local msg = require("blend.messages")
local M = {}

function M.setup(setup_opts)
	utils.create_user_cmd("GoAddStructTag", function(opts)
		if not utils.is_go_file() then
			vim.notify("not a go file", vim.log.levels.ERROR)
			return
		end

		go.add_tags(unpack(opts.fargs))
	end, { nargs = "*", desc = "Add Go struct tags" }, "<leader>tag", setup_opts)

	utils.create_user_cmd("GoRemoveStructTag", function(opts)
		if not utils.is_go_file() then
			vim.notify("not a go file", vim.log.levels.ERROR)
			return
		end

		go.remove_tags(unpack(opts.fargs))
	end, { nargs = "*", desc = "Remove Go struct tags" }, "<leader>tar", setup_opts)

	utils.create_user_cmd("Messages", msg.toggle_terminal, { desc = "messages window " }, "<leader>me", setup_opts)
end

return M
