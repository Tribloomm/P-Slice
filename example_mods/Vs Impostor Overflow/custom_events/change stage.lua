function onEvent(name, value1, value2)
	if name == 'change stage' then
addLuaScript('stages/'..value1)
loadScript(value1, true)
removeLuaScript('stages/'..value2)
removeLuaSprite('stages/'..value2);
	end
	end
