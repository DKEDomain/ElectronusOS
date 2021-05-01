---------------------------------------
-- ElectronusOS Boot
---------------------------------------

-- Local Variables --
local w, h = term.getSize()
local backgroundColor = colors.white
local textColor = colors.blue
local sides = {"left", "right", "top", "bottom", "front", "back"}
local settingsPath = '/etc/eos.settings'

if not term.isColor() then
	textColor = color.black
end

-- Local Functions --

-- Draw EOS logo
-- @return void
local function drawLogo()
	local logo = {
		'########        #######   ###### ',
		'##             ##     ## ##    ##',
		'##             ##     ## ##      ',
		'######         ##     ##  ###### ',
		'##             ##     ##       ##',
		'##             ##     ## ##    ##',
		'########        #######   ######'
	}

	for key, line in pairs(logo) do
		-- Center the logo
		term.setCursorPos(((w / 2) - 16), 2 + (key + 1))
		print(line)
	end

	term.setCursorPos(1, 6 + #logo)
end

-- Clear and setup screen
-- @return void
local function setup()
	term.setCursorPos(1, 1)
	term.setBackgroundColor(backgroundColor)
	term.setTextColor(textColor)
	term.clear()
end

-- Load default settings
-- @return void
local function loadSettings()
	print('Loading Settings...')

	-- Create settings if it doesn't exist
	if not fs.exists(settingsPath) then
		settings.clear()
		settings.save(settingsPath)
	end

	settings.load(settingsPath)

	print('Settings loaded\n--')
end

-- Load computer type into settings
-- @return void
local function loadComputerType()
	local type = 'computer'

	if turtle then
		type = 'turtle'
	elseif pocket then
		type = 'pocket_computer'
	end

	if term.isColor() then
		type = 'advanced_'..type
	end

	settings.set('eos.computer_type', type)
end

-- Load peripherals into settings
-- @return void
local function loadPeripherals()
	local count = 0

	print('Loading Peripherals...')

	local peripherals = {
		['modems'] = {},
		['monitors'] = {},
		['drives'] = {},
		['printers'] = {},
	}

	-- Map peripherals
	for _, side in pairs(sides) do
		if peripheral.isPresent(side) then
			count = count + 1

			if peripheral.getType(side) == 'modem' then
				table.insert(peripherals['modems'], side)
			elseif peripheral.getType(side) == 'monitor' then
				table.insert(peripherals['monitors'], side)
			elseif peripheral.getType(side) == 'drive' then
				table.insert(peripherals['monitors'], side)
			elseif peripheral.getType(side) == 'printer' then
				table.insert(peripherals['monitors'], side)
			end
		end
	end

	-- Add peripherals to settings
	for key, sides in pairs(peripherals) do
		settings.set('eos.peripherals.'..key, sides)
	end

	-- Set default modem side to first modem
	if peripherals['modems'][1] ~= nil then
		settings.set('eos.modem_side', peripherals['modems'][1])
	end

	print(count .. ' Peripherals Loaded\n--')
end

-- Launch configured startup program
-- @return void
local function launchStartupProgram()
	local program = settings.get('eos.startup_program')
	
	if program ~= nil then
		shell.run(program)
	else 
		setup()
	end
end

-- Run boot process
setup()
drawLogo()

loadSettings()
loadComputerType()
loadPeripherals()

print('ID: '..os.computerID())

sleep(2)

launchStartupProgram()