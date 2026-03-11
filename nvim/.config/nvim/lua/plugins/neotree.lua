return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",

	cmd = "Neotree",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},

	keys = {
		{
			"<leader>fe",
			function()
				require("neo-tree.command").execute({
					toggle = true,
					dir = require("utils.root").get(),
				})
			end,
			desc = "Explorer NeoTree (Project Root)",
		},

		{
			"<leader>fE",
			function()
				require("neo-tree.command").execute({
					toggle = true,
					dir = vim.loop.cwd(),
				})
			end,
			desc = "Explorer NeoTree (cwd)",
		},

		{ "<leader>e", "<leader>fe", remap = true },
		{ "<leader>E", "<leader>fE", remap = true },

		{
			"<leader>ge",
			function()
				require("neo-tree.command").execute({
					source = "git_status",
					toggle = true,
				})
			end,
			desc = "Git Explorer",
		},

		{
			"<leader>be",
			function()
				require("neo-tree.command").execute({
					source = "buffers",
					toggle = true,
				})
			end,
			desc = "Buffer Explorer",
		},
	},

	deactivate = function()
		vim.cmd("Neotree close")
	end,

	init = function()
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
			desc = "Start Neo-tree when opening a directory",
			once = true,
			callback = function()
				if package.loaded["neo-tree"] then
					return
				end

				local stats = vim.loop.fs_stat(vim.fn.argv(0))

				if stats and stats.type == "directory" then
					require("neo-tree")
				end
			end,
		})
	end,

	opts = {
		sources = { "filesystem", "buffers", "git_status" },

		open_files_do_not_replace_types = {
			"terminal",
			"Trouble",
			"qf",
			"Outline",
		},

		filesystem = {
			bind_to_cwd = false,
			follow_current_file = { enabled = true },
			use_libuv_file_watcher = true,
		},

		window = {
			mappings = {
				["l"] = "open",
				["h"] = "close_node",
				["<space>"] = "none",

				["Y"] = {
					function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						vim.fn.setreg("+", path, "c")
					end,
					desc = "Copy Path to Clipboard",
				},

				["O"] = {
					function(state)
						local path = state.tree:get_node().path
						vim.fn.jobstart({ "xdg-open", path }, { detach = true })
					end,
					desc = "Open with System Application",
				},

				["P"] = {
					"toggle_preview",
					config = { use_float = false },
				},
			},
		},

		default_component_configs = {
			indent = {
				with_expanders = true,
				expander_collapsed = "",
				expander_expanded = "",
				expander_highlight = "NeoTreeExpander",
			},

			git_status = {
				symbols = {
					unstaged = "󰄱",
					staged = "󰱒",
				},
			},
		},
	},

	config = function(_, opts)
		require("neo-tree").setup(opts)

		vim.api.nvim_create_autocmd("TermClose", {
			pattern = "*lazygit",
			callback = function()
				local ok, git_status = pcall(require, "neo-tree.sources.git_status")
				if ok then
					git_status.refresh()
				end
			end,
		})
	end,
}
