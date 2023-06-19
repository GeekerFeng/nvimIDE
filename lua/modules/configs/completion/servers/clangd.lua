local util = require ("lspconfig.util")
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

local function get_binary_path(binary)
	local path = nil
	if global.is_mac or global.is_linux then
		path = vim.fn.trim(vim.fn.system("which " .. binary))
	elseif global.is_windows then
		path = vim.fn.trim(vim.fn.system("where " .. binary))
	end
	if vim.v.shell_error ~= 0 then
		path = nil
	end
	return path
end

local function get_binary_path_list(binaries)
	local path_list = {}
	for _, binary in ipairs(binaries) do
		local path = get_binary_path(binary)
		if path then
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
			"--query-driver=" .. get_binary_path_list({ "clang++", "clang", "gcc", "g++"
		            , "/opt/tools/cgtools/ti-cgt-arm_20.2.0.LTS/bin/armcl"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/ti-cgt-armllvm_1.3.0.LTS/bin/tiarmclang"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/ti-cgt-c7000_3.0.0.STS/bin/cl7x"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/ti-cgt-armllvm_1.3.0.LTS/bin/tiarmasm"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/../libexec/gcc/aarch64-none-linux-gnu/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-gcc"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-g++"
		            , "/opt/tools/cgtools/ti-cgt-armllvm_1.3.0.LTS/bin/tiarmclang"
		            , "/opt/tools/cgtools/ti-cgt-armllvm_1.3.0.LTS/bin/tiarmasm"
		            , "/opt/tools/cgtools/ti-cgt-c7000_1.1.0/bin/cl7x"
		            , "/opt/tools/cgtools/ti-cgt-c7000_3.0.0.STS/bin/cl7x"
		            , "/opt/tools/cgtools/ti-cgt-c7000_1.4.2.LTS/bin/cl7x"
		            , "/opt/tools/cgtools/ti-cgt-c7000_1.0.0/bin/cl7x"
		            , "/opt/tools/cgtools/ti-cgt-c7000_1.2.0.STS/bin/cl7x"
		            , "/opt/tools/cgtools/ti-cgt-c7000_1.4.0.LTS/bin/cl7x"
		            , "/opt/tools/cgtools/ti-cgt-c6000_8.3.2/bin/cl6x"
		            , "/opt/tools/cgtools/ti-cgt-c6000_8.2.4/bin/cl6x"
		            , "/opt/tools/cgtools/ti-cgt-c6000_8.3.7/bin/cl6x"
		            , "/opt/poky/2.4.3/sysroots/x86_64-pokysdk-linux/usr/libexec/aarch64-poky-linux/gcc/aarch64-poky-linux/7.3.0/cc1"
		            , "/opt/poky/gcc-linaro-6.5.0-2018.12-x86_64_arm-linux-gnueabihf/libexec/gcc/arm-linux-gnueabihf/6.5.0/cc1"
		            , "/opt/qnx700/host/linux/x86_64/usr/lib/gcc/arm-unknown-nto-qnx7.0.0eabi/5.4.0/cc1"
		            , "/opt/qnx700/host/linux/x86_64/usr/lib/gcc/i586-pc-nto-qnx7.0.0/5.4.0/cc1"
		            , "/opt/qnx700/host/linux/x86_64/usr/lib/gcc/x86_64-pc-nto-qnx7.0.0/5.4.0/cc1"
		            , "/opt/qnx700/host/linux/x86_64/usr/lib/gcc/aarch64-unknown-nto-qnx7.0.0/5.4.0/cc1"
		            , "/opt/MXE/mxe-master/usr/libexec/gcc/i686-w64-mingw32.static/5.5.0/cc1"
		            , "/opt/MXE/mxe-master/usr/libexec/gcc/x86_64-w64-mingw32.static/5.5.0/cc1"
		            , "/opt/tools/mxe/libexec/gcc/i686-w64-mingw32.static/5.5.0/cc1"
		            , "/opt/tools/mxe/libexec/gcc/x86_64-w64-mingw32.static/5.5.0/cc1"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_j721e_0804/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/aarch64-none-linux-gnu/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_j721e_0804/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/arm-none-linux-gnueabihf/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_j721e_0703/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/aarch64-none-linux-gnu/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_j721e_0703/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/arm-none-linux-gnueabihf/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_0703/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/aarch64-none-linux-gnu/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_0703/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/arm-none-linux-gnueabihf/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/arm-linux-gnueabihf/8.3.0/cc1"
		            , "/opt/tools/rootfs/TDA4/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/aarch64-linux-gnu/8.3.0/cc1"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/libexec/gcc/aarch64-none-linux-gnu/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/libexec/gcc/aarch64-none-elf/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/libexec/gcc/arm-none-linux-gnueabihf/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4VH/linux_sdk_j784s4_0802/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/aarch64-none-linux-gnu/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4VH/linux_sdk_j784s4_0802/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/arm-none-linux-gnueabihf/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4VH/linux_sdk_j784s4_0805/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/aarch64-none-linux-gnu/9.2.1/cc1"
		            , "/opt/tools/rootfs/TDA4VH/linux_sdk_j784s4_0805/linux-devkit/sysroots/x86_64-arago-linux/usr/libexec/gcc/arm-none-linux-gnueabihf/9.2.1/cc1"
		            , "/opt/tools/cgtools/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu/libexec/gcc/aarch64-linux-gnu/8.3.0/cc1"
		            , "/opt/tools/cgtools/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-elf/libexec/gcc/aarch64-elf/7.2.1/cc1"
		            , "/opt/tools/cgtools/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/libexec/gcc/aarch64-linux-gnu/7.2.1/cc1"
		            , "/opt/tools/cgtools/gcc-linaro-6.5.0-2018.12-x86_64_aarch64-linux-gnu/libexec/gcc/aarch64-linux-gnu/6.5.0/cc1"
		            , "/opt/tools/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/libexec/gcc/aarch64-none-linux-gnu/9.2.1/cc1"
		            , "/opt/tools/cgtools/gcc-4.6.4/libexec/gcc/arm-arm1176jzfssf-linux-gnueabi/4.6.4/cc1"
		            , "/opt/tools/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/libexec/gcc/aarch64-none-elf/9.2.1/cc1"
		            , "/opt/tools/cgtools/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/libexec/gcc/arm-none-linux-gnueabihf/9.2.1/cc1"
		            , "/opt/tools/cgtools/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf/libexec/gcc/arm-linux-gnueabihf/8.3.0/cc1"
		            , "/opt/tools/cgtools/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/libexec/gcc/arm-linux-gnueabihf/7.2.1/cc1"
		            , "/opt/qnx710/host/linux/x86_64/usr/lib/gcc/arm-unknown-nto-qnx7.1.0eabi/8.3.0/cc1"
		            , "/opt/qnx710/host/linux/x86_64/usr/lib/gcc/x86_64-pc-nto-qnx7.1.0/8.3.0/cc1"
		            , "/opt/qnx710/host/linux/x86_64/usr/lib/gcc/aarch64-unknown-nto-qnx7.1.0/8.3.0/cc1"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_j721e_0804/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-gcc"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_j721e_0703/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-gcc"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_0703/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-gcc"
		            , "/opt/tools/rootfs/TDA4/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-linux-gnu-gcc"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-gcc"
		            , "/opt/tools/rootfs/TDA4VH/linux_sdk_j784s4_0802/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-gcc"
		            , "/opt/tools/rootfs/TDA4VH/linux_sdk_j784s4_0805/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-gcc"
		            , "/opt/tools/cgtools/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc"
		            , "/opt/tools/cgtools/aarch64-linux-gnu-gcc"
		            , "/opt/tools/cgtools/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc"
		            , "/opt/tools/cgtools/gcc-linaro-6.5.0-2018.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-gcc"
		            , "/opt/tools/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-gcc"
		            , "/opt/tools/mxe/i686-w64-mingw32.static/qt5/mkspecs/linux-aarch64-gnu-g++"
		            , "/opt/tools/mxe/x86_64-w64-mingw32.static/qt5/mkspecs/linux-aarch64-gnu-g++"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_j721e_0804/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-g++"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_j721e_0703/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-g++"
		            , "/opt/tools/rootfs/TDA4/linux_sdk_0703/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-g++"
		            , "/opt/tools/rootfs/TDA4/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-linux-gnu-g++"
		            , "/opt/tools/rootfs/TDA4VH/rtos_sdk_j784s4_0802/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-g++"
		            , "/opt/tools/rootfs/TDA4VH/linux_sdk_j784s4_0802/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-g++"
		            , "/opt/tools/rootfs/TDA4VH/linux_sdk_j784s4_0805/linux-devkit/sysroots/x86_64-arago-linux/usr/bin/aarch64-none-linux-gnu-g++"
		            , "/opt/tools/cgtools/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu/bin/aarch64-linux-gnu-g++"
		            , "/opt/tools/cgtools/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-g++"
		            , "/opt/tools/cgtools/gcc-linaro-6.5.0-2018.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-g++"
		            , "/opt/tools/cgtools/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-g++"
		            , "/opt/tools/cgtools/ti-cgt-arm_18.12.1.LTS/bin/armcl"
		            , "/opt/tools/cgtools/ti-cgt-arm_16.9.9.LTS/bin/armcl"
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
                '.root',
            }
            return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
        end,

    --},
	})
end
