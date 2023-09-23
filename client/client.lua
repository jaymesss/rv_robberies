local QBCore = exports[Config.CoreName]:GetCoreObject()

local near = nil
local StoreKeeperRobbed = false
local VangelicoRobbed = false
local smashing = false

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for k,v in pairs (Config.Stores.Locations) do
            if GetDistanceBetweenCoords(coords, v.SafeTarget.Coords) < 30 then
                near = v
                local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if aiming and contains(Config.Stores.ShopKeeperPedHashes, GetEntityModel(targetPed)) and GetDistanceBetweenCoords(coords, GetEntityCoords(targetPed)) < 3 then
                    RobShopkeeper(targetPed)
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

Citizen.CreateThread(function()
    exports[Config.TargetName]:AddBoxZone('vangelico-fusebox', Config.Vangelico.FuseBoxTarget.Coords, 0.8, 1.2, {
        name = "vangelico-fusebox",
        heading = Config.Vangelico.FuseBoxTarget.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_robberies:client:BlowVangelicoFusebox",
                icon = "fas fa-fire",
                label = Locale.Info.fusebox_target_label   
            }
        }
    })
    exports[Config.TargetName]:AddBoxZone('vangelico-doors', Config.Vangelico.FrontDoorsTarget.Coords, 0.8, 1.2, {
        name = "vangelico-doors",
        heading = Config.Vangelico.FrontDoorsTarget.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "client",
                event = "rv_robberies:client:OpenVangelicoDoors",
                icon = "fas fa-door-open",
                label = Locale.Info.vangelico_doors_target_label   
            }
        }
    })
end)

RegisterNetEvent('rv_robberies:client:BlowVangelicoFusebox', function()
    local p = promise.new()
    local blown
    QBCore.Functions.TriggerCallback('rv_robberies:server:IsVangelicoFuseboxBlown', function(result)
        p:resolve(result)
    end)
    blown = Citizen.Await(p)
    if blown == 1 then
        QBCore.Functions.Notify(Locale.Error.already_blown, 'error', 5000)
        return
    end
    if blown == 2 then
        QBCore.Functions.Notify(Locale.Error.need_thermite, 'error', 5000)
        return
    end
    if blown == 4 then
        QBCore.Functions.Notify(Locale.Error.try_robbing_stores, 'error', 5000)
        return
    end
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:IsVangelicoDoorOpen', function(result)
        p:resolve(result)
    end)
    allowed = Citizen.Await(p)
    if allowed then
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
            TriggerServerEvent('rv_robberies:server:VangelicoBlown')
            QBCore.Functions.Notify(Locale.Success.fusebox_blown, 'success', 5000)
            exports[Config.TargetName]:AddBoxZone('vangelico-desk', Config.Vangelico.DeskTarget.Coords, 0.8, 1.2, {
                name = "vangelico-desk",
                heading = Config.Vangelico.DeskTarget.Heading,
                debugPoly = false
            }, {
                options = {
                    {
                        type = "client",
                        event = "rv_robberies:client:HackVangelicoSecurity",
                        icon = "fas fa-computer",
                        label = Locale.Info.vangelico_desk_target_label   
                    }
                }
            })
        end, math.random(4, 7), math.random(5, 10))
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_robberies:client:HackVangelicoSecurity', function()
    exports["memorygame"]:thermiteminigame(10, 3, 3, 10,
    function()
        exports[Config.TargetName]:RemoveZone('vangelico-desk')
        QBCore.Functions.Notify(Locale.Success.vangelico_hack_success, 'success', 5000)
        for k,v in pairs(Config.Vangelico.CaseZones) do
            exports[Config.TargetName]:AddBoxZone('vangelico-case-' .. v.x .. '-' .. v.y .. '-' .. v.z, v, 1, 1, {
                name = 'vangelico-case-' .. v.x .. '-' .. v.y .. '-' .. v.z,
                heading = 40,
                debugPoly = false
            }, {
                options = {
                    {
                        type = "client",
                        action = function()
                            if smashing then
                                return
                            end
                            -- Borrowed code from qb-jewelery with permission.
                            smashing = true
                            local animDict = "missheist_jewel"
                            local animName = "smash_case"
                            exports[Config.TargetName]:RemoveZone('vangelico-case-' .. v.x .. '-' .. v.y .. '-' .. v.z)
                            QBCore.Functions.Progressbar("smash_case", Locale.Info.smashing_case, 10000, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            }, {}, {}, {}, function() -- Done
                                TriggerServerEvent('rv_robberies:server:VangelicoCaseReward')
                                smashing = false
                                TaskPlayAnim(ped, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
                            end, function() -- Cancel
                                smashing = false
                                TaskPlayAnim(ped, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
                            end)
                            local ped = PlayerPedId()
                            Citizen.CreateThread(function()
                                while smashing do
                                    LoadAnimDict(animDict)
                                    TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
                                    Wait(500)
                                    TriggerServerEvent("InteractSound_SV:PlayOnSource", "breaking_vitrine_glass", 0.25)
                                    local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.6, 0)
                                    if not HasNamedPtfxAssetLoaded("scr_jewelheist") then
                                        RequestNamedPtfxAsset("scr_jewelheist")
                                    end
                                    while not HasNamedPtfxAssetLoaded("scr_jewelheist") do
                                        Wait(0)
                                    end
                                    SetPtfxAssetNextCall("scr_jewelheist")
                                    StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", plyCoords.x, plyCoords.y, plyCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                                    Wait(2500)
                                end
                            end)
                        end,
                        icon = "fas fa-ring",
                        label = Locale.Info.case_target_label
                    }
                }
            })
        end
    end,
    function()
        QBCore.Functions.Notify(Locale.Error.couldnt_hack, 'error', 5000)
    end)
end)


RegisterNetEvent('rv_robberies:client:OpenVangelicoDoors', function()
    local p = promise.new()
    local blown
    QBCore.Functions.TriggerCallback('rv_robberies:server:IsVangelicoFuseboxBlown', function(result)
        p:resolve(result)
    end)
    blown = Citizen.Await(p)
    if blown ~= 1 then
        QBCore.Functions.Notify(Locale.Error.doors_cant_open, 'error', 5000)
        return
    end
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:CanOpenVangelicoDoors', function(result)
        p:resolve(result)
    end)
    allowed = Citizen.Await(p)
    if not allowed then
        return
    end
    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    QBCore.Functions.Progressbar("picking_doors", Locale.Info.picking_lock, math.random(5000, 10000), false, true, {
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
                QBCore.Functions.Notify(Locale.Error.failed_lockpick, 'error', 5000)
                return
            end
            QBCore.Functions.Notify(Locale.Success.unlocked_door, 'success', 5000)
            TriggerServerEvent('qb-doorlock:server:updateState', 'vangelico-vangelico_doors', false, NetworkGetNetworkIdFromEntity(PlayerPedId()), true, true, true, false)
            VangelicoRobbed = true
        end, math.random(4, 7), math.random(5, 10))
    end, function() -- Cancel
    end)
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
    exports[Config.TargetName]:RemoveZone('store-safe')
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
            LoadAnimDict("amb@prop_human_bum_bin@idle_b")
            TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
            QBCore.Functions.Progressbar("robbing_keeper", Locale.Info.emptying_safe, math.random(15000, 30000), false, true, {
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
        QBCore.Functions.Notify(Locale.Success.emptied_register, 'success', 5000)
        TriggerServerEvent('rv_robberies:server:EmptiedRegister')
        LoadAnimDict("amb@prop_human_bum_bin@idle_b")
        TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
    end, function() -- Cancel
    end)
end)

function RobShopkeeper(targetPed)
    local p = promise.new()
    local allowed
    QBCore.Functions.TriggerCallback('rv_robberies:server:CheckStoreStatus', function(result)
        p:resolve(result)
    end, near)
    allowed = Citizen.Await(p)
    if not allowed then
        return
    end
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