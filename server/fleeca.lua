local KidnapCooldown = 0
local MissionCooldown = 0
local FleecaRobberyCooldown = 0
local RobbedBanks = {}

QBCore.Functions.CreateCallback('rv_robberies:server:IsBankRobbed', function(source, cb, bank)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    for k,v in pairs(RobbedBanks) do
        if k == bank or v == bank then
            cb(true)
        end
    end
    cb(false)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:HasFleecaSkill', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.metadata['vangelicosrobbed'] < Config.Fleecas.RequiredVangelicoRobberies then
        cb(false)
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:CanKidnapEmployee', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if KidnapCooldown > os.time() then
        cb(false)
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:CanDoLaptopMission', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.FlashdriveItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.missing_flashdrive, 'error')
        return
    end
    if MissionCooldown > os.time() then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_missions, 'error')
        cb(false)
        return
    end
    if #PoliceAmount < Config.FlashdriveTraders.RequiredPolice then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.cant_be_robbed, 'error')
        cb(false)
        return
    end
    Player.Functions.RemoveItem(Config.FlashdriveItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.FlashdriveItem], 'remove')
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:HasDrill', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.DrillItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_drill, 'error')
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:CanAffordLaptop', function(source, cb, type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if type == 'green' then
        if Player.Functions.GetMoney('cash') < Config.FlashdriveTraders.Types.Green.Cost then
            cb(false)
            return
        end
        Player.Functions.RemoveMoney('cash', Config.FlashdriveTraders.Types.Green.Cost)
    elseif type == 'blue' then
        if Player.Functions.GetMoney('cash') < Config.FlashdriveTraders.Types.Blue.Cost then
            cb(false)
            return
        end
        Player.Functions.RemoveMoney('cash', Config.FlashdriveTraders.Types.Blue.Cost)
    elseif type == 'red' then
        if Player.Functions.GetMoney('cash') < Config.FlashdriveTraders.Types.Red.Cost then
            cb(false)
            return
        end
        Player.Functions.RemoveMoney('cash', Config.FlashdriveTraders.Types.Red.Cost)
    elseif type == 'gold' then
        if Player.Functions.GetMoney('cash') < Config.FlashdriveTraders.Types.Gold.Cost then
            cb(false)
            return
        end
        Player.Functions.RemoveMoney('cash', Config.FlashdriveTraders.Types.Gold.Cost)
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:HasAdvancedLockpick', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.AdvancedLockpickItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_advanced_lockpicks, 'error')
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:HasThermite', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.ThermiteItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_thermite, 'error')
        return
    end
    Player.Functions.RemoveItem(Config.ThermiteItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ThermiteItem], 'remove')
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_robberies:server:CanHackFleecaKeypad', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local keycard = Player.Functions.GetItemByName(Config.FleecaKeycardItem)
    local laptop = Player.Functions.GetItemByName(Config.Fleecas.LaptopItem)
    if keycard == nil or laptop == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.missing_item, 'error')
        return
    end
    if FleecaRobberyCooldown > os.time() then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.cant_be_robbed, 'error')
        cb(false)
        return
    end
    if #PoliceAmount < Config.Fleecas.RequiredPolice then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.cant_be_robbed, 'error')
        cb(false)
        return
    end
    cb(true)
end)


RegisterNetEvent('rv_robberies:server:GetEmployeeItems', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Config.Fleecas.EmployeeItems[math.random(#Config.Fleecas.EmployeeItems)]
    Player.Functions.AddItem(item, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
end)

RegisterNetEvent('rv_robberies:server:GiveLaptop', function(type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local laptop = 'laptop_' .. type
    Player.Functions.AddItem(laptop, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[laptop], 'add')
end)

RegisterNetEvent('rv_robberies:server:UseFleecaKeycard', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(Config.FleecaKeycardItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.FleecaKeycardItem], 'remove')
end)

RegisterNetEvent('rv_robberies:server:RobbedFleecaSafe', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', math.random(Config.Fleecas.SafeRewards.Cash.amountMin, Config.Fleecas.SafeRewards.Cash.amountMax))
    local item = Config.Fleecas.SafeRewards.Items[math.random(#Config.Fleecas.SafeRewards.Items)]
    Player.Functions.AddItem(item.item, math.random(item.amountMin, item.amountMax))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.item], 'add')
end)

RegisterNetEvent('rv_robberies:server:RobbedFleecaTrolly', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Config.Fleecas.TrollyRewards.Items[math.random(#Config.Fleecas.TrollyRewards.Items)]
    Player.Functions.AddItem(item.item, math.random(item.amountMin, item.amountMax))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.item], 'add')
end)

RegisterNetEvent('rv_robberies:server:RemoveLaptop', function(type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(type, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[type], 'remove')
end)

RegisterNetEvent('rv_robberies:server:SetBankRobbed', function(bank)
    FleecaRobberyCooldown = os.time() + (Config.Fleecas.RobbingCooldown * 60)
    table.insert(RobbedBanks, bank)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("fleecasrobbed", Player.PlayerData.metadata['fleecasrobbed'] + 1)
end)

RegisterNetEvent('rv_robberies:server:KidnapEmployeeCooldown', function()
    KidnapCooldown = os.time() + (Config.Fleecas.KidnapCooldown * 60)
end)