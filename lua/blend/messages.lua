local M = {}

local state = {
	quake = {
		buf = -1,
		win = -1,
	},
	prev_win = -1,
}

local function create_quake_window(opts)
	opts = opts or {}

	local buf
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf, "Messages")
	end

	state.prev_win = vim.api.nvim_get_current_win()

	vim.cmd("botright split")

	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)

	-- TODO: Set to own function and extend to options
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.signcolumn = "no"
	vim.wo.cursorline = false
	vim.wo.foldcolumn = "0"
	vim.cmd("setlocal laststatus=0")

	vim.wo.scrolloff = 0

	-- TODO: set height dynamically based on messages length
	vim.api.nvim_win_set_height(win, 15)

	local messages = vim.api.nvim_exec2("messages", { output = true })

	local msg_formatted = vim.split(messages.output, "\n")

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, msg_formatted)

	for _, key in ipairs({ "q", "<CR>" }) do
		vim.api.nvim_buf_set_keymap(buf, "n", key, "", {
			nowait = true,
			callback = function()
				vim.api.nvim_win_close(win, true)
			end,
		})
	end

	vim.api.nvim_create_autocmd("WinClosed", {
		buffer = buf,
		callback = function()
			vim.cmd("setlocal laststatus=2")
		end,
	})

	vim.api.nvim_set_current_win(state.prev_win)

	return { buf = buf, win = win }
end

function M.toggle_terminal()
	if not vim.api.nvim_win_is_valid(state.quake.win) then
		state.quake = create_quake_window({ buf = state.quake.buf })
	else
		vim.api.nvim_win_hide(state.quake.win)
		vim.api.nvim_set_current_win(state.prev_win)
	end
end

return M
