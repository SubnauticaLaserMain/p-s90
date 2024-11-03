local React


local newRequire = function(...) end


-- Function to give scripts their own global environment
local function GiveOwnGlobals(Func, Script)
	if Func == nil then
		error("Func cannot be nil")
	end
	
	
	local Fenv = {}
	local RealFenv = {script = Script, require = newRequire}
	local FenvMt = {}
	function FenvMt:__index(b)
		if RealFenv[b] == nil then
			return getfenv()[b]
		else
			return RealFenv[b]
		end
	end
	function FenvMt:__newindex(b, c)
		if RealFenv[b] == nil then
			getfenv()[b] = c
		else
			RealFenv[b] = c
		end
	end
	setmetatable(Fenv, FenvMt)
	setfenv(Func, Fenv)
	return Func
end

-- Function to load and execute the script synchronously and return the result
local function runScript(script, src)
	local function loadScript(Script)
		local Function, res
		
		local suc, res2 = pcall(function()
			Function, res = loadstring(src, "=" .. Script:GetFullName())
		end)
		
		
		if not res and res2 then
			res = res2
		end
		
		
		if Function == nil then
			newRequire(React)
				:PerformTaskError('' .. tostring(res), 2, 3)
			
			return
		end
		
		
		local func = GiveOwnGlobals(Function, Script)
		
		
		local a, b = pcall(function()
			return func() -- Execute the function and return the result
		end)
		
		
		if not a then
			newRequire(React)
				:PerformTaskError('' .. tostring(b))
		end
		
		
		return b
	end

	return loadScript(script)
end


local Modules = {}

local oldRequire = require

-- Custom require function
local function require(module)
	local moduleState = Modules[module]
	
	local attempt = 0
	
	
	while not moduleState do
		task.wait(0.06)
		
		if not (attempt < 1000) then
			warn('Module State waited too LONG!')
			return nil and error('Module script is not defined!')
		end
		
		attempt += 1
	end
	

	if moduleState then
		if not moduleState.Required then
			moduleState.Required = true
			moduleState.Source = runScript(module, moduleState[2].Source)
		end
		
		print('attempting to return Module: ' .. tostring(module), moduleState.Source, moduleState.Required)

		return moduleState.Source -- Return the module (i.e., the result of the script)
	end
	
	print('module: ' .. tostring(module))

	return oldRequire(module)
end

newRequire = require

-- Function to add a module to the Modules table
local function addModule(module, src)
	print('Loading Module: ' .. tostring(module))
	if not Modules[module] then
		Modules[module] = {}
		Modules[module].Required = nil
		Modules[module][2] = {}
		Modules[module][2].Source = src
	end
end







local CoreGui = game:GetService('CoreGui')
local RobloxGui = CoreGui:FindFirstChild('RobloxGui')



local MainUI_Place = Instance.new('ScreenGui')
MainUI_Place.Parent = RobloxGui or CoreGui
MainUI_Place.Name = 'API-MainUI'


local MainStorage


local suc,res=pcall(function()
    local RobloxReplicatedStorage = game:GetService('RobloxReplicatedStorage')

    MainStorage = Instance.new('Folder')
    MainStorage.Parent = RobloxReplicatedStorage
    MainStorage.Name = 'API-MainStorage'
end)


if not MainStorage or MainStorage.Parent then
    if MainStorage then
        pcall(function()
            MainStorage:Destroy()
        end)

        MainStorage = nil
    end

    MainStorage = Instance.new('Folder')
    MainStorage.Parent = MainUI_Place
    MainStorage.Name = 'API-MainStorage'
end



local BlurEngine = Instance.new('ModuleScript')
BlurEngine.Parent = MainStorage
BlurEngine.Name = 'BlurEngine'

addModule(BlurEngine, [==[
local Lighting = game:GetService('Lighting')

local Service = {}


function Service:makeBlur(ScreenUI, safemode)
    local function useFirstMethod()
        local suc,res=pcall(function()
            ScreenUI.OnTopOfCoreBlur = true
        end)


        return suc
    end

    local function useSecondMethod()
        local Blur = Instance.new('BlurEffect')

        Blur.Parent = Lighting
        Blur.Name = 'i101+1928990sd/98378yhsdusj'
    end


    
    if safemode then
        local success = useFirstMethod()

        if not success then
            error('Cannot make Blur!')
        end
    else
        local a=useFirstMethod()

        if not a then
            useSecondMethod()
        end
    end
end



return Service
]==])



local ReactConsole = Instance.new('ModuleScript')
ReactConsole.Name = 'ReactConsole'
ReactConsole.Parent = MainStorage


addModule(ReactConsole, [==[
local React = {}






function React:PerformTaskError(errorMessage, num, num2)
	local StackLinesString = ''
	-- Print the error header and message
	-- print("----- Error Caught by React -----")
	-- warn("Message: " .. message)
	-- print("----- Error Stack -----")
	
	local m = false
	
	
	if num == 2 then
		m = true
	end
	

	-- Get the full traceback from the current level
	local traceback = debug.traceback()

	-- Store the lines of the traceback in a table
	local tracebackLines = {}

	-- Iterate through each line of the traceback
	for line in string.gmatch(traceback, "[^\r\n]+") do
		table.insert(tracebackLines, line)
	end
	
	
	
	
	local f = {[1] = 0, [2] = 0}
	
	
	if m == true then
		f[1] = num2
	end
	
	

	-- Skip the last two lines (related to the function call itself)
	for i = (2 + f[1]), (#tracebackLines - 4) - f[2] do
		local line = tracebackLines[i]
		
		StackLinesString = StackLinesString .. line .. '\n'
	end


	if StackLinesString and StackLinesString ~= '' then
		warn('\n----- Error Caught by React -----\n' .. tostring(errorMessage) .. '\n----- Error Stack -----\n' .. tostring(StackLinesString))
	else
		warn('\n----- Error Caught by React -----\n' .. tostring(errorMessage) .. '\n')
	end
end


function React:PerformTaskOutput(message)
	local StackLinesString = ''
	-- Print the error header and message
	-- print("----- Error Caught by React -----")
	-- warn("Message: " .. message)
	-- print("----- Error Stack -----")

	-- Get the full traceback from the current level
	local traceback = debug.traceback()

	-- Store the lines of the traceback in a table
	local tracebackLines = {}

	-- Iterate through each line of the traceback
	for line in string.gmatch(traceback, "[^\r\n]+") do
		table.insert(tracebackLines, line)
	end

	-- Skip the last two lines (related to the function call itself)
	for i = 2, #tracebackLines - 4 do
		local line = tracebackLines[i]
		
		StackLinesString = StackLinesString .. line .. '\n'
	end


	if StackLinesString ~= '' or StackLinesString ~= nil then
		print('\n----- Message Outputed by React -----\n' .. tostring(message) .. '\n----- Message Stack -----\n' .. tostring(StackLinesString))
	else
		print('\n----- Message Outputed by React -----\n' .. tostring(message) .. '\n')
	end
end



return React
]==])


React = ReactConsole



local PlayerService = Instance.new('LocalScript')
PlayerService.Parent = MainUI_Place
PlayerService.Name = 'PlayerServiceLocal'


local Controllers = Instance.new('ModuleScript')
Controllers.Parent = PlayerService
Controllers.Name = 'Controllers'



local CharacterTeleportService = Instance.new('ModuleScript')
CharacterTeleportService.Parent = Controllers
CharacterTeleportService.Name = 'CharacterTeleportService'


addModule(CharacterTeleportService, [==[
local TweenService = game:GetService('TweenService')
local Players = game:GetService('Players')


local CharacterTeleportService = {}



function CharacterTeleportService.TweenTeleport(pos)
    local newPosition
    local oldPosition


    local HumanoidRootPart = Players.LocalPlayer.Character

    
    HumanoidRootPart:MoveTo(pos)
end




return CharacterTeleportService
]==])



addModule(Controllers, [==[
return {
    CharacterTeleportService = require(script:WaitForChild('CharacterTeleportService'))
}
]==])




local TweenTeleportCharacterWithVector3 = Instance.new('BindableEvent')
TweenTeleportCharacterWithVector3.Name = 'TweenTeleportCharacterWithVector3'
TweenTeleportCharacterWithVector3.Parent = PlayerService


runScript(PlayerService, [==[
local Controllers = require(script.Controllers)


local TweenTeleportCharacterWithVector3 = script:WaitForChild('TweenTeleportCharacterWithVector3')



TweenTeleportCharacterWithVector3.Event:Connect(function(pos)
    Controllers.CharacterTeleportService.TweenTeleport(pos)
end)
]==])



