-- Some parts of the credits script by: Piggyfriend1792, modified by: AxorTheAxolotl

local offsetX = 12 -- do not change this lmao
------ Config ------
local offsetY = 188
local objWidth = 260
local objHeight = 100
local title = "Knife Play"
local creator = "Composer: Topazowy Golem"
--------------------

function onCreatePost()
	makeLuaSprite('creditBox', 'empty', 0 - objWidth, offsetY)
	makeGraphic('creditBox', objWidth, objHeight, 'FFFFFF')
	setObjectCamera('creditBox', 'other')
	setProperty("creditBox.alpha", 0.5)
	addLuaSprite('creditBox', true)
	
	makeLuaText('creditTitle', title, objWidth, offsetX - objWidth, offsetY+11)
	setTextFont('creditTitle', 'arial-v4.ttf')
	setTextSize('creditTitle', 25)
	setTextBorder('creditTitle', 1, '000000')
	setTextAlignment('creditTitle', 'left')
	setObjectCamera('creditTitle', 'other')
	addLuaText("creditTitle",true)
	
	makeLuaText('creditCreator', creator, objWidth, offsetX - objWidth, offsetY+41)
	setTextFont('creditCreator', 'arial-v4.ttf')
	setTextSize('creditCreator', 25)
	setTextBorder('creditCreator', 1, '000000')
	setTextAlignment('creditCreator', 'left')
	setObjectCamera('creditCreator', 'other')
	addLuaText("creditCreator",true)
	
	doTweenX("creditBoxTween", "creditBox", getProperty("creditBox.x") + objWidth, 1, "quartInOut")
	doTweenX("creditTitleTween", "creditTitle", getProperty("creditTitle.x") + objWidth, 1, "quartInOut")
	doTweenX("creditCreatorTween", "creditCreator", getProperty("creditCreator.x") + objWidth, 1, "quartInOut")
	runTimer("creditDisplay", 3.5, 1)
end

function onTimerCompleted(tag)
    if tag == "creditDisplay" then
        doTweenX("creditBoxTween", "creditBox", getProperty("creditBox.x") - (objWidth * 1.1), 1, "quartInOut")
        doTweenX("creditTitleTween", "creditTitle", getProperty("creditTitle.x") - (objWidth * 1.1), 1, "quartInOut")
        doTweenX("creditCreatorTween", "creditCreator", getProperty("creditCreator.x") - (objWidth * 1.1), 1, "quartInOut")
    end
end