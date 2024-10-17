function onCreate()

	makeLuaSprite('Mountain', 'Mountain', -125, -500);
	setLuaSpriteScrollFactor('Mountain', 1, 1);
	scaleObject('Mountain', 1.1, 1.1);



	if not lowQuality then

		makeLuaSprite('isthecanvassizereallythatnecessary', 'BG/Fungle Comms/isthecanvassizereallythatnecessary', -1044, -568);
		setLuaSpriteScrollFactor('isthecanvassizereallythatnecessary', 1, 1);
		scaleObject('isthecanvassizereallythatnecessary', 0.9, 0.9);

		makeLuaSprite('Comms', 'BG/Fungle Comms/Comms', -1044, -568);
		setLuaSpriteScrollFactor('Comms', 1, 1);
		scaleObject('Comms', 0.9, 0.9);

		makeLuaSprite('Mountain', 'BG/Fungle Comms/mountain', -900, -568);
		setLuaSpriteScrollFactor('Mountain', 0.75, 1);
		scaleObject('Mountain', 0.9, 0.9);

		makeLuaSprite('Backestground', 'BG/Fungle Comms/Backestground', -1044, -568);
		setLuaSpriteScrollFactor('Backestground', 0.9, 1);
		scaleObject('Backestground', 0.9, 0.9);

		makeLuaSprite('addcomms', 'BG/Fungle Comms/addcomms', -1044, -568);
		setScrollFactor('aaddcomms', 1, 1);
		setBlendMode('aaddcomms','add')
		scaleObject('aaddcomms', 0.9, 0.9);
	end

	addLuaSprite('Backestground', false);
	addLuaSprite('Mountain', false);
	addLuaSprite('Comms', false);

	addLuaSprite('isthecanvassizereallythatnecessary', true);
	addLuaSprite('addcomms', true);

	close(true);
end
