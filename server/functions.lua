function API.DestroyResourcesCoreDependancies()
    for _, User in pairs(API.users) do
        User:Logout()
    end
end

function API.GetSources()
    return API.sources
end

function API.Logs(archive, text)
    archive = io.open(archive, "a")
    if archive then
        archive:write(text .. "\n")
    end
    archive:close()
end

function API.DropPlayer(source, reason)
    local User = API.GetUserFromSource(source)
    if User then
        User:Drop(reason)
    end
end

--                                     Licensed under                                     --
-- Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License --

function printServer(message)
    print(_serverPrefix .. message)
end

-- function log(msg)
--     -- Later
-- end

function debugMsg(msg)
    -- Later
end

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

function GetSecondsFromHumanReadableTime(str)
    local secondsFromChar = {
        ['s'] = 1,
        ['m'] = 60,
        ['h'] = 60 * 60,
        ['d'] = 60 * 60 * 24,
        ['y'] = 60 * 60 * 24 * 356,
    }

    local ret = nil

    for char, seconds in pairs(secondsFromChar) do
        local numberAndChar = string.match(str, '%d+' .. char)

        if numberAndChar then

            local number = tonumber(string.match(str, '%d+'))

            ret = number * seconds

            break
        end
    end

    return ret
end

function seconds_to_days_hours_minutes_seconds(secondsArg)
    -- local weeks = math.floor(secondsArg / 604800)
	-- local remainder = secondsArg % 604800
    
	local days = math.floor(secondsArg / 86400)
	local remainder = secondsArg % 86400

	local hours = math.floor(remainder / 3600)
	local remainder = remainder % 3600

	local minutes = math.floor(remainder / 60)
	local seconds = remainder % 60

    return ('%d dia%s + %02d:%02d:%02d'):format(days, days ~= 1 and 's' or '', hours, minutes, seconds)
end

function API.TimestampToDate(timestamp)
    local pastDate = timestamp / 1000 -- Converter milissegundos para segundos
    local dateTable = os.date("*t", pastDate)

    if not dateTable then
        print("Erro: os.date retornou nil para o timestamp:", pastDate)
        return "Data inválida"
    end

    return string.format("%02d/%02d/%d", dateTable.day, dateTable.month, dateTable.year)
end
