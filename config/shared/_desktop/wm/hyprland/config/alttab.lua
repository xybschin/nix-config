-- Windows-style Super+Tab switcher, driven by Hyprland's own focus history.
--
-- Hyprland keeps a global most-recently-used list of windows
-- (Desktop::History::CWindowHistoryTracker) and exposes each window's rank in that
-- list as `focus_history_id`: 0 is the most recently focused window, higher numbers
-- are older, and -1 means the window is not in the history. This script walks that
-- list instead of keeping a history of its own.
--
-- Like the Windows switcher, the list is a snapshot taken when the gesture starts:
-- hold Super and press Tab to walk through the snapshot, release Super to pick a
-- window. The next gesture takes a new snapshot, so a plain Super+Tab press goes
-- to the window that was in use before the current one.
--
-- Moving the focus makes the compositor fire focus events of its own: switching to
-- a workspace focuses that workspace's active window first, and a fullscreen
-- window on the target's workspace takes the focus instead of the target. Those
-- events belong to our own dispatch, so they must not be read as the user moving
-- the focus.

-- XKB keycodes of the Super keys. The input.keyboard.key event reports libinput
-- codes shifted by 8, so Super_L is 133 and Super_R is 134.
local KEY_SUPER_L = 133
local KEY_SUPER_R = 134

-- The running gesture: the snapshot of the switcher list and the cursor into it.
local gesture = nil
-- Set while we move the focus ourselves.
local in_flight = false
-- Set for a moment after a dispatch, to swallow focus events that arrive late.
local settling = false
local generation = 0
-- The window we asked the compositor to focus.
local target_address = nil

-- Every window the switcher may pick, most recently focused first.
local function candidates()
	local windows = {}
	for _, w in ipairs(hl.get_windows()) do
		if w.mapped and not w.hidden and not (w.workspace and w.workspace.special) then
			table.insert(windows, w)
		end
	end
	table.sort(windows, function(a, b)
		-- Windows outside the history (-1) sort last; ties break on the address.
		local ha, hb = a.focus_history_id, b.focus_history_id
		if ha < 0 then
			ha = math.huge
		end
		if hb < 0 then
			hb = math.huge
		end
		if ha == hb then
			return a.address < b.address
		end
		return ha < hb
	end)
	return windows
end

-- Open the switcher: snapshot the history, with the cursor on the focused window.
local function open_gesture()
	local order = {}
	for _, w in ipairs(candidates()) do
		table.insert(order, w.address)
	end
	local index = 0
	local active = hl.get_active_window()
	if active then
		for i, address in ipairs(order) do
			if address == active.address then
				index = i
				break
			end
		end
	end
	gesture = { order = order, index = index }
end

-- Move the cursor by delta positions in the switcher and focus that window.
local function step(delta)
	if not gesture then
		open_gesture()
	end

	local order = gesture.order
	local count = #order
	if count == 0 then
		gesture = nil
		return
	end

	gesture.index = ((gesture.index + delta - 1) % count) + 1
	local target = hl.get_window("address:" .. order[gesture.index])
	if not target then
		gesture = nil
		return
	end

	in_flight = true
	target_address = target.address
	hl.dispatch(hl.dsp.focus({ window = target }))
	in_flight = false

	-- Swallow focus events that arrive shortly after the dispatch.
	settling = true
	generation = generation + 1
	local mine = generation
	hl.timer(function()
		if mine == generation then
			settling = false
		end
	end, { timeout = 250, type = "oneshot" })

	-- The compositor may focus a window other than the one we asked for, e.g. a
	-- fullscreen window on the target's workspace. Follow whatever ended up
	-- focused, so the walk stays in step.
	local active = hl.get_active_window()
	if active and active.address ~= target.address then
		for i, address in ipairs(order) do
			if address == active.address then
				gesture.index = i
				break
			end
		end
	end
end

-- Super going up closes the switcher, the next press opens a new one.
hl.on("input.keyboard.key", function(keycode, timestamp, state)
	if state == 0 and (keycode == KEY_SUPER_L or keycode == KEY_SUPER_R) then
		gesture = nil
	end
end)

-- A focus change we did not ask for closes the switcher.
hl.on("window.active", function(w)
	if in_flight or settling then
		return
	end
	if target_address and w and w.address == target_address then
		target_address = nil
		return
	end
	gesture = nil
end)

-- A closed window leaves the switcher.
hl.on("window.close", function(w)
	if not gesture then
		return
	end
	for i, address in ipairs(gesture.order) do
		if address == w.address then
			table.remove(gesture.order, i)
			if gesture.index > i then
				gesture.index = gesture.index - 1
			end
			break
		end
	end
end)

hl.bind("SUPER + Tab", function()
	step(1)
end)

hl.bind("SUPER + SHIFT + Tab", function()
	step(-1)
end)
