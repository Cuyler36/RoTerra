local BLOCK_SELECTOR_MODE_NORMAL: number = 0
local BLOCK_SELECTOR_MODE_NEAREST: number = 1

local BlockSelector = {}
BlockSelector.__index = BlockSelector
BlockSelector.ClassName = "BlockSelector"

local UserInputService: UserInputService = game:GetService("UserInputService")

local Camera: Camera = workspace.CurrentCamera

local Client = script.Parent.Parent

local Character = require(Client.Character)
local WorldGrid = require(game:GetService("ReplicatedStorage").Common.World.WorldGrid)

local selectedBlockChangedEvent: BindableEvent = Instance.new("BindableEvent")
local selectModeChangedEvent: BindableEvent = Instance.new("BindableEvent")

local selectedBlock: BasePart? = nil
local enabled: boolean = false
local mode: number = BLOCK_SELECTOR_MODE_NORMAL
local selectorTask: thread? = nil
local maxRadius: number = 4

BlockSelector.BlockSelected = selectedBlockChangedEvent.Event
BlockSelector.ModeChanged = selectModeChangedEvent.Event

local function DEBUG_DrawRay(origin: Vector3, destination: Vector3, color: Color3): ()
	local p = Instance.new("Part")
	local dp = destination - origin
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Size = Vector3.new(0.1, 0.1, dp.Magnitude)
	p.CFrame = CFrame.new(origin + dp / 2, destination)
	p.Color = color
	p.Transparency = 0.8
	p.Parent = workspace.CurrentCamera

	game:GetService("Debris"):AddItem(p, 0.5)
end

local function RaycastSelectBlock(): ()
	while enabled do
		local character = Character:GetCharacter()
		if character and character.PrimaryPart then
			local nowBlock: BasePart? = selectedBlock
			local pos = UserInputService:GetMouseLocation()
			local ray: Ray = Camera:ViewportPointToRay(pos.X, pos.Y)
			local params: RaycastParams = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Whitelist
			params.FilterDescendantsInstances = { workspace.Game.World }
			local result: RaycastResult? = (workspace :: Workspace):Raycast(ray.Origin, ray.Direction * 1000, params)
			local character_pos: Vector3 = character.PrimaryPart.Position * Vector3.new(1, 1, 0)
			--print(result)
			if result then
				--[[
				DEBUG_DrawRay(
					ray.Origin + Camera.CFrame.LookVector * 5,
					result.Position * Vector3.new(1, 1, 0),
					Color3.fromRGB(255, 0, 0)
				)
				]]
				if mode == BLOCK_SELECTOR_MODE_NEAREST then
					DEBUG_DrawRay(character_pos, result.Position * Vector3.new(1, 1, 0), Color3.fromRGB(0, 255, 0))
					result = (workspace :: Workspace):Raycast(
						character_pos,
						(result.Position * Vector3.new(1, 1, 0) - character_pos).Unit * 100,
						params
					)
					if result then
						selectedBlock = result.Instance
					else
						selectedBlock = nil
					end
				else
					selectedBlock = result.Instance
				end
			else
				selectedBlock = nil
			end

			if nowBlock ~= selectedBlock then
				-- (WorldGrid:ToGridSpace(selectedBlock.Position) - WorldGrid:ToGridSpace(character_pos)).Magnitude
				if
					selectedBlock
					and (selectedBlock.Position - character_pos).Magnitude > maxRadius * WorldGrid:GetGridSize()
				then
					selectedBlock = nil
				end

				if nowBlock ~= selectedBlock then
					selectedBlockChangedEvent:Fire(selectedBlock, nowBlock)
				end
			end
		end

		task.wait()
	end
end

local function StartTask(): ()
	if not selectorTask or coroutine.status(selectorTask) == "dead" then
		selectorTask = task.spawn(RaycastSelectBlock)
	end
end

local function EndTask(): ()
	if selectorTask and coroutine.status(selectorTask) == "suspended" then
		task.cancel(selectorTask)
		selectorTask = nil
	end
end

function BlockSelector:Enable(): ()
	selectedBlock = nil
	enabled = true
	StartTask()
end

function BlockSelector:Disable(): ()
	EndTask()
	selectedBlock = nil
	enabled = false
end

function BlockSelector:IsActive(): boolean
	return enabled
end

function BlockSelector:GetSelectedBlock(): BasePart?
	return selectedBlock
end

function BlockSelector:SetMode(newMode: number)
	assert(
		newMode == BLOCK_SELECTOR_MODE_NORMAL or newMode == BLOCK_SELECTOR_MODE_NEAREST,
		"incorrect BlockSelector mode"
	)

	if mode ~= newMode then
		mode = newMode
		selectModeChangedEvent:Fire(mode)
	end
end

function BlockSelector:GetMode(): number
	return mode
end

function BlockSelector:UpdateRadius(rad: number): ()
	maxRadius = rad
end

return BlockSelector
