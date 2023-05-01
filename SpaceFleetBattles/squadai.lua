squadai = {}

function squadai.initialiseSquadList()
    for i = 65, 90 do
        for j = 1, 9 do
            local str = string.char(i) .. tostring(j)
            SQUAD_LIST[str] = nil            -- setting to nil makes it available for selection
        end
    end
end

function squadai.createSquadron(forf, shipspersquadron)
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
            squadAI[squadcallsign].orders = {}
        end
    end

    print("Created squad callsign: " .. squadcallsign)

    table.insert(SQUADS, squadcallsign)

    for i = 1, shipspersquadron do
        unitai.createFighter(forf, squadcallsign)
    end
end

function squadai.update(commanderAI, squadAI, dt)

    for callsign, squadforf in pairs(SQUAD_LIST) do

        if squadAI[callsign].orders == nil then squadAI[callsign].orders = {} end

        if #squadAI[callsign].orders == 0 then
            -- if squadforf == enum.forfFriend then
                -- check what commander is doing
                for i = 1, #commanderAI do
                    -- if commanderAI[i].forf == enum.forfFriend then
                        if commanderAI[i] ~= nil and commanderAI[i].orders[1] ~= nil then
                            if commanderAI[i].orders[1].order == enum.commanderOrdersEngage then
                                -- squad engages
                                thisorder = {}
                                thisorder.cooldown = 5
                                thisorder.active = true         -- set to false if you want to queue it but not activate it
                                thisorder.order = enum.squadOrdersEngage
                                table.insert(squadAI[callsign].orders, thisorder)
                                -- print("Squad orders: engage")
                            elseif commanderAI[i].orders[1].order == enum.commanderOrdersReturnToBase then

                                thisorder = {}
                                thisorder.cooldown = 5
                                thisorder.active = true         -- set to false if you want to queue it but not activate it
                                thisorder.order = enum.squadOrdersReturnToBase
                                table.insert(squadAI[callsign].orders, thisorder)
                                -- print("Squad orders: RTB")
                            else
                                error()
                            end
                        end
                    -- end
                end
            -- elseif squadforf == enum.forfEnemy then
                -- check what enemy commander is doing
            -- else
            --     error()
            -- end

        else
            -- cycle through all orders for this commander
            for j = #squadAI[callsign].orders, 1, -1 do
                squadAI[callsign].orders[j].cooldown = squadAI[callsign].orders[j].cooldown - dt
                if squadAI[callsign].orders[j].cooldown <= 0 then
                    table.remove(squadAI[callsign].orders, j)

                    -- print("A squad order timed out. This is the squad order table:" .. inspect(callsign))
                    -- print(inspect(squadAI[callsign].orders))
                end
            end
        end
    end

end

return squadai
