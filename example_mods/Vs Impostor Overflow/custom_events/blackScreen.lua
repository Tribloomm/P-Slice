function createGraphic()

    makeLuaSprite('blackSquare', '', 0, 0);

    makeGraphic('blackSquare', 1280, 720, '000000');

    setScrollFactor('blackSquare', 0, 0);

    setObjectCamera('blackSquare', 'hud');

    setObjectOrder('blackSquare', 9999999);

    screenCenter('blackSquare');


    addLuaSprite('blackSquare', true);

end


function removeGraphic()

    removeLuaSprite('blackSquare', true);

end


function onEvent(name,val1,val2)
    if (name == 'blackScreen') then
        if val1 == 'false' then

            removeGraphic()

        else

            createGraphic()

        end
    end
end