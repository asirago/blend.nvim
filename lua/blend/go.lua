local ts = vim.treesitter
local api = vim.api

local M = {}

local query_string = [[
    (type_declaration
        (type_spec
            name:(type_identifier) @struct.name type: (struct_type)
        ) @struct.declaration
    )

    (field_declaration
        name:(field_identifier) @field.struct.name (struct_type)
    ) @field.struct.declaration

    (
         (composite_literal
           type: (struct_type) @anon.struct.declaration 
         )
    )

    (var_declaration
        (var_spec
            name:(identifier) @struct.name type: (struct_type)
        ) @struct.declaration
    )
]]

function M.struct_in_range(row, sRow, eRow)
	return (row >= sRow) and (row <= eRow)
end

function M.get_struct_nodes(bufnr)
	local ns = {}
	local bufn = bufnr or api.nvim_get_current_buf()
	local query = ts.query.parse("go", query_string)
	local root = ts.get_parser():parse()[1]:root()

	for _, match, _ in query:iter_matches(root, bufn, 0, -1) do
		local n = {}
		for id, node in pairs(match) do
			node = node[1]
			local capture_id = query.captures[id]
			if capture_id == "struct.name" or capture_id == "field.struct.name" then
				n.name = ts.get_node_text(node, 0)
			elseif capture_id == "struct.declaration" or capture_id == "field.struct.declaration" then
				n.node = node
			elseif capture_id == "anon.struct.declaration" then
				n.node = node
				n.name = nil
				table.insert(ns, n)
			end
			if n.name and n.node then
				table.insert(ns, n)
			end
		end
	end
	return ns
end

function M.get_struct_at_cursor(bufnr)
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local bufn = bufnr or api.nvim_get_current_buf()

	local structs = M.get_struct_nodes(bufn)
	local found

	for _, struct in ipairs(structs) do
		local sRow, _, eRow = struct.node:range()

		if M.struct_in_range(row - 1, sRow, eRow) then
			if not found then
				found = struct
			else
				local fsRow, _, feRow = found.node:range()
				if (feRow - fsRow) > (eRow - sRow) then
					found = struct
				end
			end
		end
	end

	return found
end

function M.gomodify(...)
	local fname = vim.fn.expand("%")
	local setup = { "gomodifytags", "-file", fname, "-format", "json", "-w" }

	local struct = M.get_struct_at_cursor()

	if not struct then
		vim.notify("struct not found", vim.log.levels.DEBUG)
		return
	end

	if struct.name == nil then
		local sLines, _, eLines = struct.node:range()
		table.insert(setup, "-line")
		table.insert(setup, sLines .. "," .. eLines)
	else
		table.insert(setup, "-struct")
		table.insert(setup, struct.name)
	end

	-- args {"--add-tags", "json", }
	local args = { ... }
	for _, v in ipairs(args) do
		table.insert(setup, v)
	end

	vim.fn.jobstart(setup, {
		on_stdout = function(_, data, _)
			if not data or #data < 2 then
				return
			end

			local struct_tagged = vim.fn.json_decode(data)
			if struct_tagged.errors ~= nil then
				vim.notify("failed to set tags" .. vim.inspect(struct_tagged), vim.log.levels.ERROR)
			end

			api.nvim_buf_set_lines(0, struct_tagged["start"] - 1, struct_tagged["end"], false, struct_tagged.lines)
			vim.cmd("write")
			vim.notify("struct updated", vim.log.levels.INFO)
		end,
	})
end

function M.add_tags(...)
	local cmd = { "-add-tags" }
	local args = { ... }
	if #args == 0 then
		args = { "json" }
	end

	if select(1, ...) == "-transform" then
		table.insert(cmd, "json")
	end

	vim.list_extend(cmd, args)

	M.gomodify(unpack(cmd))
end

function M.remove_tags(...)
	local cmd = { "-remove-tags" }
	local args = { ... }

	if #args == 0 then
		args = { "json" }
	end

	vim.list_extend(cmd, args)

	M.gomodify(unpack(cmd))
end

return M
