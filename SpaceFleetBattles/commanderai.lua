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
            local numoffriends = numberOfObjects(enum.categoryFriendlyFighter)
            local numoffoes = numberOfObjects(enum.categoryEnemyFighter)
            local ratio     -- friend vs enemy

            if commanderAI[i].forf == enum.forfFriend then
                ratio = numoffriends / numoffoes
            elseif commanderAI[i].forf == enum.forfEnemy then
                ratio = numoffoes / numoffriends
            else
                print(inspect(commanderAI[i]))
                error()
            end
            if ratio > 0.66 and RTB_TIMER <= RTB_TIMER_LIMIT then		--! what happens when one side starts with ratio < 0.66?
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
				if ratio <= 0.66 then		-- can retreat due to ratio or to timer.
					-- this commander has lost the battle. Adjust fleet moves accordingly
					if SCORE.loser == 0 then SCORE.loser = commanderAI[i].forf end
					if commanderAI[i].forf == enum.forfFriend then
						FLEET.movesLeft = -1			--! test
					elseif commanderAI[i].forf == enum.forfEnemy then
						FLEET.movesLeft = 1				--! test
					else
						error()
					end
				end
            end
        else
            -- this commander has at least one order. Do nothing.
        end
        assert(#commanderAI[i].orders > 0)
    end
end

return commanderai
