local Packages = game:GetService("ReplicatedStorage").Packages

local BlockSelector = require(script.Parent.Parent.Blocks.BlockSelector)

local roact = require(Packages.roact)

local DebugBlockSelector = roact.Component:extend("DebugBlockSelector")

function DebugBlockSelector:init()
	local block: BasePart? = BlockSelector:GetSelectedBlock()
	self:setState({
		block = if block then block.Name else "None",
	})
end

function DebugBlockSelector:render()
	return roact.createElement("TextLabel", {
		Text = "Current Block: " .. self.state.block,
		Size = UDim2.fromOffset(200, 50),
	})
end

function DebugBlockSelector:didMount()
	self.eventConnection = BlockSelector.BlockSelected:Connect(function(block: BasePart?): ()
		self:setState(function(_)
			return {
				block = if block then block.Name else "None",
			}
		end)
	end)
end

function DebugBlockSelector:willUnmount()
	if self.eventConnection and self.eventConnection.Connected then
		self.eventConnection:Disconnect()
	end
end

return DebugBlockSelector
