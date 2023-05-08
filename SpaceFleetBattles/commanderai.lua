commanderai = {}

local function numberOfObjects(requiredcat)
    local result = 0
    for k, Obj in pairs(OBJECTS) do
        local cat = Obj.fixture:getCategory()
        if cat == requiredcat then
            result = result + 1
        end
    end
    return result
end

function commanderai.update(dt)
    -- updates all the commanders by  ensuring each commander has decided on a strategy and is broadcasting it

    for i = 1, #commanderAI do
        if commanderAI[i].orders == nil then commanderAI[i].orders = {} end
        -- adjust cooldown on the top order
        if #commanderAI[i].orders > 0 then
            commanderAI[i].orders[1].cooldown = commanderAI[i].orders[1].cooldown - dt
            if commanderAI[i].orders[1].cooldown <= 0 then
                table.remove(commanderAI[i].orders, 1)
            end
        end

        if #commanderAI[i].orders == 0 then
            -- need to determine new orders
            local numofobjs
            if commanderAI[i].forf == enum.forfFriend then
                numofobjs = numberOfObjects(enum.categoryEnemyFighter)
            elseif commanderAI[i].forf == enum.forfEnemy then
                numofobjs = numberOfObjects(enum.categoryFriendlyFighter)
            else
                print(inspect(commanderAI[i]))
                error()
            end
            if numofobjs > 0 and BATTLE_TIMER <= BATTLE_TIMER_LIMIT then
                -- set orders to engage
                thisorder = {}
                thisorder.cooldown = 10
                thisorder.active = true         -- set to false if you want to queue it but not activate it
                thisorder.order = enum.commanderOrdersEngage
                table.insert(commanderAI[i].orders, thisorder)
                -- print("Commander orders: engage")
            else
                -- set orders to return to base
                thisorder = {}
                thisorder.cooldown = 10
                thisorder.active = true         -- set to false if you want to queue it but not activate it
                thisorder.order = enum.commanderOrdersReturnToBase
                table.insert(commanderAI[i].orders, thisorder)
                print("Commander orders: RTB")
            end
        else
            -- this commander has at least one order. Do nothing.
        end
        assert(#commanderAI[i].orders > 0)
    end
end

return commanderai
