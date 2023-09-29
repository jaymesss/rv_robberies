QBCore = exports[Config.CoreName]:GetCoreObject()

near = nil
StoreKeeperRobbed = false
VangelicoRobbed = false
smashing = false
Started = false

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for k,v in pairs (Locations.Stores) do
            if GetDistanceBetweenCoords(coords, v.SafeTarget.Coords) < 30 then
                near = v
                local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if aiming and contains(Config.Stores.ShopKeeperPedHashes, GetEntityModel(targetPed)) and GetDistanceBetweenCoords(coords, GetEntityCoords(targetPed)) < 3 then
                    if not Started then
                        Started = true
                        RobShopkeeper(targetPed)
                    end
                end
            end
        end
        if VangelicoRobbed and GetDistanceBetweenCoords(coords, Config.Vangelico.FrontDoorsTarget.Coords) > 200 then
            TriggerServerEvent('qb-doorlock:server:updateState', 'vangelico-vangelico_doors', true, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
            VangelicoRobbed = false
            for k,v in pairs(Config.Vangelico.CaseZones) do
                exports[Config.TargetName]:RemoveZone('vangelico-case-' .. v.x .. '-' .. v.y .. '-' .. v.z)
            end
        end 
        Citizen.Wait(100)
    end
end)

RegisterNetEvent('rv_robberies:client:RobSafe', function()
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:CanRobSafe', function(result)
        p:resolve(result)
    end)
    allowed = Citizen.Await(p)
    if not allowed then
        return
    end
    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    QBCore.Functions.Progressbar("safe_picklock", Locale.Info.picking_lock, 7500, false, true, {
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
            exports[Config.TargetName]:RemoveZone('store-safe')
            LoadAnimDict("amb@prop_human_bum_bin@idle_b")
            TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
            QBCore.Functions.Progressbar("emptying_safe", Locale.Info.emptying_safe, math.random(15000, 30000), false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
            }, {
            }, {}, {}, function() -- Done
                LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                TriggerServerEvent('rv_robberies:server:EmptiedSafe')
                QBCore.Functions.Notify(Locale.Success.head_to_the_register, 'success', 5000)
                exports[Config.TargetName]:AddBoxZone('store-register', near.RegisterTarget.Coords, 0.8, 1.2, {
                    name = "store-register",
                    heading = near.RegisterTarget.Heading,
                    debugPoly = false
                }, {
                    options = {
                        {
                            type = "client",
                            event = "rv_robberies:client:RobRegister",
                            icon = "fas fa-credit-card",
                            label = Locale.Info.register_target_label   
                        }
                    }
                })
            end, function() -- Cancel
            end)
        end, math.random(4, 7), math.random(10, 15))
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_robberies:client:RobRegister', function()
    exports[Config.TargetName]:RemoveZone('store-register')
    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    QBCore.Functions.Progressbar("safe_picklock", Locale.Info.emptying_register, math.random(6000, 20000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        Started = false
        QBCore.Functions.Notify(Locale.Success.emptied_register, 'success', 5000)
        TriggerServerEvent('rv_robberies:server:EmptiedRegister')
        LoadAnimDict("amb@prop_human_bum_bin@idle_b")
        Started = false
        TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_robberies:client:ReceiveBlip', function(position)
    blipRobbery = AddBlipForCoord(position.x, position.y, position.z)
    SetBlipSprite(blipRobbery , 161)
    SetBlipScale(blipRobbery , 2.0)
    SetBlipColour(blipRobbery, 3)
    PulseBlip(blipRobbery)
    Wait(1000 * (5 * 60))
    RemoveBlip(blipRobbery)
end)

RegisterNetEvent('rv_robberies:client:Dispatch', function(msg, position)
    exports["ps-dispatch"]:CustomAlert({
        coords = position,
        message = msg,
        dispatchCode = "10-90",
        description = "Check your map for info.",
        radius = 0,
        sprite = 161,
        color = 3,
        scale = 1.5,
        length = 3,
    })
end)

function RobShopkeeper(targetPed)
    local p = promise.new()
    local cops
    QBCore.Functions.TriggerCallback('rv_robberies:server:GetCopCount', function(result)
        p:resolve(result)
    end)
    cops = Citizen.Await(p)
    if cops < Config.Stores.RequiredCops then
        QBCore.Functions.Notify(Locale.Error.not_available, 'error', 5000)
        return
    end
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:CheckStoreStatus', function(result)
        p:resolve(result)
    end, near)
    allowed = Citizen.Await(p)
    if not allowed then
        return
    end
    TriggerServerEvent('rv_robberies:server:ContactPolice', near.Name, near.SafeTarget.Coords)
    TriggerServerEvent('rv_robberies:server:SetStoreRobbed', near)
    LoadAnimDict('random@arrests')
    TaskPlayAnim(targetPed, "random@arrests", "idle_2_hands_up", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
    QBCore.Functions.Progressbar("robbing_keeper", Locale.Info.robbing_keeper, 7500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        LoadAnimDict("amb@prop_human_bum_bin@idle_b")
        Started = false
        TaskPlayAnim(targetPed, "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
        QBCore.Functions.Notify(Locale.Success.head_to_the_safe, 'success', 5000)
        exports[Config.TargetName]:AddBoxZone('store-safe', near.SafeTarget.Coords, 0.8, 1.2, {
            name = "store-safe",
            heading = near.SafeTarget.Heading,
            debugPoly = false
        }, {
            options = {
                {
                    type = "client",
                    event = "rv_robberies:client:RobSafe",
                    icon = "fas fa-credit-card",
                    label = Locale.Info.safe_target_label
                }
            }
        })
    end, function() -- Cancel
    end)
end

function LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

function contains(table, val)
    for i=1,#table do
       if table[i] == val then 
          return true
       end
    end
    return false
 end

 function trim(s)
    return s:match"^%s*(.*)":match"(.-)%s*$"
 end
 
 function GunInHand() 
    return GetSelectedPedWeapon(PlayerPedId()) ~= -1569615261
 end

 function DrawText3Ds(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end