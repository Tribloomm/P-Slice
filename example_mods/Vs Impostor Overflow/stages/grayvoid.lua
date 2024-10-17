function onCreate()

	makeLuaSprite('grayvoid', 'grayvoid', -100, -300);
	setLuaSpriteScrollFactor('grayvoid', 0.9, 0.9);

	if not lowQuality then

		makeLuaSprite('grayvoid', 'BG/Void/grayvoid', -500, -280);
		setLuaSpriteScrollFactor('grayvoid', 1, 1);
		scaleObject('grayvoid', 0.9, 0.9);
	end

	addLuaSprite('grayvoid', false);


	close(true);
end
