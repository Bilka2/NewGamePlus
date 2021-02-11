local mod_gui = require("mod-gui")
local util = require("utilities")
local map_gen_gui = require("map_gen_settings_gui")
local map_settings_gui = require("map_settings_gui")

local gui = {}

gui.regen = function(player)
  gui.kill(player)
  --toggle button
  local button_flow = mod_gui.get_button_flow(player)
  local button = button_flow.add{
    type = "button",
    name = "new-game-plus-toggle-config",
    style = mod_gui.button_style,
    tooltip = {"gui.new-game-plus-toggle-tooltip", {"gui.new-game-plus-config-caption"}},
    caption = {"gui.new-game-plus-toggle-config-caption"}
  }
  button.visible = true
  -- general gui frame setup --
  local frame_flow = mod_gui.get_frame_flow(player)
  local config_frame = frame_flow.add{
    type = "frame",
    name = "new-game-plus-config-frame",
    direction = "vertical"
  }
  config_frame.visible = false
  -- it's the top flow of the main window, has title, import and advanced button
  local config_frame_title_flow = config_frame.add{
    type = "flow"
  }
  config_frame_title_flow.add{
    type = "label",
    caption = {"gui.new-game-plus-config-caption"},
    style = "frame_title"
  }
  config_frame_title_flow.add{
    type = "flow",
    style = "pusher"
  }
  -- advanced button
  local advanced_button = config_frame_title_flow.add{
    type = "button",
    name = "new-game-plus-more-options",
    style = mod_gui.button_style,
    tooltip = {"gui.new-game-plus-toggle-tooltip", {"gui-map-generator.advanced-tab-title"}},
    caption = {"gui-map-generator.advanced-tab-title"}
  }
  advanced_button.style.height = 24
  advanced_button.style.bottom_padding = 4

  --make main gui sections
  local inner_frame = config_frame.add{
    type = "frame",
    direction = "vertical",
    style = "deep_frame",
    name = "new-game-plus-config-inner-frame"
  }
  gui.make_basic_settings_gui(inner_frame)
  local config_subframe = inner_frame.add{
    type = "flow",
    name = "new-game-plus-config-subframe",
    direction = "horizontal"
  }
  map_gen_gui.create(config_subframe)

  -- advanced window
  local config_more_frame = frame_flow.add{
    type = "frame",
    caption = {"gui-map-generator.advanced-tab-title"},
    name = "new-game-plus-config-more-frame",
    direction = "vertical"
  }
  config_more_frame.visible = false
  gui.make_advanced_settings_gui(config_more_frame)

  -- start button at the bottom
  local start_button_flow = config_frame.add{
    type = "flow",
    direction = "horizontal"
  }
  start_button_flow.style.top_padding = 8
  start_button_flow.add{
    type = "flow",
    style = "pusher"
  }
  start_button_flow.add{
    type = "button",
    name = "new-game-plus-start-button",
    style = "confirm_button",
    tooltip = {"gui.new-game-plus-start-button-tooltip"},
    caption = {"", "[img=utility/warning]  ", {"gui.new-game-plus-start-button-caption"}}
  }
end

gui.kill = function(player)
  local button_flow = mod_gui.get_button_flow(player)
  local frame_flow = mod_gui.get_frame_flow(player)
  if button_flow["new-game-plus-toggle-config"] then
    button_flow["new-game-plus-toggle-config"].destroy()
  end
  if frame_flow["new-game-plus-config-frame"] then
    frame_flow["new-game-plus-config-frame"].destroy()
  end
  if frame_flow["new-game-plus-config-more-frame"] then
    frame_flow["new-game-plus-config-more-frame"].destroy()
  end
  gui.kill_mes_import_window(player)
end

gui.kill_mes_import_window = function(player)
  if player.gui.center["new-game-plus-import-frame"] then
    player.gui.center["new-game-plus-import-frame"].destroy()
  end
end

gui.make_basic_settings_gui = function(parent)
  do --subheader
    local frame = parent.add{
      type = "frame",
      direction = "horizontal",
      style = "subheader_frame"
    }
    frame.add{
      type = "flow",
      direction = "horizontal",
      style = "pusher"
    }
    -- map exchange string button
    frame.add{
      type = "sprite-button",
      name = "new-game-plus-map-exchange-string",
      style = "tool_button",
      tooltip = {"gui-map-generator.import-exchange-string-tt"},
      sprite = "utility/import_slot"
    }
    -- tool buttons
    frame.add{
      type = "sprite-button",
      name = "new-game-plus-use-current-button",
      style = "tool_button",
      sprite = "utility/refresh",
      tooltip = {"gui.new-game-plus-use-current-button-caption"}
    }
    frame.add{
      type = "sprite-button",
      name = "new-game-plus-default-button",
      style = "tool_button_red",
      sprite = "utility/reset",
      tooltip = {"gui.new-game-plus-default-button-caption"}
    }
  end

  local config_option_table = parent.add{
    type = "table",
    name = "new-game-plus-config-option-table",
    column_count = 5
  }
  config_option_table.style.left_padding = 8
  config_option_table.style.right_padding = 8
  config_option_table.add{
    type = "label",
    caption = {"gui.new-game-plus-reset-evo-caption"}
  }
  config_option_table.add{
    type = "checkbox",
    name = "new-game-plus-reset-evo-checkbox",
    state = true
  }
  config_option_table.add{
    type = "flow",
    style = "pusher"
  }
  config_option_table.add{
    type = "label",
    caption = {"gui.new-game-plus-seed-caption"}
  }
  config_option_table.add{
    type = "textfield",
    name = "new-game-plus-seed-textfield",
    text = "0",
    numeric = true,
    allow_decimal = false,
    allow_negative = false
  }
  config_option_table.add{
    type = "label",
    caption = {"gui.new-game-plus-reset-research-caption"}
  }
  config_option_table.add{
    type = "checkbox",
    name = "new-game-plus-reset-research-checkbox",
    state = false
  }
  config_option_table.add{
    type = "flow",
    style = "pusher"
  }
  config_option_table.add{
    type = "label",
    caption = {"gui.new-game-plus-width-caption"}
  }
  config_option_table.add{
    type = "textfield",
    name = "new-game-plus-width-textfield",
    text = "0",
    numeric = true,
    allow_decimal = false,
    allow_negative = false
  }
  config_option_table.add{
    type = "label",
    caption = {"gui-map-generator.peaceful-mode-checkbox"}
  }
  config_option_table.add{
    type = "checkbox",
    name = "new-game-plus-peaceful-mode-checkbox",
    state = false
  }
  config_option_table.add{
    type = "flow",
    style = "pusher"
  }
  config_option_table.add{
    type = "label",
    caption = {"gui.new-game-plus-height-caption"}
  }
  config_option_table.add{
    type = "textfield",
    name = "new-game-plus-height-textfield",
    text = "0",
    numeric = true,
    allow_decimal = false,
    allow_negative = false
  }
end

gui.make_advanced_settings_gui = function(parent)
  local subframe = parent.add{
    type = "frame",
    direction = "vertical",
    style = "b_inner_frame",
    name = "new-game-plus-config-more-frame",
  }
  local table = subframe.add{
    type = "table",
    name = "new-game-plus-config-more-table",
    column_count = 2,
    vertical_centering = false
  }

  table.style.horizontal_spacing = 12
  local map_settings = game.map_settings
  --make different advanced option groups
  map_settings_gui.make_pollution_settings(table, map_settings)
  map_settings_gui.make_expansion_settings(table, map_settings)
  map_settings_gui.make_evolution_settings(table, map_settings)
  gui.make_difficulty_settings_gui(table)
end

gui.make_difficulty_settings_gui = function(parent)
  local config_more_option_difficulty_flow = parent.add{
    type = "flow",
    name = "new-game-plus-config-more-difficulty-flow",
    direction = "vertical"
  }
  config_more_option_difficulty_flow.add{
    type = "label",
    caption = {"gui.new-game-plus-recipes-and-technology-title"},
    style = "caption_label"
  }
  local table = config_more_option_difficulty_flow.add{
    type = "table",
    name = "new-game-plus-config-more-difficulty-table",
    column_count = 2,
    style = "bordered_table"
  }
  table.style.column_alignments[2] = "center"

  local difficulty_options = {{"recipe-difficulty.normal"}, {"recipe-difficulty.expensive"}}
  table.add{
    type = "label",
    caption = {"gui.new-game-plus-recipe-difficulty"}
  }
  local recipe_difficulty = table.add{
    type = "drop-down",
    name = "new-game-plus-recipe-difficulty-drop-down",
  }
  recipe_difficulty.items = difficulty_options
  recipe_difficulty.selected_index = game.difficulty_settings.recipe_difficulty + 1
  table.add{
    type = "label",
    caption = {"gui.new-game-plus-technology-difficulty"}
  }
  local technology_difficulty = table.add{
    type = "drop-down",
    name = "new-game-plus-technology-difficulty-drop-down",
  }
  technology_difficulty.items = difficulty_options
  technology_difficulty.selected_index = game.difficulty_settings.technology_difficulty + 1
  table.add{
    type = "label",
    caption = {"gui.new-game-plus-technology-price-multiplier"}
  }
  local technology_multiplier = table.add{
    type = "textfield",
    name = "new-game-plus-technology-multiplier-textfield",
    numeric = true,
    allow_decimal = true,
    allow_negative = false
  }
  technology_multiplier.text = tostring(game.difficulty_settings.technology_price_multiplier)
  technology_multiplier.style.maximal_width = 50
end

gui.open_mes_import_window = function(player)
  gui.kill_mes_import_window(player)
  local frame = player.gui.center.add{
    type = "frame",
    name = "new-game-plus-import-frame",
    direction = "vertical",
    caption = {"gui.map-exchange-string"}
  }
  frame.add{
    type = "label",
    caption = {"gui-map-generator.exchange-string-instructions"}
  }
  local textbox = frame.add{
    type = "text-box",
    name = "new-game-plus-import-text-box",
  }
  textbox.style.width = 500
  textbox.style.height = 250
  local button_flow = frame.add{
    type = "flow"
  }
  button_flow.add{
    type = "flow",
    style = "pusher"
  }
  button_flow.add{
    type = "button",
    name = "new-game-plus-import-confirm-button",
    style = "confirm_button",
    caption = {"gui.confirm"}
  }
end

return gui
