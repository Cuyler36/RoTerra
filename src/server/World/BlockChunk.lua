local CHUNK_SIZE: Vector2 = Vector2.new(16, 16)

--local BlockGroup = require(script.Parent.BlockGroup)
local Block = require(script.Parent.Block)

local WorldGrid = require(game:GetService("ReplicatedStorage").Common.World.WorldGrid)
local BlockData = require(game:GetService("ReplicatedStorage").Common.Data.BlockData)

local BlockChunk = {}
BlockChunk.__index = BlockChunk
BlockChunk.ClassName = "BlockChunk"

function BlockChunk:GetSize(): Vector2
	return CHUNK_SIZE
end

function BlockChunk:Render(): ()
	assert(self._folder, "Could not render BlockChunk because chunk folder was nil!")
	self._folder.Parent = workspace.Game.World
end

function BlockChunk:Hide(): ()
	assert(self._folder, "Could not de-render BlockChunk because chunk folder was nil!")
	self._folder.Parent = nil
end

function BlockChunk:HasBlock(x: number, y: number): boolean
	return self._start.X <= x and self._end.X > x and self._start.Y <= y and self._end.Y > y
end

function BlockChunk:ReplaceBlock(x: number, y: number, block_type: number): boolean
	if self:HasBlock(x, y) then
		x -= self._start.X
		y -= self._start.Y
		local idx: number = y * CHUNK_SIZE.X + x
		if self._blocks[idx] ~= block_type then
			self._blocks[idx] = block_type
			if self._blockParts then
				local now_block = self._blockParts[idx]
				task.defer(now_block.Destroy, now_block)

				local block = Instance.new("Part")
				block.Size = now_block.Size
				block.CFrame = now_block.CFrame
				block.Anchored = true
				block.Material = BlockData[block_type].Material
				block.Color = BlockData[block_type].Color
				block.Name = string.format("Block_%d", idx)
				block.Parent = self._folder
				self._blockParts[idx] = block
			else
				self:RebuildMeshParts()
			end
			return true
		end
	end
	return false
end

function BlockChunk:RebuildMesh(): ()
	if #self._blocks > 0 then
		local now_union: UnionOperation? = self._union

		local firstPos = self._start
		local firstBlock: BasePart = Instance.new("Part")
		firstBlock.Anchored = true
		firstBlock.Size = WorldGrid:GetBlockSize()
		firstBlock.CFrame = CFrame.new(WorldGrid:To3DSpace(firstPos))
		--print(string.format("(%d, %d):", 0, 0), firstBlock.CFrame.Position)
		firstBlock.Material = BlockData[self._blocks[1]].Material
		firstBlock.Color = BlockData[self._blocks[1]].Color
		firstBlock.Parent = workspace

		local otherBlocks: { BasePart } = {}
		for i = 1, #self._blocks - 1 do
			local x = i % CHUNK_SIZE.X
			local y = math.floor(i / CHUNK_SIZE.X)
			local otherBlock: BasePart = firstBlock:Clone()
			otherBlock.CFrame = CFrame.new(WorldGrid:To3DSpace(firstPos + Vector2.new(x, y)))
			otherBlock.Material = BlockData[self._blocks[i + 1]].Material
			otherBlock.Color = BlockData[self._blocks[i + 1]].Color
			--print(string.format("(%d, %d):", x, y), otherBlock.CFrame.Position)
			table.insert(otherBlocks, otherBlock)
		end

		-- Remove source parts
		task.defer(firstBlock.Destroy, firstBlock)
		for _, part in ipairs(otherBlocks) do
			task.defer(part.Destroy, part)
		end

		-- Create mesh
		local now = os.clock()
		self._union = firstBlock:UnionAsync(otherBlocks)
		print(os.clock() - now)

		if now_union then
			task.delay(0.5, now_union.Destroy, now_union)
		end

		self._union.Parent = self._folder
	end
end

function BlockChunk:RebuildMeshParts(): ()
	local now = os.clock()
	if #self._blocks == CHUNK_SIZE.X * CHUNK_SIZE.Y then
		local rendered = self._folder.Parent ~= nil

		local new_folder = Instance.new("Folder")
		local blocks = table.create(#self._blocks, nil)
		for i = 1, #self._blocks do
			local x = (i - 1) % CHUNK_SIZE.X
			local y = math.floor((i - 1) / CHUNK_SIZE.X)

			-- TODO: calculate positions under an actor?
			local block: BasePart = Instance.new("Part")
			block.Anchored = true
			block.Size = WorldGrid:GetBlockSize()
			block.CFrame = CFrame.new(WorldGrid:To3DSpace(self._start + Vector2.new(x, y)))
			block.Material = BlockData[self._blocks[i]].Material
			block.Color = BlockData[self._blocks[i]].Color
			block.Name = string.format("Block_%d", i - 1)
			block.Parent = new_folder

			blocks[i] = block
		end

		if self._folder then
			task.defer(self._folder.Destroy, self._folder)
		end

		self._folder = new_folder
		self._blockParts = blocks
		if rendered then
			self:Render()
		end
	end
	print(os.clock() - now)
end

function BlockChunk.new(x: number, y: number, blocks: { Block.Block_t })
	local this = {}
	this._start = Vector2.new(x, y)
	this._end = this._start + CHUNK_SIZE
	this._blocks = blocks
	this._folder = Instance.new("Folder")
	this._folder.Name = string.format("CHUNK_%d_%d", math.floor(x / CHUNK_SIZE.X), math.floor(y / CHUNK_SIZE.Y))

	-- TODO: We can reduce tris significantly by grouping blocks together. Investigate this.
	local self = setmetatable(this, BlockChunk)
	self:RebuildMeshParts()
	self:Render()
	return self
end

return BlockChunk
