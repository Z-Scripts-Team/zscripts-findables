if not IsDuplicityVersion() then
    -- CLient
    local resourceName = GetCurrentResourceName()
    
    local Callback = {
        RequestId = 0,
        ServerRequests = {},
        ClientCallbacks = {}, 
    }

    Core = {}
    
    Core.TriggerServerCallback = function(eventName, ...)
        Callback.ServerRequests[Callback.RequestId] = promise.new()
        local d = Callback.ServerRequests[Callback.RequestId]
       
        TriggerServerEvent(resourceName .. ':triggerServerCallback', eventName, Callback.RequestId, ...)
    
        Callback.RequestId += 1

        local data = Citizen.Await(d)
        return table.unpack(data)
    end
    
    RegisterNetEvent(resourceName .. ':serverCallback', function(requestId, ...)
        if not Callback.ServerRequests[requestId] then
            return
        end
    
        Callback.ServerRequests[requestId]:resolve({...})
    end)
    
    Core.RegisterClientCallback = function(eventName, callback)
        Callback.ClientCallbacks[eventName] = callback
    end
    
    RegisterNetEvent(resourceName .. ':triggerClientCallback', function(eventName, requestId, ...)
        if not Callback.ClientCallbacks[eventName] then
            return 
        end
    
        Callback.ClientCallbacks[eventName](function(...)
            TriggerServerEvent(resourceName .. ':clientCallback', requestId, ...)
        end, ...)
    end)
else
    -- Server
    local resourceName = GetCurrentResourceName()
    
    local Callback = {
        Server = {},
        RequestId = 0,
        ClientRequests = {},
    }

    Core = {}

    Core.RegisterServerCallback = function(eventName, callback)
        Callback.Server[eventName] = callback
    end

    RegisterNetEvent(resourceName .. ':triggerServerCallback', function(eventName, requestId, ...)
        if not Callback.Server[eventName] then
            return
        end

        local playerId = source

        Callback.Server[eventName](playerId, function(...)
            TriggerClientEvent(resourceName .. ':serverCallback', playerId, requestId, ...)
        end, ...)
    end)

    Core.TriggerClientCallback = function(eventName, playerId, ...)
        Callback.ClientRequests[Callback.RequestId] = promise.new()
        local d = Callback.ClientRequests[Callback.RequestId]

        TriggerClientEvent(resourceName .. ':triggerClientCallback', playerId, eventName, Callback.RequestId, ...)

        Callback.RequestId += 1

        local data = Citizen.Await(d)
        return table.unpack(data)
    end

    RegisterNetEvent(resourceName .. ':clientCallback', function(requestId, ...)
        if not Callback.ClientRequests[requestId] then
            return
        end

        Callback.ClientRequests[requestId]:resolve({...})
    end)
end