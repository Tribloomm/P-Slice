function onBeatHit()
    if curBeat == 1 then
    doTweenAlpha('white', 'white', 0, 6.6, 'linear') 
end
end

function onCreate()
makeLuaSprite('white', 'white', -800, -300);
scaleObject('white', 1.8, 1.8);
addLuaSprite('white', true);
end