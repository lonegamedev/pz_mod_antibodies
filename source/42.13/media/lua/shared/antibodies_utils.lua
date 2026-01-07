local AntibodiesUtils = {}
AntibodiesUtils.__index = AntibodiesUtils

function AntibodiesUtils.clamp(num, min, max)
	return math.max(min, math.min(num, max))
end

function AntibodiesUtils.lerp(v0, v1, t)
	return (1.0 - t) * v0 + t * v1
end

function AntibodiesUtils.lagrange(points, x)
	local sum = 0
	local n = #points
	for i = 1, n do
		local xi, yi = points[i][1], points[i][2]
		local li = 1
		for j = 1, n do
			if i ~= j then
				li = li * (x - points[j][1]) / (xi - points[j][1])
			end
		end
		sum = sum + yi * li
	end
	return sum
end

function AntibodiesUtils.getLocalPlayers()
	local result = {}
	for playerIndex = 0, getNumActivePlayers() - 1 do
		local player = getSpecificPlayer(playerIndex)
		if player ~= nil then
			if player:isLocalPlayer() then
				table.insert(result, player)
			end
		end
	end
	return result
end

function AntibodiesUtils.getMedicalSkill(player)
	return player:getPerkLevel(Perks.Doctor)
end

function AntibodiesUtils.isAlcoholBandage(bandageType)
	return string.match(tostring(bandageType), "Alcohol") ~= nil
end

function AntibodiesUtils.deepCopy(val, seen)
	if type(val) ~= "table" then
		return val
	end
	seen = seen or {}
	if seen[val] then
		return seen[val]
	end
	local copy = {}
	seen[val] = copy
	for k, v in pairs(val) do
		copy[AntibodiesUtils.deepCopy(k, seen)] = AntibodiesUtils.deepCopy(v, seen)
	end
	return copy
end

function AntibodiesUtils.containsValue(t, value)
	for _, v in ipairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

function AntibodiesUtils.formatFloat(num, chars)
	if not chars then
		chars = 1
	end
	return string.format("%." .. chars .. "f", num)
end

function AntibodiesUtils.formatChange(f, chars)
	if f > 0 then
		return "+" .. AntibodiesUtils.formatFloat(f, chars)
	elseif f < 0 then
		return AntibodiesUtils.formatFloat(f, chars)
	end
	return AntibodiesUtils.formatFloat(f, chars)
end

function AntibodiesUtils.mergeTables(t1, t2)
	for k, v in pairs(t2) do
		t1[k] = v
	end
	return t1
end

function AntibodiesUtils.printTable(t, indent, visited)
	indent = indent or 0
	visited = visited or {}

	if visited[t] then
		print(string.rep(" ", indent) .. "<cycle>")
		return
	end
	visited[t] = true

	for k, v in pairs(t) do
		local prefix = string.rep(" ", indent) .. tostring(k) .. ": "
		if type(v) == "table" then
			print(prefix)
			AntibodiesUtils.printTable(v, indent + 2, visited)
		else
			print(prefix .. tostring(v))
		end
	end
end

return AntibodiesUtils
