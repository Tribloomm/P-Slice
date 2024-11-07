--By BloonyFox
function onCreatePost()
	for i, v in ipairs ({'boyfriend', 'dad'}) do
		if checkFileExists('images/icons/'..getProperty(v..'.healthIcon')..'-win') then
			  loadGraphic('iconP'..i,'icons/'..getProperty(v..'healthIcon')..'-win',300,150)
				addAnimation('iconP'..i,i,{0,1,2},0,false) 
		 end
	  end
 end
 
 function onUpdatePost()
		   if getProperty('healthBar.percent') > 80 and checkFileExists('images/icons/'..getProperty('boyfriend.healthIcon')..'-win') then
				setProperty('iconP1.animation.curAnim.curFrame',2)
	   end
	   if getProperty('healthBar.percent') < 20 and checkFileExists('images/icons/'..getProperty('dad.healthIcon')..'-win') then
				setProperty('iconP2.animation.curAnim.curFrame',2)
	 end
 end
 function onEvent(n) 
	if n == 'Change Character' then 
		 onCreatePost() 
	end
 end