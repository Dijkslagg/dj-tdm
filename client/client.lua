local QBCore = exports['qb-core']:GetCoreObject()
Config = Config or {}
local isMenuOpen = false
local currentTeam = nil
local gameTime = 0
local showGameTimer = false
local playerTeams = { Red = {}, Blue = {} }

function openMapSelectionMenu()
    if not isMenuOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openMenu",
            maps = Config.Maps,
            weapons = Config.Weapons,
            teams = playerTeams,
            MaxPlayersPerTeam = Config.MaxPlayersPerTeam
        })
        isMenuOpen = true
    end
end

RegisterNetEvent('tdm:preparePlayer')
AddEventHandler('tdm:preparePlayer', function(gameSettings, team, spawnLocation)
    -- Close the menu
    SetNuiFocus(false, false)
    isMenuOpen = false

    -- Give the player the appropriate health and armor
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, tonumber(gameSettings.maxHealth) or 100)

    -- Ensure armor is a number and capped at 100
    local armor = tonumber(gameSettings.maxArmor) or 50
    armor = math.min(armor, 100) -- Ensures max armor doesn't exceed 100
    SetPedArmour(playerPed, armor)

    -- Request server to give the player the selected weapon and ammo
    local selectedWeapon = gameSettings.selectedWeapon or 'weapon_pistol'
    TriggerServerEvent("tdm:givePlayerItems", selectedWeapon, 250) -- Request server to give items

    -- Handle health regen setting if needed
    if gameSettings.healthRegen == "true" then
        SetPlayerHealthRechargeMultiplier(PlayerId(), 1.0) -- Enable health regen
    else
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0) -- Disable health regen
    end

    -- If the game mode is HopOuts, spawn a car and color it based on the team
    if gameSettings.gameMode == "HopOuts" and gameSettings.carModel then
        local carModel = GetHashKey(gameSettings.carModel)
        RequestModel(carModel)

        while not HasModelLoaded(carModel) do
            Citizen.Wait(0)
        end

        local vehicle = CreateVehicle(carModel, spawnLocation.x, spawnLocation.y, spawnLocation.z, GetEntityHeading(playerPed), true, false)
        
        -- Set car color based on the player's team
        if team == "Red" then
            SetVehicleCustomPrimaryColour(vehicle, 255, 0, 0)   -- Red
            SetVehicleCustomSecondaryColour(vehicle, 255, 0, 0) -- Red
        elseif team == "Blue" then
            SetVehicleCustomPrimaryColour(vehicle, 0, 0, 255)   -- Blue
            SetVehicleCustomSecondaryColour(vehicle, 0, 0, 255) -- Blue
        end

        TaskWarpPedIntoVehicle(playerPed, vehicle, -1) -- Put player in the car
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle)) -- Give keys to the player
    end

    -- Teleport player to the team's spawn location
    SetEntityCoords(playerPed, spawnLocation.x, spawnLocation.y, spawnLocation.z, false, false, false, true)
end)




RegisterNetEvent('tdm:startGameTimer')
AddEventHandler('tdm:startGameTimer', function(timer)
    gameTime = timer
    showGameTimer = true
    QBCore.Functions.Notify("The game has started!", "success", 5000)

    Citizen.CreateThread(function()
        while gameTime > 0 do
            Citizen.Wait(1000)
            gameTime = gameTime - 1

            if gameTime % 10 == 0 or gameTime == Config.GameTimer then
                QBCore.Functions.Notify("Time Remaining: " .. gameTime .. " seconds", "primary", 5000)
            end

            if gameTime <= 0 then
                showGameTimer = false
                QBCore.Functions.Notify("Time's up! The game has ended.", "error", 5000)
            end
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if showGameTimer then
            DrawText2D(0.5, 0.05, "Time Left: " .. gameTime, 0.7)
        end
    end
end)

function DrawText2D(x, y, text, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1, y - 0.02)
end

RegisterNetEvent('tdm:joinedTeam')
AddEventHandler('tdm:joinedTeam', function(team, teams)
    currentTeam = team
    playerTeams = teams or { Red = {}, Blue = {} }

    SendNUIMessage({
        action = "updateTeams",
        teams = playerTeams,
        playerTeam = currentTeam,
        MaxPlayersPerTeam = Config.MaxPlayersPerTeam
    })
end)

RegisterNetEvent('tdm:updateGameSettings')
AddEventHandler('tdm:updateGameSettings', function(gameSettings)

    Config.MaxHealth = tonumber(gameSettings.maxHealth) or Config.MaxHealth
    Config.MaxArmor = tonumber(gameSettings.maxArmor) or Config.MaxArmor
    Config.HealthRegen = gameSettings.healthRegen == "true"
    Config.GameTimer = tonumber(gameSettings.gameTimer) or Config.GameTimer
    Config.ScoreLimit = tonumber(gameSettings.scoreLimit) or Config.ScoreLimit
    Config.GameMode = gameSettings.gameMode or Config.GameMode
    Config.MapName = gameSettings.mapName or Config.MapName
    Config.SelectedWeapon = gameSettings.selectedWeapon or Config.SelectedWeapon
    Config.DefendingTeam = gameSettings.defendingTeam or "Red"
    Config.CarModel = gameSettings.carModel or Config.DefaultCarModel 

    SendNUIMessage({
        action = "updateGameSettings",
        maxHealth = Config.MaxHealth,
        maxArmor = Config.MaxArmor,
        healthRegen = Config.HealthRegen,
        gameTimer = Config.GameTimer,
        scoreLimit = Config.ScoreLimit,
        gameMode = Config.GameMode,
        mapName = Config.MapName,
        selectedWeapon = Config.SelectedWeapon,
        defendingTeam = Config.DefendingTeam,
        carModel = Config.CarModel
    })
end)

RegisterNetEvent('tdm:updateMap')
AddEventHandler('tdm:updateMap', function(selectedMap)
    currentMap = selectedMap
    SendNUIMessage({
        action = "updateMap",
        mapName = selectedMap
    })
end)

RegisterNUICallback('updateSetting', function(data, cb)
    if data then
        TriggerServerEvent('tdm:updateSetting', data)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNetEvent('tdm:closeMenu')
AddEventHandler('tdm:closeMenu', function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeMenu' })
    isMenuOpen = false
end)

RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb('ok')
end)

RegisterNUICallback('selectMap', function(data, cb)
    TriggerServerEvent('tdm:selectMap', data.mapName)
    cb('ok')
end)

RegisterNUICallback('startGame', function(data, cb)
    TriggerServerEvent('tdm:startGame', data)
    cb('ok')
end)

RegisterNUICallback('joinTeam', function(data, cb)
    TriggerServerEvent('tdm:joinTeam', data.team)  
    cb('ok')
end)

RegisterNetEvent('tdm:spawnPlayer')
AddEventHandler('tdm:spawnPlayer', function(data)
    local playerPed = PlayerPedId()
    
    -- Set player health and armor
    SetEntityHealth(playerPed, Config.MaxHealth)
    SetPedArmour(playerPed, Config.MaxArmor)
    
    -- Spawn the vehicle if it's needed
    if data and data.spawn then
        SetEntityCoords(playerPed, data.spawn.x, data.spawn.y, data.spawn.z, false, false, false, true)

        if Config.GameMode == "HopOuts" and data.carModel then
            local carHash = GetHashKey(data.carModel)
            RequestModel(carHash)
            while not HasModelLoaded(carHash) do
                Wait(1)
            end
            
            local carColor = (data.team == "Red") and 28 or 111  -- Red = 28, Blue = 111
            local vehicle = CreateVehicle(carHash, data.spawn.x, data.spawn.y, data.spawn.z, GetEntityHeading(playerPed), true, false)
            SetVehicleColours(vehicle, carColor, carColor)
            
            -- Give player keys and put them in the vehicle
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle)) -- Give keys
            TaskWarpPedIntoVehicle(playerPed, vehicle, -1) -- Warp into the car
            
            -- Clean up after model
            SetModelAsNoLongerNeeded(carHash)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if IsControlJustReleased(0, 167) then
            if isMenuOpen then
                SetNuiFocus(false, false)
                isMenuOpen = false
            else
                openMapSelectionMenu()
            end
        end
    end
end)
