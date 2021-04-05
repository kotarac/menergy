local addon_name, addon = ...

local DB_KEY = addon_name .. '_db'
local DB_VERSION = 1

local function remove_defaults(t, defaults)
	for k, v in pairs(defaults) do
		if type(t[k]) == "table" and type(v) == "table" then
			remove_defaults(t[k], v)
			if next(t[k]) == nil then
				t[k] = nil
			end
		elseif t[k] == v then
			t[k] = nil
		end
	end
	return t
end

local function copy_defaults(t, defaults)
	for k, v in pairs(defaults) do
		if type(v) == "table" then
			t[k] = copy_defaults(t[k] or {}, v)
		elseif t[k] == nil then
			t[k] = v
		end
	end
	return t
end

function addon:setup_db()
	local config = _G[DB_KEY]
	if not config then
		config = { version = DB_VERSION }
		_G[DB_KEY] = config
	end
	self.config = copy_defaults(config, self:get_defaults())
end

function addon:cleanup_db()
	local config = self.config
	if config then
		remove_defaults(config, self:get_defaults())
	end
end

function addon:get_defaults()
	return {
		enable = true,
		width = 130,
		height = 5,
		x = 0,
		y = -162,
		color = {
			r = 1,
			g = 1,
			b = 0,
		},
	}
end

function addon:reset_db()
	_G[DB_KEY] = nil
	self:setup_db()
end
