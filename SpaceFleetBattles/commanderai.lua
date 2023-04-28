commanderai = {}

local function numberOfEnemyObjects()
    local result = 0
    for k, Obj in pairs(OBJECTS) do
        if Obj.forf == enum.forfEnemy then
            result = result + 1
        end
    end
    return result
end

function commanderai.update(commanderAI, dt)
    -- updates all the commanders by  ensuring each commander has decided on a strategy and is broadcasting it

    for i = 1, #commanderAI do
        if commanderAI[i].forf == enum.forfFriend then
            if commanderAI[i].orders == nil then commanderAI[i].orders = {} end
            if #commanderAI[i].orders == 0 then
                -- need to determine new orders
                if numberOfEnemyObjects() > 0 then
                    -- set orders to engage
                    thisorder = {}
                    thisorder.cooldown = 10
                    thisorder.active = true         -- set to false if you want to queue it but not activate it
                    thisorder.order = enum.commanderOrdersEngage
                    table.insert(commanderAI[i].orders, thisorder)
                end
            else
                -- adjust cooldown on the order stack
                for k = #commanderAI[i].orders, 1, -1 do        -- traverse backwards
                    commanderAI[i].orders[k].cooldown = commanderAI[i].orders[k].cooldown - dt
                    if commanderAI[i].orders[k].cooldown <= 0 then
                        table.remove(commanderAI[i].orders, k)
                    end
                end
            end
        elseif commanderAI[i].forf == enum.forfEnemy then
            --! enemy commander

        elseif commanderAI[i].forf == enum.forfNeutral then

        else
            error()
        end
    end
end


return commanderai
