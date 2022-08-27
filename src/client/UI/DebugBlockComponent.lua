local Packages = game:GetService("ReplicatedStorage").Packages

local BlockData = require(game:GetService("ReplicatedStorage").Common.Data.BlockData)
local BlockSelector = require(script.Parent.Parent.Blocks.BlockSelector)
local WorldGrid = require(game:GetService("ReplicatedStorage").Common.World.WorldGrid)

local roact = require(Packages.roact)
local ThemeController = require(script.Parent.ThemeController)

local DebugBlockSelector = roact.Component:extend("DebugBlockSelector")

local function GetName(block: BasePart?): string
	if block then
		local b_type: number? = block:GetAttribute("Type")
		return if b_type and BlockData[b_type] then BlockData[b_type].Name else "Unknown"
	end
	return "None"
end

function DebugBlockSelector:init()
	local block: BasePart? = BlockSelector:GetSelectedBlock()
	self:setState({
		block = GetName(block),
		x = if block then WorldGrid:ToGridSpace(block.Position).X else nil,
		y = if block then WorldGrid:ToGridSpace(block.Position).Y else nil,
		s_mode = BlockSelector:GetMode(),
	})
end

function DebugBlockSelector:render()
	return roact.createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
	}, {
		roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		DebugBlockType = ThemeController.with(function(theme)
			return roact.createElement("TextLabel", {
				Text = "Current Block: " .. self.state.block,
				Size = UDim2.fromOffset(200, 50),
				LayoutOrder = 0,
				BackgroundColor3 = theme.background,
				TextColor3 = theme.foreground,
			})
		end),
		DebugBlockPosition = ThemeController.with(function(theme)
			return roact.createElement("TextLabel", {
				Text = if self.state.block ~= "None"
						and self.state.x
						and self.state.y
					then string.format("Position: (%d,%d)", self.state.x, self.state.y)
					else "-",
				Size = UDim2.fromOffset(200, 50),
				LayoutOrder = 1,
				BackgroundColor3 = theme.background,
				TextColor3 = theme.foreground,
			})
		end),
		DebugSelectMode = ThemeController.with(function(theme)
			return roact.createElement("TextLabel", {
				Text = "Block Mode: " .. if self.state.s_mode == 0 then "Normal" else "Nearest",
				Size = UDim2.fromOffset(200, 50),
				LayoutOrder = 2,
				BackgroundColor3 = theme.background,
				TextColor3 = theme.foreground,
			})
		end),
	})
end

function DebugBlockSelector:didMount()
	self.eventConnection = BlockSelector.BlockSelected:Connect(function(block: BasePart?): ()
		self:setState(function(state)
			return {
				block = GetName(block),
				x = if block then WorldGrid:ToGridSpace(block.Position).X else nil,
				y = if block then WorldGrid:ToGridSpace(block.Position).Y else nil,
				s_mode = state.s_mode,
			}
		end)
	end)
	self.eventConnection2 = BlockSelector.ModeChanged:Connect(function(mode: number): ()
		self:setState(function(state)
			return {
				block = state.block,
				x = state.x,
				y = state.y,
				s_mode = mode,
			}
		end)
	end)
end

function DebugBlockSelector:willUnmount()
	if self.eventConnection and self.eventConnection.Connected then
		self.eventConnection:Disconnect()
	end
	if self.eventConnection2 and self.eventConnection2.Connected then
		self.eventConnection2:Disconnect()
	end
end

return DebugBlockSelector
