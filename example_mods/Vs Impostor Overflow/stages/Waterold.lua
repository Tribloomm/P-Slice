function onCreate()
	
	makeLuaSprite('waterold', 'waterold', -500, -300);
	setLuaSpriteScrollFactor('Void', 0.9, 0.9);
	
	makeLuaSprite('waterold', 'waterold', -650, 600);
	setLuaSpriteScrollFactor('waterold', 0.9, 0.9);
	scaleObject('waterold', 1.1, 1.1);

	
	if not lowQuality then
		makeLuaSprite('waterold', 'waterold', -125, -100);
		setLuaSpriteScrollFactor('waterold', 0.9, 0.9);
		scaleObject('waterold', 1.1, 1.1);
		
		makeLuaSprite('Void', 'waterold', 1225, -100);
		setLuaSpriteScrollFactor('waterold', 0.9, 0.9);
		scaleObject('waterold', 1.1, 1.1);
		setPropertyLuaSprite('waterold', 'flipX', true);

		makeLuaSprite('waterold', 'waterold', -500, -300);
		setLuaSpriteScrollFactor('waterold', 1.3, 1.3);
		scaleObject('waterold', 0.9, 0.9);

		makeAnimatedLuaSprite('GF Bop', 'GF Bop', 290, 10)
		addAnimationByPrefix('GF Bop', 'GF Dancing Beat', 'GF Dancing Beat', 24, true);
		playAnim('GF Bop','GF Dancing Beat')
		setScrollFactor('GF Bop', 1, 1);

		function onBeatHit()

			luaSpritePlayAnimation('GF Bop', 'GF Dancing Beat', true);
			end
			
	end

	addLuaSprite('waterold', false);
	addLuaSprite('waterold', false);
	addLuaSprite('waterold', false);
	addLuaSprite('waterold', false);
	addLuaSprite('waterold', false);
	
	close(true); 
end