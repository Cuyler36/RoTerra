export type RespawnCallback = (Player, Model, Humanoid) -> ()
export type DiedCallback = (Player, Model, Humanoid) -> ()

local RespawnManager = {}

local Players: Players = game:GetService("Players")

local respawn_callbacks: { [string]: RespawnCallback } = {}
local died_callbacks: { [string]: DiedCallback } = {}

function RespawnManager:OnRespawn(name: string, callback: RespawnCallback): ()
	respawn_callbacks[name] = callback
end

function RespawnManager:OnDeath(name: string, callback: DiedCallback): ()
	died_callbacks[name] = callback
end

do
	local function OnPlayerAdded(player: Player): ()
		local function OnCharacterAdded(character: Model): ()
			local humanoid: Humanoid? = character:FindFirstChildWhichIsA("Humanoid")
			if not humanoid then
				local now: number = os.clock()
				repeat
					task.wait()
					humanoid = character:FindFirstChildWhichIsA("Humanoid")
				until humanoid or character.Parent == nil or os.clock() - now >= 5
			end

			for _, callback in pairs(respawn_callbacks) do
				task.spawn(callback, player, character, humanoid)
			end

			if humanoid then
				local function OnHumanoidDied(): ()
					for _, callback in pairs(died_callbacks) do
						task.spawn(callback, player, character, humanoid)
					end
				end

				humanoid.Died:Once(OnHumanoidDied)
			end
		end

		if player.Character then
			OnCharacterAdded(player.Character)
		end

		player.CharacterAdded:Connect(OnCharacterAdded)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		OnPlayerAdded(player)
	end

	Players.PlayerAdded:Connect(OnPlayerAdded)
end

return RespawnManager
