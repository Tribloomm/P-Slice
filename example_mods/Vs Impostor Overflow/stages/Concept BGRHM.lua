function onCreate()

	makeLuaSprite('rhmbg', 'rhmbg', -125, -500);
	setLuaSpriteScrollFactor('rhmbg', 1, 1);
	scaleObject('rhmbg', 0.5, 1);



	if not lowQuality then

		makeLuaSprite('rhmbg', 'BG/Armory/rhmbg', -867, -500);
		setLuaSpriteScrollFactor('rhmbg', 1, 1);
		scaleObject('rhmbg', 0.8, 0.8);

		makeLuaSprite('rhmg', 'BG/Armory/rhmg', -867, -500);
		setLuaSpriteScrollFactor('rhmg', 1, 1);
		scaleObject('rhmg', 0.8, 0.8);

	end

	addLuaSprite('rhmbg', false);
	addLuaSprite('rhmg', true);

	close(true);
end
