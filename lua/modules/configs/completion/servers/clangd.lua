local util = require("lspconfig.util")
local global = require("core.global")
local function switch_source_header_splitcmd(bufnr, splitcmd)
	bufnr = require("lspconfig").util.validate_bufnr(bufnr)
	local clangd_client = require("lspconfig").util.get_active_client_by_name(bufnr, "clangd")
	local params = { uri = vim.uri_from_bufnr(bufnr) }
	if clangd_client then
		clangd_client.request("textDocument/switchSourceHeader", params, function(err, result)
			if err then
				error(tostring(err))
			end
			if not result then
				vim.notify("Corresponding file can’t be determined", vim.log.levels.ERROR, { title = "LSP Error!" })
				return
			end
			vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
		end)
	else
		vim.notify(
			"Method textDocument/switchSourceHeader is not supported by any active server on this buffer",
			vim.log.levels.ERROR,
			{ title = "LSP Error!" }
		)
	end
end

local function get_binary_path_list(binaries)
	local path_list = {}
	for _, binary in ipairs(binaries) do
		local path = vim.fn.exepath(binary)
		if path ~= "" then
			table.insert(path_list, path)
		end
	end
	return table.concat(path_list, ",")
end

-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/clangd.lua
return function(options)
	require("lspconfig").clangd.setup({
		on_attach = options.on_attach,
		capabilities = vim.tbl_deep_extend("keep", { offsetEncoding = { "utf-16", "utf-8" } }, options.capabilities),
		single_file_support = true,
		cmd = {
			"clangd",
			"-j=12",
			"--enable-config",
			"--background-index",
			"--pch-storage=memory",
			-- You MUST set this arg ↓ to your c/cpp compiler location (if not included)!
			"--query-driver="
				.. get_binary_path_list({
					"clang++",
					"clang",
					"gcc",
					"g++",
					"aarch64-linux-gnu-gcc",
					"aarch64-linux-gnu-g++",
					"/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0806/ti-cgt-armllvm_1.3.0.LTS/bin/tiarmclang",
					"/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0806/ti-cgt-c7000_3.1.0.LTS/bin/cl7x",
					"/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0806/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-gcc",
					"/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0806/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-g++",
					"/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/ti-cgt-armllvm_1.3.0.LTS/bin/tiarmclang",
					"/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/ti-cgt-armllvm_1.3.0.LTS/bin/tiarmasm",
					"/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/ti-cgt-c7000_3.0.0.STS/bin/cl7x",
					"/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-gcc",
					"/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-g++",
				}),
			"--clang-tidy",
			"--all-scopes-completion",
			"--completion-style=detailed",
			"--header-insertion-decorators",
			"--header-insertion=iwyu",
		},
		commands = {
			ClangdSwitchSourceHeader = {
				function()
					switch_source_header_splitcmd(0, "edit")
				end,
				description = "Open source/header in current buffer",
			},
			ClangdSwitchSourceHeaderVSplit = {
				function()
					switch_source_header_splitcmd(0, "vsplit")
				end,
				description = "Open source/header in a new vsplit",
			},
			ClangdSwitchSourceHeaderSplit = {
				function()
					switch_source_header_splitcmd(0, "split")
				end,
				description = "Open source/header in a new split",
			},
		},
		--default_config = {
		-- root_dir = util.root_pattern( 'compile_commands.json'),
		root_dir = function(fname)
			local root_files = {
				".root",
			}
			return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
		end,

		--},
	})
end
