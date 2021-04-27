---------------------------------------
-- UPDATER API
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

return {
    getTableLength = getTableLength,
}