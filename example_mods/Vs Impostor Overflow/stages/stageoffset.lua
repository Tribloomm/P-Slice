function onCreate()

	makeLuaSprite('stageoffset', 'stageoffset', -125, -0);
	setLuaSpriteScrollFactor('stageoffset', 1, 1);



	if not lowQuality then

		makeLuaSprite('stageoffset', 'stageoffset', -1044, -568);
		setLuaSpriteScrollFactor('stageoffset', 1, 1);
		scaleObject('stageoffset', 0.9, 0.9);
	end

	addLuaSprite('stageoffset', false);

	close(true);
end
