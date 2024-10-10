ServerConfig = {}

ServerConfig.Locations = {
    ['halloween'] = {
        label = 'Halloween',
        items = {
            {
                coords = vec3(325.999, -1365.600, 31.977),
                dict = 'zscript-markers',
                name = 'halloween',
                bobUpAndDown = true,
                rotate = false,
                rot = vec3(90.0, 0.0, 0.0),
                size = vec2(1.0, 1.0),
                particle = { dict = 'scr_xs_celebration', name = 'scr_xs_confetti_burst', },
            },
            {
                coords = vec3(274.544, -1374.964, 31.935),
                dict = 'zscript-markers',
                name = 'halloween',
                bobUpAndDown = true,
                rotate = false,
                rot = vec3(90.0, 0.0, 0.0),
                size = vec2(1.0, 1.0),
                particle = { dict = 'scr_xs_celebration', name = 'scr_xs_confetti_burst', },
            }
        }
    }
}

Config.Function.Collect = function(playerId, event)
    print(string.format('[zscripts] Player %s collect item in event %s', playerId, event))

    Config.Function.GiveMoney(playerId, 1000)
end


Config.Function.CollectAll = function(playerId, event)
    print(string.format('[zscripts] Player %s collect all item in event %s', playerId, event))

    Config.Function.GiveItem(playerId, 'weapon_doubleaction', 1)
    Config.Function.GiveMoney(playerId, 10000)
end
