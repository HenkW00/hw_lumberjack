local Chopped = false

RegisterNetEvent('hw_lumberjack:sellItems', function()
    local source = source
    local price = 0
    local xPlayer = ESX.GetPlayerFromId(source)
    for k,v in pairs(Config.Sell) do 
        local item = xPlayer.getInventoryItem(k)
        if item and item.count >= 1 then
            price = price + (v * item.count)
            xPlayer.removeInventoryItem(k, item.count)
        end
    end
    if price > 0 then
        xPlayer.addMoney(price)
        TriggerClientEvent('hw_lumberjack:notify', source, 'HW Lumberjack', Config.Alerts["successfully_sold"], 'success')
        if Config.Debug then
            print('[DEBUG] Succesfully sold items...')
        end

    else
        TriggerClientEvent('hw_lumberjack:notify', source, 'HW Lumberjack', Config.Alerts["no_item"], 'error')
        if Config.Debug then
            print('[DEBUG] Could not sell items...')
        end
    end
end)

RegisterNetEvent('hw_lumberjack:BuyAxe', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local HWAxeClassicPrice = LumberJob.AxePrice
    local axeCount = xPlayer.getInventoryItem('weapon_battleaxe').count 

    if axeCount == 0 then
        xPlayer.addInventoryItem('weapon_battleaxe', 1) 
        xPlayer.removeMoney(HWAxeClassicPrice)
        TriggerClientEvent('hw_lumberjack:notify', source, 'HW Lumberjack', Config.Alerts["axe_bought"], 'success')
        if Config.Debug then
            print('[DEBUG] Succesfully bought a axe...')
        end
    else
        TriggerClientEvent('hw_lumberjack:notify', source, 'HW Lumberjack', Config.Alerts["axe_check"], 'error')
        if Config.Debug then
            print('[DEBUG] You already have a axe in youre inventory...')
        end
    end
end)

RegisterNetEvent('hw_lumberjack:removeAxe', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local axeItem = xPlayer.getInventoryItem('weapon_battleaxe')

    if axeItem and axeItem.count >= 1 then 
        xPlayer.removeInventoryItem('weapon_battleaxe', 1)
        TriggerClientEvent('hw_lumberjack:notify', source, 'HW Lumberjack', Config.Alerts["axe_removed"], 'success')
        if Config.Debug then
            print('[DEBUG] Succesfully removed axe from inventory...')
        end
    else
        TriggerClientEvent('hw_lumberjack:notify', source, 'HW Lumberjack', Config.Alerts["no_axe"], 'error')
        if Config.Debug then
            print('[DEBUG] Could not find axe to remove...')
        end
    end
end)



ESX.RegisterServerCallback('hw_lumberjack:axe', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local axeItem = xPlayer.getInventoryItem('weapon_battleaxe')
        if axeItem and axeItem.count > 0 then
            cb(true)  
        else
            cb(false) 
        end
    end
end)


RegisterNetEvent('hw_lumberjack:setLumberStage', function(stage, state, k)
    Config.TreeLocations[k][stage] = state
    TriggerClientEvent('hw_lumberjack:getLumberStage', -1, stage, state, k)
end)

RegisterNetEvent('hw_lumberjack:setChoppedTimer', function()
    if not Chopped then
        Chopped = true
        CreateThread(function()
            Wait(Config.Timeout)
            for k, v in pairs(Config.TreeLocations) do
                Config.TreeLocations[k]["isChopped"] = false
                TriggerClientEvent('hw_lumberjack:getLumberStage', -1, 'isChopped', false, k)
            end
            Chopped = false
        end)
    end
end)

RegisterServerEvent('hw_lumberjack:recivelumber', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local lumber = math.random(LumberJob.LumberAmount_Min, LumberJob.LumberAmount_Max)
    local bark = math.random(LumberJob.TreeBarkAmount_Min, LumberJob.TreeBarkAmount_Max)
    xPlayer.addInventoryItem('tree_lumber', lumber)
    if Config.Debug then
        print('[DEBUG] Succesfully gave tree_lumber to player...')
    end
    xPlayer.addInventoryItem('tree_bark', bark)
    if Config.Debug then
        print('[DEBUG] Succesfully gave tree_bar to player...')
    end
end)

ESX.RegisterServerCallback('hw_lumberjack:lumber', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        if xPlayer.getInventoryItem("tree_lumber").count >= 1 then
            cb(true)
        else
            cb(false)
        end
    end
end)

RegisterServerEvent('hw_lumberjack:lumberprocessed', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local lumber = xPlayer.getInventoryItem('tree_lumber')
    local TradeAmount = math.random(LumberJob.TradeAmount_Min, LumberJob.TradeAmount_Max)
    local TradeRecevied = math.random(LumberJob.TradeRecevied_Min, LumberJob.TradeRecevied_Max)
    if lumber.count < 1 then 
        TriggerClientEvent('hw_lumberjack:notify', source, 'HW Lumberjack', Config.Alerts['error_lumber'], 'error')
        
        return false
    end

    local amount = lumber.count
    if amount >= 1 then
        amount = TradeAmount
    else
      return false
    end
    if lumber.count >= amount then 
        xPlayer.removeInventoryItem('tree_lumber', amount)
        if Config.Debug then
            print('[DEBUG] Succesfully removed tree_lumber for processing...')
        end
        TriggerClientEvent('hw_lumberjack:notify', source, 'HW Lumberjack', 'Igor handed over the goods', 'success')
        Wait(750)
        xPlayer.addInventoryItem('wood_plank', TradeRecevied)
        if Config.Debug then
            print('[DEBUG] Succesfully received wood_plank in inventory...')
        end
    else 
        TriggerClientEvent('hw_lumberjack:notify', source, 'HW Lumberjack', Config.Alerts['itemamount'], 'error')
        if Config.Debug then
            print('[DEBUG] Could not give wood_plank...')
            print('[DEBUG] Check youre inventory...')
        end
        return false
    end
end)
