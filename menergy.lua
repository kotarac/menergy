local addon_name, addon = ...

do
	local event_handler = CreateFrame('Frame')
	event_handler:Hide()

	event_handler:SetScript('OnEvent', function(self, event, ...)
	 local f = addon[event]
	 if type(f) == 'function' then
		 f(addon, event, ...)
	 end
 end)

	addon.event_handler = event_handler
end

addon.event_handler:RegisterEvent('PLAYER_LOGIN')
addon.event_handler:RegisterEvent('PLAYER_LOGOUT')

local energy_tick_last = 0
local energy_value_last = 0
local ONUPDATE_INTERVAL = 0.02
local power_type_energy = _G.Enum.PowerType.Energy
local update_last = 0

function addon:UNIT_POWER_FREQUENT(event, unit, power_type)
	if power_type ~= 'ENERGY' or unit ~= 'player' then
		return
	end

	local energy_value = UnitPower('player', power_type_energy)
	local energy_max = UnitPowerMax('player', power_type_energy)
	if energy_value > energy_value_last or energy_value == energy_max then
		energy_tick_last = 0
	end

	energy_value_last = energy_value
end

function addon:PLAYER_LOGIN()
	addon:setup_db()

	local player_class, _ = UnitClassBase('player')
	if not addon.config.enable or (player_class ~= 'ROGUE' and player_class ~= 'DRUID') then
		return
	end

	addon.event_handler:RegisterEvent('UNIT_POWER_FREQUENT')

	local ticker = CreateFrame('StatusBar', 'menergy', UIParent)

	ticker:ClearAllPoints()
	ticker:SetPoint('CENTER', addon.config.x, addon.config.y)
	ticker:SetHeight(addon.config.height)
	ticker:SetWidth(addon.config.width)

	ticker:SetMinMaxValues(0, 2)
	ticker:SetStatusBarTexture([[Interface\AddOns\menergy\mflat.tga]])
	ticker:SetStatusBarColor(addon.config.color.r, addon.config.color.g, addon.config.color.b)

	ticker.bg = ticker:CreateTexture(nil, "BACKGROUND")
	ticker.bg:SetTexture([[Interface\AddOns\menergy\mflat.tga]])
	ticker.bg:SetAllPoints()
	ticker.bg:SetVertexColor(0, 0, 0)

	ticker:SetScript('OnUpdate', function (self, elapsed)
		update_last = update_last + elapsed
		energy_tick_last = energy_tick_last + elapsed

		if update_last < ONUPDATE_INTERVAL then
			return
		end

		if energy_tick_last >= 2 then
			energy_tick_last = 0
		end

		update_last = 0

		ticker:SetValue(energy_tick_last)
	end)
end

function addon:PLAYER_LOGOUT()
	addon:cleanup_db()
end

_G[addon_name] = addon
