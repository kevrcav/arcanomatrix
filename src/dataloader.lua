local dataloader = {}

-- this parses files to load orbs and the names used with those orbs
function dataloader:loadOrbs(filename)
  local nextOrbData = {}
  local orbData = {}
  for line in love.filesystem.lines(filename) do
    if line:sub(1, 1) == "-" then
      table.insert(orbData, nextOrbData)
      nextOrbData = {}
    elseif line:sub(1, 1) == ":" then
      nextOrbData.type = line:sub(2, #line)
    elseif line:sub(1, 1) == "r" then
      nextOrbData.color = nextOrbData.color or {}
      nextOrbData.color.r = line:sub(2, #line)
    elseif line:sub(1, 1) == "g" then
      nextOrbData.color = nextOrbData.color or {}
      nextOrbData.color.g = line:sub(2, #line)
    elseif line:sub(1, 1) == "b" then
      nextOrbData.color = nextOrbData.color or {}
      nextOrbData.color.b = line:sub(2, #line)
    elseif line:sub(1, 1) == "/" then
      nextOrbData.element = line:sub(2, #line)
    end
  end
  return orbData
end

function dataloader:loadNames(filename)
  local names = {}
  local currentElem = ""
  local currentType = ""
  
  for line in love.filesystem.lines(filename) do
    if line:sub(1, 1) == "-" then
      currentElem = line:sub(3, #line)
    elseif line:sub(1, 1) == ":" then
      currentType = line:sub(3, #line)
    elseif line:sub(1, 1) == "/" then
      names[currentElem] = names[currentElem] or {}
      names[currentElem][currentType] = names[currentElem][currentType] or {}
      table.insert(names[currentElem][currentType], line:sub(3, #line))
    end
  end
  return names
end

return dataloader
