QBCore.Functions.CreateCallback('rv_robberies:server:CanOpenVangelicoDoors', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.AdvancedLockpickItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_advanced_lockpicks, 'error')
        cb(false)
        return
    end
    Player.Functions.RemoveItem(Config.AdvancedLockpickItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.AdvancedLockpickItem], 'remove')
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:IsVangelicoFuseboxBlown', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.ThermiteItem)
    if VangelicoBlown > os.time() then
        cb(1)
        return
    end
    if item == nil then
        cb(2)
        return
    end
    if Player.PlayerData.metadata['storesrobbed'] < Config.Vangelico.RequiredStoreRobberies then
        cb(4)
        return
    end
    Player.Functions.RemoveItem(Config.ThermiteItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ThermiteItem], 'remove')
    cb(3)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:IsVangelicoDoorOpen', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if VangelicoDoor > os.time() then
        cb(true)
        return
    end
    cb(false)
end)

RegisterNetEvent('rv_robberies:server:VangelicoCaseReward', function()
    local src = source
    local reward = Config.Vangelico.Rewards[math.random(#Config.Vangelico.Rewards)]
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(reward.item, math.random(reward.amountMin, reward.amountMax))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[reward.item], 'add')
end)

RegisterNetEvent('rv_robberies:server:VangelicoBlown', function()
    VangelicoBlown = os.time() + (Config.Vangelico.RobbingCooldown * 60)
end)

RegisterNetEvent('rv_robberies:server:VangelicoDoorOpened', function()
    VangelicoDoor = os.time() + (Config.Vangelico.RobbingCooldown * 60)
end)