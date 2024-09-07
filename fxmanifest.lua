fx_version "cerulean"
game "gta5"

lua54 "yes"
use_experimental_fxv2_oal "yes"

author "yiruzu"
description "Cloud Service - Rental"
version "1.0.0"

discord "https://discord.gg/jAnEnyGBef"
repository "https://github.com/yiruzu/cloud-rental"
license "CC BY-NC"

shared_scripts { "@ox_lib/init.lua", "shared/*.lua" }
server_scripts { "bridge/server/*.lua", "server/*.lua" }
client_scripts { "client/**/*.lua" }
