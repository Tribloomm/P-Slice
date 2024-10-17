function onCreate()

	makeLuaSprite('rhmbg', 'rhmbg', -125, -500);
	setLuaSpriteScrollFactor('rhmbg', 1, 1);
	scaleObject('rhmbg', 1.1, 1.1);



	if not lowQuality then

		makeLuaSprite('rhmbg', 'BG/Armory/rhmbg', -1070, -625);
		setLuaSpriteScrollFactor('rhmbg', 1, 1);
		scaleObject('rhmbg', 0.9, 0.9);
	end

	addLuaSprite('rhmbg', false);

	close(true);
end
