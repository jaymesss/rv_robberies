local KidnappedPed = nil
local TopFloorNotification = false
local Interrogating = false
local Carrying = false
local HandcuffedPed = false
local Blip = nil

local MissionType = nil
local CurrentMission = nil
local Spawned = false
local SpawnedPeds = {}

Citizen.CreateThread(function()
    for k,v in pairs(Config.FlashdriveTraders.Types) do
        RequestModel(GetHashKey(v.Ped.Model))
        while not HasModelLoaded(GetHashKey(v.Ped.Model)) do
            Wait(1)
        end
        local ped = CreatePed(5, GetHashKey(v.Ped.Model), v.Ped.Coords, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        exports[Config.TargetName]:AddBoxZone('flashdrive-trader-' .. k, v.Target.Coords, 1.5, 1.6, {
            name = "flashdrive-trader-" .. k,
            heading = v.Target.Heading,
            debugPoly = false
        }, {
            options = {
                {
                    action = function()
                        TriggerEvent("rv_robberies:client:FlashdriveTrader", string.lower(k))
                    end,
                    icon = "fas fa-computer",
                    label = Locale.Info.trade_flashdrive
                }
            }
        })
    end

    for k,v in pairs(Locations.Fleecas) do
        RequestModel(GetHashKey(v.Employee.Model))
        while not HasModelLoaded(GetHashKey(v.Employee.Model)) do
            Wait(1)
        end
        local ped = CreatePed(5, GetHashKey(v.Employee.Model), v.Employee.Coords, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TriggerServerEvent('rv_robberies:server:AddGlobalTarget','fleeca-employee' .. v.Name, v.Employee.Coords, 1.5, 1.6, {
            name = "fleeca-employee-" .. v.Name,
            heading = v.Employee.Heading,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        TriggerEvent('rv_robberies:client:KidnapEmployee', ped, v)
                        TriggerServerEvent('rv_robberies:server:RemoveTarget', 'fleeca-employee' .. v.Name)
                    end,
                    icon = "fas fa-gun",
                    label = Locale.Info.kidnap_employee
                }
            }
        })
        TriggerServerEvent('rv_robberies:server:AddGlobalTarget','fleeca-keypad' .. trim(v.Name), v.Keypad.Coords, 1.5, 1.6, {
            name = "fleeca-keypad-" .. trim(v.Name),
            heading = v.Keypad.Heading,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        TriggerEvent('rv_robberies:client:HackFleecaKeypad', v)
                    end,
                    icon = "fas fa-id-card",
                    label = Locale.Info.keypad_label
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
        
        if CurrentMission ~= nil then
            local ped = PlayerPedId()
            if not Spawned and GetDistanceBetweenCoords(GetEntityCoords(ped), CurrentMission.Peds[1].Coords) <= 60 then
                SpawnMission()
            end
            if Spawned then
                local dead = 0
                for k,v in pairs(SpawnedPeds) do
                    if IsPedDeadOrDying(v) then
                        dead = dead + 1
                    end
                end
                if dead == #SpawnedPeds then
                    EndMission()
                end
            end
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if KidnappedPed ~= nil then
            local InRange = false
            local PlayerPed = PlayerPedId()
            local PlayerPos = GetEntityCoords(PlayerPed)
            local dist = GetDistanceBetweenCoords(PlayerPos, Config.Fleecas.Kidnapping.Coords) 
            if dist < 30 then
                if not TopFloorNotification then
                    TopFloorNotification = true
                    QBCore.Functions.Notify(Locale.Info.take_to_top_floor, 'success', 5000)
                end
                if dist < 5 and not Interrogating then
                    DrawMarker(2,Config.Fleecas.Kidnapping.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 0, 0, 155, 0, 0, 0, 1, 0, 0, 0)
                    DrawText3Ds(Config.Fleecas.Kidnapping.Coords, '~g~E~w~ - ' .. Locale.Info.interrogate_text) 
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
                                TriggerServerEvent('rv_robberies:server:GetEmployeeItems')
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

RegisterNetEvent('rv_robberies:client:KidnapEmployee', function(ped, location)

    local p = promise.new()
    local hasSkill
    QBCore.Functions.TriggerCallback('rv_robberies:server:HasFleecaSkill', function(result)
        p:resolve(result)
    end)
    hasSkill = Citizen.Await(p)
    if not hasSkill then
        QBCore.Functions.Notify(Locale.Error.try_robbing_vangelico, 'error', 5000)
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
    RemoveAllPedWeapons(PlayerPedId(), true)
    TriggerEvent('animations:client:EmoteCommandStart', {"mafia"})
    TriggerServerEvent('rv_robberies:server:KidnapEmployeeCooldown')
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
        Blip = AddBlipForCoord(Config.Fleecas.Kidnapping.Coords)
        SetBlipSprite(Blip, 8)
        SetBlipColour(Blip, 3)
        SetBlipRoute(Blip, true)
        SetBlipRouteColour(Blip, 3)
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_robberies:client:FlashdriveTrader', function(type)
    local options = {}
    if type == 'green' then
        options[#options+1] = {
            title = Locale.Info.green_laptop.. ' - $' .. Config.FlashdriveTraders.Types.Green.Cost,
            icon = 'computer',
            onSelect = function()   
                TriggerEvent('rv_robberies:client:GiveLaptopMission', 'green')
            end
        }
    end
    if type == 'blue' then
        options[#options+1] = {
            title = Locale.Info.blue_laptop .. ' - $' .. Config.FlashdriveTraders.Types.Blue.Cost,
            icon = 'computer',
            onSelect = function()   
                TriggerEvent('rv_robberies:client:GiveLaptopMission', 'blue')
            end
        }
    end
    if type == 'gold' then
        options[#options+1] = {
            title = Locale.Info.gold_laptop .. ' - $' .. Config.FlashdriveTraders.Types.Gold.Cost,
            icon = 'computer',
            onSelect = function()   
                TriggerEvent('rv_robberies:client:GiveLaptopMission', 'gold')
            end
        }
    end
    if type == 'red' then
        options[#options+1] = {
            title = Locale.Info.red_laptop .. ' - $' .. Config.FlashdriveTraders.Types.Green.Cost,
            icon = 'computer',
            onSelect = function()
                TriggerEvent('rv_robberies:client:GiveLaptopMission', 'red')
            end
        }
    end
    lib.registerContext({
        id = 'flashdrive_trader',
        title = Locale.Info.which_computer,
        options = options,
        onExit = function()
        end
    })
    lib.showContext('flashdrive_trader')
end)

RegisterNetEvent('rv_robberies:client:GiveLaptopMission', function(type)
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:CanDoLaptopMission', function(result)
        p:resolve(result)
    end)
    allowed = Citizen.Await(p)
    if not allowed then
        return
    end
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:CanAffordLaptop', function(result)
        p:resolve(result)
    end)
    allowed = Citizen.Await(p)
    if not allowed then
        QBCore.Functions.Notify(Locale.Error.cannot_afford_mission, 'error', 5000)
        return
    end
    MissionType = type
    GiveMission()
end)

RegisterNetEvent('rv_robberies:client:HackFleecaKeypad', function(location)
    local p = promise.new()
    local hasSkill
    QBCore.Functions.TriggerCallback('rv_robberies:server:HasFleecaSkill', function(result)
        p:resolve(result)
    end)
    hasSkill = Citizen.Await(p)
    if not hasSkill then
        QBCore.Functions.Notify(Locale.Error.try_robbing_vangelico, 'error', 5000)
        return
    end
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:CanHackFleecaKeypad', function(result)
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
        FleecaLaptopAnimation(location)
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
        QBCore.Functions.Notify("Canceled..", "error")
    end)
end)

function GiveMission()
    CurrentMission = TradeMissions[math.random(#TradeMissions)]
    Blip = AddBlipForCoord(CurrentMission.Peds[1].Coords)
    SetBlipSprite(Blip, 8)
    SetBlipColour(Blip, 3)
    SetBlipRoute(Blip, true)
    SetBlipRouteColour(Blip, 3)
    QBCore.Functions.Notify(Locale.Info.marked_mission, 'success', 5000)
end

function SpawnMission()
    Spawned = true
    local ped = PlayerPedId()
    SetPedRelationshipGroupHash(ped, GetHashKey('PLAYER'))
    AddRelationshipGroup('ShooterPeds')
    for k,v in pairs(CurrentMission.Peds) do
        RequestModel(GetHashKey(v.Model))
        while not HasModelLoaded(GetHashKey(v.Model)) do
            Wait(1)
        end
        shooter = CreatePed(1, GetHashKey(v.Model), v.Coords, false, false)
        NetworkRegisterEntityAsNetworked(shooter)
        networkID = NetworkGetNetworkIdFromEntity(shooter)
        SetNetworkIdCanMigrate(networkID, true)
        GiveWeaponToPed(shooter, GetHashKey(v.Weapon), 255, false, false) 
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetEntityAsMissionEntity(shooter)
        SetPedDropsWeaponsWhenDead(shooter, false)
        SetPedRelationshipGroupHash(shooter, GetHashKey("ShooterPeds"))
        SetEntityVisible(shooter, true)
        SetPedRandomComponentVariation(shooter, 0)
        SetPedRandomProps(shooter)
        SetPedCombatMovement(shooter, 3)
        SetPedAlertness(shooter, 3)
        SetPedAccuracy(shooter, 60)
        SetPedMaxHealth(shooter, v.Health)
        TaskCombatPed(shooter, ped, 0, 16)
        table.insert(SpawnedPeds, shooter)
        Wait(100)
    end
end

function EndMission()
    QBCore.Functions.Notify(Locale.Success.got_laptop, 'success', 5000)
    TriggerServerEvent('rv_robberies:server:GiveLaptop', MissionType)
    CurrentMission = nil
    MissionType = nil
    RemoveBlip(Blip)
    Spawned = false    
end

function FleecaLaptopAnimation(location)
    TriggerServerEvent('rv_robberies:server:UseFleecaKeycard')
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
            TriggerServerEvent('rv_robberies:server:RemoveLaptop', 'laptop_green')
            TriggerServerEvent('rv_robberies:server:SetBankRobbed', location.Name)
            UnlockDoor(location)
        end
    end)
end

function UnlockDoor(location)
    local door = GetClosestObjectOfType(location.Door.Coords, 3.0, location.Door.Model)
    FreezeEntityPosition(door, false)
    SetEntityRotation(door, 0.0, 0.0, location.Door.Heading.Open)
    FreezeEntityPosition(door, true)
    CreateTrollys(location)
    for k,v in pairs(location.Trollys) do
        TriggerServerEvent('rv_robberies:server:AddGlobalTarget', 'fleeca-trolly' .. v.x, v, 0.8, 1.0, {
            name = "fleeca-trolly-" .. v.x,
            heading = v.w,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    action = function()
                        TriggerServerEvent('rv_robberies:server:RemoveGlobalTarget', 'fleeca-trolly' .. v.x)
                        local ped = PlayerPedId()
                        QBCore.Functions.Progressbar("looting_trolly", Locale.Info.looting_trolly, 40000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        }, {
                        }, {}, {}, function() -- Done
                            TriggerServerEvent('rv_robberies:server:RobbedFleecaTrolly')
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
        TriggerServerEvent('rv_robberies:server:AddGlobalTarget','fleeca-safe' .. v.Coords.x, v.Coords, 0.8, 1.0, {
            name = "fleeca-safe-" .. v.Coords.x,
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
                                    TriggerServerEvent('rv_robberies:server:RemoveGlobalTarget', 'fleeca-safe' .. v.Coords.x)
                                    StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)
                                    DetachEntity(DrillObject, true, true)
                                    DeleteObject(DrillObject)
                                    TriggerServerEvent('rv_robberies:server:RobbedFleecaSafe')
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
    TriggerServerEvent('rv_robberies:server:AddGlobalTarget','fleeca-indoor' .. trim(location.Name), location.LockedDoor.Coords, 0.8, 1.0, {
        name = "fleeca-indoor-" .. trim(location.Name),
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
                            TriggerServerEvent('rv_robberies:server:RemoveGlobalTarget', 'fleeca-indoor' .. trim(location.Name))
                            LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                            TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
                            TriggerServerEvent('qb-doorlock:server:updateState', 'banks-' .. location.Name, false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
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

function CreateTrollys(location)
    RequestModel("hei_prop_hei_cash_trolly_01")
    RequestModel("ch_prop_gold_trolly_01a")
    while not HasModelLoaded("hei_prop_hei_cash_trolly_01") or not HasModelLoaded("ch_prop_gold_trolly_01a") do Wait(10) end
    for k, v in pairs(location.Trollys) do
        local oldcashtrolley = GetClosestObjectOfType(v.x, v.y, v.z, 1.0, 269934519, false, false, false)
        if oldcashtrolley ~= 0 then
            local netId = NetworkGetNetworkIdFromEntity(oldcashtrolley)
            TriggerServerEvent('rv_robberies:server:DeleteObject', netId)
            Wait(500)
        end
        local emptytrolly = GetClosestObjectOfType(v.x, v.y, v.z, 1.0, 769923921, false, false, false)
        if emptytrolly ~= 0 then
            local netId = NetworkGetNetworkIdFromEntity(emptytrolly)
            TriggerServerEvent('rv_robberies:server:DeleteObject', netId)
            Wait(500)
        end
        local trolly = CreateObject(269934519, v.x, v.y, v.z, 1, 0, 0)
        SetEntityHeading(trolly, v.w)
        FreezeEntityPosition(trolly, true)
        SetEntityInvincible(trolly, true)
        PlaceObjectOnGroundProperly(trolly)
    end
end

function GetTrader(type) 
    for k,v in pairs(Config.FlashdriveTraders.Types) do
        if k == type then
            return v
        end
    end
end