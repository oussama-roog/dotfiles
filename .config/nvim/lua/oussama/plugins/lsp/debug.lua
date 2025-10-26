return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
	},
	config = function()
		local dap = require("dap")
		local ui = require("dapui")
		local dap_virtual_text = require("nvim-dap-virtual-text")

		dap_virtual_text.setup()

		dap.adapters.cppdbg = {
			id = "cppdbg",
			type = "executable",
			command = "gdb",
			name = "cppdbg",
		}

		dap.configurations = {
			c = {
				{
					name = "Launch file",
					type = "cppdbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtEntry = false,
					MIMode = "gdb",
					miDebuggerPath = "gdb",
					setupCommands = {
						{
							description = "Enable pretty-printing for gdb",
							text = "-enable-pretty-printing",
							ignoreFailures = true,
						},
					},
				},
				{
					name = "Attach to gdbserver :1234",
					type = "cppdbg",
					request = "launch",
					MIMode = "gdb",
					miDebuggerServerAddress = "localhost:1234",
					miDebuggerPath = "gdb",
					cwd = "${workspaceFolder}",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
				},
			},
		}

		ui.setup({
			layouts = {
				{
					elements = {
						{
							id = "scopes",
							size = 0.35,
						},
						{
							id = "breakpoints",
							size = 0.25,
						},
						{
							id = "stacks",
							size = 0.25,
						},
						{
							id = "watches",
							size = 0.15,
						},
					},
					position = "left",
					size = 40,
				},
				{
					elements = {
						{
							id = "repl",
							size = 0.5,
						},
						{
							id = "console",
							size = 0.5,
						},
					},
					position = "bottom",
					size = 10,
				},
			},
		})

		vim.api.nvim_set_hl(0, "DapBreak", { fg = "#e51400" })
		vim.api.nvim_set_hl(0, "DapStop", { fg = "#ffcc00" })
		local breakpoint_icons = vim.g.have_nerd_font
				and {
					Breakpoint = "",
					BreakpointCondition = "",
					BreakpointRejected = "",
					LogPoint = "",
					Stopped = "",
				}
			or {
				Breakpoint = "●",
				BreakpointCondition = "⊜",
				BreakpointRejected = "⊘",
				LogPoint = "◆",
				Stopped = "⭔",
			}
		for type, icon in pairs(breakpoint_icons) do
			local tp = "Dap" .. type
			local hl = (type == "Stopped") and "DapStop" or "DapBreak"
			vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
		end

		dap.listeners.before.attach.dapui_config = function()
			ui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			ui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			ui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			ui.close()
		end
	end,
	keys = {
		{
			"<leader>d",
			group = "Debugger",
			nowait = true,
			remap = false,
		},
		{
			"<leader>dt",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle Breakpoint",
			nowait = true,
			remap = false,
		},
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Continue",
			nowait = true,
			remap = false,
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
			nowait = true,
			remap = false,
		},
		{
			"<leader>do",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
			nowait = true,
			remap = false,
		},
		{
			"<leader>du",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
			nowait = true,
			remap = false,
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.open()
			end,
			desc = "Open REPL",
			nowait = true,
			remap = false,
		},
		{
			"<leader>dl",
			function()
				require("dap").run_last()
			end,
			desc = "Run Last",
			nowait = true,
			remap = false,
		},
		{
			"<leader>dq",
			function()
				require("dap").terminate()
				require("dapui").close()
				require("nvim-dap-virtual-text").toggle()
			end,
			desc = "Terminate",
			nowait = true,
			remap = false,
		},
		{
			"<leader>db",
			function()
				require("dap").list_breakpoints()
				vim.cmd("copen")
			end,
			desc = "List Breakpoints",
			nowait = true,
			remap = false,
		},
		{
			"<leader>de",
			function()
				require("dap").set_exception_breakpoints({ "all" })
			end,
			desc = "Set Exception Breakpoints",
			nowait = true,
			remap = false,
		},
	},
}
