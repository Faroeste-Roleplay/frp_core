local prompts = {}
function API.Prompt(source,title,default_text)
	local r = async()
    prompts[source] = r
	cAPI._Prompt(source,title,default_text)
	return r:wait()
end

function cAPI.PromptResult(text)
	if text == nil then
		text = ""
	end

	local prompt = prompts[source]
	if prompt ~= nil then
		prompts[source] = nil
		prompt(text)
	end
end