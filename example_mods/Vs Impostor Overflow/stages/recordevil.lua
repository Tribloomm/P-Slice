function onCreate()

	makeLuaSprite('Reb', 'Reb', -125, -0);
	setLuaSpriteScrollFactor('Reb', 1, 1);

	if not lowQuality then

		makeLuaSprite('Reb', 'BG/Records/Reb', -700, -225);
		setLuaSpriteScrollFactor('Reb', 1, 1);
		scaleObject('Reb', 0.7, 0.7);

		makeLuaSprite('Ref', 'BG/Records/Ref', -700, -285);
		setLuaSpriteScrollFactor('Ref', 0.85, 1);
		scaleObject('Ref', 0.7, 0.7);

		makeLuaSprite('opinlight', 'BG/Records/opinlight', -700, -225);
		setScrollFactor('opinlight', 1, 1);
		setBlendMode('opinlight','pin light')
		scaleObject('opinlight', 0.7, 0.7);

		makeLuaSprite('osoftlightb', 'BG/Records/osoftlightb', -700, -225);
		setScrollFactor('osoftlightb', 1, 1);
		setBlendMode('osoftlightb','soft light')
		scaleObject('osoftlightb', 0.7, 0.7);

	end

	addLuaSprite('Reb', false);

	addLuaSprite('Ref', true);
	addLuaSprite('opinlight', true);
	addLuaSprite('osoftlightb', true);



	close(true);
end
