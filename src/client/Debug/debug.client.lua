local Packages = game:GetService("ReplicatedStorage").Packages

local UI = script.Parent.Parent.UI

local DebugBlockComponent = require(UI.DebugBlockComponent)

local roact = require(Packages.roact)
--local rodux = require(Packages.rodux)
--local roact_rodux = require(Packages["roact-rodux"])

local _ = roact.mount(
	roact.createElement("ScreenGui", {}, {
		BlockSelection = roact.createElement(DebugBlockComponent),
	}),
	game:GetService("Players").LocalPlayer.PlayerGui,
	"Debug UI"
)
