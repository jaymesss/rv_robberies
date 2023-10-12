local SecurityHacked = false
local KeysFound = false

QBCore.Functions.CreateCallback('rv_robberies:server:HasPacificSkill', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.metadata['paletosrobbed'] < Config.Pacific.RequiredPaletoRobberies then
        cb(false)
        return
    end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("pacificsrobbed", Player.PlayerData.metadata['pacificsrobbed'] + 1)
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:CanHackPacific', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if SecurityHacked then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.cant_be_robbed, 'error')
        cb(false)
        return
    end
    if #PoliceAmount < Config.Pacific.RequiredPolice then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.cant_be_robbed, 'error')
        cb(false)
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:HasPacificKeys', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.Pacific.KeysItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_keys, 'error')
        cb(false)
        return
    end
    Player.Functions.RemoveItem(Config.Pacific.KeysItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Pacific.KeysItem], 'remove')
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:HasPacificKeycard', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.Pacific.KeycardItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_keycard, 'error')
        cb(false)
        return
    end
    Player.Functions.RemoveItem(Config.Pacific.KeycardItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Pacific.KeycardItem], 'remove')
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:HasPacificLaptop', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.Pacific.LaptopItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_red_laptop, 'error')
        cb(false)
        return
    end
    cb(true)
end)

RegisterNetEvent('rv_robberies:server:SearchDrawers', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if KeysFound then
        TriggerClientEvent('QBCore:Notify', src, Locale.Info.already_found, 'error')
        return
    end
    if math.random(0, 100) < 50 then
        TriggerClientEvent('QBCore:Notify', src, Locale.Info.nothing_found, 'error')
        return
    end
    KeysFound = true
    Player.Functions.AddItem(Config.Pacific.KeysItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Pacific.KeysItem], 'add')
end)

RegisterNetEvent('rv_robberies:server:GivePacificKeycard', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(Config.Pacific.KeycardItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Pacific.KeycardItem], 'add')
end)

RegisterNetEvent('rv_robberies:server:PacificSecurityHacked', function()
    SecurityHacked = true
end)