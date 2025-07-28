local M = {}

local zoomed_nvim_window = nil
local zoomed_tmux_window = nil
local previous_nvim_window = nil
local equalize_windows = false

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
	if sync_tmux and vim.env.TMUX then
		if is_tmux_zoomed() and zoomed_nvim_window then
			return
		elseif not is_tmux_zoomed() and not zoomed_nvim_window then
			return
		end
	end
	if zoomed_nvim_window then
		zoomed_nvim_window = nil
		zoomed_tmux_window = nil
	else
		zoomed_nvim_window = vim.api.nvim_get_current_win()
		zoomed_tmux_window = get_tmux_window()
	end
	vim.cmd("WindowsMaximize")
end

local function enable_zoom(enable, sync_tmux)
	if enable and not zoomed_nvim_window then
		toggle_zoom(sync_tmux)
	elseif not enable and zoomed_nvim_window then
		toggle_zoom(sync_tmux)
	end
end

M.toggle = toggle_zoom
M.enable = enable_zoom

function M.init(opts)
	M.options = opts or {}
	-- Auto commands
	vim.api.nvim_create_autocmd("FocusLost", {
		callback = function()
			local sync_tmux_on_focus_lost = (M.options.sync_tmux_on and M.options.sync_tmux_on.focus_lost) or true
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
            -- Skip if previous win was floating
            if previous_nvim_window then
              local cfg = vim.api.nvim_win_get_config(previous_nvim_window)
              if cfg.relative ~= "" then
                return
              end
            end

			local sync_tmux_on_win_enter = (M.options.sync_tmux_on and M.options.sync_tmux_on.win_enter) or true
			if zoomed_nvim_window then
				if vim.env.TMUX and is_tmux_zoomed() and sync_tmux_on_win_enter then
					vim.fn.system({ "tmux", "resize-pane", "-Z" })
				end
				toggle_zoom(sync_tmux_on_win_enter)
			end
			if equalize_windows then
				if vim.fn.exists(":WindowsEqualize") == 2 then
					vim.cmd("WindowsEqualize")
				end
				equalize_windows = false
			end
		end,
	})

	vim.api.nvim_create_autocmd("WinNew", {
		callback = function()
			equalize_windows = vim.o.equalalways
		end,
	})

	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function()
			equalize_windows = vim.o.equalalways
		end,
	})

    vim.api.nvim_create_autocmd("WinLeave", {
      callback = function()
        previous_nvim_window = vim.api.nvim_get_current_win()
      end,
    })
end

return M
