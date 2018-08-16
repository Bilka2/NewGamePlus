local util = {}

util.float_to_string = function(number)
  return string.format("%f", tostring(number))
end

util.get_table_of_resources = function(number)
  local resources = {}
  for _, prototype in pairs(game.entity_prototypes) do
    if prototype.type == "resource" then
      resources[prototype.name] = true
    end
  end
  return resources
end

util.textfield_to_uint = function(textfield)
  local number = tonumber(textfield.text)
  if textfield.text and number and (number >= 0) and (number <= 4294967295) and (math.floor(number) == number) then
    return number
  else
    return false
  end
end

util.textfield_to_number = function(textfield)
  local number = tonumber(textfield.text)
  if textfield.text and number then
    return number
  else
    return false
  end
end

util.get_valid_surface_number = function(next_nauvis_number)
  if not game.surfaces["Nauvis plus " .. next_nauvis_number] then
    return next_nauvis_number
  end
  for i = 1, 254 do
    if not game.surfaces["Nauvis plus " .. i] then
      global.next_nauvis_number = i
      return i
    end
  end
end

return util
