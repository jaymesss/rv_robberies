Citizen.CreateThread(function()
    local p = promise.new()
    local blackout
    QBCore.Functions.TriggerCallback('rv_robberies:server:IsBlackout', function(result)
        p:resolve(result)
    end)
    blackout = Citizen.Await(p)
    if blackout then
        TriggerEvent('rv_robberies:client:Blackout', true)
        return
    end
    for k,v in pairs(Locations.Vault) do
        for k2,v2 in pairs(v.FuseBoxes) do
            exports[Config.TargetName]:AddBoxZone('vault-fusebox' .. v2.Name, v2.Coords, 0.8, 1.2, {
                name = "valut-fusebox" .. v2.Name,
                heading = v2.Heading,
                debugPoly = false
            }, {
                options = {
                    {
                        type = "client",
                        action = function()
                            TriggerEvent('rv_robberies:client:BlowVaultFusebox', v2)
                        end,
                        icon = "fas fa-fire",
                        label = Locale.Info.fusebox_target_label   
                    }
                }
            })
        end
        exports[Config.TargetName]:AddBoxZone('vault-keypad' .. trim(v.Name), v.Keypad.Coords, 1.5, 1.6, {
            name = "vault-keypad-" .. trim(v.Name),
            heading = v.Keypad.Heading,
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
                            local blown
                            QBCore.Functions.TriggerCallback('rv_robberies:server:IsBlackout', function(result)
                                p:resolve(result)
                            end)
                            blown = Citizen.Await(p)
                            if not blown then
                                QBCore.Functions.Notify(Locale.Error.fuseboxes_must_be_blown, 'error', 5000)
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
                            local p = promise.new()
                            local laptop
                            QBCore.Functions.TriggerCallback('rv_robberies:server:HasVaultLaptop', function(result)
                                p:resolve(result)
                            end)
                            laptop = Citizen.Await(p)
                            if not laptop then
                                return
                            end
                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                            VaultLaptopAnimation(v)
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
end)

RegisterNetEvent('rv_robberies:client:BlowVaultFusebox', function(location)
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:CanHackPacific', function(result)
        p:resolve(result)
    end)
    allowed = Citizen.Await(p)
    if not allowed then
        return
    end
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:HasThermite', function(result)
        p:resolve(result)
    end)
    allowed = Citizen.Await(p)
    if not allowed then
        return
    end
    local p = promise.new()
    local blown
    QBCore.Functions.TriggerCallback('rv_robberies:server:IsVaultFuseboxBlown', function(result)
        p:resolve(result)
    end, location.Name)
    blown = Citizen.Await(p)
    if blown then
        QBCore.Functions.Notify(Locale.Error.already_blown, 'error', 5000)
        return
    end
    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    QBCore.Functions.Progressbar("blowing_fusebox", Locale.Info.blowing_fusebox, math.random(15000, 30000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        LoadAnimDict("amb@prop_human_bum_bin@idle_b")
        TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
        exports['ps-ui']:Circle(function(success)
            if not success then
                QBCore.Functions.Notify(Locale.Error.failed_thermite, 'error', 5000)
                return
            end
            TriggerServerEvent('rv_robberies:server:RemoveGlobalTarget','vault-fusebox' .. location.Name)
            TriggerServerEvent('rv_robberies:server:BlowVaultFusebox', location.Name)
            QBCore.Functions.Notify(Locale.Info.vault_fusebox_blown, 'success', 5000)
        end, math.random(4, 7), math.random(5, 10))
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_robberies:client:Blackout', function(isBlackout)
    if isBlackout then
        return
    end
end)

function VaultLaptopAnimation(location)
    TriggerServerEvent('rv_robberies:server:ContactPolice', location.Name, location.Keypad.Coords)
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
            TriggerServerEvent('rv_robberies:server:RemoveLaptop', 'laptop_gold')
            UnlockVaultFirstDoor(location)
        end
    end)
end

function OnInside(location)
    CreateTrollys(location)
    for k,v in pairs(location.Trollys) do
        TriggerServerEvent('rv_robberies:server:AddGlobalTarget', 'pacific-trolly' .. v.x, v, 1.1, 1.1, {
            name = "pacific-trolly-" .. v.x,
            heading = v.w,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        local ped = PlayerPedId()
                        TriggerServerEvent('rv_robberies:server:RemoveGlobalTarget','pacific-trolly' .. v.x)
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
    for k,v in pairs(location.Doors) do
        if v.Id ~= 'Main' and v.Id ~= 'First' then
            TriggerServerEvent('rv_robberies:server:AddGlobalTarget', 'vault-indoor' .. v.Id, v.Coords, 1.2, 1.2, {
                name = "vault-indoor-" .. v.Id,
                heading = v.Heading,
                debugPoly = false
            }, {
                options = {
                    {
                        type = "client",
                        action = function()
                            local p = promise.new()
                            local allowed
                            QBCore.Functions.TriggerCallback('rv_robberies:server:HasThermite', function(result)
                                p:resolve(result)
                            end)
                            allowed = Citizen.Await(p)
                            if not allowed then
                                return
                            end
                            QBCore.Functions.Progressbar("door_lockpick", Locale.Info.blowing_door, 7500, false, true, {
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
                                    TriggerServerEvent('rv_robberies:server:RemoveGlobalTarget','vault-indoor' .. v.Id)
                                    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                                    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                                    local door = GetClosestObjectOfType(v.Coords, 3.0, v.Model)
                                    FreezeEntityPosition(door, false)
                                    SetEntityRotation(door, 180.0, 180.0, 180)
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
    end
end

function UnlockVaultFirstDoor(location)
    TriggerServerEvent('qb-doorlock:server:updateState', 'banks-' .. location.Name .. ' ' .. 'First', false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
    for k,v in pairs(location.Lockers) do
        TriggerServerEvent('rv_robberies:server:AddGlobalTarget', 'vault-locker' .. v.Coords.x, v.Coords, 1.1, 1.1, {
            name = "vault-locker-" .. v.Coords.x,
            heading = v.Heading,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        QBCore.Functions.Progressbar("locker", Locale.Info.searching_locker, math.random(5000, 10000), false, true, {
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
                            TriggerServerEvent('rv_robberies:server:SearchLocker')
                        end, function() -- Cancel
                            StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                            QBCore.Functions.Notify("Canceled..", "error")
                        end)
                    end,
                    icon = "fas fa-magnifying-glass",
                    label = Locale.Info.search_locker
                }
            }
        })
    end
    local door = GetDoorById(location, 'Main')
    TriggerServerEvent('rv_robberies:server:AddGlobalTarget', 'vault-main-door', door.Coords, 1.1, 1.1, {
        name = "vault-main-door",
        heading = door.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                action = function()
                    local p = promise.new()
                    local keycard
                    QBCore.Functions.TriggerCallback('rv_robberies:server:HasVaultKeycard', function(result)
                        p:resolve(result)
                    end)
                    keycard = Citizen.Await(p)
                    if not keycard then
                        return
                    end
                    TriggerServerEvent('rv_robberies:server:RemoveGlobalTarget','vault-main-door')
                    
                    local door = GetClosestObjectOfType(location.VaultDoor.Coords, 3.0, location.VaultDoor.Model)
                    FreezeEntityPosition(door, false)
                    SetEntityRotation(door, 0.0, 0.0, location.VaultDoor.Heading.Open)
                    -- TriggerServerEvent('qb-doorlock:server:updateState', 'banks-' .. location.Name .. ' ' .. door.Id, false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
                    OnInside(location)
                end,
                icon = "fas fa-door-open",
                label = Locale.Info.open_door
            }
        }
    })
    TriggerServerEvent('rv_robberies:server:AddGlobalTarget', 'vault-computer', location.Computer.Coords, 1.1, 1.1, {
        name = "vault-computer",
        heading = location.Computer.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                action = function()
                    local p = promise.new()
                    local keycard
                    QBCore.Functions.TriggerCallback('rv_robberies:server:HasVaultUSB', function(result)
                        p:resolve(result)
                    end)
                    keycard = Citizen.Await(p)
                    if not keycard then
                        QBCore.Functions.Notify(Locale.Error.search_lockers, 'error', 5000)
                        return
                    end
                    QBCore.Functions.Progressbar("computer", Locale.Info.booting_computer, math.random(5000, 10000), false, true, {
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
                        exports["memorygame"]:thermiteminigame(10, 3, 3, 10,
                        function()
                            TriggerServerEvent('rv_robberies:server:RemoveGlobalTarget','vault-computer')
                            QBCore.Functions.Notify(Locale.Success.disabled_systems, 'success', 5000)
                            TriggerServerEvent('rv_robberies:server:TakeUSB')
                            TriggerServerEvent('rv_robberies:server:GiveVaultKeycard')
                        end,
                        function()
                            QBCore.Functions.Notify(Locale.Error.failed_systems, 'error', 5000)
                        end)
                    end, function() -- Cancel
                        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                        QBCore.Functions.Notify("Canceled..", "error")
                    end)
                end,
                icon = "fas fa-computer",
                label = Locale.Info.boot_computer
            }
        }
    })
end
