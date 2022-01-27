local mod_gui = require("__core__/lualib/mod-gui")
local util = require("__NewGamePlus__/utilities")
local gui = require("__NewGamePlus__/gui")
local map_gen_gui = require("__NewGamePlus__/map_gen_settings_gui")
local map_settings_gui = require("__NewGamePlus__/map_settings_gui")
local DEBUG_MODE = true

local no_delete_surfaces =
{
  ["Foenestra"] = true, --don't delete special Space exploration surface (requested by Earendel)
  ["nauvis"] = true --we are here. Don't touch
}

local no_delete_surface_patterns =
{
  ["Factory floor"] = true, --don't delete factorissimo stuff
  --don't delete mobile factory surfaces (requested by Honktown)
  ["ControlRoom"] = true,
  ["mfSurface"] = true
}

local on_technology_reset_event = script.generate_event_name()
local on_post_new_game_plus_event = script.generate_event_name()

remote.add_interface("newgameplus",
{
  get_on_technology_reset_event = function() return on_technology_reset_event end,
  -- Contains: event.force = LuaForce that the technology was reset for
  get_on_post_new_game_plus_event = function() return on_post_new_game_plus_event end -- called after everything is done to create the new game plus
  -- Contains: event.tech_reset = boolean for whether technologies were reset
})

--[[ How to: Subscribe to mod events
  Basics: You get the event id from a remote interface. You subscribe to the event in on_init and on_load

  Example:

  script.on_load(function()
    if remote.interfaces["newgameplus"] then
      script.on_event(remote.call("newgameplus", "get_on_technology_reset_event"), function(event)
        -- Oh no, techs were reset, time to put my technologies into a valid state again!
      end)
    end
  end)

  script.on_init(function()
    if remote.interfaces["newgameplus"] then
      script.on_event(remote.call("newgameplus", "get_on_technology_reset_event"), function(event)
       -- Oh no, techs were reset, time to put my technologies into a valid state again!
      end)
    end
  end)

 ]]


local function debug_log(msg)
  if DEBUG_MODE then
    log(msg)
  end
end

local function full_gui_regen(player)
  gui.regen(player)
  use_current_map_gen(player, player.surface.map_gen_settings, game.difficulty_settings, game.map_settings)
end

script.on_event(defines.events.on_rocket_launched, function(event)
  if global.rocket_launched then return end --don't regen gui if this is not the first rocket launch
  if event.rocket.get_item_count("satellite") > 0 then
    for _, player in pairs(game.players) do
      full_gui_regen(player)
    end
    global.rocket_launched = true --the rocket has now been launched, so the gui has to be regened on player created and config changed
  end
end)

local function reset_to_default(player)
  local frame_flow = mod_gui.get_frame_flow(player)
  -- general options --
  local config_options = frame_flow["new-game-plus-config-frame"]["new-game-plus-config-inner-frame"]["new-game-plus-config-option-table"]
  config_options["new-game-plus-reset-evo-checkbox"].state = true
  config_options["new-game-plus-peaceful-mode-checkbox"].state = false
  config_options["new-game-plus-seed-textfield"].text = "0"
  config_options["new-game-plus-width-textfield"].text = "0"
  config_options["new-game-plus-height-textfield"].text = "0"

  -- MAP GEN SETTINGS --
  map_gen_gui.reset_to_defaults(frame_flow["new-game-plus-config-frame"]["new-game-plus-config-inner-frame"]["new-game-plus-config-subframe"])

  -- DIFFICULTY SETTINGS --
  local more_config_table = frame_flow["new-game-plus-config-more-frame"]["new-game-plus-config-more-frame"]["new-game-plus-config-more-table"]
  local difficulty_table = more_config_table["new-game-plus-config-more-difficulty-flow"]["new-game-plus-config-more-difficulty-table"]
  difficulty_table["new-game-plus-recipe-difficulty-drop-down"].selected_index  = 1
  difficulty_table["new-game-plus-technology-difficulty-drop-down"].selected_index = 1
  difficulty_table["new-game-plus-technology-multiplier-textfield"].text = "1"
  -- MAP SETTINGS --
  map_settings_gui.expansion_reset_to_defaults(more_config_table)
  map_settings_gui.evolution_reset_to_defaults(more_config_table)
  map_settings_gui.pollution_reset_to_defaults(more_config_table)
end

function use_current_map_gen(player, map_gen_settings, difficulty_settings, map_settings) -- Warning: not local
  local frame_flow = mod_gui.get_frame_flow(player)
  -- general options --
  local config_options = frame_flow["new-game-plus-config-frame"]["new-game-plus-config-inner-frame"]["new-game-plus-config-option-table"]
  config_options["new-game-plus-peaceful-mode-checkbox"].state = map_gen_settings.peaceful_mode
  config_options["new-game-plus-seed-textfield"].text = tostring(map_gen_settings.seed)
  config_options["new-game-plus-width-textfield"].text = tostring(map_gen_settings.width == 2000000 and 0 or map_gen_settings.width) --show 0 if it was set to "infinite"
  config_options["new-game-plus-height-textfield"].text = tostring(map_gen_settings.height == 2000000 and 0 or map_gen_settings.height)

  -- MAP GEN SETTINGS --
  map_gen_gui.set_to_current(frame_flow["new-game-plus-config-frame"]["new-game-plus-config-inner-frame"]["new-game-plus-config-subframe"], map_gen_settings)

  -- DIFFICULTY SETTINGS --
  local more_config_table = frame_flow["new-game-plus-config-more-frame"]["new-game-plus-config-more-frame"]["new-game-plus-config-more-table"]
  local difficulty_table = more_config_table["new-game-plus-config-more-difficulty-flow"]["new-game-plus-config-more-difficulty-table"]
  difficulty_table["new-game-plus-recipe-difficulty-drop-down"].selected_index  = difficulty_settings.recipe_difficulty + 1
  difficulty_table["new-game-plus-technology-difficulty-drop-down"].selected_index = difficulty_settings.technology_difficulty + 1
  difficulty_table["new-game-plus-technology-multiplier-textfield"].text = tostring(difficulty_settings.technology_price_multiplier)
  -- MAP SETTINGS --
  map_settings_gui.expansion_set_to_current(more_config_table, map_settings)
  map_settings_gui.evolution_set_to_current(more_config_table, map_settings)
  map_settings_gui.pollution_set_to_current(more_config_table, map_settings)
end

-- Import map exchange string
local function import_mes(player)
  local textbox = player.gui.center["new-game-plus-import-frame"]["new-game-plus-import-text-box"]
  local status, settings = pcall(game.parse_map_exchange_string, textbox.text)
  gui.kill_mes_import_window(player)
  if not status then
    player.print({"gui-map-generator.error-importing-exchange-string"})
    player.print(settings)
    return
  end
  use_current_map_gen(player, settings.map_gen_settings, settings.map_settings.difficulty_settings, settings.map_settings)
end

-- WOLRD GEN --
local function change_map_settings(player)
  local frame_flow = mod_gui.get_frame_flow(player)
  local more_config_table = frame_flow["new-game-plus-config-more-frame"]["new-game-plus-config-more-frame"]["new-game-plus-config-more-table"]
  --Reset evolution
  if frame_flow["new-game-plus-config-frame"]["new-game-plus-config-inner-frame"]["new-game-plus-config-option-table"]["new-game-plus-reset-evo-checkbox"].state then
    for _, force in pairs(game.forces) do
      force.reset_evolution()
    end
  end
  --Difficulty
  local difficulty_settings = game.difficulty_settings
  local difficulty_table = more_config_table["new-game-plus-config-more-difficulty-flow"]["new-game-plus-config-more-difficulty-table"]
  difficulty_settings.recipe_difficulty = difficulty_table["new-game-plus-recipe-difficulty-drop-down"].selected_index - 1
  difficulty_settings.technology_difficulty = difficulty_table["new-game-plus-technology-difficulty-drop-down"].selected_index - 1
  local technology_price_multiplier = util.textfield_to_uint(difficulty_table["new-game-plus-technology-multiplier-textfield"])
  if technology_price_multiplier and (technology_price_multiplier > 0) and (technology_price_multiplier <= 1000) then
    difficulty_settings.technology_price_multiplier = technology_price_multiplier
  elseif technology_price_multiplier and (technology_price_multiplier > 0) and (technology_price_multiplier > 1000) then
    difficulty_settings.technology_price_multiplier = 1000
  else
    player.print({"msg.new-game-plus-invalid-technology-multiplier"})
    return false
  end
  -- MAP SETTINGS --
  local status, enemy_expansion = pcall(map_settings_gui.expansion_read, more_config_table)
  if not status then
    player.print(enemy_expansion)
    player.print({"msg.new-game-plus-apply-failed"})
    return false
  end
  local status2, enemy_evolution = pcall(map_settings_gui.evolution_read, more_config_table)
  if not status2 then
    player.print(enemy_evolution)
    player.print({"msg.new-game-plus-apply-failed"})
    return false
  end
  local status3, pollution = pcall(map_settings_gui.pollution_read, more_config_table)
  if not status3 then
    player.print(pollution)
    player.print({"msg.new-game-plus-apply-failed"})
    return false
  end

  local map_settings = game.map_settings
  if (pollution.enabled ~= map_settings.pollution.enabled) and (pollution.enabled == false) then
    for _, surface in pairs(game.surfaces) do
      surface.clear_pollution()
    end
  end
  for k, v in pairs(pollution) do -- fucking structs
    map_settings.pollution[k] = v
  end
  for k, v in pairs(enemy_expansion) do
    map_settings.enemy_expansion[k] = v
  end
  for k, v in pairs(enemy_evolution) do
    map_settings.enemy_evolution[k] = v
  end
  return true
end

local function make_map_gen_settings(player)
  local frame_flow = mod_gui.get_frame_flow(player)
  local config_options = frame_flow["new-game-plus-config-frame"]["new-game-plus-config-inner-frame"]["new-game-plus-config-option-table"]
  local map_gen_settings = {}

  -- overall settings
  local status, map_gen_settings = pcall(map_gen_gui.read, frame_flow["new-game-plus-config-frame"]["new-game-plus-config-inner-frame"]["new-game-plus-config-subframe"], player.surface.map_gen_settings)
  if not status then
    player.print(map_gen_settings)
    player.print({"msg.new-game-plus-apply-failed"})
    return
  end

  -- fill out missing fields with the current settings
  map_gen_settings.starting_points = player.surface.map_gen_settings.starting_points
  map_gen_settings.default_enable_all_autoplace_controls = player.surface.map_gen_settings.default_enable_all_autoplace_controls
  map_gen_settings.autoplace_settings = player.surface.map_gen_settings.autoplace_settings

  -- rest of the fields
  local seed = util.textfield_to_uint(config_options["new-game-plus-seed-textfield"])
  if seed and seed == 0 then
    map_gen_settings.seed = math.random(0, 4294967295)
  elseif seed then
    map_gen_settings.seed = seed
  else
    player.print({"msg.new-game-plus-start-invalid-seed"})
    return
  end
  local width = util.textfield_to_uint(config_options["new-game-plus-width-textfield"])
  if width then
    map_gen_settings.width = width
  else
    player.print({"msg.new-game-plus-start-invalid-width"})
    return
  end
  local height = util.textfield_to_uint(config_options["new-game-plus-height-textfield"])
  if height then
    map_gen_settings.height = height
  else
    player.print({"msg.new-game-plus-start-invalid-height"})
    return
  end
  map_gen_settings.peaceful_mode = config_options["new-game-plus-peaceful-mode-checkbox"].state

  return map_gen_settings
end

local function generate_new_world(player)
  debug_log("Generating new game plus...")
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
  -- teleport to nauvis --
  local nauvis = game.surfaces[1]
  for _, plyr in pairs(game.players) do
    plyr.teleport({1, 1}, nauvis)
  end
  -- apply map gen settings
  nauvis.map_gen_settings = map_gen_settings
  -- clear nauvis so that it can be regenerated, ignore characters
  nauvis.clear(true)
  -- chart, set spawn
  for _, force in pairs(game.forces) do
    force.chart(nauvis, {{-200, -200}, {200, 200}})
    force.set_spawn_position({1,1}, nauvis)
  end

  nauvis.request_to_generate_chunks({0,0},1)
  nauvis.force_generate_chunk_requests()

  --reset tech
  local frame_flow = mod_gui.get_frame_flow(player)
  local tech_reset = false
  if frame_flow["new-game-plus-config-frame"]["new-game-plus-config-inner-frame"]["new-game-plus-config-option-table"]["new-game-plus-reset-research-checkbox"].state then
    tech_reset = true
    for _, force in pairs(game.forces) do
      for _, tech in pairs(force.technologies) do
        tech.researched = false;
        force.set_saved_technology_progress(tech, 0)
      end
      script.raise_event(on_technology_reset_event, {force = force})
    end
  end  
  
  --kill the gui, it's not needed and should not exist in the background
  debug_log("Destroying the gui...")
  for _, player in pairs(game.players) do
    gui.kill(player)
  end
  --destroy the other surfaces
  debug_log("Removing surfaces...")
  for _,surface in pairs(game.surfaces) do
    local name = surface.name
    if not (no_delete_surfaces[name] or util.str_contains_any_from_table(name, no_delete_surface_patterns)) then 
      game.delete_surface(surface)
    end
  end
  global.world_generated = true
  global.rocket_launched = false  --we act like no rocket has been launched, so that we can do the whole "launch a satellite and make gui" thing again
  debug_log("New game plus has been generated, raising event")
  script.raise_event(on_post_new_game_plus_event, {tech_reset = tech_reset})
end

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  local frame_flow = mod_gui.get_frame_flow(player)
  local clicked_name = event.element.name
  if clicked_name == "new-game-plus-toggle-config" then
    if not frame_flow["new-game-plus-config-frame"] then
      full_gui_regen(player)
    end
    frame_flow["new-game-plus-config-frame"].visible = not frame_flow["new-game-plus-config-frame"].visible
    frame_flow["new-game-plus-config-more-frame"].visible = false
  elseif clicked_name == "new-game-plus-more-options" then
    frame_flow["new-game-plus-config-more-frame"].visible = not frame_flow["new-game-plus-config-more-frame"].visible
  elseif clicked_name == "new-game-plus-use-current-button" then
    use_current_map_gen(player, player.surface.map_gen_settings, game.difficulty_settings, game.map_settings)
  elseif clicked_name == "new-game-plus-start-button" then
    if not player.admin then
      player.print({"msg.new-game-plus-start-admin-restriction"})
      return
    end
    generate_new_world(player)
  elseif clicked_name == "new-game-plus-default-button" then
    reset_to_default(player)
  elseif clicked_name == "new-game-plus-map-exchange-string" then
    gui.open_mes_import_window(player)
  elseif clicked_name == "new-game-plus-import-confirm-button" then
    import_mes(player)
  end
end)

local function make_grass_bridge(from, to, surface) --makes a two tile wide north-south bridge if there is water
  local tile_table = {}
  for y=from, to do
    local tile = surface.get_tile(0, y)
    if tile.name:find("water") then
      table.insert(tile_table,{name="grass-1", position={0, y}})
    end
    tile = surface.get_tile(1, y)
    if tile.name:find("water") then
      table.insert(tile_table,{name="grass-1", position={1, y}})
    end
  end
  surface.set_tiles(tile_table)
end

script.on_event(defines.events.on_chunk_generated, function(event) --prevent island spawns (hopefully)
  if not global.world_generated then return end
  local surface = event.surface
  if surface.index == 1 then
    local chunk_area = event.area
    if chunk_area.left_top.x == 0 and chunk_area.left_top.y == 0 and chunk_area.right_bottom.x == 32 and chunk_area.right_bottom.y == 32 then
      debug_log("Making grass bridge in chunk...") -- island spawns are so rare now that I only make a bridge in the first chunk
      make_grass_bridge(0, 32, surface)
      global.world_generated = false
    end
  end
end)

script.on_configuration_changed(function() --regen gui in case a mod added/removed resources, only if a rocket has been launched; also runs if startup settings change
  if global.rocket_launched then
    for _, player in pairs(game.players) do
      full_gui_regen(player)
    end
  end
  global.use_rso = nil -- migration from pre 3.0.1
  global.tech_reset = nil -- migration from pre 3.1.2
  if not global.world_generated then
    global.world_generated = global.next_nauvis_number and global.next_nauvis_number ~= 1 or false -- migration from pre 3.1.0
  end
end)

script.on_event(defines.events.on_player_created, function(event) --create gui for joining player, only if a rocket has been launched
  if global.rocket_launched then
    full_gui_regen(game.get_player(event.player_index))
  end
end)

script.on_init(function()
  global.world_generated = false
end)

commands.add_command("ngp-gui", {"msg.new-game-plus-gui-command-help"}, function(event)
  if game.get_player(event.player_index).admin then
    if settings.global["new-game-plus-allow-early-gui"].value then
      for _, player in pairs(game.players) do
        full_gui_regen(player)
      end
      global.rocket_launched = true --the rocket has now been launched, so the gui has to be regened on player created and config changed
    else
      game.get_player(event.player_index).print({"msg.new-game-plus-gui-command-disabled"})
    end
  end
end)
