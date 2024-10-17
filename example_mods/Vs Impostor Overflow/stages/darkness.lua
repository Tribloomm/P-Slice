function onCreate()

	makeLuaSprite('black', 'black', -500, -300);
	setLuaSpriteScrollFactor('black', 1.1, 1.9);

	makeLuaSprite('black', 'black', -650, 600);
	setLuaSpriteScrollFactor('black', 1.1, 1.1);
	scaleObject('black', 1.2, 1.2);


	if not lowQuality then

		makeLuaSprite('black', 'black', -1500, -900);
		setLuaSpriteScrollFactor('black', 1.3, 1.3);
		scaleObject('black', 1.7, 1.7);
	end

	addLuaSprite('black', true);

	close(true);
end
