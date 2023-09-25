FuseboxBlown = false
PaletoRobbed = false

QBCore.Functions.CreateCallback('rv_robberies:server:IsPaletoFuseboxBlown', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if FuseboxBlown then
        cb(true)
        return
    end
    cb(false)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:HasPaletoSkill', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.metadata['fleecasrobbed'] < Config.Paleto.RequiredFleecaRobberies then
        cb(false)
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:CanHackPaletoKeypad', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local keycard = Player.Functions.GetItemByName(Config.PaletoKeycardItem)
    local laptop = Player.Functions.GetItemByName(Config.Paleto.LaptopItem)
    if keycard == nil or laptop == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.missing_item, 'error')
        cb(false)
        return
    end
    if PaletoRobbed then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.cant_be_robbed, 'error')
        cb(false)
        return
    end
    if #PoliceAmount < Config.Paleto.RequiredPolice then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.cant_be_robbed, 'error')
        cb(false)
        return
    end
    cb(true)
end)

RegisterNetEvent('rv_robberies:server:UsePaletoKeycard', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(Config.PaletoKeycardItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.PaletoKeycardItem], 'remove')
end)

RegisterNetEvent('rv_robberies:server:RobbedPaletoSafe', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', math.random(Config.Paleto.SafeRewards.Cash.amountMin, Config.Paleto.SafeRewards.Cash.amountMax))
    local item = Config.Paleto.SafeRewards.Items[math.random(#Config.Paleto.SafeRewards.Items)]
    Player.Functions.AddItem(item.item, math.random(item.amountMin, item.amountMax))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.item], 'add')
end)

RegisterNetEvent('rv_robberies:server:RobbedPaletoTrolly', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Config.Paleto.TrollyRewards.Items[math.random(#Config.Paleto.TrollyRewards.Items)]
    Player.Functions.AddItem(item.item, math.random(item.amountMin, item.amountMax))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.item], 'add')
end)

RegisterNetEvent('rv_robberies:server:GetPaletoEmployeeItems', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Config.Paleto.EmployeeItems[math.random(#Config.Paleto.EmployeeItems)]
    Player.Functions.AddItem(item, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
end)

RegisterNetEvent('rv_robberies:server:SetPaletoRobbed', function()
    PaletoRobbed = true
end)
RegisterNetEvent('rv_robberies:server:PaletoFuseboxBlown', function()
    FuseboxBlown = true
end)