AntibodiesUtils = {}
AntibodiesUtils.__index = AntibodiesUtils

local function has_value(table, val)
  for k,v in pairs(table) do
    if v == val then
      return true
    end
  end
  return false
end

local function has_key(table, key)
    return table[key] ~= nil
end

local function get_keys(table)
  local keys={}
  local n=0
  for k,v in pairs(table) do
    n=n+1
    keys[n]=k
  end
  return keys
end

local function lerp(v0, v1, t)
  return (1.0 - t) * v0 + t * v1
end

local function format_float(num, chars)
  return string.format("%.2f", num)
end

local function is_number(num)
    if type(num) == "number" then
        return true
    else
        return false
    end
end

local function is_table(num)
    if type(num) == "table" then
        return true
    else
        return false
    end
end

local function clamp(num, min, max)
  return math.max(min, math.min(num, max))
end

local function deep_copy(val)
  local val_copy
  if type(val) == 'table' then
      val_copy = {}
      for k,v in pairs(val) do
        val_copy[k] = deep_copy(v)
      end
  else
      val_copy = val
  end
  return val_copy
end

local function parse_value(txt)
  if txt == "true" then return true end
  if txt == "false" then return false end
  local num = tonumber(txt)
  if num == nil then
    return txt
  end
  return num
end

local function print_table(options)
  for group_key, group in pairs(options) do
    if is_table(group) then
      for prop_key, prop_val in pairs(group) do
        print(group_key.."."..prop_key.." = "..tostring(prop_val))
      end
    else
      print(group_key.." = "..tostring(group))
    end
  end
end

local function to_camel_case(str)
  local len = string.len(str)
  if len < 1 then
    return str
  end
  local a = string.sub(str, 1, 1)
  local b = string.sub(str, 2, len)
  a = string.lower(a)
  return a..b
end

local function indent(num, str)
  if str == nil then
    str = "    "
  end
  local s = ""
  for i = 0, num - 1, 1 do
    s = s..str
  end
  return s
end

local function joinStrings(strings, glue)
  local result = ""
  for i,val in ipairs(strings) do
    result = result..glue..tostring(val)
  end
  return result
end

function first_to_upper(str)
    return (str:gsub("^%l", string.upper))
end

local function table_to_string(tbl, separator, fontSize, maxWidth)
  if separator == nil then
    separator = ", "
  end
  if fontSize == nil then
    fontSize = UIFont.Small
  end
  if maxWidth == nil then
    maxWidth = 200
  end
  local count = #(tbl)
  local index = 0
  local result = ""
  for key in pairs(tbl) do
    index = index + 1
    local new_text = result..tbl[key]
    if index < count then
      new_text = new_text..separator
    end
    local width = getTextManager():MeasureStringX(fontSize, new_text)
    if width > maxWidth then
      new_text = result.."\n"..tbl[key]
      if index < count then
        new_text = new_text..separator
      end     
    end
    result = new_text
  end
  return result
end

local function flatten_version(version)
  return tostring(tonumber(version) * 100)
end

local function getLocalPlayers()
  local result = {}
  for playerIndex = 0, getNumActivePlayers()-1 do
    local player = getSpecificPlayer(playerIndex)
    if player ~= nil then
      if player:isLocalPlayer() then
        table.insert(result, player)
      end
    end
  end
  return result
end

local function getMedicalSkill(player)
  return player:getPerkLevel(Perks.Doctor)
end

local function isAlcoholBandage(bandageType)
  return string.match(bandageType, "Alcohol")
end

local function tab_filter(tab, iter)
  local out = {}
  for k, v in pairs(tab) do
    if iter(v, k, tab) then table.insert(out, v) end
  end
  return out
end

local function tab_map(tab, iter)
  local out = {}
  for k, v in pairs(tab) do
    out[k] = iter(v, k, tab)
  end
  return out
end

local function tab_sum(tab)
  local out = 0
  for k, v in pairs(tab) do
    out = out + v
  end
  return out
end

local function tab_product(tab)
  if tab[1] == nil then
    return 0
  end
  local p = tab[1]
  for i = 2,#(tab),1 do
    p = p * tab[i]
  end
  return p
end

local function lagrange(points, x)
  if #(points) > 0 then
    return tab_sum(
      tab_map(points, 
        function(ref_point, index)
          local subset = tab_filter(points, function(_, i) return i~=index end)
          local numenator = ref_point[2] * tab_product(
            tab_map(subset, function(point) return x - point[1] end)
          )
          local denominator = tab_product(
            tab_map(subset, function(point) return ref_point[1] - point[1] end)
          )
          if denominator ~= 0 then
            return numenator / denominator
          end
          return 0
        end
      )
    )
  end
  return 0
end

-----------------------------------------------------
--EXPORTS--------------------------------------------
-----------------------------------------------------

AntibodiesUtils.has_value = has_value
AntibodiesUtils.has_key = has_key
AntibodiesUtils.get_keys = get_keys
AntibodiesUtils.lerp = lerp
AntibodiesUtils.format_float = format_float
AntibodiesUtils.is_number = is_number
AntibodiesUtils.is_table = is_table
AntibodiesUtils.clamp = clamp
AntibodiesUtils.deep_copy = deep_copy
AntibodiesUtils.parse_value = parse_value
AntibodiesUtils.to_camel_case = to_camel_case
AntibodiesUtils.first_to_upper = first_to_upper
AntibodiesUtils.indent = indent

AntibodiesUtils.tab_map = tab_map
AntibodiesUtils.tab_filter = tab_filter
AntibodiesUtils.tab_sum = tab_sum
AntibodiesUtils.tab_product = tab_product
AntibodiesUtils.lagrange = lagrange

AntibodiesUtils.table_to_string = table_to_string
AntibodiesUtils.print_table = print_table
AntibodiesUtils.flatten_version = flatten_version

AntibodiesUtils.getLocalPlayers = getLocalPlayers
AntibodiesUtils.getMedicalSkill = getMedicalSkill
AntibodiesUtils.isAlcoholBandage = isAlcoholBandage

return AntibodiesUtils
