export type KeybindInput = Enum.KeyCode | Enum.UserInputType

local Keybinds = {}
Keybinds.__index = Keybinds
Keybinds.ClassName = "Keybinds"

local keybinds = {} -- mock

function Keybinds:GetBoundKeyboardInput(action: string): KeybindInput?
	return keybinds[action] -- Mock
end

function Keybinds:GetBoundControllerInput(action: string): KeybindInput?
	return keybinds[action]
end

function Keybinds:SetBoundKeyboardInput(action: string, input: KeybindInput): ()
	assert(
		typeof(input) == "EnumItem"
			and ((input :: EnumItem).EnumType == Enum.KeyCode or (input :: EnumItem).EnumType == Enum.UserInputType),
		"input must be an Enum.KeyCode or Enum.UserInputType"
	)
	-- TODO: Implement
	return action
end

function Keybinds:SetBoundControllerInput(action: string, input: KeybindInput): ()
	assert(
		typeof(input) == "EnumItem"
			and ((input :: EnumItem).EnumType == Enum.KeyCode or (input :: EnumItem).EnumType == Enum.UserInputType),
		"input must be an Enum.KeyCode or Enum.UserInputType"
	)
	return action
end

return Keybinds
