--local SharedFolder = game:GetService("ReplicatedStorage").Common
local Block = require(script.Parent.Parent.Block)

--local BlockData = require(SharedFolder.BlockData)
--local WorldGrid = require(SharedFolder.WorldGrid)

local WorldGenerator = {}
WorldGenerator.__index = WorldGenerator
WorldGenerator.ClassName = "WorldGenerator"

function WorldGenerator:Generate(): { Block.Block_t }
	return {}
end

return WorldGenerator
