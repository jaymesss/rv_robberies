local BlownFuseboxes = {}
local Blackout = false
local USBFound = false
local VaultRobbed = fallse

QBCore.Functions.CreateCallback('rv_robberies:server:HasVaultSkill', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.metadata['pacificsrobbed'] < Config.Pacific.RequiredPaletoRobberies then
        cb(false)
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:IsVaultFuseboxBlown', function(source, cb, name)
    cb(contains(BlownFuseboxes, name))
end)

QBCore.Functions.CreateCallback('rv_robberies:server:IsBlackout', function(source, cb)
    cb(Blackout)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:HasVaultLaptop', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.Vault.LaptopItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_gold_laptop, 'error')
        cb(false)
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:CanRobVault', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if VaultRobbed then
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

QBCore.Functions.CreateCallback('rv_robberies:server:HasVaultKeycard', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.Vault.KeycardItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_keycard, 'error')
        cb(false)
        return
    end
    Player.Functions.RemoveItem(Config.Vault.KeycardItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Vault.KeycardItem], 'remove')
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:HasVaultUSB', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.Vault.USBItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_keycard, 'error')
        cb(false)
        return
    end
    cb(true)
end)

RegisterNetEvent('rv_robberies:server:BlowVaultFusebox', function(name)
    table.insert(BlownFuseboxes, name)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("vaultsrobbed", Player.PlayerData.metadata['vaultsrobbed'] + 1)
    if #BlownFuseboxes >= 3 then
        Blackout = true
        
        TriggerServerEvent("qb-weathersync:server:toggleBlackout")
        Wait(60 * (60 * 15))
        TriggerServerEvent("qb-weathersync:server:toggleBlackout")
        -- for k,v in pairs(QBCore.Functions.GetQBPlayers()) do
        --     TriggerClientEvent('rv_robberies:client:Blackout', v.PlayerData.source, true)
        -- end
    end
end)

RegisterNetEvent('rv_robberies:server:SearchLocker', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if USBFound then
        TriggerClientEvent('QBCore:Notify', src, Locale.Info.already_found, 'error')
        return
    end
    if math.random(0, 100) < 25 then
        TriggerClientEvent('QBCore:Notify', src, Locale.Info.nothing_found, 'error')
        return
    end
    USBFound = true
    Player.Functions.AddItem(Config.Vault.USBItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Vault.USBItem], 'add')
end)

RegisterNetEvent('rv_robberies:server:TakeUSB', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(Config.Vault.USBItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Vault.USBItem], 'remove')
end)

RegisterNetEvent('rv_robberies:server:GiveVaultKeycard', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(Config.Vault.KeycardItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Vault.KeycardItem], 'add')
end)
