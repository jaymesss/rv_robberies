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
    if blown == 5 then
        QBCore.Functions.Notify(Locale.Error.cant_be_robbed, 'error', 5000)
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
    TriggerServerEvent('rv_robberies:server:ContactPolice', 'Vangelico Robbery', Config.Vangelico.DeskTarget.Coords)
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
    local cops
    QBCore.Functions.TriggerCallback('rv_robberies:server:GetCopCount', function(result)
        p:resolve(result)
    end)
    cops = Citizen.Await(p)
    if cops < Config.Vangelico.RequiredCops then
        QBCore.Functions.Notify(Locale.Error.not_available, 'error', 5000)
        return
    end
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