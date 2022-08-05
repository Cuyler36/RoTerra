local Players: Players = game:GetService("Players")
local RespawnManager = require(script.Parent.Character.RespawnManager)

local function OnRespawn(player: Player, _: Model, humanoid: Humanoid): ()
	local desc: HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(player.UserId)
	humanoid:ApplyDescription(desc)
end

RespawnManager:OnRespawn("CharacterRespawn", OnRespawn)
