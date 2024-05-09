i18n = setmetatable({}, i18n)
i18n.__index = i18n

local IS_SERVER = IsDuplicityVersion()
local RESOURCE_NAME = GetCurrentResourceName()
local languageCache = {}

local lang = GetResourceKvpString('frp:language') or 'en'

if not IS_SERVER then
	lang = GetExternalKvpString('frp_core', 'frp:language') or 'en'

	if RESOURCE_NAME == 'frp_core' then
		TriggerServerEvent('FRP:SetLanguage', lang)
	end
end

avalLangs = {}

function i18n.setup(l)
	if(l ~= nil)then
		lang = l
	end
end

function i18n.exportData()
	local result = languageCache
	return result
end

function i18n.importData(l,s)
	local pData = {}

	for prefix, data in pairs(s) do

		if prefix == 1 then
			pData = data
			break
		else
			pData[prefix] = data
		end
	end

	table.insert( avalLangs, l)

	languageCache[l] = pData
end

function i18n.setLang(l)
	lang = l
end

function i18n.translate(key, ...)
	if not key then return languageCache[lang] end

	local result = ""
	if(languageCache == nil or not languageCache[lang] ) then
		result = "Error 502 : no translation available !"
	else
		key = mysplit(key, '.')

		local prefix = key[1]
		local label = key[2]

		if label then
			result = languageCache[lang][prefix][label]
		else
			result = languageCache[lang][prefix]
		end

		if ... then
			if type(...) == "table" then
				result = ""

				for _, name in pairs(...) do
					result = result .. string.format(result, name)
				end

			else
				result = string.format(result, ...)
			end
		end

		
		if(result == nil) then
			result = string.format("%s", type(key) == "string" and key or json.encode(key))
		end
	end

	return result
end

function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

RegisterNetEvent("FRP:SetLanguage", function(language)
	i18n.setLang(language)
	
	if RESOURCE_NAME == 'frp_core' then
		SetResourceKvp('frp:language', language)

		if not IsDuplicityVersion() then
			if language ~= GetResourceKvpString('frp:language') then
				cAPI.Notify(i18n.translate('info.language_changed'), 'success')
			end
		end
	end
end)

