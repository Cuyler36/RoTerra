local XY_VECTOR: Vector3 = Vector3.xAxis + Vector3.yAxis

local RunService: RunService = game:GetService("RunService")

local LocalPlayer: Player = game:GetService("Players").LocalPlayer

local Client = script.Parent

local BlockSelector = require(Client.Blocks.BlockSelector)
local BlockHighlighter = require(Client.Blocks.BlockHighlighter)
local BlockDestroyer = require(Client.Blocks.BlockDestroyer)
local Character = require(Client.Character)
local Input = require(Client.Input)

local moveLeft: number = 0
local moveRight: number = 0
local jump: boolean = false
local jumpDown: boolean = false

local function HandleControlsInputLeft(
	_: string,
	inputState: Enum.UserInputState,
	_: InputObject
): Enum.ContextActionResult
	if inputState == Enum.UserInputState.Begin then
		moveLeft = -1
	elseif inputState == Enum.UserInputState.End then
		moveLeft = 0
	end

	return Enum.ContextActionResult.Pass
end

local function HandleControlsInputRight(
	_: string,
	inputState: Enum.UserInputState,
	_: InputObject
): Enum.ContextActionResult
	if inputState == Enum.UserInputState.Begin then
		moveRight = 1
	elseif inputState == Enum.UserInputState.End then
		moveRight = 0
	end

	return Enum.ContextActionResult.Pass
end

local function HandleControlsJumpRequest(
	_: string,
	inputState: Enum.UserInputState,
	_: InputObject
): Enum.ContextActionResult
	if inputState == Enum.UserInputState.Begin then
		jump = true
		jumpDown = true
	elseif inputState == Enum.UserInputState.End then
		jumpDown = false
	end
	return Enum.ContextActionResult.Pass
end

Input:Bind("MoveLeft", HandleControlsInputLeft, Enum.KeyCode.A, Enum.UserInputType.Gamepad1)
Input:Bind("MoveRight", HandleControlsInputRight, Enum.KeyCode.D, Enum.UserInputType.Gamepad1)
Input:Bind("Jump", HandleControlsJumpRequest, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)

local lastMovementDirection: number = 0
local function OnRenderStepped(_: number): ()
	local character = Character:GetCharacter()
	if character and character.PrimaryPart then
		local movementDirection: number = moveLeft + moveRight
		if lastMovementDirection ~= movementDirection then
			lastMovementDirection = movementDirection
			LocalPlayer:Move(Vector3.new(movementDirection, 0, 0), false)
		end

		if movementDirection ~= 0 then
			local pos: Vector3 = character:GetPivot().Position * XY_VECTOR
			character:PivotTo(CFrame.new(pos) * CFrame.fromOrientation(0, movementDirection * math.rad(-90), 0))
		end
	end

	if jump then
		jump = false
		local humanoid: Humanoid? = character:FindFirstChildWhichIsA("Humanoid")
		if humanoid then
			humanoid.Jump = true
		end
	end

	if jumpDown then
		jumpDown = false -- TODO: should we allow auto-jumps?
	end
end

RunService:BindToRenderStep("Movement", Enum.RenderPriority.First.Value, OnRenderStepped)

local function OnRespawn(_: Model, humanoid: Humanoid): ()
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false) -- Disable climbing

	BlockSelector:Enable()
	BlockHighlighter:Enable()
end

local function OnDeath(): ()
	BlockHighlighter:Disable()
	BlockSelector:Disable()
end

Character:OnRespawn("ControlsOnRespawn", OnRespawn, true)
Character:OnDeath("ControlsOnDeath", OnDeath)

local function HandleMouseClickInput(
	action: string,
	inputState: Enum.UserInputState,
	_: InputObject
): Enum.ContextActionResult
	if action == "ClickBlock" and inputState == Enum.UserInputState.Begin then
		local block: BasePart? = BlockSelector:GetSelectedBlock()
		if block then
			BlockDestroyer:DestroyBlock(block)
		end
	end

	return Enum.ContextActionResult.Pass
end

Input:Bind("ClickBlock", HandleMouseClickInput, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

local function HandleToggleSelectModeInput(
	action: string,
	inputState: Enum.UserInputState,
	_: InputObject
): Enum.ContextActionResult
	if action == "TogSelMode" and inputState == Enum.UserInputState.Begin then
		BlockSelector:SetMode(bit32.bxor(BlockSelector:GetMode(), 1))
	end
	return Enum.ContextActionResult.Pass
end

Input:Bind("TogSelMode", HandleToggleSelectModeInput, Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl)
