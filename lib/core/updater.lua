---------------------------------------
-- UPDATER API
---------------------------------------

local helpers = require('/libs/core/helpers');
local sha256 = require('/libs/core/sha256');

-- Fetch a local file
-- @param string - file with path
-- @return table
local function getLocalFile(file)
    if not fs.exists(file) then 
        error('File not found: ' .. file)
    end
    
    local f = fs.open(file, 'r')
    local retrievedFile = f.readAll()
    f.close();

    return retrievedFile
end

-- Fetch a remote file
-- @param string - file url
-- @return table
local function getRemoteFile(file_url)
    local response, err = http.get(file_url)

    if response == nil then
        error('Error fetching remote file ' .. file_url .. ': ' .. err)
    end

    local file = response.readAll();
    response.close();

    return file
end

-- Get a files contents locally or remote
-- @param string - file to get
-- @return string
local function getFile(file)
    local retrievedFile = nil

    -- Check if the remote manifest is http or a path
    if string.find(file, 'http') == nil then
        retrievedFile = getLocalFile(file)
    else
        retrievedFile = getRemoteFile(file)
    end

    return retrievedFile
end

-- Write contents to a file
-- @param string - contents to write
-- @param string - path and file to write to
-- @return void
local function writeToFile(contents, file)
    local f = fs.open(file, 'w')
    f.write(contents)
    f.close()
end

-- Parse Manifest Contents
-- @param file
-- @return table
local function parseManifest(file)
    local manifest = textutils.unserializeJSON(file);

    if manifest == nil then 
        error('Failed parsing manifest')
    end

    return manifest
end

-- Update
-- @param string - manifest file with path
-- @return void
local function update(manifest_file)
    -- Get manifests
    local manifest = parseManifest(getFile(manifest_file))
    local remoteManifest = parseManifest(getFile(manifest['remote_manifest']))
    local filesRemaining = manifest['files']

    -- Loop through them and compare
    for file, hash in pairs(remoteManifest['files']) do
        -- Check the remote and local hash matches, if not create / update it
        if hash ~= manifest['files'][file] then
            -- Update the local file
            local remoteFile = getFile(remoteManifest['repository_url'] .. file)
            writeToFile(remoteFile, file)

            -- Update and save the local manifest
            manifest['files'][file] = hash
            writeToFile(textutils.serializeJSON(manifest), manifest_file)
        end

        -- Update files remaining
        filesRemaining[file] = nil

        -- Fire off update event
        os.queueEvent('eos.core.updater.status', {
            ['updatedFile'] = file,
            ['remaining'] = helpers.getTableLength(filesRemaining),
            ['total'] = helpers.getTableLength(remoteManifest['files']),
        })
    end

    -- Delete remaining files
    for file, _ in pairs(filesRemaining) do
        fs.delete(file)

        -- Fire off delete event
        os.queueEvent('eos.core.updater.delete', file)
    end

    -- Replace local manifest with remote
    writeToFile(textutils.serializeJSON(remoteManifest), manifest_file)

    -- Complete!
    os.queueEvent('eos.core.updater.complete', true)
end

-- Public functions
return {
    update = update
}