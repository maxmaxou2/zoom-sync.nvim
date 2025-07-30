local M = {}

local zoomed_nvim_window = nil
local zoomed_tmux_window = nil
local nvim_window_was_floating = false
local equalize_windows = false

local function is_current_window_floating()
	local win = vim.api.nvim_get_current_win()
	if not vim.api.nvim_win_is_valid(win) then
		return false
	end
	return vim.api.nvim_win_is_valid(win) and vim.fn.win_gettype(win) == "popup"
end

local function get_tmux_window()
	if not vim.env.TMUX then
		return nil
	end

	return vim.fn.trim(vim.fn.system({ "tmux", "display-message", "-p", "#I" }))
end

local function is_tmux_zoomed()
	if not vim.env.TMUX then
		return false
	end

	local status = vim.fn.system({ "tmux", "display-message", "-p", "#{window_zoomed_flag}" })
	return vim.fn.trim(status) == "1"
end

local function toggle_zoom(sync_tmux)
	local is_zoomed = (zoomed_nvim_window ~= nil)
	if sync_tmux and vim.env.TMUX and is_zoomed == is_tmux_zoomed() then
		-- No toggle needed if tmux is not in another state than nvim
		-- because tmux is zoomed in/out before nvim
		return
	end

	-- Swap states
	if is_zoomed then
		zoomed_nvim_window = nil
		zoomed_tmux_window = nil
	else
		zoomed_nvim_window = vim.api.nvim_get_current_win()
		zoomed_tmux_window = get_tmux_window()
	end
	vim.cmd("WindowsMaximize")
end

local function enable_zoom(enable, sync_tmux)
	local is_zoomed = (zoomed_nvim_window ~= nil)
	if is_zoomed ~= enable then
		return
	end

	toggle_zoom(sync_tmux)
end

M.toggle = toggle_zoom
M.enable = enable_zoom

function M.init(opts)
	M.options = opts or {}

	-- Auto commands
	vim.api.nvim_create_autocmd("FocusLost", {
		callback = function()
			local sync_tmux_on_focus_lost = true
			if M.options.sync_tmux_on and M.options.sync_tmux_on.focus_lost ~= nil then
				sync_tmux_on_focus_lost = M.options.sync_tmux_on.focus_lost
			end

			local cur_win = get_tmux_window()
			if
				zoomed_nvim_window
				and zoomed_tmux_window
				and cur_win == zoomed_tmux_window
				and not is_tmux_zoomed()
				and sync_tmux_on_focus_lost
			then
				toggle_zoom(sync_tmux_on_focus_lost)
			end
		end,
	})
	vim.api.nvim_create_autocmd("WinEnter", {
		callback = function()
			if nvim_window_was_floating then
				-- NOTE: This is a workaround for a bug in windows.nvim where
				--       it unzooms upon leaving a floating window.
				if zoomed_tmux_window then
					vim.schedule_wrap(function()
						vim.cmd("WindowsMaximize")
					end)()
				end
				nvim_window_was_floating = false
				equalize_windows = false
				return
			elseif is_current_window_floating() then
				equalize_windows = false
				return
			end

			local sync_tmux_on_win_enter = true
			if M.options.sync_tmux_on and M.options.sync_tmux_on.win_enter ~= nil then
				sync_tmux_on_win_enter = M.options.sync_tmux_on.win_enter
			end

			if zoomed_nvim_window then
				if vim.env.TMUX and is_tmux_zoomed() and sync_tmux_on_win_enter then
					vim.fn.system({ "tmux", "resize-pane", "-Z" })
				end
				toggle_zoom(sync_tmux_on_win_enter)
			end

			if equalize_windows then
				vim.cmd("WindowsEqualize")
				equalize_windows = false
			end
		end,
	})

	vim.api.nvim_create_autocmd("WinNew", {
		callback = function()
            equalize_windows = M.options.equalize_windows or true
		end,
	})

	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function()
            equalize_windows = M.options.equalize_windows or true
		end,
	})

	vim.api.nvim_create_autocmd("WinLeave", {
		callback = function()
			nvim_window_was_floating = is_current_window_floating()
		end,
	})
end

return M
