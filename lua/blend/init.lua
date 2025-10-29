local go = require("blend.go")
local utils = require("blend.utils")
local M = {}

function M.setup(setup_opts)
	utils.create_user_cmd("GoAddStructTag", function(opts)
		if not utils.is_go_file() then
			vim.notify("not a go file", vim.log.levels.ERROR)
			return
		end

		local struct = go.get_struct_at_cursor()

		if not struct then
			vim.notify("struct not found", vim.log.levels.DEBUG)
			return
		end

		go.add_tags(unpack(opts.fargs))
	end, { nargs = "*", desc = "Add Go struct tags" }, "<leader>tag", setup_opts)

	utils.create_user_cmd("GoRemoveStructTag", function(opts)
		if not utils.is_go_file() then
			vim.notify("not a go file", vim.log.levels.ERROR)
			return
		end

		local struct = go.get_struct_at_cursor()

		if not struct then
			vim.notify("struct not found", vim.log.levels.DEBUG)
			return
		end

		go.remove_tags(unpack(opts.fargs))
	end, { nargs = "*", desc = "Remove Go struct tags" }, "<leader>tar", setup_opts)
end

return M
