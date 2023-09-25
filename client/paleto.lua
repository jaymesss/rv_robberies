local KidnappedPed = nil
local Interrogating = false
local Carrying = false
local HandcuffedPed = false
local Blip = nil

Citizen.CreateThread(function()
    for k,v in pairs(Locations.Paleto) do
        RequestModel(GetHashKey(v.Employee.Model))
        while not HasModelLoaded(GetHashKey(v.Employee.Model)) do
            Wait(1)
        end
        local ped = CreatePed(5, GetHashKey(v.Employee.Model), v.Employee.Coords, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        exports[Config.TargetName]:AddBoxZone('paleto-employee' .. v.Name, v.Employee.Coords, 1.5, 1.6, {
            name = "paleto-employee-" .. v.Name,
            heading = v.Employee.Heading,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        TriggerEvent('rv_robberies:client:KidnapPaletoEmployee', ped, v)
                        TriggerServerEvent('rv_robberies:server:RemoveTarget', 'paleto-employee' .. v.Name)
                    end,
                    icon = "fas fa-gun",
                    label = Locale.Info.kidnap_employee
                }
            }
        })
        exports[Config.TargetName]:AddBoxZone('paleto-fusebox' .. trim(v.Name), v.Fusebox.Coords, 1.5, 1.6, {
            name = "paleto-fusebox-" .. trim(v.Name),
            heading = v.Fusebox.Heading,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        TriggerEvent('rv_robberies:client:PaletoFusebox')
                        local p = promise.new()
                        local hasSkill
                        QBCore.Functions.TriggerCallback('rv_robberies:server:HasPaletoSkill', function(result)
                            p:resolve(result)
                        end)
                        hasSkill = Citizen.Await(p)
                        if not hasSkill then
                            QBCore.Functions.Notify(Locale.Error.try_robbing_fleeca, 'error', 5000)
                            return
                        end
                        local p = promise.new()
                        local blown
                        QBCore.Functions.TriggerCallback('rv_robberies:server:IsPaletoFuseboxBlown', function(result)
                            p:resolve(result)
                        end)
                        blown = Citizen.Await(p)
                        if blown then
                            QBCore.Functions.Notify(Locale.Error.already_blown, 'error', 5000)
                            return
                        end
                        local p = promise.new()
                        local thermite
                        QBCore.Functions.TriggerCallback('rv_robberies:server:HasThermite', function(result)
                            p:resolve(result)
                        end)
                        thermite = Citizen.Await(p)
                        if not thermite then
                            return
                        end
                        TriggerServerEvent('rv_robberies:server:ContactPolice', 'Vangelico Robbery')
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
                            exports["memorygame"]:thermiteminigame(10, 3, 3, 10,
                            function()
                                TriggerServerEvent('rv_robberies:server:PaletoFuseboxBlown')
                                QBCore.Functions.Notify(Locale.Success.fusebox_blown)
                                exports[Config.TargetName]:AddBoxZone('paleto-keypad' .. trim(v.Name), v.Keypad.Coords, 1.5, 1.6, {
                                    name = "paleto-keypad-" .. trim(v.Name),
                                    heading = v.Keypad.Heading,
                                    debugPoly = false
                                }, {
                                    options = {
                                        {
                                            type = "client",
                                            action = function()
                                                local blown
                                                QBCore.Functions.TriggerCallback('rv_robberies:server:IsPaletoFuseboxBlown', function(result)
                                                    p:resolve(result)
                                                end)
                                                blown = Citizen.Await(p)
                                                if not blown then
                                                    QBCore.Functions.Notify(Locale.Error.fusebox_not_blown, 'error', 5000)
                                                    return
                                                end
                                                TriggerEvent('rv_robberies:client:HackPaletoKeypad', v)
                                            end,
                                            icon = "fas fa-id-card",
                                            label = Locale.Info.keypad_label
                                        }
                                    }
                                })
                            end,
                            function()
                                QBCore.Functions.Notify(Locale.Error.failed_thermite, 'error', 5000)
                            end)
                        end, function() -- Cancel
                        end)
                    end,
                    icon = "fas fa-fire",
                    label = Locale.Info.fusebox_target_label
                }
            }
        })     
    
    end
end)

Citizen.CreateThread(function()
    while true do
        local LongWait = true
        if Carrying then
            LongWait = false
            TaskPlayAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, -8.0, 100000, 49, 0, false, false, false)
            TaskPlayAnim(KidnappedPed, 'nm', 'firemans_carry', 8.0, -8.0, 100000, 33, 0, true, true, true)
        end
        if HandcuffedPed then
            LongWait = false
            LoadAnimDict('mp_arresting')
            TaskPlayAnim(KidnappedPed, "mp_arresting", "idle", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end
        if LongWait then
            Citizen.Wait(1000)
        else
            Citizen.Wait(1)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if KidnappedPed ~= nil then
            local InRange = false
            local PlayerPed = PlayerPedId()
            local PlayerPos = GetEntityCoords(PlayerPed)
            local dist = GetDistanceBetweenCoords(PlayerPos, Config.Paleto.Kidnapping.Coords) 
            if dist < 30 then
                if dist < 5 and not Interrogating then
                    DrawMarker(2,Config.Paleto.Kidnapping.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 0, 0, 155, 0, 0, 0, 1, 0, 0, 0)
                    DrawText3Ds(Config.Paleto.Kidnapping.Coords, '~g~E~w~ - ' .. Locale.Info.interrogate_text) 
                    if IsControlJustPressed(0, 38) then
                        RemoveBlip(Blip)
                        Blip = nil
                        Interrogating = true
                        Carrying = false
                        FreezeEntityPosition(KidnappedPed, false)
                        ClearPedSecondaryTask(PlayerPed)
                        ClearPedSecondaryTask(KidnappedPed)
                        DetachEntity(KidnappedPed, true, false)
                        DetachEntity(PlayerPed, true, false)
                        LoadAnimDict("mp_arrest_paired")
                        Wait(100)
                        TaskPlayAnim(PlayerPed, "mp_arrest_paired", "cop_p2_back_right", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
                        TaskPlayAnim(KidnappedPed, "mp_arrest_paired", "crook_p2_back_right", 3.0, 3.0, -1, 32, 0, 0, 0, 0 ,true, true, true)
                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "Cuff", 0.2)
                        Wait(3500)
                        HandcuffedPed = true
                        QBCore.Functions.Progressbar("searching", Locale.Info.searching_employee, math.random(10000, 20000), false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        }, {
                        }, {}, {}, function() -- Done
                            exports['ps-ui']:Circle(function(success)
                                if not success then
                                    QBCore.Functions.Notify(Locale.Error.couldnt_get_items, 'error', 5000)
                                    return
                                end
                                TriggerServerEvent('rv_robberies:server:GetPaletoEmployeeItems')
                            end, math.random(4, 7), math.random(10, 15))
                        end, function() -- Cancel
                        end)
                    end
                end
                InRange = true
            else
                InRange = false
            end
            if not InRange then
                Wait(1000)
            end
        end
        Wait(1)
    end
end)

RegisterNetEvent('rv_robberies:client:KidnapPaletoEmployee', function(ped, location)
    local p = promise.new()
    local hasSkill
    QBCore.Functions.TriggerCallback('rv_robberies:server:HasPaletoSkill', function(result)
        p:resolve(result)
    end)
    hasSkill = Citizen.Await(p)
    if not hasSkill then
        QBCore.Functions.Notify(Locale.Error.try_robbing_fleeca, 'error', 5000)
        return
    end
    local p = promise.new()
    local canKidnap
    QBCore.Functions.TriggerCallback('rv_robberies:server:CanKidnapEmployee', function(result)
        p:resolve(result)
    end)
    canKidnap = Citizen.Await(p)
    if not canKidnap then
        QBCore.Functions.Notify(Locale.Error.too_much_noise, 'error', 5000)
        return
    end
    TriggerServerEvent('rv_robberies:server:KidnapEmployeeCooldown')
    TriggerEvent('animations:client:EmoteCommandStart', {"mafia"})
    QBCore.Functions.Progressbar("searching", Locale.Info.kidnapping_employee, math.random(10000, 20000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        DeleteEntity(ped)
        local ped = CreatePed(5, GetHashKey(location.Employee.Model), location.Employee.Coords, true, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, false)
        KidnappedPed = ped
	    LoadAnimDict('missfinale_c2mcs_1')
	    LoadAnimDict('nm')
        AttachEntityToEntity(ped, PlayerPedId(), 0, 0.27, 0.15, 0.63, 0.5, 0.5, 180, false, false, false, false, 2, true)
        QBCore.Functions.Notify(Locale.Info.follow_map, 'success', 5000)
        Carrying = true
        Blip = AddBlipForCoord(Config.Paleto.Kidnapping.Coords)
        SetBlipSprite(Blip, 8)
        SetBlipColour(Blip, 3)
        SetBlipRoute(Blip, true)
        SetBlipRouteColour(Blip, 3)
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_robberies:client:HackPaletoKeypad', function(location)
    local p = promise.new()
    local hasSkill
    QBCore.Functions.TriggerCallback('rv_robberies:server:HasPaletoSkill', function(result)
        p:resolve(result)
    end)
    hasSkill = Citizen.Await(p)
    if not hasSkill then
        QBCore.Functions.Notify(Locale.Error.try_robbing_fleeca, 'error', 5000)
        return
    end
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:CanHackPaletoKeypad', function(result)
        p:resolve(result)
    end)
    allowed = Citizen.Await(p)
    if not allowed then
        return
    end
    local p = promise.new()
    local robbed
    QBCore.Functions.TriggerCallback('rv_robberies:server:IsBankRobbed', function(result)
        p:resolve(result)
    end, location.Name)
    robbed = Citizen.Await(p)
    if robbed then
        QBCore.Functions.Notify(Locale.Error.bank_already_robbed, 'error', 5000)
        return
    end
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
        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
        PaletoLaptopAnimation(location)
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
        QBCore.Functions.Notify("Canceled..", "error")
    end)
end)

function PaletoLaptopAnimation(location)
    TriggerServerEvent('rv_robberies:server:UsePaletoKeycard')
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
            TriggerServerEvent('rv_robberies:server:RemoveLaptop', 'laptop_blue')
            TriggerServerEvent('rv_robberies:server:SetPaletoRobbed')
            TriggerServerEvent('qb-doorlock:server:updateState', 'banks-' .. location.Name .. ' Out', false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
            UnlockPaletoDoor(location)
        end
    end)
end

function UnlockPaletoDoor(location)
    CreateTrollys(location)
    for k,v in pairs(location.Trollys) do
        exports[Config.TargetName]:AddBoxZone('paleto-trolly' .. v.x, v, 1.1, 1.1, {
            name = "paleto-trolly-" .. v.x,
            heading = v.w,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        local ped = PlayerPedId()
                        exports[Config.TargetName]:RemoveZone('paleto-trolly' .. v.x)
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
        exports[Config.TargetName]:AddBoxZone('paleto-safe' .. v.Coords.x, v.Coords, 1.1, 1.1, {
            name = "paleto-safe-" .. v.Coords.x,
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
    exports[Config.TargetName]:AddBoxZone('paleto-indoor' .. trim(location.Name), location.LockedDoor.Coords, 1.2, 1.2, {
        name = "paleto-indoor-" .. trim(location.Name),
        heading = location.LockedDoor.Heading,
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
                            exports[Config.TargetName]:RemoveZone('fleeca-indoor' .. trim(location.Name))
                            LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                            TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
                            TriggerServerEvent('qb-doorlock:server:updateState', 'banks-' .. location.Name .. ' In', false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
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