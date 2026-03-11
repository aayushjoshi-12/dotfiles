local M = {}

local markers = {
	".git",
	"package.json",
	"pyproject.toml",
	"Cargo.toml",
	"go.mod",
	"Makefile",
}

function M.get()
	local bufname = vim.api.nvim_buf_get_name(0)

	if bufname == "" then
		return vim.loop.cwd()
	end

	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients > 0 then
		local root = clients[1].config.root_dir
		if root then
			return root
		end
	end

	local path = vim.fs.dirname(bufname)

	local found = vim.fs.find(markers, {
		upward = true,
		path = path,
	})[1]

	if found then
		return vim.fs.dirname(found)
	end

	return vim.loop.cwd()
end

return M
