function onCreate()

	makeLuaSprite('EG', 'BG/Electrical/EG', -125, -500);
	setLuaSpriteScrollFactor('EG', 1, 1);
	scaleObject('EG', 1.1, 1.1);



	if not lowQuality then

		makeAnimatedLuaSprite('snow', 'BG/Electrical/snow', -500, -250)
		addAnimationByPrefix('snow', 'cum', 'cum', 24);
		playAnim('snow','cum')
		setScrollFactor('snow', 1, 1);
		scaleObject('snow', 2.1, 2.1);

		makeLuaSprite('EG', 'BG/Electrical/EG', -500, -300);
		setLuaSpriteScrollFactor('EG', 1, 1);
		scaleObject('EG', 0.9, 0.9);

		makeLuaSprite('EF', 'BG/Electrical/EF', -500, -300);
		setLuaSpriteScrollFactor('EF', 0.9, 1);
		scaleObject('EF', 0.9, 0.9);

		makeLuaSprite('EBG', 'BG/Electrical/EBG', -500, -300);
		setLuaSpriteScrollFactor('EBG', 0.8, 1);
		scaleObject('EBG', 0.9, 0.9);

		makeLuaSprite('front', 'BG/Electrical/front', -500, -300);
		setLuaSpriteScrollFactor('front', 1, 1);
		setBlendMode('front','add')
		scaleObject('front', 0.9, 0.9);
	end

	addLuaSprite('EBG', false);
	addLuaSprite('EF', false);
	addLuaSprite('EG', false);

	addLuaSprite('front', true);
	addLuaSprite('snow', true)

	close(true);
end
