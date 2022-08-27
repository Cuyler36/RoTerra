task.defer(workspace.Game.BlockFabTest.Destroy, workspace.Game.BlockFabTest)

--local Block = require(script.Parent.World.Block)
--[[
local BlockGroup = require(script.Parent.World.BlockGroup)

BlockGroup.new({
	Block.new(0, Vector2.new(0, 0)),
	Block.new(0, Vector2.new(1, 0)),
	Block.new(0, Vector2.new(-1, 0)),
	Block.new(0, Vector2.new(-2, 0)),
	Block.new(0, Vector2.new(-2, -1)),
	Block.new(0, Vector2.new(0, -1)),
	Block.new(0, Vector2.new(-1, -1)),
})
]]

-- Block group creation
--local BlockChunk = require(script.Parent.World.BlockChunk)
local WorldGenerator = require(script.Parent.World.Generator.WorldGenerator)

WorldGenerator:Generate()

--[[local tab: { number } = table.create(BlockChunk:GetSize().X * BlockChunk:GetSize().Y, 0)

for i = 1, #tab do
	tab[i] = math.random(1, 2)
end

local chunk = BlockChunk.new(0, 0, tab)

while true do
	task.wait(math.random(1, 3))
	chunk:ReplaceBlock(
		math.random(1, BlockChunk:GetSize().X),
		math.random(1, BlockChunk:GetSize().Y),
		math.random(1, 2)
	)
end
]]
