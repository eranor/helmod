---
-- Description of the module.
-- @module Player
--
local Player = {
  -- single-line comment
  classname = "HMPlayer"
}

local Lua_player = nil

-------------------------------------------------------------------------------
-- Print message
--
-- @function [parent=#Player] print
--
-- @param #string message
--
function Player.print(message)
  if Lua_player ~= nil then
    Lua_player.print(message)
  end
end
-------------------------------------------------------------------------------
-- Load factorio player
--
-- @function [parent=#Player] load
--
-- @param #LuaEvent event
--
-- @return #Player
--
function Player.load(event)
  --log("event.player_index="..(event.player_index or "nil"))
  Lua_player = game.players[event.player_index]
  return Player
end

-------------------------------------------------------------------------------
-- Set factorio player
--
-- @function [parent=#Player] set
--
-- @param #LuaPlayer player
--
-- @return #Player
--
function Player.set(player)
  Lua_player = player
  return Player
end

-------------------------------------------------------------------------------
-- Return factorio player
--
-- @function [parent=#Player] native
--
-- @return #Lua_player
--
function Player.native()
  return Lua_player
end

-------------------------------------------------------------------------------
-- Return admin player
--
-- @function [parent=#Player] native
--
-- @return #boolean
--
function Player.isAdmin()
  return Lua_player.admin
end

-------------------------------------------------------------------------------
-- Get top gui
--
-- @function [parent=#Player] getGuiTop
--
-- @param player
--
function Player.getGuiTop(player)
  return player.gui.top
end

-------------------------------------------------------------------------------
-- Init global settings
--
-- @function [parent=#Player] initGlobalSettings
--
function Player.initGlobalSettings()
  global["users"][Lua_player.name].settings = Player.getDefaultSettings()
end

-------------------------------------------------------------------------------
-- Get default settings
--
-- @function [parent=#Player] getDefaultSettings
--
function Player.getDefaultSettings()
  return {
    display_pin_beacon = false,
    display_pin_level = 4,
    model_auto_compute = false,
    model_loop_limit = 1000,
    other_speed_panel=false,
    filter_show_disable=false,
    filter_show_hidden=false
  }
end

-------------------------------------------------------------------------------
-- Get sorted style
--
-- @function [parent=#Player] getSortedStyle
--
-- @param #string key
--
-- @return #string style
--
function Player.getSortedStyle(key)
  local globalGui = Player.getGlobalGui()
  if globalGui.order == nil then globalGui.order = {name="index",ascendant="true"} end
  local style = "helmod_button-sorted-none"
  if globalGui.order.name == key and globalGui.order.ascendant then style = "helmod_button-sorted-up" end
  if globalGui.order.name == key and not(globalGui.order.ascendant) then style = "helmod_button-sorted-down" end
  return style
end

-------------------------------------------------------------------------------
-- Get global variable for player
--
-- @function [parent=#Player] getGlobal
--
-- @param #string key
--
-- @return #table global
--
function Player.getGlobal(key)
  if global["users"] == nil then
    global["users"] = {}
  end
  if global["users"][Lua_player.name] == nil then
    global["users"][Lua_player.name] = {}
  end

  if global["users"][Lua_player.name].settings == nil then
    Player.initGlobalSettings()
  end

  if key ~= nil then
    if global["users"][Lua_player.name][key] == nil then
      global["users"][Lua_player.name][key] = {}
    end
    return global["users"][Lua_player.name][key]
  end
  return global["users"][Lua_player.name]
end

-------------------------------------------------------------------------------
-- Get global gui
--
-- @function [parent=#Player] getGlobalGui
--
-- @param #string property
--
function Player.getGlobalGui(property)
  local settings = Player.getGlobal("gui")
  if settings ~= nil and property ~= nil then
    return settings[property]
  end
  return settings
end

-------------------------------------------------------------------------------
-- Get global settings
--
-- @function [parent=#Player] getGlobalSettings
--
-- @param #string property
--
function Player.getGlobalSettings(property)
  local settings = Player.getGlobal("settings")
  if settings ~= nil and property ~= nil then
    local value = settings[property]
    if value == nil then
      value = Player.getDefaultSettings()[property]
    end
    return value
  end
  return settings
end

-------------------------------------------------------------------------------
-- Get settings
--
-- @function [parent=#Player] getSettings
--
-- @param #string name
-- @param #boolean global
--
function Player.getSettings(name, global)
  Logging:trace(Player.classname, "getSettings(name, global)", name, global)
  local property = nil
  local prefixe = "helmod_"
  if not(global) then
    property = Lua_player.mod_settings[prefixe..name]
  else
    property = settings.global[prefixe..name]
  end
  if property ~= nil then
    return property.value
  else
    Logging:error(Player.classname, "settings property not found:", name)
    return helmod_settings_mod[name].default_value
  end
end

-------------------------------------------------------------------------------
-- Get style sizes
--
-- @function [parent=#Player] getStyleSizes
--
function Player.getStyleSizes()
  Logging:trace(Player.classname, "getStyleSizes(player)")
  local display_size = Player.getSettings("display_size")
  local display_size_free = Player.getSettings("display_size_free")
  if string.match(display_size_free, "([0-9]*x[0-9]*)", 1) then
    display_size = display_size_free
  end
  Logging:trace(Player.classname, "getStyleSizes(player):display_size", display_size)
  local style_sizes = {}
  if display_size ~= nil then
    local width_info=490
    local width_scroll=8
    local width_block_info=290
    local width_recipe_column=220
    local height_block_header = 450
    local height_selector_header = 350
    local height_row_element = 72

    local string_width = string.match(display_size,"([0-9]*)x[0-9]*",1)
    local string_height = string.match(display_size,"[0-9]*x([0-9]*)",1)
    Logging:trace(Player.classname, "getStyleSizes(player):parse", string_width, string_height)
    local width = math.ceil(1920*0.85)
    local height = math.ceil(1680*0.85)
    if string_width ~= nil then width = math.ceil(tonumber(string_width)*0.85) end
    if string_height ~= nil then height = math.ceil(tonumber(string_height)*0.85) end

    style_sizes.main = {}
    style_sizes.main.minimal_width = width
    style_sizes.main.minimal_height = height

    style_sizes.data = {}
    style_sizes.data.minimal_width = width - width_info
    style_sizes.data.maximal_width = width - width_info

    style_sizes.scroll_recipe_selector = {}
    style_sizes.scroll_recipe_selector.minimal_height = height - height_selector_header
    style_sizes.scroll_recipe_selector.maximal_height = height - height_selector_header

    -- input/output table
    style_sizes.scroll_block_element = {}
    style_sizes.scroll_block_element.minimal_width = width - width_info - width_block_info - width_scroll - 10
    style_sizes.scroll_block_element.maximal_width = width - width_info - width_block_info - width_scroll - 10
    style_sizes.scroll_block_element.minimal_height = height_row_element
    style_sizes.scroll_block_element.maximal_height = height_row_element

    -- recipe table
    style_sizes.scroll_block_list = {}
    style_sizes.scroll_block_list.minimal_width = width - width_info - width_scroll
    style_sizes.scroll_block_list.maximal_width = width - width_info - width_scroll
    style_sizes.scroll_block_list.minimal_height = height - height_block_header
    style_sizes.scroll_block_list.maximal_height = height - height_block_header


  end
  Logging:trace(Player.classname, "getStyleSizes(player)", style_sizes)
  return style_sizes
end

-------------------------------------------------------------------------------
-- Set style
--
-- @function [parent=#Player] setStyle
--
-- @param #LuaGuiElement element
-- @param #string style
-- @param #string property
--
function Player.setStyle(element, style, property)
  Logging:trace(Player.classname, "setStyle(player, element, style, property)", element, style, property)
  local style_sizes = Player.getStyleSizes()
  if element.style ~= nil and style_sizes[style] ~= nil and style_sizes[style][property] ~= nil then
    Logging:trace(Player.classname, "setStyle(player, element, style, property)", style_sizes[style][property])
    element.style[property] = style_sizes[style][property]
  end
end

-------------------------------------------------------------------------------
-- Return icon type
--
-- @function [parent=#Player] getIconType
--
-- @param #ModelRecipe element
--
-- @return #string recipe type
--
function Player.getIconType(element)
  Logging:trace(Player.classname, "getIconType(element)", element)
  if element == nil or element.name == nil then return "unknown" end
  local item = Player.getItemPrototype(element.name)
  if item ~= nil then
    return "item"
  end
  local fluid = Player.getFluidPrototype(element.name)
  if fluid ~= nil then
    return "fluid"
  end
  local entity = Player.getEntityPrototype(element.name)
  if entity ~= nil then
    return "entity"
  end
  local technology = Player.getTechnology(element.name)
  if technology ~= nil then
    return "technology"
  end
  return "recipe"
end

-------------------------------------------------------------------------------
-- Return force's player
--
-- @function [parent=#Player] getForce
--
--
-- @return #table force
--
function Player.getForce()
  return Lua_player.force
end

-------------------------------------------------------------------------------
-- Return recipe type
--
-- @function [parent=#Player] getRecipeIconType
--
-- @param #ModelRecipe element
--
-- @return #string recipe type
--
function Player.getRecipeIconType(element)
  Logging:trace(Player.classname, "getRecipeIconType(element)", element)
  if element == nil then Logging:error(Player.classname, "getRecipeIconType(element): missing player") end
  local lua_recipe = Player.getRecipe(element.name)
  if lua_recipe ~= nil and lua_recipe.force ~= nil then
    return "recipe"
  end
  local lua_technology = Player.getTechnology(element.name)
  if lua_technology ~= nil and lua_technology.force ~= nil then
    return "technology"
  end
  return Player.getIconType(element);
end

-------------------------------------------------------------------------------
-- Return item type
--
-- @function [parent=#Player] getItemIconType
--
-- @param #table factorio prototype
--
-- @return #string item type
--
function Player.getItemIconType(element)
  local item = Player.getItemPrototype(element.name)
  if item ~= nil then
    return "item"
  end
  local fluid = Player.getFluidPrototype(element.name)
  if fluid ~= nil then
    return "fluid"
  else
    return "item"
  end
end

-------------------------------------------------------------------------------
-- Return entity type
--
-- @function [parent=#Player] getEntityIconType
--
-- @param #table factorio prototype
--
-- @return #string item type
--
function Player.getEntityIconType(element)
  local item = Player.getEntityPrototype(element.name)
  if item ~= nil then
    return "entity"
  end
  return Player.getItemIconType(element)
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#Player] getLocalisedName
--
-- @param #table element factorio prototype
--
-- @return #string localised name
--
function Player.getLocalisedName(element)
  Logging:trace(Player.classname, "getLocalisedName(element)", element)
  if Player.getSettings("display_real_name", true) then
    return element.name
  end
  local localisedName = element.name
  if element.type ~= nil then
    if element.type == "entity" then
      local item = Player.getEntityPrototype(element.name)
      if item ~= nil then
        localisedName = item.localised_name
      end
    end
    if element.type == 0 or element.type == "item" then
      local item = Player.getItemPrototype(element.name)
      if item ~= nil then
        localisedName = item.localised_name
      end
    end
    if element.type == 1 or element.type == "fluid" then
      local item = Player.getFluidPrototype(element.name)
      if item ~= nil then
        localisedName = item.localised_name
      end
    end
  end
  return localisedName
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#Player] getRecipeLocalisedName
--
-- @param #LuaPrototype prototype factorio prototype
--
-- @return #string localised name
--
function Player.getRecipeLocalisedName(prototype)
  local element = Player.getRecipe(prototype.name)
  if element ~= nil and not(Player.getSettings("display_real_name", true)) then
    return element.localised_name
  end
  return prototype.name
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#Player] getTechnologyLocalisedName
--
-- @param #LuaPrototype prototype factorio prototype
--
-- @return #string localised name
--
function Player.getTechnologyLocalisedName(prototype)
  local element = Player.getTechnology(prototype.name)
  if element ~= nil and not(Player.getSettings("display_real_name", true)) then
    return element.localised_name
  end
  return element.name
end

-------------------------------------------------------------------------------
-- Return recipes
--
-- @function [parent=#Player] getRecipes
--
-- @return #table recipes
--
function Player.getRecipes()
  local recipes = {}
  for _,recipe in pairs(Player.getForce().recipes) do
    recipes[recipe.name] = recipe
  end
  return recipes
end

-------------------------------------------------------------------------------
-- Return recipe groups
--
-- @function [parent=#Player] getRecipeGroups
--
-- @return #table recipe groups
--
function Player.getRecipeGroups()
  -- recuperation des groupes avec les recipes
  local recipeGroups = {}
  for key, recipe in pairs(Player.getRecipes()) do
    if recipe.group ~= nil then
      if recipeGroups[recipe.group.name] == nil then recipeGroups[recipe.group.name] = {} end
      table.insert(recipeGroups[recipe.group.name], recipe.name)
    end
  end
  return recipeGroups
end

-------------------------------------------------------------------------------
-- Return recipe subgroups
--
-- @function [parent=#Player] getRecipeSubgroups
--
-- @return #table recipe subgroups
--
function Player.getRecipeSubgroups()
  -- recuperation des groupes avec les recipes
  local recipeSubgroups = {}
  for key, recipe in pairs(Player.getRecipes()) do
    if recipe.subgroup ~= nil then
      if recipeSubgroups[recipe.subgroup.name] == nil then recipeSubgroups[recipe.subgroup.name] = {} end
      table.insert(recipeSubgroups[recipe.subgroup.name], recipe.name)
    end
  end
  return recipeSubgroups
end

-------------------------------------------------------------------------------
-- Return technologies
--
-- @function [parent=#Player] getTechnologies
--
-- @return #table technologies
--
function Player.getTechnologies()
  local technologies = {}
  for _,technology in pairs(Player.getForce().technologies) do
    technologies[technology.name] = technology
  end
  return technologies
end

-------------------------------------------------------------------------------
-- Return technology
--
-- @function [parent=#Player] getTechnology
--
-- @param #string name technology name
--
-- @return #LuaPrototype factorio prototype
--
function Player.getTechnology(name)
  local technology = Player.getForce().technologies[name]
  return technology
end

-------------------------------------------------------------------------------
-- Return list of productions
--
-- @function [parent=#Player] getProductionsCrafting
--
-- @param #string category filter
-- @param #string entity_name name entity filter
--
-- @return #table list of productions
--
function Player.getProductionsCrafting(category, entity_name)
  Logging:debug(Player.classname, "getProductionsCrafting(category)", category, entity_name)
  local productions = {}
  if entity_name ~= nil and entity_name == "water" then
    for key, lua_entity in pairs(game.entity_prototypes) do
      if lua_entity.type ~= nil and lua_entity.name ~= nil and lua_entity.name ~= "player" then
        if lua_entity.type == EntityType.offshore_pump then
          productions[lua_entity.name] = lua_entity
        end
      end
    end
  elseif entity_name ~= nil and entity_name == "steam" then
    for key, lua_entity in pairs(game.entity_prototypes) do
      if lua_entity.type ~= nil and lua_entity.name ~= nil and lua_entity.name ~= "player" then
        if lua_entity.type == EntityType.boiler then
          productions[lua_entity.name] = lua_entity
        end
      end
    end
  else
    for key, lua_entity in pairs(game.entity_prototypes) do
      if lua_entity.type ~= nil and lua_entity.type ~= "offshore-pump" and lua_entity.name ~= nil and lua_entity.name ~= "player" then
        Logging:trace(Player.classname, "getProductionsCrafting(category):item", lua_entity.name, lua_entity.type, lua_entity.group.name, lua_entity.subgroup.name, lua_entity.crafting_categories)
        local check = false
        if category ~= nil and category ~= "extraction-machine" and category ~= "energy" and category ~= "technology" then
          -- standard recipe
          if lua_entity.crafting_categories ~= nil and lua_entity.crafting_categories[category] then
            check = true
          end
        elseif category ~= nil and category == "extraction-machine" then
          if lua_entity.subgroup ~= nil and lua_entity.subgroup.name == "extraction-machine" then
            check = true
          end
        elseif category ~= nil and category == "energy" then
          if lua_entity.subgroup ~= nil and lua_entity.subgroup.name == "energy" then
            check = true
          end
        elseif category ~= nil and category == "technology" then
          if lua_entity.type == "lab" then
            check = true
          end
        else
          if lua_entity.group ~= nil and lua_entity.group.name == "production" then
            check = true
          end
        end
        -- resource filter
        if check then
          if entity_name ~= nil then
            local lua_entity_filter = Player.getEntityPrototype(entity_name)
            if lua_entity_filter ~= nil and lua_entity.resource_categories ~= nil and not(lua_entity.resource_categories[lua_entity_filter.resource_category]) then
              check = false
            end
          end
        end
        -- ok to add entity
        if check then
          productions[lua_entity.name] = lua_entity
        end
      end
    end
  end
  Logging:debug(Player.classname, "category", category, "productions", productions)
  return productions
end

-------------------------------------------------------------------------------
-- Return list of modules
--
-- @function [parent=#Player] getModules
--
-- @return #table list of modules
--
function Player.getModules()
  -- recuperation des groupes
  local modules = {}
  for key, item in pairs(game.item_prototypes) do
    if item.type ~= nil and item.type == "module" then
      modules[item.name] = item
    end
  end
  return modules
end

-------------------------------------------------------------------------------
-- Return module bonus (default return: bonus = 0 )
--
-- @function [parent=#Player] getModuleBonus
--
-- @param #string module module name
-- @param #string effect effect name
--
-- @return #number
--
function Player.getModuleBonus(module, effect)
  if module == nil then return 0 end
  local bonus = 0
  -- search module
  local module = Player.getItemPrototype(module)
  if module ~= nil and module.module_effects ~= nil and module.module_effects[effect] ~= nil then
    bonus = module.module_effects[effect].bonus
  end
  return bonus
end

-------------------------------------------------------------------------------
-- Return recipe
--
-- @function [parent=#Player] getRecipe
--
-- @param #string name recipe name
--
-- @return #LuaRecipe recipe
--
function Player.getRecipe(name)
  return Player.getForce().recipes[name]
end

-------------------------------------------------------------------------------
-- Return list of recipes
--
-- @function [parent=#Player] searchRecipe
--
-- @param #string recipe name
--
-- @return #table list of recipes
--
function Player.searchRecipe(name)
  local recipes = {}
  -- recherche dans les produits des recipes
  for key, recipe in pairs(Player.getRecipes()) do
    for k, product in pairs(recipe.products) do
      if product.name == name then
        table.insert(recipes,{name=recipe.name, type="recipe"})
      end
    end
  end
  -- recherche dans les resource
  for key, resource in pairs(Player.getResources()) do
    if resource.name == name then
      table.insert(recipes,{name=resource.name, type="resource"})
    end
  end
  -- recherche dans les fluids
  for key, fluid in pairs(Player.getFluidPrototypes()) do
    if fluid.name == name then
      table.insert(recipes,{name=fluid.name, type="fluid"})
    end
  end
  return recipes
end

-------------------------------------------------------------------------------
-- Return entity prototypes
--
-- @function [parent=#Player] getEntityPrototypes
--
-- @param #table type filter
--
-- @return #LuaEntityPrototype entity prototype
--
function Player.getEntityPrototypes(types)
  if types == nil then
  return game.entity_prototypes
  else
    local entities = {}
    for _,entity in pairs(game.entity_prototypes) do
      for _,type in pairs(types) do
        if entity.type == type then
          entities[entity.name] = entity
        end
      end
    end
    return entities
  end
end

-------------------------------------------------------------------------------
-- Return entity prototype
--
-- @function [parent=#Player] getEntityPrototype
--
-- @param #string name entity name
--
-- @return #LuaEntityPrototype entity prototype
--
function Player.getEntityPrototype(name)
  if name == nil then return nil end
  return game.entity_prototypes[name]
end

-------------------------------------------------------------------------------
-- Return beacon production
--
-- @function [parent=#Player] getProductionsBeacon
--
-- @return #table items prototype
--
function Player.getProductionsBeacon()
  local items = {}
  for _,item in pairs(game.entity_prototypes) do
    --Logging:debug(Player.classname, "getItemsPrototype(type):", item.name, item.group.name, item.subgroup.name)
    if item.name ~= nil and item.type == EntityType.beacon then
      local efficiency = EntityPrototype.load(item.name).getElectricEffectivity()
      Logging:trace(Player.classname, "getProductionsBeacon(type):", item.name, efficiency)
      if efficiency ~= nil then
        table.insert(items,item)
      end
    end
  end
  return items
end

-------------------------------------------------------------------------------
-- Return generators
--
-- @function [parent=#Player] getGenerators
--
-- @param #string type type primary or secondary
--
-- @return #table items prototype
--
function Player.getGenerators(type)
  if type == nil then type = "primary" end
  local items = {}
  for _,item in pairs(game.entity_prototypes) do
    --Logging:debug(Player.classname, "getItemsPrototype(type):", item.name, item.group.name, item.subgroup.name)
    if item.name ~= nil then
      local entity_type = EntityPrototype.load(item).getType()
      if item.group.name == "production" then
        Logging:trace(Player.classname, "getGenerators():", item.name, item.type, item.group.name, item.subgroup.name)
      end
      if type == "primary" and (entity_type == EntityType.generator or entity_type == EntityType.solar_panel) then
        table.insert(items,item)
      end
      if type == "secondary" and (entity_type == EntityType.boiler or entity_type == EntityType.accumulator) then
        table.insert(items,item)
      end
    end
  end
  return items
end

-------------------------------------------------------------------------------
-- Return resources list
--
-- @function [parent=#Player] getResources
--
-- @return #table entity prototype
--
local cache_resources = nil

function Player.getResources()
  if cache_resources ~= nil then return cache_resources end
  local items = {}
  for _,item in pairs(game.entity_prototypes) do
    --Logging:debug(Player.classname, "getItemsPrototype(type):", item.name, item.group.name, item.subgroup.name)
    if item.name ~= nil and item.resource_category ~= nil then
      table.insert(items,item)
    end
  end
  cache_resources = items
  return items
end

-------------------------------------------------------------------------------
-- Return item prototypes
--
-- @function [parent=#Player] getItemPrototypes
--
-- @return #LuaItemPrototype item prototype
--
function Player.getItemPrototypes()
  return game.item_prototypes
end

-------------------------------------------------------------------------------
-- Return item prototype
--
-- @function [parent=#Player] getItemPrototype
--
-- @param #string name item name
--
-- @return #LuaItemPrototype item prototype
--
function Player.getItemPrototype(name)
  if name == nil then return nil end
  return game.item_prototypes[name]
end

-------------------------------------------------------------------------------
-- Return fluid prototypes
--
-- @function [parent=#Player] getFluidPrototypes
--
-- @return #LuaFluidPrototype fluid prototype
--
function Player.getFluidPrototypes()
  return game.fluid_prototypes
end

-------------------------------------------------------------------------------
-- Return fluid prototype
--
-- @function [parent=#Player] getFluidPrototype
--
-- @param #string name fluid name
--
-- @return #LuaFluidPrototype fluid prototype
--
function Player.getFluidPrototype(name)
  if name == nil then return nil end
  return game.fluid_prototypes[name]
end

-------------------------------------------------------------------------------
-- Return number
--
-- @function [parent=#Player] parseNumber
--
-- @param #string name
-- @param #string property
--
function Player.parseNumber(number)
  Logging:trace(Player.classname, "parseNumber(number)", number)
  if number == nil then return 0 end
  local value = string.match(number,"[0-9.]*",1)
  local power = string.match(number,"[0-9.]*([a-zA-Z]*)",1)
  Logging:trace(Player.classname, "parseNumber(number)", number, value, power)
  if power == nil then
    return tonumber(value)
  elseif string.lower(power) == "kw" then
    return tonumber(value)*1000
  elseif string.lower(power) == "mw" then
    return tonumber(value)*1000*1000
  elseif string.lower(power) == "gw" then
    return tonumber(value)*1000*1000*1000
  elseif string.lower(power) == "kj" then
    return tonumber(value)*1000
  elseif string.lower(power) == "mj" then
    return tonumber(value)*1000*1000
  elseif string.lower(power) == "gj" then
    return tonumber(value)*1000*1000*1000
  end
end

return Player
