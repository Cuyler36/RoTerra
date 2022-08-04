local BlockDestroyer = {}
BlockDestroyer.__index = BlockDestroyer
BlockDestroyer.ClassName = "BlockDestroyer"

function BlockDestroyer:DestroyBlock(block: BasePart): ()
	-- TODO: look up block in internal bitmap database and remove it. Also verify with server that it was correctly destroyed
	task.defer(block.Destroy, block)
end

return BlockDestroyer
