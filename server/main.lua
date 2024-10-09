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
