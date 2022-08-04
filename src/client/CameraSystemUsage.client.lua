local Client = script.Parent
local Character = require(Client.Character)

local Module = require(script.Parent:WaitForChild("Camera"):WaitForChild("CameraSystem"))

local function OnRespawn(character: Model): ()
	Module.UpdateFocusPart(character:WaitForChild("HumanoidRootPart") :: BasePart)
end

Character:OnRespawn("CameraOnRespawn", OnRespawn, true)
Module.EnableSideScrollingCamera()
