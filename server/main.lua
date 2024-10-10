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
    local data = ServerConfig.Locations

    for k, v in pairs(data) do
        for i = 1, #v.items do
            data.items[i].id = i
        end
    end

    UpdateGlobalStateBag('locations', data)
end

CreatEthread(Server.MainThread)
