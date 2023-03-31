fx_version "cerulean"
games { "gta5" }

author 'rcore.cz'
description 'Remake of esx_addonaccount'
version '1.0.0'

server_scripts {
    "config.lua",

    "@mysql-async/lib/MySQL.lua",
    "main/System/*.lua",
    "main/*.lua",
}

dependencies {
    "es_extended",
}

provide 'esx_addonaccount'
