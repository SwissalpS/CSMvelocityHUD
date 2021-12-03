local velocityHUD = {}
-- some values for users to configure
-- seconds to wait before init
velocityHUD.startDelay = 7
-- seconds between updates
velocityHUD.interval = 0.5
-- how many characters to show per vector
velocityHUD.precision = 4
-- rrggbb colour of text
velocityHUD.colour = 0xff0000

-- don't modify this, holds the HUD-ID when initialized
velocityHUD.hudID = nil
velocityHUD.store = core.get_mod_storage()


function velocityHUD.init()

	local oPlayer = core.localplayer
	if not oPlayer then return end

	local tHud = {
		hud_elem_type = 'text',
		name = 'velocityHUD',
		number = velocityHUD.colour,
		position = { x = 0, y = 1 },
		offset = { x = 8, y = -8 },
		text = 'velocityHUD',
		scale = { x = 200, y = 60 },
		alignment = { x = 1, y = -1 },
	}
	velocityHUD.hudID = oPlayer:hud_add(tHud)

end -- init


function velocityHUD.isOn()

	return '' == velocityHUD.store:get_string('switch')

end -- isOn


function velocityHUD.removeHUD()

	-- no hud yet?
	if not velocityHUD.hudID then return end

	local oPlayer = core.localplayer
	if not oPlayer then return end

	oPlayer:hud_remove(velocityHUD.hudID)
	velocityHUD.hudID = nil

end -- removeHUD


function velocityHUD.toggleHUD()

	local sNew = velocityHUD.isOn() and '-' or ''
	velocityHUD.store:set_string('switch', sNew)

	if velocityHUD.isOn() then
		velocityHUD.update()
	else
		velocityHUD.removeHUD()
	end

end -- toggleHUD


function velocityHUD.update()

	-- if hud is turned off, abbort
	if not velocityHUD.isOn() then return end

	core.after(velocityHUD.interval, velocityHUD.update)

	local oPlayer = core.localplayer
	if not oPlayer then return end

	if not velocityHUD.hudID then return velocityHUD.init() end

	local tV = core.localplayer:get_velocity()
	local sOut = ''
	if tV then
		local iP = velocityHUD.precision
		local x, y, z = math.abs(tV.x), math.abs(tV.y), math.abs(tV.z)
		local tVabs = { x = x, y = y, z = z }
		sOut = 'vX: ' .. tostring(x):sub(1, iP) .. ' '
			.. 'vY: ' .. tostring(y):sub(1, iP) .. ' '
			.. 'vZ: ' .. tostring(z):sub(1, iP) .. '\n'
			.. 'vXZ: ' .. tostring(math.hypot(x, z)):sub(1, iP) .. ' '
			.. 'vXYZ: ' .. tostring(vector.length(tVabs)):sub(1, iP)
	end

	oPlayer:hud_change(velocityHUD.hudID, 'text', sOut)

end -- update


core.after(velocityHUD.startDelay, velocityHUD.update)
core.register_chatcommand("toggleVH", { func = velocityHUD.toggleHUD })

