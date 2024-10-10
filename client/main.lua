local Client = {
    Locations = false
}

local locales = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. Config.Lang .. '.lua')

if not locales then
    return error('No locale file found!')
end

local stringFunction, errorMessage = load(locales)
if errorMessage then
    return error('Error in locale file: ' .. errorMessage)
else
    Client.Locales = stringFunction()
end

Client.MainThread = function()
    repeat
        Wait(1000)
    until NetworkIsPlayerActive(PlayerId())

    Wait(2000)

    local showItems = {}
    local collecting = {}

    CreateThread(function()
        while true do
            local _wait = 100
            showItems = {}
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            for key, conf in pairs(Client.Locations) do
                for i = 1, #conf.items do
                    local row = conf.items[i]

                    local distance = #(vec3(playerCoords.x, playerCoords.y, playerCoords.z) - vec3(row.coords.x, row.coords.y, row.coords.z))

                    if distance <= Config.ShowDistance then
                        showItems[#showItems + 1] = row
                    end

                    if distance <= Config.InteractDistance and not collecting[tostring(row.id)] then
                        collecting[tostring(row.id)] = true
                        print('Zbieram')
                    end
                end
            end

            Wait(_wait)
        end
    end)

    CreateThread(function()
        while true do
            local _wait = 500

            if #showItems > 0 then
                for i = 1, #showItems do
                    local row = showItems[i]
                    if not collecting[tostring(row.id)] then
                        _wait = 1
                        print('Show', row.coords)
                    end
                end
            end

            Wait(_wait)
        end
    end)
end

Client.UpdateLocations = function(data)
    Client.Locations = data
end

CreatEthread(Client.MainThread)

RegisterChangeStateBags('Global', 'locations', Client.UpdateLocations)
