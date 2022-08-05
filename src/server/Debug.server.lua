task.defer(workspace.Game.BlockFabTest.Destroy, workspace.Game.BlockFabTest)

local Block = require(script.Parent.World.Block)
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

-- Block group creation
