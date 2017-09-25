require("mod-gui")

-- GUI --
function kill_gui(player)
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
end

function format_number(number)
	return string.format("%f", tostring(number))
end

local function make_config_option(parent, name, caption, tooltip, default, max_width)
	parent.add{
		type = "label",
		caption = caption,
		tooltip = tooltip,
		name = "new-game-plus-" .. name .. "-label",
	}
	local child = parent.add{
		type = "textfield",
		name = "new-game-plus-" .. name .. "-textfield",
	}
	child.text = default
	if max_width then child.style.maximal_width = max_width end
	return child
end

local function make_expansion_settings_gui(config_more_table, map_settings)
	local config_more_option_expansion_flow = config_more_table.add{
		type = "flow",
		name = "new-game-plus-config-more-expansion-flow",
		direction = "vertical"
	}
	config_more_option_expansion_flow.add{
		type = "label",
		caption = {"gui-map-generator.enemy-expansion-group-tile"},
		style = "caption_label_style",
		name = "new-game-plus-expansion-title-label",
	}
	local config_more_option_expansion_table = config_more_option_expansion_flow.add{
		type = "table",
		name = "new-game-plus-config-more-expansion-table",
		colspan = 2
	}
	
	config_more_option_expansion_table.add{
		type = "label",
		caption = {"gui-map-generator.enemy-expansion-group-tile"},
		name = "new-game-plus-enemy-expansion-label",
	}
	config_more_option_expansion_table.add{
		type = "checkbox",
		name = "new-game-plus-enemy-expansion-checkbox",
		state = map_settings.enemy_expansion.enabled,
	}
	local thirty = 30
	make_config_option(config_more_option_expansion_table, "expansion-distance", {"gui-map-generator.enemy-expansion-maximum-expansion-distance"}, {"gui-map-generator.enemy-expansion-maximum-expansion-distance-description"}, tostring(map_settings.enemy_expansion.max_expansion_distance), thirty)
	make_config_option(config_more_option_expansion_table, "expansion-min-size", {"gui-map-generator.enemy-expansion-minimum-expansion-group-size"}, {"gui-map-generator.enemy-expansion-minimum-expansion-group-size-description"}, tostring(map_settings.enemy_expansion.settler_group_min_size), thirty)
	make_config_option(config_more_option_expansion_table, "expansion-max-size", {"gui-map-generator.enemy-expansion-maximum-expansion-group-size"}, {"gui-map-generator.enemy-expansion-maximum-expansion-group-size-description"}, tostring(map_settings.enemy_expansion.settler_group_max_size), thirty)
	make_config_option(config_more_option_expansion_table, "expansion-min-cd", {"gui.new-game-plus-in-unit", {"gui-map-generator.enemy-expansion-minimum-expansion-cooldown"}, {"minute5+"}}, {"gui-map-generator.enemy-expansion-minimum-expansion-cooldown-description"},  tostring(map_settings.enemy_expansion.min_expansion_cooldown / 3600), thirty)
	make_config_option(config_more_option_expansion_table, "expansion-max-cd", {"gui.new-game-plus-in-unit", {"gui-map-generator.enemy-expansion-maximum-expansion-cooldown"}, {"minute5+"}}, {"gui-map-generator.enemy-expansion-maximum-expansion-cooldown-description"}, tostring(map_settings.enemy_expansion.max_expansion_cooldown / 3600), thirty)
end

local function make_pollution_settings_gui(config_more_table, map_settings)
	local config_more_option_pollution_flow = config_more_table.add{
		type = "flow",
		name = "new-game-plus-config-more-pollution-flow",
		direction = "vertical"
	}
	config_more_option_pollution_flow.add{
		type = "label",
		caption = {"gui-map-generator.pollution"},
		style = "caption_label_style",
		name = "new-game-plus-pollution-title-label",
	}
	local config_more_option_pollution_table = config_more_option_pollution_flow.add{
		type = "table",
		name = "new-game-plus-config-more-pollution-table",
		colspan = 2
	}
	
	config_more_option_pollution_table.add{
		type = "label",
		caption = {"gui-map-generator.pollution"},
		name = "new-game-plus-pollution-label",
	}
	config_more_option_pollution_table.add{
		type = "checkbox",
		name = "new-game-plus-pollution-checkbox",
		state = map_settings.pollution.enabled,
	}
	make_config_option(config_more_option_pollution_table, "pollution-diffusion", {"gui.new-game-plus-in-unit", {"gui-map-generator.pollution-diffusion-ratio"}, {"gui.new-game-plus-percent"}}, {"gui-map-generator.pollution-diffusion-ratio-description"}, tostring(map_settings.pollution.diffusion_ratio * 100), 50)
	make_config_option(config_more_option_pollution_table, "pollution-dissipation", {"gui-map-generator.pollution-dissipation-rate"}, {"gui-map-generator.pollution-dissipation-rate-description"}, tostring(map_settings.pollution.ageing), 50)
	make_config_option(config_more_option_pollution_table, "pollution-tree-dmg", {"gui-map-generator.minimum-pollution-to-damage-trees"}, {"gui-map-generator.minimum-pollution-to-damage-trees-description"}, tostring(map_settings.pollution.min_pollution_to_damage_trees), 50)
	make_config_option(config_more_option_pollution_table, "pollution-tree-absorb", {"gui-map-generator.pollution-absorbed-per-tree-damaged"}, {"gui-map-generator.pollution-absorbed-per-tree-damaged-description"}, tostring(map_settings.pollution.pollution_restored_per_tree_damage), 50)
end

local function make_evolution_settings_gui(config_more_table, map_settings)
	local config_more_option_evo_flow = config_more_table.add{
		type = "flow",
		name = "new-game-plus-config-more-evo-flow",
		direction = "vertical"
	}
	config_more_option_evo_flow.add{
		type = "label",
		caption = {"gui-map-generator.evolution"},
		style = "caption_label_style",
		name = "new-game-plus-evolution-title-label",
	}
	local config_more_option_evo_table = config_more_option_evo_flow.add{
		type = "table",
		name = "new-game-plus-config-more-evo-table",
		colspan = 2
	}
	
	config_more_option_evo_table.add{
		type = "label",
		caption = {"gui-map-generator.evolution"},
		name = "new-game-plus-pollution-enabled-label",
	}
	config_more_option_evo_table.add{
		type = "checkbox",
		name = "new-game-plus-evolution-checkbox",
		state = map_settings.enemy_evolution.enabled,
	}
	make_config_option(config_more_option_evo_table, "evolution-time", {"gui-map-generator.evolution-time-factor"}, {"gui-map-generator.evolution-time-factor-description"}, format_number(map_settings.enemy_evolution.time_factor), 80)
	make_config_option(config_more_option_evo_table, "evolution-destroy", {"gui-map-generator.evolution-destroy-factor"}, {"gui-map-generator.evolution-destroy-factor-description"}, format_number(map_settings.enemy_evolution.destroy_factor), 80)
	make_config_option(config_more_option_evo_table, "evolution-pollution", {"gui-map-generator.evolution-pollution-factor"}, {"gui-map-generator.evolution-pollution-factor-description"}, format_number(map_settings.enemy_evolution.pollution_factor), 80)
end

local function make_difficulty_settings_gui(config_more_table)
	local config_more_option_difficulty_flow = config_more_table.add{
		type = "flow",
		name = "new-game-plus-config-more-difficulty-flow",
		direction = "vertical"
	}
	config_more_option_difficulty_flow.add{
		type = "label",
		caption = {"gui-map-generator.recipes-and-technology-group-tile"},
		style = "caption_label_style",
		name = "new-game-plus-difficulty-title-label",
	}
	local config_more_option_difficulty_table = config_more_option_difficulty_flow.add{
		type = "table",
		name = "new-game-plus-config-more-difficulty-table",
		colspan = 2
	}
	
	local difficulty_options = {{"recipe-difficulty.normal"}, {"recipe-difficulty.expensive"}}
	config_more_option_difficulty_table.add{
		type = "label",
		caption = {"gui-map-generator.recipe-difficulty"},
		name = "new-game-plus-recipe-difficulty-label",
	}
	local recipe_difficulty = config_more_option_difficulty_table.add{
		type = "drop-down",
		name = "new-game-plus-recipe-difficulty-drop-down",
	}
	recipe_difficulty.items = difficulty_options
	recipe_difficulty.selected_index = game.difficulty_settings.recipe_difficulty + 1
	config_more_option_difficulty_table.add{
		type = "label",
		caption = {"gui-map-generator.technology-difficulty"},
		name = "new-game-plus-technology-difficulty-label",
	}
	local technology_difficulty = config_more_option_difficulty_table.add{
		type = "drop-down",
		name = "new-game-plus-technology-difficulty-drop-down",
	}
	technology_difficulty.items = difficulty_options
	technology_difficulty.selected_index = game.difficulty_settings.technology_difficulty + 1
	config_more_option_difficulty_table.add{
		type = "label",
		caption = {"gui-map-generator.technology-price-multiplier"},
		name = "new-game-plus-technology-multiplier-label",
	}
	local technology_multiplier = config_more_option_difficulty_table.add{
		type = "textfield",
		name = "new-game-plus-technology-multiplier-textfield",
	}
	technology_multiplier.text = tostring(game.difficulty_settings.technology_price_multiplier)
	technology_multiplier.style.maximal_width = 50
end

local function make_advanced_settings_gui(config_more_frame)
	local config_more_table = config_more_frame.add{
		type = "table",
		name = "new-game-plus-config-more-table",
		colspan = 2
	}
	local map_settings = game.map_settings
	--make different advanced option groups
	make_difficulty_settings_gui(config_more_table)
	make_evolution_settings_gui(config_more_table, map_settings)
	make_pollution_settings_gui(config_more_table, map_settings)
	make_expansion_settings_gui(config_more_table, map_settings)
end

local function generate_resource_options(resource_name, config_resource_table, freq_options, size_options, richn_options)
	if resource_name == "lithia-water" then return end --belongs to ground-water autoplace control (bob's mod)
	config_resource_table.add{
		type = "label",
		caption = {"autoplace-control-names." .. resource_name},
		name = "new-game-plus-config-" .. resource_name .. "-label",
	}
	local resource_freq = config_resource_table.add{
		type = "drop-down",
		name = "new-game-plus-config-" .. resource_name .. "-freq",
	}
	resource_freq.items = freq_options
	resource_freq.selected_index = 3
	local resource_size = config_resource_table.add{
		type = "drop-down",
		name = "new-game-plus-config-" .. resource_name .. "-size",
	}
	resource_size.items = size_options
	resource_size.selected_index = 4
	local resource_richn = config_resource_table.add{
		type = "drop-down",
		name = "new-game-plus-config-" .. resource_name .. "-richn",
	}
	resource_richn.items = richn_options
	resource_richn.selected_index = 3
end

local function make_resource_settings_gui(config_frame)
	local config_resource_scroll_pane = config_frame.add{
		type = "scroll-pane",
		name = "new-game-plus-config-resource-scroll-pane",
	}
	config_resource_scroll_pane.style.maximal_height = 400
	config_resource_scroll_pane.style.visible = true
	local config_resource_table = config_resource_scroll_pane.add{
		type = "table",
		name = "new-game-plus-config-resource-table",
		colspan = 4
	}
	config_resource_table.add{
		type = "label",
		caption = " ",
		name = "new-game-plus-config-resource-empty-label",
	}
	config_resource_table.add{
		type = "label",
		caption = {"gui-map-generator.frequency"},
		style = "caption_label_style",
		name = "new-game-plus-config-resource-freq-label",
	}
	config_resource_table.add{
		type = "label",
		caption = {"gui-map-generator.size"},
		style = "caption_label_style",
		name = "new-game-plus-config-resource-size-label",
	}
	config_resource_table.add{
		type = "label",
		caption = {"gui-map-generator.richness"},
		style = "caption_label_style",
		name = "new-game-plus-config-resource-richn-label",
	}
	local freq_options = {{"frequency.very-low"}, {"frequency.low"}, {"frequency.normal"}, {"frequency.high"}, {"frequency.very-high"}}
	local size_options = {{"size.none"}, {"size.very-low"}, {"size.low"}, {"size.normal"}, {"size.high"}, {"size.very-high"}}
	local richn_options = {{"richness.very-low"}, {"richness.low"}, {"richness.normal"}, {"richness.high"}, {"richness.very-high"}}
	--water stuff
	config_resource_table.add{
		type = "label",
		caption = {"gui-map-generator.water"},
		name = "new-game-plus-config-water-label",
	}
	local resource_freq = config_resource_table.add{ --terrain segmentation
		type = "drop-down",
		name = "new-game-plus-config-water-freq",
	}
	resource_freq.items = freq_options
	resource_freq.selected_index = 3
	local resource_size = config_resource_table.add{  --"water" in the map gen settings
		type = "drop-down",
		name = "new-game-plus-config-water-size",
	}
	resource_size.items = size_options --first option should actually be size.only-starting-area but that localized string is waaaay too long
	resource_size.selected_index = 4
	config_resource_table.add{
		type = "label",
		caption = " ",
		name = "new-game-plus-config-resource-empty-label-2",
	}
	--biters
	if game.entity_prototypes["biter-spawner"] and game.entity_prototypes["biter-spawner"].autoplace_specification and game.entity_prototypes["spitter-spawner"] and game.entity_prototypes["spitter-spawner"].autoplace_specification then
		generate_resource_options("enemy-base", config_resource_table, freq_options, size_options, richn_options)
	end
	--resources
	for _, resource in pairs(game.entity_prototypes) do
		if resource.type == "resource" and resource.autoplace_specification then
			generate_resource_options(resource.name, config_resource_table, freq_options, size_options, richn_options)
		end
	end
	--starting area
	config_resource_table.add{
		type = "label",
		caption = {"gui-map-generator.starting-area"},
		name = "new-game-plus-config-starting-area-label",
	}
	config_resource_table.add{
		type = "label",
		caption = " ",
		name = "new-game-plus-config-resource-empty-label-3",
	}
	local starting_area_size = config_resource_table.add{
		type = "drop-down",
		name = "new-game-plus-config-starting-area-size",
	}
	starting_area_size.items = {{"size.very-low"}, {"size.low"}, {"size.normal"}, {"size.high"}, {"size.very-high"}}
	starting_area_size.selected_index = 3
	config_resource_table.add{
		type = "label",
		caption = " ",
		name = "new-game-plus-config-resource-empty-label-4",
	}
end

local function make_basic_settings_gui(config_frame)
	local config_option_table = config_frame.add{
		type = "table",
		name = "new-game-plus-config-option-table",
		colspan = 2
	}
	config_option_table.add{
		type = "label",
		name = "new-game-plus-reset-evo-label",
		caption = {"gui.new-game-plus-reset-evo-caption"},
	}
	config_option_table.add{
		type = "checkbox",
		name = "new-game-plus-reset-evo-checkbox",
		state = true,
	}
	config_option_table.add{
		type = "label",
		name = "new-game-plus-reset-research-label",
		caption = {"gui.new-game-plus-reset-research-caption"},
	}
	config_option_table.add{
		type = "checkbox",
		name = "new-game-plus-reset-research-checkbox",
		state = false,
	}
	config_option_table.add{
		type = "label",
		name = "new-game-plus-peaceful-mode-label",
		caption = {"gui-map-generator.peaceful-mode"},
	}
	config_option_table.add{
		type = "checkbox",
		name = "new-game-plus-peaceful-mode-checkbox",
		state = false,
	}
	config_option_table.add{
		type = "label",
		name = "new-game-plus-seed-label",
		caption = {"gui.new-game-plus-seed-caption"},
	}
	local seed_textfield = config_option_table.add{
		type = "textfield",
		name = "new-game-plus-seed-textfield",
	}
	seed_textfield.text = "0"
	config_option_table.add{
		type = "label",
		name = "new-game-plus-width-label",
		caption = {"gui.new-game-plus-width-caption"},
	}
	local width_textfield = config_option_table.add{
		type = "textfield",
		name = "new-game-plus-width-textfield",
	}
	width_textfield.text = "0"
	config_option_table.add{
		type = "label",
		name = "new-game-plus-height-label",
		caption = {"gui.new-game-plus-height-caption"},
	}
	local height_textfield = config_option_table.add{
		type = "textfield",
		name = "new-game-plus-height-textfield",
	}
	height_textfield.text = "0"
	local button_table = config_frame.add{
		type = "table",
		name = "new-game-plus-config-button-table",
		colspan = 2
	}
	button_table.add{
		type = "button",
		name = "new-game-plus-use-current-button",
		style = mod_gui.button_style,
		caption = {"gui.new-game-plus-use-current-button-caption"}
	}
	button_table.add{
		type = "button",
		name = "new-game-plus-default-button",
		style = mod_gui.button_style,
		caption = {"gui.new-game-plus-default-button-caption"}
	}
end

function regen_gui(player)
	kill_gui(player)
	--toggle button
	local button_flow = mod_gui.get_button_flow(player)
	local button = button_flow.add{
		type = "button",
		name = "new-game-plus-toggle-config",
		style = mod_gui.button_style,
		tooltip = {"gui.new-game-plus-toggle-tooltip", {"gui.new-game-plus-config-caption"}},
		caption = {"gui.new-game-plus-toggle-config-caption"}
	}
	button.style.visible = true
	-- general gui frame setup --
	local frame_flow = mod_gui.get_frame_flow(player)
	local config_frame = frame_flow.add{
		type = "frame",
		name = "new-game-plus-config-frame",
		direction = "vertical"
	}
	config_frame.style.visible = false
	local config_frame_title_table = config_frame.add{
		type = "table",
		name = "new-game-plus-config-frame-title-table",
		colspan = 2
	}
	local config_frame_title = config_frame_title_table.add{
		type = "label",
		name = "new-game-plus-config-frame-title-label",
		caption = {"gui.new-game-plus-config-caption"},
		style = frame_caption_label_style
	}
	config_frame_title.style.font = "default-frame"
	config_frame_title.style.right_padding = 10
	config_frame_title.style.bottom_padding = 5
	config_frame_title_table.add{
		type = "button",
		name = "new-game-plus-more-options",
		style = mod_gui.button_style,
		tooltip = {"gui.new-game-plus-toggle-tooltip", {"gui-map-generator.advanced-tab-title"}},
		caption = {"gui-map-generator.advanced-tab-title"}
	}
	local config_more_frame = frame_flow.add{
		type = "frame",
		caption = {"gui-map-generator.advanced-tab-title"},
		name = "new-game-plus-config-more-frame",
		direction = "vertical"
	}
	config_more_frame.style.visible = false
	config_more_frame.style.title_bottom_padding = 8
	
	--make gui sections
	make_basic_settings_gui(config_frame)
	make_resource_settings_gui(config_frame)
	make_advanced_settings_gui(config_more_frame)

	-- start button at the bottom
	local start_button = config_frame.add{
		type = "button",
		name = "new-game-plus-start-button",
		--style = mod_gui.button_style,
		tooltip = {"gui.new-game-plus-start-button-tooltip"},
		caption = {"gui.new-game-plus-start-button-caption"}
	}
	start_button.style.font_color = { r=1, g=0.75, b=0.22}
end
