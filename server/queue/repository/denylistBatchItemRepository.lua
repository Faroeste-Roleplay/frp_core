-- DenylistBatchItemRepository = RepositoryBase:Create('denylist_batch_item')

-- function DenylistBatchItemRepository:Create(denylistBatchId, playerTokenId)
-- 	return self:Insert('INSERT INTO denylist_batch_item(denylist_batch_id, player_token_id) VALUES(?, ?)', { denylistBatchId, playerTokenId })
-- end

-- function DenylistBatchItemRepository:BulkCreate(denylistBatchId, playerTokenIds)
-- 	local parameters = { }

-- 	for index, playerTokenId in ipairs(playerTokenIds) do
-- 		parameters[index] =
-- 		{
-- 			denylistBatchId,
-- 			playerTokenId,
-- 		}
-- 	end

-- 	return self:Prepare('INSERT INTO denylist_batch_item(denylist_batch_id, player_token_id) VALUES(?, ?)', parameters)
-- end