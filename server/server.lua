QBCore = exports[Config.CoreName]:GetCoreObject()

RobbedStores = {}
VangelicoBlown = 0
VangelicoDoor = 0
StoreCooldown = 0
PoliceAmount = {}

Citizen.CreateThread(function()
    while true do
        local NewPolice = {}
        for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
            for k,v2 in pairs(Config.PoliceJobNames) do
                if v.PlayerData.job.name == v2 and v.PlayerData.job.onduty then
                    table.insert(NewPolice, v)
                end
            end
        end
        PoliceAmount = NewPolice
        Citizen.Wait(10000)
    end
end)

RegisterNetEvent('rv_robberies:server:SetStoreRobbed', function(store)
    StoreCooldown =  os.time() + (Config.Stores.RobbingCooldown * 60)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("storesrobbed", Player.PlayerData.metadata['storesrobbed'] + 1)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:CheckStoreStatus', function(source, cb, store)
    local src = source
    local contains = contains(RobbedStores, store.Name)
    if StoreCooldown > os.time() then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.cant_be_robbed, 'error')
        cb(false)
        return
    end
    if #PoliceAmount < Config.Stores.RequiredCops then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.cant_be_robbed, 'error')
        cb(false)
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:CanRobSafe', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.LockpickItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_lockpicks, 'error')
        cb(false)
        return
    end
    Player.Functions.RemoveItem(Config.LockpickItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.LockpickItem], 'remove')
    cb(true)
end)

RegisterNetEvent('rv_robberies:server:EmptiedSafe', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', Config.Stores.SafeReward)
    if math.random(1, 100) < 25 then
        Player.Functions.AddItem(Config.Stores.RareSafeItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Stores.RareSafeItem], 'add')
    end
end)

RegisterNetEvent('rv_robberies:server:EmptiedRegister', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', Config.Stores.RegisterReward)
end)

RegisterNetEvent('rv_robberies:server:ContactPolice', function(msg, coords)
    local src = source
    local Ps = false
    for k,v in pairs(PoliceAmount) do
        if not Config.UsingPsDispatch then
            TriggerClientEvent('rv_robberies:client:ReceiveBlip', v.PlayerData.source, coords)
            TriggerClientEvent('QBCore:Notify', v.PlayerData.source, Locale.Info.robbery_starting, 'error')
        else
            if not Ps then
                Ps = true
                TriggerClientEvent('rv_robberies:client:Dispatch', src, msg, coords)
            end
        end
    end
end)

RegisterNetEvent('rv_robberies:server:AddGlobalTarget', function(name, coords, sizeX, sizeY, data, options)
    TriggerClientEvent('rv_robberies:client:AddGlobalTarget', -1, name, coords, sizeX, sizeY, data, options)
end)

RegisterNetEvent('rv_robberies:server:RemoveGlobalTarget', function(target)
    TriggerClientEvent('rv_robberies:client:RemoveGlobalTarget', -1, target)
end)

function contains(table, val)
    for i=1,#table do
       if table[i].name == val then 
          return table[i]
       end
    end
    return false
end
 
QBCore.Functions.CreateCallback('rv_robberies:server:GetCopCount', function(source, cb)
	local amount = 0
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        for k,v2 in pairs(Config.PoliceJobNames) do
            if v.PlayerData.job.name == v2 and v.PlayerData.job.onduty then
                amount = amount + 1
            end
        end
    end
    PoliceAmount[source] = amount
    cb(amount)
end)

RegisterNetEvent('rv_robberies:server:DeleteObject', function(netId)
    local object = NetworkGetEntityFromNetworkId(netId)
	DeleteEntity(object)
end)