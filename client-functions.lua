Config.Function = {}

framework = nil
ESX, QBCore = nil, nil

Config.Function.GetFramework = function()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports["es_extended"]:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif GetResourceState('vrp') == 'started' then
        framework = 'vrp'
    else
        error('Failed to load ESX/QBCore/vRP')
        return false
    end

    if ESX then
        framework = 'esx'
        RegisterNetEvent('esx:playerLoaded', function(xPlayer)
            ESX.PlayerLoaded = true
        end)
    elseif QBCore then
        framework = 'qbcore'
    end
end

Config.Function.IsPlayerLoaded = function()
    if framework == 'esx' then
        return ESX.PlayerLoaded
    else
        return NetworkIsPlayerActive(PlayerId())
    end
end

Config.Function.ShowNotification = function(msg, type)
    if framework == 'esx' then
        ESX.ShowNotification(msg, type)
    elseif QBCore then
        QBCore.Functions.Notify(msg, type)
    end
end
