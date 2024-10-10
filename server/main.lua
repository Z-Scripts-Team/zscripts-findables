Server = {}

local locales = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. Config.Lang .. '.lua')

if not locales then
    return error('No locale file found!')
end

local stringFunction, errorMessage = load(locales)
if errorMessage then
    return error('Error in locale file: ' .. errorMessage)
else
    Server.Locales = stringFunction()
end

Server.MainThread = function()
    Config.Function.GetFramework()
    local data = ServerConfig.Locations

    for k, v in pairs(data) do
        for i = 1, #v.items do
            v.items[i].id = i
        end
    end

    UpdateGlobalStateBag('locations', data)
end

Server.StartMysql = function()
    if Config.AutoInstallDB then
        MySQL.update.await([=[
            CREATE TABLE IF NOT EXISTS findables_data (
                id int(11) NOT NULL AUTO_INCREMENT,
                license varchar(100) NOT NULL,
                data longtext NOT NULL DEFAULT '{}',
                PRIMARY KEY (id)
            );
        ]=])
    end

    Server.MainThread()
end

Server.PlayerLoaded = function()
    local playerId = source
    local identifier = Config.Function.GetPlayerIdentifier(playerId)
    if not identifier then
        return error('Failed to load ESX/QBCore/vRP')
    end

    local data = MySQL.scalar.await('SELECT data FROM findables_data WHERE license = ? LIMIT 1', {
        identifier
    })

    data = json.decode(data or "{}")
    UpdatePlayerStateBag(playerId, 'collected', data)
end

Server.Collect = function(key, id)
    local playerId = source
    if not ServerConfig.Locations[key].items[id] then return end

    local identifier = Config.Function.GetPlayerIdentifier(playerId)
    if not identifier then
        return error('Failed to load ESX/QBCore/vRP')
    end

    local data = MySQL.scalar.await('SELECT data FROM findables_data WHERE license = ? LIMIT 1', {
        identifier
    })

    if data then
        data = json.decode(data)
        if data?[key]?[tostring(id)] then return end
        if not data[key] then data[key] = {} end
        data[key][tostring(id)] = true

        MySQL.update.await('UPDATE findables_data SET data = ? WHERE license = ?', {
            json.encode(data), identifier
        })
    else
        data = {}
        data[key] = {}
        data[key][tostring(id)] = true

        MySQL.insert.await('INSERT INTO findables_data (license, data) VALUES (?, ?)', {
            identifier, json.encode(data)
        })
    end

    local collected = 0

    for k, v in pairs(data[key]) do
        if v then
            collected += 1
        end
    end

    if collected >= #ServerConfig.Locations[key].items then
        TriggerClientEvent('zscripts-findables:client:notification', playerId, string.format(Server.Locales.collectedAll,
            ServerConfig.Locations[key].label), 'success')
        Config.Function.CollectAll(playerId, key)
    else
        TriggerClientEvent('zscripts-findables:client:notification', playerId, string.format(Server.Locales.collected,
            ServerConfig.Locations[key].label, #ServerConfig.Locations[key].items - collected), 'success')
        Config.Function.Collect(playerId, key)
    end
end

Server.GetEventPoints = function(playerId, args)
    if playerId < 1 then return end

    local event = args[1]
    if not ServerConfig.Locations[event] then return TriggerClientEvent('zscripts-findables:client:notification', playerId,
        Server.Locales.errorEvent, 'error') end

    local identifier = Config.Function.GetPlayerIdentifier(playerId)
    if not identifier then
        return error('Failed to load ESX/QBCore/vRP')
    end

    local data = MySQL.scalar.await('SELECT data FROM findables_data WHERE license = ? LIMIT 1', {
        identifier
    })

    if data then
        data = json.decode(data)

        local collected = 0

        for k, v in pairs(data[event]) do
            if v then
                collected += 1
            end
        end

        TriggerClientEvent('zscripts-findables:client:notification', playerId, string.format(Server.Locales.collectedInfo,
            collected, #ServerConfig.Locations[event].items, ServerConfig.Locations[event].label), 'info')
    else
        TriggerClientEvent('zscripts-findables:client:notification', playerId, string.format(Server.Locales.noCollected,
            ServerConfig.Locations[event].label), 'error')
    end
end

if Config.AutoInstallDB then
    MySQL.ready(Server.StartMysql)
else
    CreateThread(Server.MainThread)
end

if Config.CheckEventCommand then
    RegisterCommand(Config.CheckEventCommand, Server.GetEventPoints)
end

RegisterNetEvent('zscripts-findables:server:playerLoaded', Server.PlayerLoaded)
RegisterNetEvent('zscripts-findables:server:collect', Server.Collect)
