local Block = require(script.Parent.Block)
local WorldGrid = require(script.Parent.WorldGrid)

local BlockGroup = {}
BlockGroup.__index = BlockGroup
BlockGroup.ClassName = "BlockGroup"

type BlockRect_t = {
	BottomLeft: Vector2,
	Size: Vector2,
}

-- 1) Create 2D list of points
-- 2) Step through each point, finding the largest rectangle possible. Remove included points from list
-- 3) Repeat until all squares have been accounted for

function BlockGroup:DEBUG_DrawBlocksRaw(blocks: { Block.Block_t }): ()
	for _, block: Block.Block_t in ipairs(blocks) do
		local p = Instance.new("Part")
		p.Size = WorldGrid:GetBlockSize()
		p.PivotOffset = CFrame.new(Vector3.new(-1, -1, 0))
		p:PivotTo(CFrame.new(WorldGrid:To3DSpace(block.Position)))
		p.Color = Color3.fromRGB(255, 0, 0)
		p.Anchored = true
		p.Parent = workspace
	end
end

function BlockGroup:BuildLayout2D(blocks: { Block.Block_t }): ()
	--self:DEBUG_DrawBlocksRaw(blocks)

	local list2d: { [number]: { [number]: boolean } } = { Count = 0 } -- [y][x]
	local rectangles: { BlockRect_t } = {}
	local bottomleft: Vector2 = Vector2.new(99999, 99999)
	local groupStartPos: Vector2 = Vector2.zero
	local top: number = -99999

	-- Construct list
	for _, block in ipairs(blocks) do
		if list2d[block.Position.Y] == nil then
			list2d[block.Position.Y] =
				{ [block.Position.X] = true, StartPos = block.Position.X, EndPos = block.Position.X, Count = 1 }
			list2d.Count += 1
		else
			list2d[block.Position.Y][block.Position.X] = true
			list2d[block.Position.Y].Count += 1

			if list2d[block.Position.Y].StartPos > block.Position.X then
				list2d[block.Position.Y].StartPos = block.Position.X
			elseif list2d[block.Position.Y].EndPos < block.Position.X then
				list2d[block.Position.Y].EndPos = block.Position.X
			end
		end

		if block.Position.Y < bottomleft.Y then
			bottomleft = Vector2.new(bottomleft.X, block.Position.Y)
		end

		if block.Position.X < bottomleft.X then
			bottomleft = Vector2.new(block.Position.X, bottomleft.Y)
		end

		if block.Position.Y > top then
			top = block.Position.Y
		end
	end

	groupStartPos = bottomleft
	-- Construct rectangles
	while list2d.Count > 0 do
		local startPos: Vector2 = bottomleft
		while list2d[startPos.Y] == nil do
			startPos += Vector2.yAxis
		end

		local nowPos: Vector2 = startPos
		while list2d[nowPos.Y + 1] ~= nil do
			nowPos += Vector2.yAxis
		end

		local minX = list2d[startPos.Y].StartPos
		local maxX = list2d[startPos.Y].EndPos
		for y = startPos.Y, nowPos.Y do
			for x = minX, list2d[y].EndPos do
				if list2d[y][x] == nil then
					if x < maxX then
						maxX = x - 1
					end
					break
				end
			end
		end

		for y = startPos.Y, nowPos.Y do
			for x = minX, maxX do
				list2d[y][x] = nil
				list2d[y].Count -= 1
				if list2d[y].Count <= 0 then
					list2d[y] = nil
					list2d.Count -= 1

					if list2d.Count > 0 then
						if y == top then
							repeat
								top -= 1
							until list2d[top]
						elseif y == bottomleft.Y then
							repeat
								bottomleft += Vector2.yAxis
							until list2d[bottomleft.Y]
						end
					end

					break
				else
					if x == list2d[y].StartPos then
						repeat
							list2d[y].StartPos += 1
						until list2d[y][list2d[y].StartPos]
					elseif x == list2d[y].EndPos then
						repeat
							list2d[y].EndPos += 1
						until list2d[y][list2d[y].EndPos]
					end
				end
			end
		end

		table.insert(rectangles, {
			BottomLeft = Vector2.new(minX, startPos.Y) - groupStartPos,
			Size = Vector2.new((maxX - minX) + 1, (nowPos.Y - startPos.Y) + 1),
		})

		print(
			string.format(
				"Added rectangle: Size=(%d, %d), BottomLeft=(%d, %d)",
				rectangles[#rectangles].Size.X,
				rectangles[#rectangles].Size.Y,
				rectangles[#rectangles].BottomLeft.X,
				rectangles[#rectangles].BottomLeft.Y
			)
		)
	end

	self._startPos = groupStartPos
	self._layout = rectangles
end

function BlockGroup:BuildMeshRects(): ()
	if self._layout and #self._layout > 0 then
		if self._mesh then
			task.defer(self._mesh.Destroy, self._mesh)
		end

		local startPos: Vector3 = WorldGrid:To3DSpace(self._startPos)
		print(self._startPos, startPos)
		local firstRect: BlockRect_t = self._layout[1]
		local firstBlock: BasePart = Instance.new("Part")
		firstBlock.Anchored = true
		firstBlock.Size = WorldGrid:To3DSize(firstRect.Size)
		firstBlock.PivotOffset =
			CFrame.new(-0.5 * Vector3.new(firstRect.Size.X, firstRect.Size.Y, 0) * WorldGrid:GetGridSize())
		firstBlock:PivotTo(CFrame.new(startPos + WorldGrid:To3DSpace(firstRect.BottomLeft)))
		firstBlock.Parent = workspace

		local mesh: BasePart
		if #self._layout > 1 then
			local otherBlocks: { BasePart } = table.create(#self._layout - 1, nil)
			for i = 2, #self._layout do
				local block: BasePart = firstBlock:Clone()
				block.Size = WorldGrid:To3DSize(self._layout[i].Size)
				block.PivotOffset = CFrame.new(
					-0.5 * Vector3.new(self._layout[i].Size.X, self._layout[i].Size.Y, 0) * WorldGrid:GetGridSize()
				)
				block:PivotTo(CFrame.new(startPos + WorldGrid:To3DSpace(self._layout[i].BottomLeft)))
				block.Name = string.format("Part_%d", i)
				block.Parent = workspace
				table.insert(otherBlocks, block)
			end

			-- Remove source parts
			task.defer(firstBlock.Destroy, firstBlock)
			for _, part in ipairs(otherBlocks) do
				task.defer(part.Destroy, part)
			end

			print(firstBlock, otherBlocks)
			local union =
				firstBlock:UnionAsync(otherBlocks, Enum.CollisionFidelity.Default, Enum.RenderFidelity.Automatic)
			union.Parent = workspace
			mesh = union
		else
			mesh = firstBlock
		end

		self._mesh = mesh
	end
end

function BlockGroup:BuildLayout(blocks: { Block.Block_t }): ()
	if #blocks < 1 then
		return
	end

	local coordinates: { Vector2 } = table.create(#blocks - 1, nil)
	-- TODO: Make this more performant. O(n^2) is terrible.

	-- Determine the first block in the group
	local firstPos: Vector2? = nil
	local firstBlockIdx: number? = nil
	for i, block in ipairs(blocks) do
		if
			firstPos == nil
			or block.Position.Y < firstPos.Y
			or (block.Position.Y == firstPos.Y and block.Position.X < firstPos.X)
		then
			firstPos = block.Position
			firstBlockIdx = i
		end
	end

	if firstPos then
		table.remove(blocks, firstBlockIdx)

		for _, otherBlock in ipairs(blocks) do
			table.insert(coordinates, otherBlock.Position - firstPos)
		end
	end

	self._startPos = firstPos
	self._layout = coordinates
end

function BlockGroup:BuildMesh(): ()
	if self._layout then
		if self._union then
			task.defer(self._union.Destroy, self._union)
		end

		-- Build first block
		local firstPos = self._startPos
		local firstBlock: BasePart = Instance.new("Part")
		firstBlock.Anchored = true
		firstBlock.Size = WorldGrid:GetBlockSize()
		firstBlock.CFrame = CFrame.new(WorldGrid:To3DSpace(firstPos))
		firstBlock.Parent = workspace

		-- Build other blocks
		local otherBlocks: { BasePart } = table.create(#self._layout)
		for _, otherPos in ipairs(self._layout) do
			local otherBlock: BasePart = firstBlock:Clone()
			otherBlock.CFrame = CFrame.new(WorldGrid:To3DSpace(firstPos + otherPos))
			table.insert(otherBlocks, otherBlock)
		end

		-- Remove source parts
		task.defer(firstBlock.Destroy, firstBlock)
		for _, part in ipairs(otherBlocks) do
			task.defer(part.Destroy, part)
		end

		-- Create mesh
		self._union = firstBlock:UnionAsync(otherBlocks)
		self._union.Parent = workspace
	end
end

function BlockGroup.new(blocks: { Block.Block_t })
	local group = {}
	setmetatable(group, BlockGroup)

	group:BuildLayout2D(blocks)
	group:BuildMeshRects()

	--group:BuildLayout(blocks)
	--group:BuildMesh()

	return group
end

export type BlockGroup_t = typeof(BlockGroup.new({}))

return BlockGroup
