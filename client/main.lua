local Client = {
    Locations = false,
    Collected = {},
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
    Config.Function.GetFramework()
    repeat
        Wait(1000)
    until Config.Function.IsPlayerLoaded()

    TriggerServerEvent('zscripts-findables:server:playerLoaded')

    repeat
        Wait(1000)
    until StateBags.Global.locations

    local showItems = {}
    local collecting = {}

    CreateThread(function()
        while true do
            local _wait = 100
            showItems = {}
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            for key, conf in pairs(StateBags.Global.locations) do
                for i = 1, #conf.items do
                    local row = conf.items[i]

                    if not collecting[key..":"..row.id] then
                        local collected = false
                        if StateBags.Player.collected[key] then
                            collected = StateBags.Player.collected[key][tostring(row.id)] or false
                        end
                        if not collected then
                            local distance = #(vec3(playerCoords.x, playerCoords.y, playerCoords.z) - vec3(row.coords.x, row.coords.y, row.coords.z))

                            if distance <= Config.ShowDistance then
                                local id = #showItems + 1
                                showItems[id] = row
                                showItems[id].key = key
                            end

                            if distance <= Config.InteractDistance then
                                collecting[key..":"..row.id] = true

                                TriggerServerEvent('zscripts-findables:server:collect', key, row.id)

                                local tick = 10
                                local duration = Config.CollectingTime / 2

                                local currentSizeX, currentSizeY = row.size.x, row.size.y
                                local steps = duration / tick
                                local sizeTickX, sizeTickY = currentSizeX / steps, currentSizeY / steps

                                CreateThread(function()
                                    RequestNamedPtfxAsset(row.particle.dict)
                                    while not HasNamedPtfxAssetLoaded(row.particle.dict) do
                                        Wait(0)
                                    end
                                    UseParticleFxAssetNextCall(row.particle.dict)
                                   	local particleHandle = StartParticleFxLoopedAtCoord(row.particle.name,
                                        row.coords.x, row.coords.y, row.coords.z,
                                        0.0, 0.0, 0.0,
                                        1,
                                        false, false, false)

                                   	SetParticleFxLoopedColour(particleHandle, 0, 255, 0 ,0)
                                   	Wait(Config.CollectingTime)
                                   	StopParticleFxLooped(particleHandle, false)
                                end)

                                CreateThread(function()
                                    for i = 1, steps do
                                        currentSizeX -= sizeTickX
                                        currentSizeY -= sizeTickY
                                        Wait(tick)
                                    end
                                    currentSizeX, currentSizeY = 0, 0
                                end)

                                while true do
                                    if currentSizeX <= 0 or currentSizeY <= 0 then
                                        break
                                    end

                                    DrawMarker(43, row.coords.x, row.coords.y, row.coords.z,
                                        0.0, 0.0, 0.0,
                                        row.rot.x, row.rot.y, row.rot.z,
                                        currentSizeX, currentSizeY, 0.001,
                                        255, 255, 255, 255,
                                        row.bobUpAndDown, not row.rotate, 2, row.rotate, row.dict, row.name, false)

                                    Wait(1)
                                end
                            end
                        end
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
                    if not collecting[row.key..":"..row.id] then
                        _wait = 1

                        if not HasStreamedTextureDictLoaded(row.dict) then
                            RequestStreamedTextureDict(row.dict, true)
                            while not HasStreamedTextureDictLoaded(row.dict) do
                                Wait(1)
                            end
                        else
                            DrawMarker(43, row.coords.x, row.coords.y, row.coords.z,
                                0.0, 0.0, 0.0,
                                row.rot.x, row.rot.y, row.rot.z,
                                row.size.x, row.size.y, 0.001,
                                255, 255, 255, 255,
                                row.bobUpAndDown, not row.rotate, 2, row.rotate, row.dict, row.name, false)
                        end
                    end
                end
            end

            Wait(_wait)
        end
    end)
end


if Config.CheckEventCommand then
    TriggerEvent("chat:addSuggestion", ("/%s"):format(Config.CheckEventCommand), Client.Locales.commandInfo, {
        { name = Client.Locales.commandArguments }
    })
end

CreateThread(Client.MainThread)
RegisterNetEvent('zscripts-findables:client:notification', Config.Function.ShowNotification)
