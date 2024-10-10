Config.Function = {}

framework = nil
ESX, QBCore, vRP, vRPclient = nil, nil, nil, nil

Config.Function.GetFramework = function()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports["es_extended"]:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif GetResourceState('vrp') == 'started' then
        local Tunnel = module("vrp", "lib/Tunnel")
        local Proxy = module("vrp", "lib/Proxy")

        vRP = Proxy.getInterface("vRP")
        vRPclient = Tunnel.getInterface("vRP", "vRP")
    else
        error('Failed to load ESX/QBCore/vRP')
        return false
    end

    if ESX then
        framework = 'esx'
    elseif QBCore then
        framework = 'qbcore'
    elseif vRP then
        framework = 'vrp'
    end
end

Config.Function.GetPlayerIdentifier = function(playerId)
    if framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if not xPlayer then
            return false
        end
        local identifier = xPlayer.getIdentifier()
        return identifier
    elseif framework == 'qbcore' then
        local identifier = QBCore.Functions.GetIdentifier(playerId, 'license')
        return identifier
    elseif framework == 'vrp' then
        local user_id = tostring(vRP.getUserId({ playerId }))
        return user_id
    else
        local identifier = GetPlayerIdentifierByType(playerId, Config.IdentifierType)
        return identifier
    end
end

Config.Function.ShowNotification = function(playerId, msg)
    if framework == 'esx' then
        TriggerClientEvent("esx:showNotification", playerId, msg)
    elseif framework == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', playerId, msg)
    elseif framework == 'vrp' then
        vRPclient.notify(playerId, { msg })
    else
        error('Invalid framework')
    end
end


Config.Function.GiveItem = function(playerId, item, count)
    if framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        xPlayer.addInventoryItem(item, count)
        return true
    elseif framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(playerId)
        xPlayer.Functions.AddItem(item, count)
        return true
    elseif framework == 'vrp' then
        local user_id = vRP.getUserId({ playerId })
        vRP.giveInventoryItem({ user_id, item, count, true })
        return true
    else
        error('Invalid framework')
        return false
    end
end

Config.Function.GiveMoney = function(playerId, amount)
    if framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        xPlayer.addMoney(amount)
        return true
    elseif framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(playerId)
        xPlayer.Functions.AddMoney('cash', amount)
        return true
    elseif framework == 'vrp' then
        local user_id = vRP.getUserId({ playerId })
        vRP.giveMoney(user_id, amount)
        return true
    else
        error('Invalid framework')
        return false
    end
end
