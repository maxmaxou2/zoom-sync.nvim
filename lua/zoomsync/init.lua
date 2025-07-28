local M = {}

local function deep_merge(tbl1, tbl2)
	for k, v in pairs(tbl2) do
		if type(v) == "table" and type(tbl1[k]) == "table" then
			deep_merge(tbl1[k], v)
		else
			tbl1[k] = v
		end
	end
end

local default_opts = { sync_tmux = { focus_lost = true, win_enter = true } }

function M.setup(user_opts)
	user_opts = user_opts or {}
	local opts = vim.deepcopy(default_opts)
	deep_merge(opts, user_opts)

	local windows_ok, _ = pcall(require, "windows")
	if not windows_ok then
		vim.notify("[zoomsync] windows.nvim is not installed!", vim.log.levels.ERROR)
	end

	local internal = require("zoomsync.internal")
	internal.init(opts)

	vim.api.nvim_create_user_command("ZoomToggle", function(opts)
		internal.toggle(opts.bang)
	end, { desc = "Toggle zoom", bang = true })
	vim.api.nvim_create_user_command("ZoomEnable", function(opts)
		internal.enable(true, opts.bang)
	end, { desc = "Enable zoom", bang = true })
	vim.api.nvim_create_user_command("ZoomDisable", function(opts)
		internal.enable(false, opts.bang)
	end, { desc = "Disable zoom", bang = true })
end

return M
