local Block = {}
Block.__index = Block
Block.ClassName = "Block"

function Block.new(blockType: number, position: Vector2)
	local this = {}
	this.Type = blockType
	this.Position = position

	return setmetatable(this, Block)
end

export type Block_t = typeof(Block.new(0, Vector2.new(0, 0)))

return Block
