---------------------------------------
-- HELPERS API
---------------------------------------

-- Get a table length
-- @param table
-- @return int
local function getTableLength(table)
  local count = 0
  
  for _, __ in pairs(table) do
    count = count + 1
  end

  return count
end

-- Create file if it doesn't exist
-- @param string
-- @param string
local function createFile(file, defaultValue)
  local file = fs.open(file, "w")

	if defaultValue then
		file.write(defaultValue)
	end

	file.close()
end

return {
    getTableLength = getTableLength,
    createFile = createFile,
}
