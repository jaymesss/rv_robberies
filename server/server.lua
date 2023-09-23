QBCore = exports[Config.CoreName]:GetCoreObject()

RobbedStores = {}
VangelicoBlown = 0
VangelicoDoor = 0
PoliceAmount = {}

RegisterNetEvent('rv_robberies:server:SetStoreRobbed', function(store)
    table.insert(RobbedStores, { name = store.Name, til = os.time() + (Config.Stores.RobbingCooldown * 60) })
end)

QBCore.Functions.CreateCallback('rv_robberies:server:CheckStoreStatus', function(source, cb, store)
    local src = source
    local contains = contains(RobbedStores, store.Name)
    if contains and contains.til > os.time() then
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
end)

RegisterNetEvent('rv_robberies:server:EmptiedRegister', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', Config.Stores.RegisterReward)
end)

RegisterNetEvent('rv_robberies:server:ContactPolice', function(msg)
    local src = source
    local police = {}
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        for k,v2 in pairs(Config.PoliceJobNames) do
            if v.PlayerData.job.name == v2 and v.PlayerData.job.onduty then
                table.insert(police, v)
            end
        end
    end
    if not Config.UsingPsDispatch then
        for k,v in pairs(police) do
            TriggerClientEvent('rv_robberies:client:ReceiveBlip', v.PlayerData.source)
            TriggerClientEvent('QBCore:Notify', v.PlayerData.SoundVehicleHornThisFrame, Locale.Info.robbery_starting, 'error')
        end
        return
    end
    TriggerClientEvent('rv_robberies:server:Dispatch', src, msg)
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