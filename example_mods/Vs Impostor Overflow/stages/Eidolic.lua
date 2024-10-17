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
		setLuaSpriteScrollFactor('EF', 0.95, 1);
		scaleObject('EF', 0.9, 0.9);

		makeLuaSprite('EBG', 'BG/Electrical/EBG', -935, -250);
		setLuaSpriteScrollFactor('EBG', 1, 1);
		scaleObject('EBG', 0.7, 0.7);

		makeLuaSprite('star', 'BG/Electrical/star', -500, -300);
		setLuaSpriteScrollFactor('star', 1, 1);
		scaleObject('star', 0.9, 0.9);
	end

	addLuaSprite('star', false);
	addLuaSprite('EBG', false);
	addLuaSprite('EF', false);
	addLuaSprite('EG', false);

	addLuaSprite('snow', true)

	close(true);
end
