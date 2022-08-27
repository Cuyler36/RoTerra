--local SharedFolder = game:GetService("ReplicatedStorage").Common
--local Block = require(script.Parent.Parent.Block)
local BlockChunk = require(script.Parent.Parent.BlockChunk)

local WORLD_SIZE_CHUNKS: Vector2 = Vector2.new(20, 10)

--local BlockData = require(SharedFolder.BlockData)
--local WorldGrid = require(SharedFolder.WorldGrid)

local WorldGenerator = {}
WorldGenerator.__index = WorldGenerator
WorldGenerator.ClassName = "WorldGenerator"

function WorldGenerator:Generate(): { BlockChunk.BlockChunk_t }
	local chunks: { BlockChunk.BlockChunk_t } = table.create(WORLD_SIZE_CHUNKS.X * WORLD_SIZE_CHUNKS.Y, nil)
	local chunk_template_dirt = table.create(BlockChunk:GetSize().X * BlockChunk:GetSize().Y, 1)
	local chunk_template_air = table.create(#chunk_template_dirt, 0)

	for y = 0, WORLD_SIZE_CHUNKS.Y - 1 do
		for x = 0, WORLD_SIZE_CHUNKS.X - 1 do
			if y < WORLD_SIZE_CHUNKS.Y / 2 then
				table.insert(
					chunks,
					BlockChunk.new(x * BlockChunk:GetSize().X, y * BlockChunk:GetSize().Y, chunk_template_dirt)
				)
			else
				table.insert(
					chunks,
					BlockChunk.new(x * BlockChunk:GetSize().X, y * BlockChunk:GetSize().Y, chunk_template_air)
				)
			end
		end
	end

	return chunks
end

return WorldGenerator
