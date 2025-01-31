fx_version "cerulean"
game "gta5"

lua54 "yes"
use_experimental_fxv2_oal "yes"

author "yiruzu"
description "Cloud Resources - Rental"
version "2.0.1"

support "https://discord.gg/jAnEnyGBef"
repository "https://github.com/yiruzu/cloud-rental"
license "CC BY-NC"

shared_scripts { "@ox_lib/init.lua", "config/cfg_functions.lua" }
server_scripts { "bridge/server/*.lua", "server/**/*.lua" }
client_scripts { "client/stores/*.lua", "client/*.lua" }

files {
    "config/cfg_main.lua",
    "config/cfg_locales.lua",
    "shared/utils/*.lua",
    "client/utils/*.lua",
}
