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

		makeLuaSprite('ash', 'BG/Armory/ash', -867, -500);
		setLuaSpriteScrollFactor('ash', 1, 1);
		scaleObject('ash', 0.8, 0.8);

		makeAnimatedLuaSprite('speakers','characters/speakers', 290,-0)
		addAnimationByPrefix('speakers','cheer','GF',19,false)
		scaleObject('speakers', 1, 1);
		setScrollFactor('speakers', 1, 1);


	end

	addLuaSprite('rhmbg', false);
	addLuaSprite('speakers', false);
	addLuaSprite('ash', false);
	addLuaSprite('rhmg', true);

end

function onBeatHit()
	-- triggered 2 times per section
	if curBeat % 1 == 0 then
		playAnim('speakers', 'cheer', true);
		if not lowQuality then
			playAnim('speakers', 'cheer', true);
		end
	end
end
