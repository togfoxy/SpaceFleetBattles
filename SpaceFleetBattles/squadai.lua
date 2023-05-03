squadai = {}

function squadai.initialiseSquadList()
    for i = 65, 90 do
        for j = 1, 9 do
            local str = string.char(i) .. tostring(j)
            SQUAD_LIST[str] = nil            -- setting to nil makes it available for selection
        end
    end
end

function squadai.createSquadron(forf)
    -- create a wing of 6 units
    -- the squadron is a concept only and is created by giving x fighters the same squad id
    -- input: forf = friend or foe. example: enum.forfFriend

    -- get a random and empty callsign from the squadlist
    -- the squad callsign is a two character code. the squadlist ensures it is unique
    local squadcallsign = nil
    while squadcallsign == nil do
        local txt = string.char(love.math.random(65, 90))
        local txt = txt .. tostring(love.math.random(1,9))
        squadcallsign = txt
        if SQUAD_LIST[squadcallsign] == nil then

            SQUAD_LIST[squadcallsign] = forf       -- mark this squad as friend or enemy

            squadAI[squadcallsign] = {}
            squadAI[squadcallsign].forf = forf
            squadAI[squadcallsign].orders = {}
        end
    end

    print("Created squad callsign: " .. squadcallsign)

    table.insert(SQUADS, squadcallsign)

    for i = 1, SHIPS_PER_SQUADRON do
        unitai.createFighter(forf, squadcallsign)
    end
end

function squadai.update(commanderAI, squadAI, dt)
    -- cycle through all squads and assign orders or cool down existing orders
    -- the commanderAI is all the commanders. Be sure to filter into the one appropriate for the squad
    for callsign, squadforf in pairs(SQUAD_LIST) do -- cycle through all known squads (SQUAD_LIST) e.g. C7 = enum.forfFriend
        if squadAI[callsign].orders == nil then squadAI[callsign].orders = {} end

        for j = #squadAI[callsign].orders, 1, -1 do
            squadAI[callsign].orders[j].cooldown = squadAI[callsign].orders[j].cooldown - dt
            if squadAI[callsign].orders[j].cooldown <= 0 then
                table.remove(squadAI[callsign].orders, j)
            end
        end

        if #squadAI[callsign].orders == 0 then
            -- squad has no current orders. Check what commander is ordering
            for i = 1, #commanderAI do
                if commanderAI[i] ~= nil then
                    if commanderAI[i].forf == squadAI[callsign].forf then
                        if commanderAI[i].orders ~= nil then
                            if commanderAI[i].orders[1].order ~= nil then
                                if commanderAI[i].orders[1].order == enum.commanderOrdersEngage then
                                    -- squad engages. Add the order to the squadAI
                                    thisorder = {}
                                    thisorder.cooldown = 5
                                    thisorder.active = true         -- set to false if you want to queue it but not activate it
                                    thisorder.order = enum.squadOrdersEngage
                                    table.insert(squadAI[callsign].orders, thisorder)
                                    -- print("Squad orders: engage")
                                elseif commanderAI[i].orders[1].order == enum.commanderOrdersReturnToBase then
                                    -- squad RTB
                                    thisorder = {}
                                    thisorder.cooldown = 5
                                    thisorder.active = true         -- set to false if you want to queue it but not activate it
                                    thisorder.order = enum.squadOrdersReturnToBase
                                    table.insert(squadAI[callsign].orders, thisorder)
                                    -- print("Squad orders: RTB")
                                else
                                    error("Commander has an unexpected order.", 80)
                                end
                            else
                                print(inspect(commanderAI[i].orders[1]))
                                error("Commander has an unexpected order.", 83)
                            end
                        else
                            --! is this an error?
                            print("Commander has no orders. Is that possible?")
                        end
                    end
                else
                    --! is this an error?
                    print("Hello world")
                end
            end
        else
            -- do nothing. Cooldown will be invoked next cycle
        end
    end

end

return squadai
