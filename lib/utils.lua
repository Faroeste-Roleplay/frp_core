-- Original Author (see LICENSE or https://github.com/ImagicTheCat/vRP)

-- This file define global tools required by vRP and vRP extensions.

SERVER = IsDuplicityVersion()
CLIENT = not SERVER

function table.maxn(t)
	local max = 0
	for k, v in pairs(t) do
		local n = tonumber(k)
		if n and n > max then
			max = n
		end
	end
	return max
end

local modules = {}
function module(rsc, path)
	if path == nil then
		path = rsc
		rsc = "frp_core"
	end

	local key = rsc .. path
	local module = modules[key]
	if module then
		return module
	else
		local code = LoadResourceFile(rsc, path .. ".lua")
		if code then
			local f, err = load(code, rsc .. "/" .. path .. ".lua")
			if f then
				local ok, res = xpcall(f, debug.traceback)
				if ok then
					modules[key] = res
					return res
				else
					error("error loading module " .. rsc .. "/" .. path .. ":" .. res)
				end
			else
				error("error parsing module " .. rsc .. "/" .. path .. ":" .. debug.traceback(err))
			end
		else
			error("resource file " .. rsc .. "/" .. path .. ".lua not found")
		end
	end
end

local function wait(self)
	local rets = Citizen.Await(self.p)
	if not rets then
		rets = self.r
	end
	return table.unpack(rets, 1, table.maxn(rets))
end

local function areturn(self, ...)
	self.r = {...}
	self.p:resolve(self.r)
end

function async(func)
	if func then
		Citizen.CreateThreadNow(func)
	else
		return setmetatable({wait = wait, p = promise.new()}, {__call = areturn})
	end
end

local sanitize_tmp = {}
function sanitizeString(str, strchars, allow_policy)
	local r = ""
	local chars = sanitize_tmp[strchars]
	if chars == nil then
		chars = {}
		local size = string.len(strchars)
		for i = 1, size do
			local char = string.sub(strchars, i, i)
			chars[char] = true
		end
		sanitize_tmp[strchars] = chars
	end

	size = string.len(str)
	for i = 1, size do
		local char = string.sub(str, i, i)
		if (allow_policy and chars[char]) or (not allow_policy and not chars[char]) then
			r = r .. char
		end
	end
	return r
end

function splitString(str, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	local i = 1

	for str in string.gmatch(str, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end

	return t
end

function joinStrings(list, sep)
	if sep == nil then
		sep = ""
	end

	local str = ""
	local count = 0
	local size = #list
	for k, v in pairs(list) do
		count = count + 1
		str = str .. v
		if count < size then
			str = str .. sep
		end
	end
	return str
end

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function NUISetFocus(hasFocus, hasCursor, hasKeepInput)
	cAPI.NUIClearFocus()

	SetNuiFocus(hasFocus, hasCursor)
	cAPI.NUISetResourceHasFocus(GetCurrentResourceName(), hasFocus, hasCursor, hasKeepInput)
end

AddEventHandler(
	"NUI:ClearResourceFocus",
	function(resourceName)
		if GetCurrentResourceName() == resourceName then
			SetNuiFocus(false, false)
		end
	end
)
-- function Ns
