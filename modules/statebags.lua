if not IsDuplicityVersion() then
    -- CLient
    StateBags = {
        Global = {},
        Player = {},
    }

    Callback = {
        Global = {},
        Player = {},
    }

    local MainThread = function()
        repeat
            Wait(1000)
        until NetworkIsPlayerActive(PlayerId())

        TriggerServerEvent(GetCurrentResourceName() .. ':modules:statebags:playerLoaded')
    end

    local SyncData = function(type, key, value)
        if Callback[type]?[key] then
            Callback[type][key](value)
        end
        StateBags[type][key] = value
    end

    local SyncDataAll = function(data)
        StateBags = data
    end

    RegisterChangeStateBags = function(type, key, cb)
        Callback[type][key] = cb
    end

    CreateThread(MainThread)

    RegisterNetEvent(GetCurrentResourceName() .. ':modules:statebags:update', SyncData)
    RegisterNetEvent(GetCurrentResourceName() .. ':modules:statebags:updateAll', SyncDataAll)
else
    -- Server
    StateBags = {
        Global = {},
        Player = {},
    }

    UpdateGlobalStateBag = function(key, value)
        StateBags.Global[key] = value
        TriggerClientEvent(GetCurrentResourceName() .. ':modules:statebags:update', -1, 'Global', key, value)
    end

    UpdatePlayerStateBag = function(playerId, key, value)
        if not StateBags.Player['player:' .. playerId] then
            StateBags.Player['player:' .. playerId] = {}
        end
        StateBags.Player['player:' .. playerId][key] = value
        TriggerClientEvent(GetCurrentResourceName() .. ':modules:statebags:update', playerId, 'Player', key, value)
    end

    local PlayerLoaded = function()
        local playerId = source
        TriggerClientEvent(GetCurrentResourceName() .. ':modules:statebags:updateAll', playerId, StateBags)
    end

    RegisterNetEvent(GetCurrentResourceName() .. ':modules:statebags:playerLoaded', PlayerLoaded)
end
