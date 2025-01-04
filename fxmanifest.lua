fx_version "cerulean"
game "gta5"

lua54 "yes"
use_experimental_fxv2_oal "yes"

author "yiruzu"
description "Cloud Resources - Rental"
version "2.0.0"

discord "https://discord.gg/jAnEnyGBef"
repository "https://github.com/yiruzu/cloud-rental"
license "CC BY-NC"

files {
    "configuration/config.lua",
    "configuration/locales.lua",

    "shared/utils/*.lua",

    "client/stores/*.lua",
    "client/utils/*.lua",
}

shared_scripts { "@ox_lib/init.lua", "configuration/functions.lua" }
server_scripts { "bridge/server/*.lua", "server/**/*.lua" }
client_scripts { "client/*.lua" }
