local BlockSelector = {}
BlockSelector.__index = BlockSelector
BlockSelector.ClassName = "BlockSelector"

local Camera: Camera = workspace.CurrentCamera
local LocalPlayer: Player = game:GetService("Players").LocalPlayer

local Client = script.Parent.Parent

local Character = require(Client.Character)
local Input = require(Client.Input)

local selectedBlockChangedEvent: BindableEvent = Instance.new("BindableEvent")
local selectedBlock: BasePart? = nil
local enabled: boolean = false

BlockSelector.BlockSelected = selectedBlockChangedEvent.Event

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

	game:GetService("Debris"):AddItem(p, 3)
end

local function OnMouseMoved(inputObject: InputObject): ()
	local character = Character:GetCharacter()
	if character and character.PrimaryPart then
		local nowBlock: BasePart? = selectedBlock

		local character_pos: Vector3 = character.PrimaryPart.Position * Vector3.new(1, 1, 0)
		local ray: Ray = Camera:ScreenPointToRay(inputObject.Position.X, inputObject.Position.Y)
		local params: RaycastParams = RaycastParams.new()
		params.FilterDescendantsInstances = { LocalPlayer.Character }
		--DEBUG_DrawRay(ray.Origin, ray.Direction * 1000, Color3.fromRGB(255, 0, 0))
		local result: RaycastResult? = (workspace :: Workspace):Raycast(ray.Origin, ray.Direction * 1000, params)
		print(result)
		if result then
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
			selectedBlock = nil
		end

		if nowBlock ~= selectedBlock then
			selectedBlockChangedEvent:Fire(selectedBlock, nowBlock)
		end
	end
end

local function HandleInput(
	action: string,
	inputState: Enum.UserInputState,
	inputObject: InputObject
): Enum.ContextActionResult
	if action == "BlockSelector" then
		if inputState == Enum.UserInputState.Begin or inputState == Enum.UserInputState.Change then
			OnMouseMoved(inputObject)
		end
	end

	return Enum.ContextActionResult.Pass
end

function BlockSelector:Enable(): ()
	selectedBlock = nil
	enabled = true
	Input:Bind("BlockSelector", HandleInput, Enum.UserInputType.MouseMovement, Enum.UserInputType.Gamepad1)
end

function BlockSelector:Disable(): ()
	Input:Unbind("BlockSelector")
	selectedBlock = nil
	enabled = false
end

function BlockSelector:IsActive(): boolean
	return enabled
end

function BlockSelector:GetSelectedBlock(): BasePart?
	return selectedBlock
end

return BlockSelector
