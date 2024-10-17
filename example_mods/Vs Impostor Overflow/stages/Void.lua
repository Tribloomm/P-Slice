function onCreate()

	makeLuaSprite('Void', 'Void', -500, -300);
	setLuaSpriteScrollFactor('Void', 1.1, 1.9);

	makeLuaSprite('Void', 'BG/Void/Void', -650, 600);
	setLuaSpriteScrollFactor('Void', 1.1, 1.1);
	scaleObject('Void', 1.2, 1.2);


	if not lowQuality then

		makeLuaSprite('Void', 'BG/Void/Void', -1225, -800);
		setLuaSpriteScrollFactor('Void', 1.3, 1.3);
		scaleObject('Void', 1.7, 1.7);
	end

	addLuaSprite('Void', false);

	close(true);
end
