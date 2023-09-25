Citizen.CreateThread(function()
    for k,v in pairs(Locations.Pacific) do
        exports[Config.TargetName]:AddBoxZone('pacific-frontdesk' .. v.Name, v.FrontDesk.Coords, 1.1, 1.1, {
            name = "pacific-frontdesk-" .. v.Name,
            heading = v.FrontDesk.Heading,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        TriggerEvent('rv_robberies:client:PacificSecurity', v)
                    end,
                    icon = "fas fa-computer",
                    label = Locale.Info.crack_security
                }
            }
        })
    end
end)

RegisterNetEvent('rv_robberies:client:PacificSecurity', function(location)
    local p = promise.new()
    local hasSkill
    QBCore.Functions.TriggerCallback('rv_robberies:server:HasPacificSkill', function(result)
        p:resolve(result)
    end)
    hasSkill = Citizen.Await(p)
    if not hasSkill then
        QBCore.Functions.Notify(Locale.Error.try_robbing_paleto, 'error', 5000)
        return
    end
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:CanHackPacific', function(result)
        p:resolve(result)
    end)
    allowed = Citizen.Await(p)
    if not allowed then
        return
    end
    QBCore.Functions.Progressbar("cracking", Locale.Info.cracking_security, math.random(5000, 10000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@gangops@facility@servers@",
        anim = "hotwire",
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
        exports['ps-ui']:Circle(function(success)
            if not success then
                QBCore.Functions.Notify(Locale.Error.failed_to_crack, 'error', 5000)
                return
            end
            TriggerServerEvent('rv_robberies:server:PacificSecurityHacked')
            QBCore.Functions.Notify(Locale.Info.door_available, 'success', 5000)
            local door = GetDoorById(location, 'Main')
            exports[Config.TargetName]:AddBoxZone('pacific-door' .. door.Id, door.Coords, 1.1, 1.1, {
                name = "pacific-door-" .. door.Id,
                heading = door.Heading,
                debugPoly = false
                
            }, {
                options = {
                    {
                        type = "client",
                        action = function()
                            local p = promise.new()
                            local thermite
                            QBCore.Functions.TriggerCallback('rv_robberies:server:HasThermite', function(result)
                                p:resolve(result)
                            end)
                            thermite = Citizen.Await(p)
                            if not thermite then
                                return
                            end
                            exports['ps-ui']:Circle(function(success)
                                if not success then
                                    QBCore.Functions.Notify(Locale.Error.failed_thermite, 'error', 5000)
                                    return
                                end
                                exports[Config.TargetName]:RemoveZone('pacific-door-' .. door.Id)
                                TriggerServerEvent('qb-doorlock:server:updateState', 'banks-' .. location.Name .. ' ' .. door.Id, false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
                                AddDrawersTarget(location)
                            end, math.random(4, 7), math.random(10, 15))
                        end,
                        icon = "fas fa-door-open",
                        label = Locale.Info.open_door
                    }
                }
            })
            local door = GetDoorById(location, 'Keys')
            exports[Config.TargetName]:AddBoxZone('pacific-door' .. door.Id, door.Coords, 1.1, 1.1, {
                name = "pacific-door-" .. door.Id,
                heading = door.Heading,
                debugPoly = false
            }, {
                options = {
                    {
                        type = "client",
                        action = function()
                            local p = promise.new()
                            local keys
                            QBCore.Functions.TriggerCallback('rv_robberies:server:HasPacificKeys', function(result)
                                p:resolve(result)
                            end)
                            keys = Citizen.Await(p)
                            if not keys then
                                return
                            end
                            exports[Config.TargetName]:RemoveZone('pacific-door-' .. door.Id)
                            TriggerServerEvent('qb-doorlock:server:updateState', 'banks-' .. location.Name .. ' ' .. door.Id, false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
                            exports[Config.TargetName]:AddBoxZone('pacific-system', location.DisableSystems.Coords, 1.1, 1.1, {
                                name = "pacific-system",
                                heading = location.DisableSystems.Heading,
                                debugPoly = false
                            }, {
                                options = {
                                    {
                                        type = "client",
                                        action = function()
                                            exports["memorygame"]:thermiteminigame(10, 3, 3, 10,
                                            function()
                                                exports[Config.TargetName]:RemoveZone('pacific-system')
                                                QBCore.Functions.Notify(Locale.Success.disabled_systems)
                                                AddLowerBankDoor(location)
                                                TriggerServerEvent('rv_robberies:server:GivePacificKeycard')
                                            end,
                                            function()
                                                QBCore.Functions.Notify(Locale.Error.failed_systems, 'error', 5000)
                                            end)
                                            
                                            
                                        end,
                                        icon = "fas fa-computer",
                                        label = Locale.Info.crack_systems
                                    }
                                }
                            })
                        end,
                        icon = "fas fa-door-open",
                        label = Locale.Info.open_door
                    }
                }
            })
        end, math.random(4, 7), math.random(10, 15))
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
        QBCore.Functions.Notify("Canceled..", "error")
    end)
end)

function AddLowerBankDoor(location)
    local door = GetDoorById(location, 'Lower Bank')
    exports[Config.TargetName]:AddBoxZone('pacific-door' .. door.Id, door.Coords, 1.1, 1.1, {
        name = "pacific-door-" .. door.Id,
        heading = door.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                action = function()
                    local p = promise.new()
                    local keys
                    QBCore.Functions.TriggerCallback('rv_robberies:server:HasPacificKeycard', function(result)
                        p:resolve(result)
                    end)
                    keys = Citizen.Await(p)
                    if not keys then
                        return
                    end
                    exports[Config.TargetName]:RemoveZone('pacific-door-' .. door.Id)
                    TriggerServerEvent('qb-doorlock:server:updateState', 'banks-' .. location.Name .. ' ' .. door.Id, false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
                    AddLaptopTarget(location)
                end,
                icon = "fas fa-door-open",
                label = Locale.Info.open_door
            }
        }
    })
end

function AddLaptopTarget(location)
    exports[Config.TargetName]:AddBoxZone('pacific-keypad', location.Keypad.Coords, 1.5, 1.6, {
        name = "pacific-keypad",
        heading = location.Keypad.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                action = function()
                    QBCore.Functions.Progressbar("connecting", Locale.Info.connecting, math.random(5000, 10000), false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = "anim@gangops@facility@servers@",
                        anim = "hotwire",
                        flags = 16,
                    }, {}, {}, function() -- Done
                        local p = promise.new()
                        local laptop
                        QBCore.Functions.TriggerCallback('rv_robberies:server:HasPacificLaptop', function(result)
                            p:resolve(result)
                        end)
                        laptop = Citizen.Await(p)
                        if not laptop then
                            return
                        end
                        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                        PacificLaptopAnimation(location)
                    end, function() -- Cancel
                        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                        QBCore.Functions.Notify("Canceled..", "error")
                    end)
                end,
                icon = "fas fa-id-card",
                label = Locale.Info.keypad_label
            }
        }
    })
end

function PacificLaptopAnimation(location)
    TriggerServerEvent('rv_robberies:server:ContactPolice', location.Name, location.Employee.Coords)
    LocalPlayer.state:set("inv_busy", true, true)
    local animDict = "anim@heists@ornate_bank@hack"
    local loc = location.Keypad.AnimCoords
    RequestAnimDict(animDict)
    RequestModel("hei_prop_hst_laptop")
    RequestModel("hei_p_m_bag_var22_arm_s")
    while not HasAnimDictLoaded(animDict) or not HasModelLoaded("hei_prop_hst_laptop") or not HasModelLoaded("hei_p_m_bag_var22_arm_s") do Wait(10) end
    local ped = PlayerPedId()
    local targetPosition, targetRotation = (vec3(GetEntityCoords(ped))), vec3(GetEntityRotation(ped))
    local animPos = GetAnimInitialOffsetPosition(animDict, "hack_enter", loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, 0, 2)
    FreezeEntityPosition(ped, true)

    local netScene = NetworkCreateSynchronisedScene(animPos, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject('hei_p_m_bag_var22_arm_s', targetPosition, 1, 1, 0)
    local laptop = CreateObject('hei_prop_hst_laptop', targetPosition, 1, 1, 0)
    NetworkAddPedToSynchronisedScene(ped, netScene, animDict, "hack_enter", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene, animDict, "hack_enter_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene, animDict, "hack_enter_laptop", 4.0, -8.0, 1)

    local netScene2 = NetworkCreateSynchronisedScene(animPos, targetRotation, 2, false, true, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene2, animDict, "hack_loop", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene2, animDict, "hack_loop_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene2, animDict, "hack_loop_laptop", 4.0, -8.0, 1)

    local netScene3 = NetworkCreateSynchronisedScene(animPos, targetRotation, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, netScene3, animDict, "hack_exit", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, netScene3, animDict, "hack_exit_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(laptop, netScene3, animDict, "hack_exit_laptop", 4.0, -8.0, 1)

    Wait(200)
    NetworkStartSynchronisedScene(netScene)
    Wait(6300)
    NetworkStartSynchronisedScene(netScene2)
    Wait(2000)
    exports['hacking']:OpenHackingGame(8, 4, 4, function(Success)
        NetworkStartSynchronisedScene(netScene3)
        Wait(4600)
        NetworkStopSynchronisedScene(netScene3)
        DeleteObject(bag)
        DeleteObject(laptop)
        FreezeEntityPosition(ped, false)
        if Success then
            TriggerServerEvent('rv_robberies:server:RemoveLaptop', 'laptop_red')
            UnlockPacificDoor(location)
        end
    end)
end

function AddDrawersTarget(location)
    for k,v in pairs(location.Drawers) do
        exports[Config.TargetName]:AddBoxZone('pacific-drawers' .. v.Coords.x, v.Coords, 1.1, 1.1, {
            name = "pacific-drawers-" .. v.Coords.x,
            heading = v.Heading,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        QBCore.Functions.Progressbar("drawer", Locale.Info.searching_drawers, math.random(5000, 10000), false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = "anim@gangops@facility@servers@",
                            anim = "hotwire",
                            flags = 16,
                        }, {}, {}, function() -- Done
                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                            TriggerServerEvent('rv_robberies:server:SearchDrawers')
                        end, function() -- Cancel
                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                            QBCore.Functions.Notify("Canceled..", "error")
                        end)
                    end,
                    icon = "fas fa-magnifying-glass",
                    label = Locale.Info.search_drawers
                }
            }
        })
    end
end

function UnlockPacificDoor(location)
    local door = GetClosestObjectOfType(location.VaultDoor.Coords, 3.0, location.VaultDoor.Model)
    FreezeEntityPosition(door, false)
    SetEntityRotation(door, 0.0, 0.0, location.VaultDoor.Heading.Open)
    FreezeEntityPosition(door, true)
    CreateTrollys(location)
    for k,v in pairs(location.Trollys) do
        exports[Config.TargetName]:AddBoxZone('pacific-trolly' .. v.x, v, 1.1, 1.1, {
            name = "pacific-trolly-" .. v.x,
            heading = v.w,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        local ped = PlayerPedId()
                        exports[Config.TargetName]:RemoveZone('pacific-trolly' .. v.x)
                        QBCore.Functions.Progressbar("looting_trolly", Locale.Info.looting_trolly, 40000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        }, {
                        }, {}, {}, function() -- Done
                            TriggerServerEvent('rv_robberies:server:RobbedPaletoTrolly')
                            LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                            TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                        end, function() -- Cancel
                        end)
                        local CurrentTrolly = GetClosestObjectOfType(v.x, v.y, v.z, 1.0, 269934519, false, false, false)
                        local MoneyObject = CreateObject('hei_prop_heist_cash_pile', GetEntityCoords(ped), true)
                        SetEntityVisible(MoneyObject, false, false)
                        AttachEntityToEntity(MoneyObject, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
                        local GrabBag = CreateObject('hei_p_m_bag_var22_arm_s', GetEntityCoords(ped), true, false, false)
                        
                        local GrabOne = NetworkCreateSynchronisedScene(GetEntityCoords(CurrentTrolly), GetEntityRotation(CurrentTrolly), 2, false, false, 1065353216, 0, 1.3)
                        NetworkAddPedToSynchronisedScene(ped, GrabOne, "anim@heists@ornate_bank@grab_cash", "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
                        NetworkAddEntityToSynchronisedScene(GrabBag, GrabOne, "anim@heists@ornate_bank@grab_cash", "bag_intro", 4.0, -8.0, 1)
                        SetPedComponentVariation(ped, 5, 0, 0, 0)
                        NetworkStartSynchronisedScene(GrabOne)
                        Wait(1500)
                        SetEntityVisible(MoneyObject, true, true)
                        
                        local GrabTwo = NetworkCreateSynchronisedScene(GetEntityCoords(CurrentTrolly), GetEntityRotation(CurrentTrolly), 2, false, false, 1065353216, 0, 1.3)
                        NetworkAddPedToSynchronisedScene(ped, GrabTwo, "anim@heists@ornate_bank@grab_cash", "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
                        NetworkAddEntityToSynchronisedScene(GrabBag, GrabTwo, "anim@heists@ornate_bank@grab_cash", "bag_grab", 4.0, -8.0, 1)
                        NetworkAddEntityToSynchronisedScene(CurrentTrolly, GrabTwo, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 4.0, -8.0, 1)
                        NetworkStartSynchronisedScene(GrabTwo)
                        Wait(37000)
                        SetEntityVisible(MoneyObject, false, false)
                        
                        local GrabThree = NetworkCreateSynchronisedScene(GetEntityCoords(CurrentTrolly), GetEntityRotation(CurrentTrolly), 2, false, false, 1065353216, 0, 1.3)
                        NetworkAddPedToSynchronisedScene(ped, GrabThree, "anim@heists@ornate_bank@grab_cash", "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
                        NetworkAddEntityToSynchronisedScene(GrabBag, GrabThree, "anim@heists@ornate_bank@grab_cash", "bag_exit", 4.0, -8.0, 1)
                        NetworkStartSynchronisedScene(GrabThree)
                        
                        local NewTrolley = CreateObject(769923921, GetEntityCoords(CurrentTrolly) + vector3(0.0, 0.0, - 0.985), true, false, false)
                        SetEntityRotation(NewTrolley, GetEntityRotation(CurrentTrolly))
                        while not NetworkHasControlOfEntity(CurrentTrolly) do
                            Wait(10)
                            NetworkRequestControlOfEntity(CurrentTrolly)
                        end
                        DeleteObject(CurrentTrolly)
                        while DoesEntityExist(CurrentTrolly) do
                            Wait(10)
                            DeleteObject(CurrentTrolly)
                        end
                        PlaceObjectOnGroundProperly(NewTrolley)
                        Wait(1800)
                        DeleteEntity(GrabBag)
                        DeleteObject(MoneyObject)
                    end,
                    icon = "fas fa-money-bill",
                    label = Locale.Info.loot_trolly
                }
            }
        })
    end
    for k,v in pairs(location.Safes) do
        exports[Config.TargetName]:AddBoxZone('pacific-safe' .. v.Coords.x, v.Coords, 1.1, 1.1, {
            name = "pacific-safe-" .. v.Coords.x,
            heading = v.Heading,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        local p = promise.new()
                        local allowed
                        QBCore.Functions.TriggerCallback('rv_robberies:server:HasDrill', function(result)
                            p:resolve(result)
                        end)
                        allowed = Citizen.Await(p)
                        if not allowed then
                            return
                        end
                        local ped = PlayerPedId()
                        local pos = GetEntityCoords(ped)
                        LoadAnimDict("anim@heists@fleeca_bank@drilling")
                        TaskPlayAnim(ped, 'anim@heists@fleeca_bank@drilling', 'drill_straight_idle' , 3.0, 3.0, -1, 1, 0, false, false, false)
                        local DrillObject = CreateObject('hei_prop_heist_drill', pos.x, pos.y, pos.z, true, true, true)
                        AttachEntityToEntity(DrillObject, ped, GetPedBoneIndex(ped, 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, "bankdrill", 0.1)
                        QBCore.Functions.Progressbar("opening_safe", Locale.Info.opening_safe, 20000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        }, {
                        }, {}, {}, function() -- Done
                            LoadAnimDict("anim@heists@fleeca_bank@drilling")
                            TaskPlayAnim(ped, 'anim@heists@fleeca_bank@drilling', 'drill_straight_idle' , 3.0, 3.0, -1, 1, 0, false, false, false)
                            exports['ps-ui']:Circle(function(success)
                                if not success then
                                    QBCore.Functions.Notify(Locale.Error.failed_to_open, 'error', 5000)
                                    StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)
                                    DetachEntity(DrillObject, true, true)
                                    DeleteObject(DrillObject)
                                    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                                    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                                    return
                                end
                                LoadAnimDict("anim@heists@fleeca_bank@drilling")
                                TaskPlayAnim(ped, 'anim@heists@fleeca_bank@drilling', 'drill_straight_idle' , 3.0, 3.0, -1, 1, 0, false, false, false)
                                QBCore.Functions.Progressbar("opening_safe", Locale.Info.emptying_safe, math.random(10000, 20000), false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true
                                }, {
                                }, {}, {}, function() -- Done
                                    exports[Config.TargetName]:RemoveZone('paleto-safe' .. v.Coords.x)
                                    StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)
                                    DetachEntity(DrillObject, true, true)
                                    DeleteObject(DrillObject)
                                    TriggerServerEvent('rv_robberies:server:RobbedPaletoSafe')
                                    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                                    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                                end, function() -- Cancel
                                end)
                            end, math.random(4, 7), math.random(10, 15))
                        end, function() -- Cancel
                        end)
                    end,
                    icon = "fas fa-door-open",
                    label = Locale.Info.drill_safe
                }
            }
        })
    end
    local door = GetDoorById(location, 'Vault 1')
    exports[Config.TargetName]:AddBoxZone('pacific-indoor' .. door.Id, door.Coords, 1.2, 1.2, {
        name = "paleto-indoor-" .. door.Id,
        heading = door.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                action = function()
                    local p = promise.new()
                    local allowed
                    QBCore.Functions.TriggerCallback('rv_robberies:server:HasAdvancedLockpick', function(result)
                        p:resolve(result)
                    end)
                    allowed = Citizen.Await(p)
                    if not allowed then
                        return
                    end
                    QBCore.Functions.Progressbar("door_lockpick", Locale.Info.picking_lock, 7500, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true
                    }, {
                    }, {}, {}, function() -- Done
                        exports['ps-ui']:Circle(function(success)
                            if not success then
                                QBCore.Functions.Notify(Locale.Error.failed_lockpick, 'error', 5000)
                                LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                                TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                                return
                            end
                            exports[Config.TargetName]:RemoveZone('pacific-indoor' .. door.Id)
                            LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                            TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
                            TriggerServerEvent('qb-doorlock:server:updateState', 'banks-' .. location.Name .. ' ' .. door.Id, false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
                        end, math.random(4, 7), math.random(10, 15))
                    end, function() -- Cancel
                    end)
                end,
                icon = "fas fa-door-open",
                label = Locale.Info.lockpick_door
            }
        }
    })
    local door = GetDoorById(location, 'Vault 2')
    exports[Config.TargetName]:AddBoxZone('pacific-indoor' .. door.Id, door.Coords, 1.2, 1.2, {
        name = "paleto-indoor-" .. door.Id,
        heading = door.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                action = function()
                    local p = promise.new()
                    local allowed
                    QBCore.Functions.TriggerCallback('rv_robberies:server:HasAdvancedLockpick', function(result)
                        p:resolve(result)
                    end)
                    allowed = Citizen.Await(p)
                    if not allowed then
                        return
                    end
                    QBCore.Functions.Progressbar("door_lockpick", Locale.Info.picking_lock, 7500, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true
                    }, {
                    }, {}, {}, function() -- Done
                        exports['ps-ui']:Circle(function(success)
                            if not success then
                                QBCore.Functions.Notify(Locale.Error.failed_lockpick, 'error', 5000)
                                LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                                TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                                return
                            end
                            exports[Config.TargetName]:RemoveZone('pacific-indoor' .. door.Id)
                            LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                            TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
                            TriggerServerEvent('qb-doorlock:server:updateState', 'banks-' .. location.Name .. ' ' .. door.Id, false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
                        end, math.random(4, 7), math.random(10, 15))
                    end, function() -- Cancel
                    end)
                end,
                icon = "fas fa-door-open",
                label = Locale.Info.lockpick_door
            }
        }
    })
end

function GetDoorById(location, id)
    for k,v in pairs(location.Doors) do
        if v.Id == id then
            return v
        end
    end
end