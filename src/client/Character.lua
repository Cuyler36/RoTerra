export type DiedCallback = (Model, Humanoid) -> ()
export type RespawnCallback = (Model, Humanoid) -> ()

local Character = {}
Character.__index = Character
Character.ClassName = "Character"

local LocalPlayer: Player = game:GetService("Players").LocalPlayer

local died_callbacks: { [string]: DiedCallback } = {}
local respawn_callbacks: { [string]: RespawnCallback } = {}

local function OnDied(): ()
	local h: Humanoid = Character:GetHumanoid() :: Humanoid
	local c: Model = Character:GetCharacter() :: Model

	for _, callback in pairs(died_callbacks) do
		task.spawn(callback, c, h)
	end
end

local function OnRespawned(): ()
	local h: Humanoid = Character:GetHumanoid() :: Humanoid
	local c: Model = Character:GetCharacter() :: Model

	for _, callback in pairs(respawn_callbacks) do
		task.spawn(callback, c, h)
	end
end

function Character:_OnNewCharacter(new_character: Model): ()
	self._isAlive = true
	self._character = new_character

	-- Wait for humanoid
	local humanoid: Humanoid? = new_character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		local now: number = os.clock()
		repeat
			task.wait()
			humanoid = new_character:FindFirstChildWhichIsA("Humanoid")
		until humanoid or new_character.Parent == nil or os.clock() - now >= 5
		assert(humanoid, "Couldn't find a humanoid in the character!")
	end
	self._humanoid = humanoid

	local h: Humanoid = humanoid :: Humanoid
	h.Died:Once(OnDied)

	OnRespawned()
end

function Character:GetCharacter(): Model?
	return self._character
end

function Character:GetHumanoid(): Humanoid?
	return self._humanoid
end

function Character:OnDeath(name: string, callback: DiedCallback): ()
	died_callbacks[name] = callback
end

function Character:OnRespawn(name: string, callback: RespawnCallback, runIfSpawned: boolean?): ()
	respawn_callbacks[name] = callback
	if runIfSpawned and self:GetCharacter() then
		task.spawn(callback, self:GetCharacter(), self:GetHumanoid())
	end
end

do
	local function OnCharacterAdded(new_character: Model): ()
		Character:_OnNewCharacter(new_character)
	end

	if LocalPlayer.Character then
		OnCharacterAdded(LocalPlayer.Character)
	end
	LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
end

return Character
