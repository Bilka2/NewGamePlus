local mod_gui = require("mod-gui")
require("gui")
local DEBUG_MODE = true

local function debug_log(msg)
	if DEBUG_MODE then
		log(msg)
	end
end

script.on_event(defines.events.on_rocket_launched, function(event)
	if global.rocket_launched then return end --don't regen gui if this is not the first rocket launch
	if event.rocket.get_item_count("satellite") > 0 then
		for _, player in pairs(game.players) do
			regen_gui(player)
		end
		global.rocket_launched = true --the rocket has now been launched, so the gui has to be regened on player created and config changed
	end
end)

local function reset_to_default(player)
	local frame_flow = mod_gui.get_frame_flow(player)
	-- general options --
	local config_options = frame_flow["new-game-plus-config-frame"]["new-game-plus-config-option-table"]
	config_options["new-game-plus-reset-evo-checkbox"].state = true
	config_options["new-game-plus-peaceful-mode-checkbox"].state = false
	config_options["new-game-plus-seed-textfield"].text = 0
	config_options["new-game-plus-width-textfield"].text = 0
	config_options["new-game-plus-height-textfield"].text = 0
	-- MAP GEN SETTINGS --
	-- resource table --
	local resource_table = frame_flow["new-game-plus-config-frame"]["new-game-plus-config-resource-scroll-pane"]["new-game-plus-config-resource-table"]
	--water stuff
	resource_table["new-game-plus-config-water-freq"].selected_index = 3
	resource_table["new-game-plus-config-water-size"].selected_index = 4
	--starting area
	resource_table["new-game-plus-config-starting-area-size"].selected_index = 3
	-- resources
	for _, resource in pairs(game.entity_prototypes) do
		if resource.type == "resource" and resource.autoplace_specification and resource.name ~= "lithia-water" then
			resource_table["new-game-plus-config-" .. resource.name .. "-freq"].selected_index = 3
			resource_table["new-game-plus-config-" .. resource.name .. "-size"].selected_index = 4
			resource_table["new-game-plus-config-" .. resource.name .. "-richn"].selected_index = 3
		end
	end
	--building platform mod
	if game.active_mods["building-platform"] and settings.startup["bp-platform-generator"].value == "default" and game.tile_prototypes["building-platform"] and game.tile_prototypes["building-platform"].autoplace_specification then
		resource_table["new-game-plus-config-building-platform-freq"].selected_index = 3
		resource_table["new-game-plus-config-building-platform-size"].selected_index = 4
	end
	resource_table["new-game-plus-config-enemy-base-freq"].selected_index = 3
	resource_table["new-game-plus-config-enemy-base-size"].selected_index = 4
	resource_table["new-game-plus-config-enemy-base-richn"].selected_index = 3
	-- DIFFICULTY SETTINGS --
	local more_config_table = frame_flow["new-game-plus-config-more-frame"]["new-game-plus-config-more-table"]
	local difficulty_table = more_config_table["new-game-plus-config-more-difficulty-flow"]["new-game-plus-config-more-difficulty-table"]
	difficulty_table["new-game-plus-recipe-difficulty-drop-down"].selected_index  = 1
	difficulty_table["new-game-plus-technology-difficulty-drop-down"].selected_index = 1
	difficulty_table["new-game-plus-technology-multiplier-textfield"].text = "1"
	-- MAP SETTINGS --
	--Evolution
	local evo_table = more_config_table["new-game-plus-config-more-evo-flow"]["new-game-plus-config-more-evo-table"]
	evo_table["new-game-plus-evolution-checkbox"].state = true
	evo_table["new-game-plus-evolution-time-textfield"].text = "0.000004"
	evo_table["new-game-plus-evolution-destroy-textfield"].text = "0.002000"
	evo_table["new-game-plus-evolution-pollution-textfield"].text = "0.000015"
	--Pollution
	local pollution_table = more_config_table["new-game-plus-config-more-pollution-flow"]["new-game-plus-config-more-pollution-table"]
	pollution_table["new-game-plus-pollution-checkbox"].state = true
	pollution_table["new-game-plus-pollution-diffusion-textfield"].text = "2"
	pollution_table["new-game-plus-pollution-dissipation-textfield"].text = "1"
	pollution_table["new-game-plus-pollution-tree-dmg-textfield"].text = "3500"
	pollution_table["new-game-plus-pollution-tree-absorb-textfield"].text = "500"
	--Enemy expansion
	local expansion_table = more_config_table["new-game-plus-config-more-expansion-flow"]["new-game-plus-config-more-expansion-table"]
	expansion_table["new-game-plus-enemy-expansion-checkbox"].state = true
	expansion_table["new-game-plus-expansion-distance-textfield"].text = "7"
	expansion_table["new-game-plus-expansion-min-size-textfield"].text = "5"
	expansion_table["new-game-plus-expansion-max-size-textfield"].text = "20"
	expansion_table["new-game-plus-expansion-min-cd-textfield"].text = "4"
	expansion_table["new-game-plus-expansion-max-cd-textfield"].text = "60"
end

local function use_current_map_gen(player)
	local frame_flow = mod_gui.get_frame_flow(player)
	local surface = player.surface
	local map_gen_settings = surface.map_gen_settings
	-- general options --
	local config_options = frame_flow["new-game-plus-config-frame"]["new-game-plus-config-option-table"]
	config_options["new-game-plus-peaceful-mode-checkbox"].state = map_gen_settings.peaceful_mode
	config_options["new-game-plus-seed-textfield"].text = tostring(map_gen_settings.seed)
	config_options["new-game-plus-width-textfield"].text = tostring(map_gen_settings.width == 2000000 and 0 or map_gen_settings.width) --show 0 if it was set to "infinite"
	config_options["new-game-plus-height-textfield"].text = tostring(map_gen_settings.height == 2000000 and 0 or map_gen_settings.height)
	-- MAP GEN SETTINGS --
	-- resource table --
	local resource_table = frame_flow["new-game-plus-config-frame"]["new-game-plus-config-resource-scroll-pane"]["new-game-plus-config-resource-table"]
	local none_lookup = {
		["none"] = 1,
		["very-low"] = 2,
		["low"] = 3,
		["normal"] = 4,
		["high"] = 5,
		["very-high"] = 6
	}
	local lookup = {
		["very-low"] = 1,
		["low"] = 2,
		["normal"] = 3,
		["high"] = 4,
		["very-high"] = 5
	}
	--water stuff
	resource_table["new-game-plus-config-water-freq"].selected_index = lookup[map_gen_settings.terrain_segmentation]
	resource_table["new-game-plus-config-water-size"].selected_index = none_lookup[map_gen_settings.water]
	--starting area
	resource_table["new-game-plus-config-starting-area-size"].selected_index = lookup[map_gen_settings.starting_area]
	-- resources
	local autoplace_controls = map_gen_settings.autoplace_controls
	for resource, tbl in pairs(autoplace_controls) do
		resource_table["new-game-plus-config-" .. resource .. "-freq"].selected_index = lookup[tbl["frequency"]]
		resource_table["new-game-plus-config-" .. resource .. "-size"].selected_index = none_lookup[tbl["size"]]
		if resource ~= "building-platform" then --building platforms dont have richness
			resource_table["new-game-plus-config-" .. resource .. "-richn"].selected_index = lookup[tbl["richness"]]
		end
	end
	-- DIFFICULTY SETTINGS --
	local more_config_table = frame_flow["new-game-plus-config-more-frame"]["new-game-plus-config-more-table"]
	local difficulty_settings = game.difficulty_settings
	local difficulty_table = more_config_table["new-game-plus-config-more-difficulty-flow"]["new-game-plus-config-more-difficulty-table"]
	difficulty_table["new-game-plus-recipe-difficulty-drop-down"].selected_index  = difficulty_settings.recipe_difficulty + 1
	difficulty_table["new-game-plus-technology-difficulty-drop-down"].selected_index = difficulty_settings.technology_difficulty + 1
	difficulty_table["new-game-plus-technology-multiplier-textfield"].text = tostring(difficulty_settings.technology_price_multiplier)
	-- MAP SETTINGS --
	local map_settings = game.map_settings
	--Evolution
	local evo_table = more_config_table["new-game-plus-config-more-evo-flow"]["new-game-plus-config-more-evo-table"]
	evo_table["new-game-plus-evolution-checkbox"].state = map_settings.enemy_evolution.enabled
	evo_table["new-game-plus-evolution-time-textfield"].text = format_number(map_settings.enemy_evolution.time_factor)
	evo_table["new-game-plus-evolution-destroy-textfield"].text = format_number(map_settings.enemy_evolution.destroy_factor)
	evo_table["new-game-plus-evolution-pollution-textfield"].text = format_number(map_settings.enemy_evolution.pollution_factor)
	--Pollution
	local pollution_table = more_config_table["new-game-plus-config-more-pollution-flow"]["new-game-plus-config-more-pollution-table"]
	pollution_table["new-game-plus-pollution-checkbox"].state = map_settings.pollution.enabled
	pollution_table["new-game-plus-pollution-diffusion-textfield"].text = tostring(map_settings.pollution.diffusion_ratio * 100)
	pollution_table["new-game-plus-pollution-dissipation-textfield"].text = tostring(map_settings.pollution.ageing)
	pollution_table["new-game-plus-pollution-tree-dmg-textfield"].text = tostring(map_settings.pollution.min_pollution_to_damage_trees)
	pollution_table["new-game-plus-pollution-tree-absorb-textfield"].text = tostring(map_settings.pollution.pollution_restored_per_tree_damage)
	--Enemy expansion
	local expansion_table = more_config_table["new-game-plus-config-more-expansion-flow"]["new-game-plus-config-more-expansion-table"]
	expansion_table["new-game-plus-enemy-expansion-checkbox"].state = map_settings.enemy_expansion.enabled
	expansion_table["new-game-plus-expansion-distance-textfield"].text = tostring(map_settings.enemy_expansion.max_expansion_distance)
	expansion_table["new-game-plus-expansion-min-size-textfield"].text = tostring(map_settings.enemy_expansion.settler_group_min_size)
	expansion_table["new-game-plus-expansion-max-size-textfield"].text = tostring(map_settings.enemy_expansion.settler_group_max_size)
	expansion_table["new-game-plus-expansion-min-cd-textfield"].text = tostring(map_settings.enemy_expansion.min_expansion_cooldown / 3600)
	expansion_table["new-game-plus-expansion-max-cd-textfield"].text = tostring(map_settings.enemy_expansion.max_expansion_cooldown / 3600)
end

-- WOLRD GEN --
local function textfield_to_uint(textfield)
	local number = tonumber(textfield.text)
	if textfield.text and number and (number >= 0) and (number <= 4294967295) and (math.floor(number) == number) then
		return number
	else
		return false
	end
end

local function textfield_to_number(textfield)
	local number = tonumber(textfield.text)
	if textfield.text and number then
		return number
	else
		return false
	end
end

local function change_map_settings(player)
	local frame_flow = mod_gui.get_frame_flow(player)
	local more_config_table = frame_flow["new-game-plus-config-more-frame"]["new-game-plus-config-more-table"]
	--Reset evolution
	if frame_flow["new-game-plus-config-frame"]["new-game-plus-config-option-table"]["new-game-plus-reset-evo-checkbox"].state then
		for _, force in pairs(game.forces) do
			force.evolution_factor = 0
		end
	end
	--Difficulty
	local difficulty_settings = game.difficulty_settings
	local difficulty_table = more_config_table["new-game-plus-config-more-difficulty-flow"]["new-game-plus-config-more-difficulty-table"]
	difficulty_settings.recipe_difficulty = difficulty_table["new-game-plus-recipe-difficulty-drop-down"].selected_index - 1
	difficulty_settings.technology_difficulty = difficulty_table["new-game-plus-technology-difficulty-drop-down"].selected_index - 1
	local technology_price_multiplier = textfield_to_uint(difficulty_table["new-game-plus-technology-multiplier-textfield"])
	if technology_price_multiplier and (technology_price_multiplier > 0) and (technology_price_multiplier <= 1000) then
		difficulty_settings.technology_price_multiplier = technology_price_multiplier
	elseif technology_price_multiplier and (technology_price_multiplier > 0) and (technology_price_multiplier > 1000) then
		difficulty_settings.technology_price_multiplier = 1000
	else
		player.print({"msg.new-game-plus-invalid-technology-multiplier"})
		return false
	end
	-- MAP SETTINGS --
	local map_settings = game.map_settings
	--Evolution
	local evo_table = more_config_table["new-game-plus-config-more-evo-flow"]["new-game-plus-config-more-evo-table"]
	map_settings.enemy_evolution.enabled = evo_table["new-game-plus-evolution-checkbox"].state
	local evolution_time = textfield_to_number(evo_table["new-game-plus-evolution-time-textfield"])
	if evolution_time and (evolution_time >= 0) and (evolution_time <= 0.0001) then
		map_settings.enemy_evolution.time_factor = evolution_time
	else
		player.print({"msg.new-game-plus-invalid-evolution-time"})
		return false
	end
	local evolution_destroy = textfield_to_number(evo_table["new-game-plus-evolution-destroy-textfield"])
	if evolution_destroy and (evolution_destroy >= 0) and (evolution_destroy <= 0.01) then
		map_settings.enemy_evolution.destroy_factor = evolution_destroy
	else
		player.print({"msg.new-game-plus-invalid-evolution-destroy"})
		return false
	end
	local evolution_pollution = textfield_to_number(evo_table["new-game-plus-evolution-pollution-textfield"])
	if evolution_pollution and (evolution_pollution >= 0) and (evolution_pollution <= 0.0001) then
		map_settings.enemy_evolution.pollution_factor = evolution_pollution
	else
		player.print({"msg.new-game-plus-invalid-evolution-pollution"})
		return false
	end
	--Pollution
	local pollution_table = more_config_table["new-game-plus-config-more-pollution-flow"]["new-game-plus-config-more-pollution-table"]
	map_settings.pollution.enabled = pollution_table["new-game-plus-pollution-checkbox"].state
	local pollution_diffusion = textfield_to_uint(pollution_table["new-game-plus-pollution-diffusion-textfield"])
	if pollution_diffusion and (pollution_diffusion >= 0) and (pollution_diffusion <= 25) then
		map_settings.pollution.diffusion_ratio = (pollution_diffusion / 100)
	else
		player.print({"msg.new-game-plus-invalid-pollution-diffusion"})
		return false
	end
	local pollution_dissipation = textfield_to_uint(pollution_table["new-game-plus-pollution-dissipation-textfield"])
	if pollution_dissipation and (pollution_dissipation > 0) and (pollution_dissipation <= 1000) then
		map_settings.pollution.ageing = pollution_dissipation
	else
		player.print({"msg.new-game-plus-invalid-pollution-dissipation"})
		return false
	end
	local pollution_tree_dmg = textfield_to_uint(pollution_table["new-game-plus-pollution-tree-dmg-textfield"])
	if pollution_tree_dmg and (pollution_tree_dmg >= 0) and (pollution_tree_dmg <= 9999) then
		map_settings.pollution.min_pollution_to_damage_trees = pollution_tree_dmg
	else
		player.print({"msg.new-game-plus-invalid-pollution-tree-dmg"})
		return false
	end
	local pollution_tree_absorb = textfield_to_uint(pollution_table["new-game-plus-pollution-tree-absorb-textfield"])
	if pollution_tree_absorb and (pollution_tree_absorb >= 0) and (pollution_tree_absorb <= 9999) then
		map_settings.pollution.pollution_restored_per_tree_damage = pollution_tree_absorb
	else
		player.print({"msg.new-game-plus-invalid-pollution-tree-absorb"})
		return false
	end
	--Enemy expansion
	local expansion_table = more_config_table["new-game-plus-config-more-expansion-flow"]["new-game-plus-config-more-expansion-table"]
	map_settings.enemy_expansion.enabled = expansion_table["new-game-plus-enemy-expansion-checkbox"].state
	local expansion_distance = textfield_to_uint(expansion_table["new-game-plus-expansion-distance-textfield"])
	if expansion_distance and (expansion_distance >= 2) and (expansion_distance <= 20) then
		map_settings.enemy_expansion.max_expansion_distance = expansion_distance
	else
		player.print({"msg.new-game-plus-invalid-expansion-distance"})
		return false
	end
	local expansion_min_size = textfield_to_uint(expansion_table["new-game-plus-expansion-min-size-textfield"])
	if expansion_min_size and (expansion_min_size >= 1) and (expansion_min_size <= 20) then
		map_settings.enemy_expansion.settler_group_min_size = expansion_min_size
	else
		player.print({"msg.new-game-plus-invalid-expansion-min-size"})
		return false
	end
	local expansion_max_size = textfield_to_uint(expansion_table["new-game-plus-expansion-max-size-textfield"])
	if expansion_max_size and (expansion_max_size >= 1) and (expansion_max_size <= 50) then
		if expansion_max_size < map_settings.enemy_expansion.settler_group_min_size then
			player.print({"msg.new-game-plus-too-low-expansion-max-size"})
			return false
		else
			map_settings.enemy_expansion.settler_group_max_size = expansion_max_size
		end
	else
		player.print({"msg.new-game-plus-invalid-expansion-max-size"})
		return false
	end
	local expansion_min_cd = textfield_to_uint(expansion_table["new-game-plus-expansion-min-cd-textfield"])
	if expansion_min_cd and (expansion_min_cd >= 1) and (expansion_min_cd <= 60) then
		map_settings.enemy_expansion.min_expansion_cooldown = (expansion_min_cd * 3600)
	else
		player.print({"msg.new-game-plus-invalid-expansion-min-cd"})
		return false
	end
	local expansion_max_cd = textfield_to_uint(expansion_table["new-game-plus-expansion-max-cd-textfield"])
	if expansion_max_cd and (expansion_max_cd >= 5) and (expansion_max_cd <= 180) then
		if expansion_max_cd < (map_settings.enemy_expansion.min_expansion_cooldown / 3600) then
			player.print({"msg.new-game-plus-too-low-expansion-max-cd"})
			return false
		else
			map_settings.enemy_expansion.max_expansion_cooldown = (expansion_max_cd * 3600)
		end
	else
		player.print({"msg.new-game-plus-invalid-expansion-max-cd"})
		return false
	end
	return true
end

local function make_map_gen_settings(player)
	local frame_flow = mod_gui.get_frame_flow(player)
	local config_options = frame_flow["new-game-plus-config-frame"]["new-game-plus-config-option-table"]
	local map_gen_settings = {}
	--general things
	local seed = textfield_to_uint(config_options["new-game-plus-seed-textfield"])
	if seed and seed == 0 then
		map_gen_settings.seed = math.random(0, 4294967295)
	elseif seed then
		map_gen_settings.seed = seed
	else
		player.print({"msg.new-game-plus-start-invalid-seed"})
		return nil
	end
	local width = textfield_to_uint(config_options["new-game-plus-width-textfield"])
	if width then
		map_gen_settings.width = width
	else
		player.print({"msg.new-game-plus-start-invalid-width"})
		return nil
	end
	local height = textfield_to_uint(config_options["new-game-plus-height-textfield"])
	if height then
		map_gen_settings.height = height
	else
		player.print({"msg.new-game-plus-start-invalid-height"})
		return nil
	end
	map_gen_settings.peaceful_mode = config_options["new-game-plus-peaceful-mode-checkbox"].state

	local freq_options = {"very-low", "low", "normal", "high", "very-high"}
	local size_options = {"none", "very-small", "small", "medium", "big", "very-big"}
	local richn_options = {"very-poor", "poor", "regular", "good", "very-good"}
	local resource_table = frame_flow["new-game-plus-config-frame"]["new-game-plus-config-resource-scroll-pane"]["new-game-plus-config-resource-table"]
	--water stuff
	map_gen_settings.terrain_segmentation = freq_options[resource_table["new-game-plus-config-water-freq"].selected_index]
	map_gen_settings.water = size_options[resource_table["new-game-plus-config-water-size"].selected_index]
	--starting area
	local starting_area_options = {"very-small", "small", "medium", "big", "very-big"}
	map_gen_settings.starting_area = starting_area_options[resource_table["new-game-plus-config-starting-area-size"].selected_index]
	--resources
	local autoplace_controls_mine = {}
	for _, resource in pairs(game.entity_prototypes) do
		if resource.type == "resource" and resource.autoplace_specification and resource.name ~= "lithia-water" then
			autoplace_controls_mine[resource.name] = {
				frequency = freq_options[resource_table["new-game-plus-config-" .. resource.name .. "-freq"].selected_index],
				size = size_options[resource_table["new-game-plus-config-" .. resource.name .. "-size"].selected_index],
				richness = richn_options[resource_table["new-game-plus-config-" .. resource.name .. "-richn"].selected_index]
			}
		end
	end
	--building platform mod
	if game.active_mods["building-platform"] and settings.startup["bp-platform-generator"].value == "default" and game.tile_prototypes["building-platform"] and game.tile_prototypes["building-platform"].autoplace_specification then
		autoplace_controls_mine["building-platform"] = {
		frequency = freq_options[resource_table["new-game-plus-config-building-platform-freq"].selected_index],
		size = size_options[resource_table["new-game-plus-config-building-platform-size"].selected_index]
		}
	end
	--biters
	if game.entity_prototypes["biter-spawner"] and game.entity_prototypes["biter-spawner"].autoplace_specification and game.entity_prototypes["spitter-spawner"] and game.entity_prototypes["spitter-spawner"].autoplace_specification then
		autoplace_controls_mine["enemy-base"] = {
		frequency = freq_options[resource_table["new-game-plus-config-enemy-base-freq"].selected_index],
		size = size_options[resource_table["new-game-plus-config-enemy-base-size"].selected_index],
		richness = richn_options[resource_table["new-game-plus-config-enemy-base-richn"].selected_index]
		}
	end
	map_gen_settings.autoplace_controls = autoplace_controls_mine
	return map_gen_settings
end

local function generate_new_world(player)
	debug_log("Generating new game plus...")
	--rso integration
	debug_log("Looking for RSO...")
	if remote.interfaces["RSO"] then
		debug_log("Detected RSO")
		if remote.interfaces["RSO"]["resetGeneration"] then
			global.use_rso = true
		else
			player.print({"msg.new-game-plus-outdated-rso"})
			return
		end
	else
		debug_log("No RSO found")
		global.use_rso = false
	end
	-- MAP GEN SETTINGS
	debug_log("Making map gen settings...")
	local map_gen_settings = make_map_gen_settings(player)
	if not map_gen_settings then
		debug_log("Aborted generating new game plus")
		return
	end
	-- MAP SETTINGS
	debug_log("Changing map settings...")
	if not change_map_settings(player) then
		debug_log("Aborted generating new game plus")
		return
	end
	-- create new surface --
	debug_log("Creating surface...")
	local nauvis_plus = game.create_surface("Nauvis plus " .. global.next_nauvis_number, map_gen_settings)
	-- teleport players to new surface --
	for _, player in pairs(game.players) do
		player.teleport({1, 1}, nauvis_plus)
		player.force.chart(nauvis_plus, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
	end 
	--set spawn
	for _, force in pairs(game.forces) do
		force.set_spawn_position({1,1}, nauvis_plus)
	end
	--set whether the tech needs to be reset
	local frame_flow = mod_gui.get_frame_flow(player)
	if frame_flow["new-game-plus-config-frame"]["new-game-plus-config-option-table"]["new-game-plus-reset-research-checkbox"].state then
		global.tech_reset = true
	else
		global.tech_reset = false
	end
	--kill the gui, it's not needed and should not exist in the background
	debug_log("Destroying the gui...")
	for _, player in pairs(game.players) do
		kill_gui(player)
	end
	--destroy the other surfaces
	debug_log("Removing surfaces...")
	for _,surface in pairs(game.surfaces) do
		if surface.name == "nauvis" then --can't delete nauvis
			for chunk in surface.get_chunks() do --so I delete its chunks on it
				local area = {{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}
				local entities = surface.find_entities(area)
				for _, entity in pairs(entities) do
					script.raise_event(defines.events.on_entity_died, {entity=entity}) --raise event so that mods can do their stuff with the entities
				end
				for _, entity in pairs(entities) do
					if entity.valid then entity.destroy() end
				end
				surface.delete_chunk({chunk.x, chunk.y})
			end
		elseif not surface.name:find("Factory floor") and (surface.name ~= "Nauvis plus " .. global.next_nauvis_number) then --don't delete factorissimo stuff or the new surface
			game.delete_surface(surface)
		end
	end
	global.next_nauvis_number = global.next_nauvis_number + 1
	global.rocket_launched = false	--we act like no rocket has been launched, so that we can do the whole "launch a satellite and make gui" thing again
	debug_log("New game plus has been generated")
end

script.on_event({defines.events.on_gui_click}, function(event)
	local player = game.players[event.player_index]
	local frame_flow = mod_gui.get_frame_flow(player)
	local clicked_name = event.element.name
	if clicked_name == "new-game-plus-toggle-config" then
		frame_flow["new-game-plus-config-frame"].style.visible = not frame_flow["new-game-plus-config-frame"].style.visible
		frame_flow["new-game-plus-config-more-frame"].style.visible = false
	elseif clicked_name == "new-game-plus-more-options" then
		frame_flow["new-game-plus-config-more-frame"].style.visible = not frame_flow["new-game-plus-config-more-frame"].style.visible
	elseif clicked_name == "new-game-plus-use-current-button" then
		use_current_map_gen(player)
	elseif clicked_name == "new-game-plus-start-button" then
		if not player.admin then
			player.print({"msg.new-game-plus-start-admin-restriction"})
			return
		end
		generate_new_world(player)
	elseif clicked_name == "new-game-plus-default-button" then
		reset_to_default(player)
	end
end)

local function make_grass_bridge(from, to, surface) --makes a two tile wide north-south bridge if there is water
	local tile_table = {}
	for y=from, to do
		local tile = surface.get_tile(0, y)
		if tile.name:find("water") then
			table.insert(tile_table,{name="grass", position={0, y}})
		end
		tile = surface.get_tile(1, y)
		if tile.name:find("water") then
			table.insert(tile_table,{name="grass", position={1, y}})
		end
	end
	surface.set_tiles(tile_table)
end

script.on_event(defines.events.on_chunk_generated, function(event) --prevent island spawns (hopefully)
	if global.next_nauvis_number == 1 then return end
	local this_nauvis_number = global.next_nauvis_number - 1
	local surface = event.surface
	if surface.name == "Nauvis plus " .. this_nauvis_number then
		local chunk_area = event.area
		if chunk_area.left_top.x == 0 and chunk_area.left_top.y == 0 and chunk_area.right_bottom.x == 32 and chunk_area.right_bottom.y == 32 then
			debug_log("Making grass bridge in first chunk...")
			make_grass_bridge(0, 32, surface)
			if global.tech_reset then --tech reset on chunk gen because then the spilling works correctly
				for _, force in pairs(game.forces) do
					for _, tech in pairs(force.technologies) do
						tech.researched = false;
						force.set_saved_technology_progress(tech, 0)
					end
				end
			end
			if global.use_rso then --doing this here because otherwise ores may spawn on water
				debug_log("Using RSO ore generation")
				remote.call("RSO", "resetGeneration", surface)
				remote.call("RSO", "regenerate", false)
				debug_log("Called RSO resetGeneration and regenerate")
			end
		end
		if chunk_area.left_top.x == 0 and chunk_area.left_top.y == 32 and chunk_area.right_bottom.x == 32 and chunk_area.right_bottom.y == 64 then
			debug_log("Making grass bridge in second chunk...")
			make_grass_bridge(33, 64, surface)
		end
		if chunk_area.left_top.x == 0 and chunk_area.left_top.y == 64 and chunk_area.right_bottom.x == 32 and chunk_area.right_bottom.y == 96 then
			debug_log("Making grass bridge in third chunk...")
			make_grass_bridge(65, 95, surface)
		end
	end
end)

script.on_configuration_changed(function() --regen gui in case a mod added/removed resources, only if a rocket has been launched; also runs if startup settings change
	if global.rocket_launched then
		for _, player in pairs(game.players) do
			regen_gui(player)
		end
	end
end)

script.on_event(defines.events.on_player_created, function(event) --create gui for joining player, only if a rocket has been launched
	if global.rocket_launched then
		regen_gui(game.players[event.player_index])
	end
end)

script.on_init(function()
	global.next_nauvis_number = 1
	global.use_rso = false
end)

commands.add_command("ngp-gui", {"msg.new-game-plus-gui-command-help"}, function(event)
	if game.players[event.player_index].admin then
		if settings.global["new-game-plus-allow-early-gui"].value then
			for _, player in pairs(game.players) do
				regen_gui(player)
			end
			global.rocket_launched = true --the rocket has now been launched, so the gui has to be regened on player created and config changed
		else
			game.players[event.player_index].print({"msg.new-game-plus-gui-command-disabled"})
		end
	end
end)
