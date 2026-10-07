-- Configurações --

effect_invoke_banner = 2 -- efeito que saira no banner quando ele for colocado no chao -- 944 -- 9
effect_decay_banner = 2 -- efeito que saira no banner quando o tempo dele acabar
effect_kill_banner = 420 -- efeito que saira no banner quando o player matar um monstro e ganhar o bonus de exp -- 1048

banner_radius_x = 10 -- distancia maxima em x que ira ocorreu o bonus
banner_radius_y = 10 -- distancia maxima em y que ira ocorreu o bonus

time_in_minutes = 60 -- configurado em minutos (caso queira em horas só colocar 60 * 60)
remove_banner_item = true -- Se estiver TRUE o item de criacao do banner sera removido do player, caso esteja FALSE o item não sera removido. 

config_banner = {

--[ID DO ITEM CRIAR O BANNER] = {banner_id = ID DO BANNER, exp_bonus = % EXP PLAYER IRA GANHAR, time_left = TEMPO PARA SUBIR O BANNER},
[29838] = {banner_id = 34525, exp_bonus = 0.5, banner_percent = "5", time_left = 60, time_xp = 60 * 60, banner_name = "XP Plank"}, -- XP Plank
[26758] = {banner_id = 34526, exp_bonus = 0.10, banner_percent = "10", time_left = 60, time_xp = 60 * 60, banner_name = "Lesser XP Banner"}, -- Lesser XP Banner
[26759] = {banner_id = 34527, exp_bonus = 0.15, banner_percent = "15", time_left = 60, time_xp = 60 * 60, banner_name = "Average XP Banner"}, -- Average XP Banner
[26760] = {banner_id = 34528, exp_bonus = 0.30, banner_percent = "30", time_left = 60, time_xp = 60 * 60, banner_name = "Greater XP Banner"}, -- Greater XP Banner
[26761] = {banner_id = 34529, exp_bonus = 0.60, banner_percent = "60", time_left = 60, time_xp = 60 * 60, banner_name = "Superior XP Banner"}, -- Superior XP Banner

}

-- Não Mexer --
time_banner = 7899987 
player_use_banner = 78999788 
storage_banner_x = 7889911 
storage_banner_y = 7889912 
storage_banner_z = 7889913 
storage_banner_id = 7884544 
storage_exp = 7889915 
rate_level = SKILL__LEVEL