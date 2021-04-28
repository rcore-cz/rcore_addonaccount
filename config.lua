Config = {}

-- 15 minutes for saving to the DB
Config.SaveInterval  = 1000 * 60 * 15

-- Is debug allowed?
Config.Debug = true

-- What levels of debug are allowed to print?
Config.DebugLevel = {
    ['INFO']     = true,
    ['SECURITY'] = true,
    ['CRITICAL'] = true,
    ['DEBUG']    = true,
    ['ERROR']    = true,
    ['SUCCESS']  = true,
}