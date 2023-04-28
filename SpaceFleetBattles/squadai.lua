squadai = {}


function squadai.update(commanderAI, squadAI, squadlist, dt)

    for callsign, squadforf in pairs(squadlist) do

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
                end
            end
        end
    end

end

return squadai
