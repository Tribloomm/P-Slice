function onEvent(n,v1,v2)
if n == "Reactor Beep" then
charType = tonumber(v1);
if charType == nil then
charType = 0.4
end
setProperty('flashSprite.alpha',charType)
triggerEvent('Add Camera Zoom', 0.015, 0.03)
cameraFlash('hud', '0x'..string.format("%x", math.floor(255*charType))..'ff0000', charType, true)
end
end

