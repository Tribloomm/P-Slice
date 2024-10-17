function onCreate()

	makeLuaSprite('water', 'water', -125, -500);
	setLuaSpriteScrollFactor('water', 1, 1);

	makeLuaSprite('water', 'water', -125, -500);
	setLuaSpriteScrollFactor('water', 1, 1);
	scaleObject('water', 1.1, 1.1);



	if not lowQuality then


		makeLuaSprite('water', 'BG/Boiler/water', -1084, -568);
		setLuaSpriteScrollFactor('water', 1, 1);
		scaleObject('water', 0.9, 0.9);

		makeLuaSprite('overlayboil', 'BG/Boiler/overlayboil', -700, -225);
		setScrollFactor('overlayboil', 1, 1);
		setBlendMode('overlayboil','add')
		scaleObject('overlayboil', 1.5, 1.5);

	end

	addLuaSprite('water', false);

	addLuaSprite('overlayboil', true);
	close(true);
end
