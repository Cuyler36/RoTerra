export type KeybindInput = Enum.KeyCode | Enum.UserInputType

local Keybinds = {}
Keybinds.__index = Keybinds
Keybinds.ClassName = "Keybinds"

function Keybinds:GetBoundKeyboardInput(action: string): KeybindInput?
	return nil -- Mock
end

function Keybinds:GetBoundControllerInput(action: string): KeybindInput?
	return nil
end

function Keybinds:SetBoundKeyboardInput(action: string, input: KeybindInput): ()
	assert(
		typeof(input) == "EnumItem"
			and ((input :: EnumItem).EnumType == Enum.KeyCode or (input :: EnumItem).EnumType == Enum.UserInputType),
		"input must be an Enum.KeyCode or Enum.UserInputType"
	)
	-- TODO: Implement
end

function Keybinds:SetBoundControllerInput(action: string, input: KeybindInput): ()
	assert(
		typeof(input) == "EnumItem"
			and ((input :: EnumItem).EnumType == Enum.KeyCode or (input :: EnumItem).EnumType == Enum.UserInputType),
		"input must be an Enum.KeyCode or Enum.UserInputType"
	)
end

return Keybinds
