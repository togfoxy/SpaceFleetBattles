squadai = {}

function squadai.update(dt)
    -- cycle through all squads and assign orders or cool down existing orders
    -- the commanderAI is all the commanders. Be sure to filter into the one appropriate for the squad

    for callsign, squad in pairs(squadAI) do
        if squad.orders == nil then squad.orders = {} end

        -- cool down the top order
        if #squad.orders > 0 then
            squad.orders[1].cooldown = squad.orders[1].cooldown - dt
            if squad.orders[1].cooldown <= 0 then
                table.remove(squadAI[callsign].orders, 1)
            end
        end

        if #squad.orders == 0 then
            -- squad has no current orders. Check what commander is ordering
            for i = 1, #commanderAI do
                if commanderAI[i] ~= nil then
                    if commanderAI[i].forf == squad.forf then
                        if commanderAI[i].orders ~= nil then
                            if commanderAI[i].orders[1].order ~= nil then
                                if commanderAI[i].orders[1].order == enum.commanderOrdersEngage then
                                    -- squad engages. Add the order to the squadAI
                                    thisorder = {}
                                    thisorder.cooldown = 5
                                    thisorder.active = true         -- set to false if you want to queue it but not activate it
                                    thisorder.order = enum.squadOrdersEngage
                                    table.insert(squadAI[callsign].orders, thisorder)
                                    print("Squad orders: engage")
                                elseif commanderAI[i].orders[1].order == enum.commanderOrdersReturnToBase then
                                    -- squad RTB
                                    thisorder = {}
                                    thisorder.cooldown = 5
                                    thisorder.active = true         -- set to false if you want to queue it but not activate it
                                    thisorder.order = enum.squadOrdersReturnToBase
                                    table.insert(squadAI[callsign].orders, thisorder)
                                    print("Squad orders: RTB")
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
                    else
                        -- this commander is not the commander for this squad
                        -- print("Wrong commander. Skipping to next commander")
                    end
                else
                    --! is this an error?
                    print("Hello world")
                end
            end
        else
            -- do nothing. Cooldown will be invoked next cycle
            --! debugging
            -- print("Number of squad orders: " .. #squad.orders)
            -- print(inspect(squad.orders))
            -- print(callsign .. " squad has order: " .. squad.orders[1].order)
        end

        if not (squad.orders[1] ~= nil) then
            print(inspect(squad.orders))
        end
        assert(squad.orders[1] ~= nil)
    end
end

return squadai
