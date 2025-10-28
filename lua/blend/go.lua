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

M.get_struct_nodes = function(bufnr)
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

return M
