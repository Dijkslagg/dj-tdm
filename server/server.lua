Config = Config or {}
local QBCore = exports['qb-core']:GetCoreObject()
local json = require("json")
local currentMap = Config.DefaultMap
local playerTeams = { Red = {}, Blue = {} }

RegisterNetEvent('tdm:selectMap')
AddEventHandler('tdm:selectMap', function(selectedMap)
    if Config.Maps[selectedMap] then
        currentMap = selectedMap
        TriggerClientEvent('tdm:updateMap', -1, currentMap) 
    end
end)

RegisterNetEvent('tdm:joinTeam')
AddEventHandler('tdm:joinTeam', function(team)
    local source = source
    local playerName = GetPlayerName(source)

    if not team then
        return
    end

    if #playerTeams[team] >= Config.MaxPlayersPerTeam then
        TriggerClientEvent('chat:addMessage', source, { args = { "Team is full!" } })
        return
    end

    for i, player in ipairs(playerTeams.Red) do
        if player.id == source then
            table.remove(playerTeams.Red, i)
            break
        end
    end
    for i, player in ipairs(playerTeams.Blue) do
        if player.id == source then
            table.remove(playerTeams.Blue, i)
            break
        end
    end

    table.insert(playerTeams[team], { id = source, name = playerName })

    TriggerClientEvent('tdm:joinedTeam', -1, team, playerTeams) 
    TriggerClientEvent('tdm:updateTeams', -1, playerTeams, Config.MaxPlayersPerTeam)
end)

RegisterNetEvent('tdm:updateSetting')
AddEventHandler('tdm:updateSetting', function(gameSettings)

    if gameSettings then
        Config.MaxHealth = tonumber(gameSettings.maxHealth) or 100
        Config.MaxArmor = tonumber(gameSettings.maxArmor) or 50
        Config.HealthRegen = gameSettings.healthRegen == true
        Config.GameMode = gameSettings.gameMode or "TDM"
        Config.ScoreLimit = tonumber(gameSettings.scoreLimit) or 10
        Config.GameTimer = tonumber(gameSettings.gameTimer) or 50
        Config.MapName = gameSettings.mapName or Config.DefaultMap
        Config.SelectedWeapon = gameSettings.selectedWeapon or Config.Weapons[1]
        Config.DefendingTeam = gameSettings.defendingTeam or "Red"
        Config.CarModel = gameSettings.carModel or Config.DefaultCarModel  

        TriggerClientEvent('tdm:updateGameSettings', -1, gameSettings)
    end
end)

RegisterNetEvent('tdm:startGame')
AddEventHandler('tdm:startGame', function(gameSettings)
    local maxHealth = tonumber(gameSettings.maxHealth) or 100
    local maxArmor = tonumber(gameSettings.maxArmor) or 100
    local healthRegen = gameSettings.healthRegen == "true"
    local gameTimer = tonumber(gameSettings.gameTimer) or 300
    local gameMode = gameSettings.gameMode or "HopOuts"
    local scoreLimit = tonumber(gameSettings.scoreLimit) or 20
    local carModel = gameSettings.carModel or "jugular"
    local defendingTeam = gameSettings.defendingTeam or "Red" 
    local currentMap = gameSettings.mapName or Config.DefaultMap

    Config.MaxHealth = maxHealth
    Config.MaxArmor = maxArmor
    Config.HealthRegen = healthRegen
    Config.GameTimer = gameTimer

    TriggerClientEvent('tdm:updateGameSettings', -1, gameSettings)

    if not Config.Maps[currentMap] then
        currentMap = Config.DefaultMap 
    end

    TriggerClientEvent('tdm:updateMap', -1, currentMap)

    local totalPlayers = #playerTeams.Red + #playerTeams.Blue
    if totalPlayers < 1 then
        TriggerClientEvent('chat:addMessage', -1, { args = { "Not enough players to start the game!" } })
        return
    end

    if gameMode == "TDM" then
        Config.ScoreLimit = scoreLimit

        for _, player in ipairs(playerTeams.Red) do
            local redTeamSpawns = Config.Maps[currentMap].SpawnLocations.Red
            local spawn = redTeamSpawns[math.random(#redTeamSpawns)]
            TriggerClientEvent('tdm:spawnPlayer', player.id, { team = "Red", spawn = spawn })
        end

        for _, player in ipairs(playerTeams.Blue) do
            local blueTeamSpawns = Config.Maps[currentMap].SpawnLocations.Blue
            local spawn = blueTeamSpawns[math.random(#blueTeamSpawns)]
            TriggerClientEvent('tdm:spawnPlayer', player.id, { team = "Blue", spawn = spawn })
        end

    elseif gameMode == "Infiltrate" then
        local defenseSpawn = Config.Maps[currentMap].SpawnLocations.Defense
        local attackSpawn = Config.Maps[currentMap].SpawnLocations.Attack

        if defendingTeam == "Red" then
            for _, player in ipairs(playerTeams.Red) do
                local spawn = defenseSpawn[math.random(#defenseSpawn)]
                TriggerClientEvent('tdm:spawnPlayer', player.id, { team = "Defender", spawn = spawn })
            end

            for _, player in ipairs(playerTeams.Blue) do
                local spawn = attackSpawn[math.random(#attackSpawn)]
                TriggerClientEvent('tdm:spawnPlayer', player.id, { team = "Attacker", spawn = spawn })
            end
        else
            for _, player in ipairs(playerTeams.Blue) do
                local spawn = defenseSpawn[math.random(#defenseSpawn)]
                TriggerClientEvent('tdm:spawnPlayer', player.id, { team = "Defender", spawn = spawn })
            end

            for _, player in ipairs(playerTeams.Red) do
                local spawn = attackSpawn[math.random(#attackSpawn)]
                TriggerClientEvent('tdm:spawnPlayer', player.id, { team = "Attacker", spawn = spawn })
            end
        end

    elseif gameMode == "HopOuts" then
        print("Starting Hop Outs with car model: " .. carModel)
    end

    for _, player in ipairs(playerTeams.Red) do
        local redTeamSpawns = Config.Maps[currentMap].SpawnLocations.Red
        local spawn = redTeamSpawns[math.random(#redTeamSpawns)]
        TriggerClientEvent('tdm:preparePlayer', player.id, gameSettings, "Red", spawn)
    end

    for _, player in ipairs(playerTeams.Blue) do
        local blueTeamSpawns = Config.Maps[currentMap].SpawnLocations.Blue
        local spawn = blueTeamSpawns[math.random(#blueTeamSpawns)]
        TriggerClientEvent('tdm:preparePlayer', player.id, gameSettings, "Blue", spawn)
    end

    TriggerClientEvent('tdm:startGameTimer', -1, Config.GameTimer) 
end)

RegisterNetEvent('tdm:closeMenuForAll')
AddEventHandler('tdm:closeMenuForAll', function()
    TriggerClientEvent('tdm:closeMenu', -1)  
end)

RegisterNetEvent("tdm:givePlayerItems")
AddEventHandler("tdm:givePlayerItems", function(weaponName, ammoCount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        -- Add the weapon to the player's inventory
        Player.Functions.AddItem(weaponName, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[weaponName], "add")

        -- Add ammo to the player's inventory
        Player.Functions.AddItem("pistol_ammo", ammoCount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["pistol_ammo"], "add")
    end
end)