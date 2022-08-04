export type InputHandler = (string, Enum.UserInputState, InputObject) -> (Enum.ContextActionResult)
export type InputModeChangedCallback = (Enum.UserInputType, Enum.UserInputType) -> ()

local ContextActionService: ContextActionService = game:GetService("ContextActionService")
local Keybinds = require(script.Parent.Keybinds)

local _onInputModeChangedCallbacks = {}

local Input = { _inputs = {} }
Input.__index = Input
Input.ClassName = "Input"

function Input:Bind(
	action: string,
	handler: InputHandler,
	defaultKeyboardKeybind: Keybinds.KeybindInput,
	defaultControllerKeybind: Keybinds.KeybindInput
): ()
	assert(not self._inputs[action], string.format("%s has already been bound as an action!", action))
	self._inputs[action] = { handler, defaultKeyboardKeybind, defaultControllerKeybind }
	ContextActionService:BindAction(
		action,
		handler,
		false,
		Keybinds:GetBoundKeyboardInput(action) or defaultKeyboardKeybind,
		Keybinds:GetBoundControllerInput(action) or defaultControllerKeybind
	)
end

function Input:Unbind(action: string): ()
	if self._inputs[action] then
		self._inputs[action] = nil
		ContextActionService:UnbindAction(action)
	end
end

function Input:RefreshKeybinds(): ()
	for action: string, data: { any } in pairs(self._inputs) do
		ContextActionService:UnbindAction(action)
		ContextActionService:BindAction(
			action,
			data[1],
			false,
			Keybinds:GetBoundKeyboardInput(action) or data[2],
			Keybinds:GetBoundControllerInput(action) or data[3]
		)
	end
end

function Input:RegisterInputModeChangedCallback(name: string, callback: InputModeChangedCallback): ()
	_onInputModeChangedCallbacks[name] = callback
end

function Input:RemoveInputModeChangedCallback(name: string): ()
	_onInputModeChangedCallbacks[name] = nil
end

do
	local UserInputService: UserInputService = game:GetService("UserInputService")
	local currentInputType: Enum.UserInputType = nil

	local function OnLastInputTypeChanged(lastInputType: Enum.UserInputType): ()
		-- refine type
		local value: number = lastInputType.Value
		if value >= 0 and value <= 4 then
			lastInputType = Enum.UserInputType.MouseButton1
		elseif value >= 12 and value <= 19 then
			lastInputType = Enum.UserInputType.Gamepad1
		elseif value ~= 7 and value ~= 8 then
			return
		end

		if lastInputType ~= currentInputType then
			if currentInputType ~= nil then
				for _, callback in pairs(_onInputModeChangedCallbacks) do
					task.spawn(callback, lastInputType, currentInputType)
				end
			end
			currentInputType = lastInputType
		end
	end

	OnLastInputTypeChanged(UserInputService:GetLastInputType())
	UserInputService.LastInputTypeChanged:Connect(OnLastInputTypeChanged)
end

return Input
