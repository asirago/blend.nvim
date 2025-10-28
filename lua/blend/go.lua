local ts = vim.treesitter
local api = vim.api

local M = {}

local query_string = [[
    (type_declaration
        (type_spec
            name:(type_identifier) @struct.name type: (struct_type)
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
			if capture_id == "struct.name" then
				n.name = ts.get_node_text(node, 0)
			elseif capture_id == "struct.declaration" then
				n.node = node
			end
			if n.name and n.node then
				table.insert(ns, n)
			end
		end
	end

	return ns
end

-- TODO: Handle nested structs
function M.get_struct_at_cursor(bufnr)
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	local bufn = bufnr or api.nvim_get_current_buf()

	local structs = M.get_struct_nodes(bufn)

	for _, struct in ipairs(structs) do
		local sRow, _, eRow = struct.node:range()

		-- row from cursor is 1-based indexed
		if M.struct_in_range(row - 1, sRow, eRow) then
			return struct
		end
	end
	return nil
end

return M
