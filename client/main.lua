local chopping = false
local LumberDepo = Config.Blips.LumberDepo
local LumberProcessor = Config.Blips.LumberProcessor
local LumberSeller = Config.Blips.LumberSeller

RegisterNetEvent('hw_lumberjack:getLumberStage', function(stage, state, k)
    Config.TreeLocations[k][stage] = state
end)

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(3)
    end
end

local function axe()
    local ped = PlayerPedId()
    local pedWeapon = GetSelectedPedWeapon(ped)

    for k, v in pairs(Config.Axe) do
        if pedWeapon == k then
            return true
        end
    end

    TriggerEvent('hw_lumberjack:notify', 'HW Lumberjack', Config.Alerts["error_axe"], 'error')
end

local function ChopLumber(k)
    local animDict = "melee@hatchet@streamed_core"
    local animName = "plyr_rear_takedown_b"
    local trClassic = PlayerPedId()
    local choptime = LumberJob.ChoppingTreeTimer
    chopping = true
    FreezeEntityPosition(trClassic, true)
    if lib.progressBar({
        duration = choptime,
        label = Config.Alerts["chopping_tree"],
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = true
        },
        anim = {
            dict = animDict,
            clip = animName
        },
    }) then  
        TriggerServerEvent('hw_lumberjack:setLumberStage', "isChopped", true, k)
        TriggerServerEvent('hw_lumberjack:setLumberStage', "isOccupied", false, k)
        TriggerServerEvent('hw_lumberjack:recivelumber')
        TriggerServerEvent('hw_lumberjack:setChoppedTimer')
        chopping = false
        TaskPlayAnim(trClassic, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
        FreezeEntityPosition(trClassic, false)
    else 
        ClearPedTasks(trClassic)
        TriggerServerEvent('hw_lumberjack:setLumberStage', "isOccupied", false, k)
        chopping = false
        TaskPlayAnim(trClassic, animDict, "exit", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
        FreezeEntityPosition(trClassic, false)
    end
    TriggerServerEvent('hw_lumberjack:setLumberStage', "isOccupied", true, k)
    CreateThread(function()
        while chopping do
            loadAnimDict(animDict)
            TaskPlayAnim(trClassic, animDict, animName, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
            Wait(3000)
        end
    end)
end

RegisterNetEvent('hw_lumberjack:StartChopping', function()
    for k, v in pairs(Config.TreeLocations) do
        if not Config.TreeLocations[k]["isChopped"] then
            if axe() then
                ChopLumber(k)
            end
        end
    end
end)

if Config.Job then
    CreateThread(function()
        for k, v in pairs(Config.TreeLocations) do
            exports["qtarget"]:AddBoxZone("trees" .. k, v.coords, 1.5, 1.5, {
                name = "trees" .. k,
                heading = 40,
                minZ = v.coords["z"] - 2,
                maxZ = v.coords["z"] + 2,
                debugPoly = false
            }, {
                options = {
                    {
                        action = function()
                            if axe() then
                                ChopLumber(k)
                            end
                        end,
                        event = "hw_lumberjack:StartChopping",
                        icon = "fa fa-hand",
                        label = Config.Alerts["Tree_label"],
                        job = "lumberjack",
                        canInteract = function()
                            if v["isChopped"] or v["isOccupied"] then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.0
            })

        end
    end)
    exports['qtarget']:AddBoxZone("lumberjackdepo", LumberDepo.targetZone, 1, 1, {
        name = "Lumberjackdepo",
        heading = LumberDepo.targetHeading,
        debugPoly = false,
        minZ = LumberDepo.minZ,
        maxZ = LumberDepo.maxZ,
    }, {
        options = {
        {
          event = "hw_lumberjack:bossmenu",
          icon = "Fas Fa-hands",
          label = Config.Alerts["depo_label"],
          job = "lumberjack",
        },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("LumberProcessor", LumberProcessor.targetZone, 1, 1, {
        name = "LumberProcessor",
        heading = LumberProcessor.targetHeading,
        debugPoly = false,
        minZ = LumberProcessor.minZ,
        maxZ = LumberProcessor.maxZ,
    }, {
        options = {
        {
          event = "hw_lumberjack:processormenu",
          icon = "Fas Fa-hands",
          label = Config.Alerts["mill_label"],
          job = "lumberjack",
        },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("LumberSeller", LumberSeller.targetZone, 1, 1, {
        name = "LumberProcessor",
        heading = LumberSeller.targetHeading,
        debugPoly = false,
        minZ = LumberSeller.minZ,
        maxZ = LumberSeller.maxZ,
    }, {
        options = {
        {
          type = "server",
          event = "hw_lumberjack:sellItems",
          icon = "fa fa-usd",
          label = Config.Alerts["Lumber_Seller"],
          job = "lumberjack",
        },
        },
        distance = 1.0
    })
else
    CreateThread(function()
        for k, v in pairs(Config.TreeLocations) do
            exports["qtarget"]:AddBoxZone("trees" .. k, v.coords, 1.5, 1.5, {
                name = "trees" .. k,
                heading = 40,
                minZ = v.coords["z"] - 2,
                maxZ = v.coords["z"] + 2,
                debugPoly = false
            }, {
                options = {
                    {
                        action = function()
                            if axe() then
                                ChopLumber(k)
                            end
                        end,
                        type = "client",
                        event = "hw_lumberjack:StartChopping",
                        icon = "fa fa-hand",
                        label = Config.Alerts["Tree_label"],
                        canInteract = function()
                            if v["isChopped"] or v["isOccupied"] then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.0
            })

        end
    end)
    exports['qtarget']:AddBoxZone("lumberjackdepo", LumberDepo.targetZone, 1, 1, {
        name = "Lumberjackdepo",
        heading = LumberDepo.targetHeading,
        debugPoly = false,
        minZ = LumberDepo.minZ,
        maxZ = LumberDepo.maxZ,
    }, {
        options = {
        {
          type = "client",
          event = "hw_lumberjack:bossmenu",
          icon = "Fas Fa-hands",
          label = Config.Alerts["depo_label"],
        },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("LumberProcessor", LumberProcessor.targetZone, 1, 1, {
        name = "LumberProcessor",
        heading = LumberProcessor.targetHeading,
        debugPoly = false,
        minZ = LumberProcessor.minZ,
        maxZ = LumberProcessor.maxZ,
    }, {
        options = {
        {
          type = "client",
          event = "hw_lumberjack:processormenu",
          icon = "Fas Fa-hands",
          label = Config.Alerts["mill_label"],
        },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("LumberSeller", LumberSeller.targetZone, 1, 1, {
        name = "LumberProcessor",
        heading = LumberSeller.targetHeading,
        debugPoly = false,
        minZ = LumberSeller.minZ,
        maxZ = LumberSeller.maxZ,
    }, {
        options = {
        {
          type = "server",
          event = "hw_lumberjack:sellItems",
          icon = "fa fa-usd",
          label = Config.Alerts["Lumber_Seller"],
        },
        },
        distance = 1.0
    })
end

RegisterNetEvent('hw_lumberjack:vehicle', function()
    local vehicle = LumberDepo.Vehicle
    local coords = LumberDepo.VehicleCoords
    local HW = PlayerPedId()
    RequestModel(vehicle)
    while not HasModelLoaded(vehicle) do
        Wait(0)
    end
    if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
        local JobVehicle = CreateVehicle(vehicle, coords, 45.0, true, false)
        SetVehicleHasBeenOwnedByPlayer(JobVehicle,  true)
        SetEntityAsMissionEntity(JobVehicle,  true,  true)
        Config.FuelSystem(JobVehicle, 100.0)
        local id = NetworkGetNetworkIdFromEntity(JobVehicle)
        DoScreenFadeOut(1500)
        Wait(1500)
        SetNetworkIdCanMigrate(id, true)
        TaskWarpPedIntoVehicle(HW, JobVehicle, -1)
        DoScreenFadeIn(1500)
    else
        TriggerEvent('hw_lumberjack:notify', 'HW Lumberjack', Config.Alerts["depo_blocked"], 'error')
    end
end)

RegisterNetEvent('hw_lumberjack:removevehicle', function()
    local HW88 = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(HW88,true)
    SetEntityAsMissionEntity(HW88,true)
    DeleteVehicle(vehicle)
    TriggerEvent('hw_lumberjack:notify', 'HW Lumberjack', Config.Alerts["depo_stored"], 'success')
end)

RegisterNetEvent('hw_lumberjack:getaxe', function()
    TriggerServerEvent('hw_lumberjack:BuyAxe')
end)

RegisterNetEvent('hw_lumberjack:bossmenu', function(data)
    --print(json.encode(data, {indent=true}))
    lib.registerContext({
        id = 'bossmenu_vehicle',
        title = Config.Alerts["shop_text"],
        menu = 'bossmenu_vehicle',
        options = {
            --{title = Config.Alerts["vehicle_text"]},
            {
                title = Config.Alerts["vehicle_header"],
                description = 'Lumberjack vehicle',
                arrow = true,
                event = 'hw_lumberjack:vehicle',
                --args = {value1 = 300, value2 = 'Other value'}
            },
            {
                title = Config.Alerts["remove_text"],
                description = 'Return the vehicle',
                arrow = true,
                event = 'hw_lumberjack:removevehicle',
                --args = {value1 = 300, value2 = 'Other value'}
            },
            {
                title = Config.Alerts["battleaxe_text"],
                description = 'Buy your own axe',
                arrow = true,
                event = 'hw_lumberjack:getaxe',
                --args = {value1 = 300, value2 = 'Other value'}
            },
            {
                title = Config.Alerts["bring_axe"],
                description = 'Remove your axe',
                arrow = true,
                event = 'hw_lumberjack:removeAxe',
                --args = {value1 = 300, value2 = 'Other value'}
            }
        }
    })
    lib.showContext('bossmenu_vehicle')
end)

RegisterNetEvent('hw_lumberjack:removeAxe', function()
    ESX.ShowNotification("Attempting to remove axe...")
    TriggerServerEvent('hw_lumberjack:removeAxe')
end)


RegisterNetEvent('hw_lumberjack:processormenu', function(data)
    --print(json.encode(data, {indent=true}))
    lib.registerContext({
        id = 'bossmenu_lumbermill',
        title = Config.Alerts["lumber_mill"],
        menu = 'bossmenu_lumbermill',
        options = {
            --{title = Config.Alerts["vehicle_text"]},
            {
                title = Config.Alerts["lumber_text"],
                description = 'Let Igor process the wood',
                arrow = true,
                event = 'hw_lumberjack:processor',
                --args = {value1 = 300, value2 = 'Other value'}
            },
            {
                title = Config.Alerts["remove_text"],
                description = 'Return the vehicle',
                arrow = true,
                event = 'hw_lumberjack:removevehicle',
                --args = {value1 = 300, value2 = 'Other value'}
            },
            {
                title = Config.Alerts["battleaxe_text"],
                description = 'Buy your own axe',
                arrow = true,
                event = 'hw_lumberjack:getaxe',
                --args = {value1 = 300, value2 = 'Other value'}
            }
        }
    })
    lib.showContext('bossmenu_lumbermill')
end)

RegisterNetEvent('hw_lumberjack:processor', function()
    ESX.TriggerServerCallback('hw_lumberjack:lumber', function(lumber)
      if lumber then
        if lib.progressBar({
            duration = LumberJob.ProcessingTime,
            label = Config.Alerts['lumber_progressbar'],
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true,
                mouse = true
            },
            anim = {
                dict = 'missheistdockssetup1clipboard@idle_a',
                clip = 'idle_a'
            },
            
            
        }) then  
            TriggerServerEvent("hw_lumberjack:lumberprocessed")
        else 
            TriggerEvent('hw_lumberjack:notify', 'Puuraidur', Config.Alerts['cancel'], 'inform')
        end
    else
         TriggerEvent('hw_lumberjack:notify', 'HW Lumberjack', Config.Alerts['error_lumber'], 'error')
    end
    end)
  end)
