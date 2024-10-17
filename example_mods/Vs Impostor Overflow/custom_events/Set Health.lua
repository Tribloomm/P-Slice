function onEvent(name, value1, value2)
        healthSet = tonumber(value1);
                 if healthSet == null then
                 healthSet = 1;
                 end
	if name == 'Set Health' then
                setProperty('health', healthSet);
        end
end