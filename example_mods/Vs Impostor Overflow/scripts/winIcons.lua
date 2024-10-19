--By BloonyFox
bfWinningIcons = true
dadWinningIcons = true

function onCreatePost()
	createWinIcons()
end

function createWinIcons()
	if not lowQuality then
		--BF
		if bfWinningIcons == true then
			makeLuaSprite('winIcoPlayer', 'icons/win-'..getProperty('boyfriend.healthIcon'), getProperty('iconP1.x'), getProperty('iconP1.y'))
			setObjectCamera('winIcoPlayer', 'hud')
			addLuaSprite('winIcoPlayer', true)
			setProperty('winIcoPlayer.flipX', true)
			setProperty('winIcoPlayer.visible', false)
		end

		--Opponent
		if dadWinningIcons == true then
			makeLuaSprite('winIcoOpponent', 'icons/win-'..getProperty('dad.healthIcon'), getProperty('iconP2.x'), getProperty('iconP2.y'))
			setObjectCamera('winIcoOpponent', 'hud')
			addLuaSprite('winIcoOpponent', true)
			setProperty('winIcoOpponent.flipX', false)
			setProperty('winIcoOpponent.visible', false)
		end
	end
end

function onUpdatePost(elapsed)
	if not lowQuality then
		--BF
		if bfWinningIcons == true then
			--Set sprite and things
			setObjectOrder('winIcoPlayer', getObjectOrder('iconP1') - 1)
			makeLuaSprite('winIcoPlayer', 'icons/win-'..getProperty('boyfriend.healthIcon'), getProperty('iconP1.x'), getProperty('iconP1.y'))
			setObjectCamera('winIcoPlayer', 'hud')
			addLuaSprite('winIcoPlayer', true)
			setProperty('winIcoPlayer.flipX', true)
			setProperty('winIcoPlayer.visible', false)

			--Set pos
			setProperty('winIcoPlayer.x', getProperty('iconP1.x'))
			setProperty('winIcoPlayer.angle', getProperty('iconP1.angle'))
			setProperty('winIcoPlayer.alpha', getProperty('iconP1.alpha'))
			setProperty('winIcoPlayer.y', getProperty('iconP1.y'))
			setProperty('winIcoPlayer.scale.x', getProperty('iconP1.scale.x'))
			setProperty('winIcoPlayer.scale.y', getProperty('iconP1.scale.y'))

			--Toggle win icon
			if getProperty('health') >= 1.62 then
				setProperty('iconP1.visible', false)
				setProperty('winIcoPlayer.visible', true)
			else
				setProperty('iconP1.visible', true)
				setProperty('winIcoPlayer.visible', false)
			end
		end

		--Opponent
		if dadWinningIcons == true then
			setObjectOrder('winIcoOpponent', getObjectOrder('iconP2') - 1)
			makeLuaSprite('winIcoOpponent', 'icons/win-'..getProperty('dad.healthIcon'), getProperty('iconP2.x'), getProperty('iconP2.y'))
			setObjectCamera('winIcoOpponent', 'hud')
			addLuaSprite('winIcoOpponent', true)
			setProperty('winIcoOpponent.flipX', false)
			setProperty('winIcoOpponent.visible', false)

			--Set pos
			setProperty('winIcoOpponent.x', getProperty('iconP2.x'))
			setProperty('winIcoOpponent.angle', getProperty('iconP2.angle'))
			setProperty('winIcoOpponent.alpha', getProperty('iconP2.alpha'))
			setProperty('winIcoOpponent.y', getProperty('iconP2.y'))
			setProperty('winIcoOpponent.scale.x', getProperty('iconP2.scale.x'))
			setProperty('winIcoOpponent.scale.y', getProperty('iconP2.scale.y'))
			
			--Toggle win icon
			if getProperty('health') <= 0.4 then
				setProperty('iconP2.visible', false)
				setProperty('winIcoOpponent.visible', true)
			else
				setProperty('iconP2.visible', true)
				setProperty('winIcoOpponent.visible', false)
			end
		end
	end
end

function onEvent(name, value1, value2, strumTime)
	if not lowQuality then
		if name == 'Change Character' then
			--Update characters
			removeLuaSprite('winIcoPlayer', true)
			removeLuaSprite('winIcoOpponent', true)
			createWinIcons()
		end
	end
end