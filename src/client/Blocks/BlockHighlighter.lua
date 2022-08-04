local Client = script.Parent.Parent
local BlockSelector = require(Client.Blocks.BlockSelector)

local BlockHighlighter = {}
BlockHighlighter.__index = BlockHighlighter
BlockHighlighter.ClassName = "BlockHighlighter"

local highlight: Highlight? = nil
local connection: RBXScriptConnection? = nil

local function OnBlockSelected(newBlock: BasePart?, _: BasePart?): ()
	if highlight then
		highlight.Adornee = newBlock
	end
end

function BlockHighlighter:Enable(): ()
	if highlight then
		return
	end

	local h: Highlight = Instance.new("Highlight")
	h.Name = "BlockHighlighter"
	h.OutlineColor = Color3.fromRGB(255, 217, 0)
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.Parent = workspace.CurrentCamera

	highlight = h
	connection = BlockSelector.BlockSelected:Connect(OnBlockSelected)
end

function BlockHighlighter:Disable(): ()
	if highlight then
		highlight:Destroy()
		highlight = nil
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end
end

return BlockHighlighter
