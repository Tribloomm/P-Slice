
function onEvent(eventName, value1, value2)
    if eventName == 'Force Cam Section' then
            if value1 == '1' then
                runHaxeCode([[
                    game.moveCamera(true,false);
                    game.callOnLuas('onMoveCamera', ['dad']);
                ]])
                
            elseif value1 == '2' then
                runHaxeCode([[
                    game.moveCamera(false,false);
                    game.callOnLuas('onMoveCamera', ['boyfriend']);
                ]])
            elseif value1 == '3' then
                runHaxeCode([[
                    game.moveCamera(true,true);
                    game.callOnLuas('onMoveCamera', ['gf']);
                ]])
            else
                triggerEvent('Camera Follow Pos' , '', '')
            end
        end
        end


end