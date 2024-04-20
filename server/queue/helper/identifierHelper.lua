function MapIdentifiers(identifiers)
	local map = { }

	for _, identifier in ipairs(identifiers) do
		local prefix = identifier:sub(1, identifier:find(':') - 1)

		map[prefix] = identifier
	end

	return map
end

HIGH_TRUSTED_IDENTIFIERS_PREFIX =
{
	'discord',
	'steam',
}

function IsAnyMappedIdentifierHighTrusted(mappedIdentifiers)
	for _, prefix in ipairs(HIGH_TRUSTED_IDENTIFIERS_PREFIX) do
		if mappedIdentifiers[prefix] then
			return true
		end
	end

	return false
end