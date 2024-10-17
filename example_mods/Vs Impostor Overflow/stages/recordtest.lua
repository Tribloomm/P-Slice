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

		makeLuaSprite('omultiply', 'BG/Records/omultiply', -700, -225);
		setScrollFactor('omultiply', 0.85, 1);
		setBlendMode('omultiply','multiply')
		scaleObject('omultiply', 0.7, 1);

		makeLuaSprite('oadd', 'BG/Records/oadd', -700, -225);
		setScrollFactor('oadd', 1, 1);
		setBlendMode('oadd','add')
		scaleObject('oadd', 0.7, 0.7);

		makeLuaSprite('osoftlight', 'BG/Records/osoftlight', -700, -225);
		setScrollFactor('osoftlight', 0.85, 1);
		setBlendMode('osoftlight','soft light')
		scaleObject('osoftlight', 0.7, 0.7);
	end

	addLuaSprite('Reb', false);

	addLuaSprite('Ref', true);
	addLuaSprite('omultiply', true);
	addLuaSprite('oadd', true);
	addLuaSprite('osoftlight', true);


	close(true);
end
