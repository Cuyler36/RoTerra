local GRID_SIZE: number = 2 -- studs

local WorldGrid = {}
WorldGrid.__index = WorldGrid
WorldGrid.ClassName = "WorldGrid"

local blockSize: Vector3 = Vector3.new(GRID_SIZE, GRID_SIZE, GRID_SIZE)

function WorldGrid:To3DSpace(pos: Vector2): Vector3
	return Vector3.new(math.floor(pos.X * GRID_SIZE), math.floor(pos.Y * GRID_SIZE), 0)
end

function WorldGrid:ToGridSpace(pos: Vector3): Vector2
	return Vector2.new(math.floor(pos.X / GRID_SIZE), math.floor(pos.Y / GRID_SIZE))
end

function WorldGrid:To3DSize(size2d: Vector2): Vector3
	return Vector3.new(math.floor(size2d.X) * GRID_SIZE, math.floor(size2d.Y) * GRID_SIZE, GRID_SIZE)
end

function WorldGrid:GetBlockSize(): Vector3
	return blockSize
end

function WorldGrid:GetGridSize(): number
	return GRID_SIZE
end

return WorldGrid
