-- DenylistBatchRepository = RepositoryBase:Create('ban_batch')

-- function DenylistBatchRepository:Create(reason, userId, perpetrator, optionalExpirationTimeInSeconds)
-- 	if optionalExpirationTimeInSeconds == nil then
-- 		--[[ Não vai se expirar... ]]
-- 		return self:Insert('INSERT INTO ban_batch(reason, perpetrator, userId) VALUES(?, ?, ?)', { reason, perpetrator, userId })
-- 	else
-- 		return self:Insert('INSERT INTO ban_batch(reason, perpetrator, userId, expiresAt) VALUES(?, ?, ?, CURRENT_TIMESTAMP + INTERVAL ? SECOND)', { reason, perpetrator, userId, optionalExpirationTimeInSeconds })
-- 	end
-- end

-- function DenylistBatchRepository:FindOneByIdentifiers(playerTokenIds)
-- 	return self:Single(
-- [[
-- SELECT
-- 	batch.id,
-- 	batch.reason,
-- 	batch.expiresAt,
-- 	TIMESTAMPDIFF(DAY, batch.createdAt, batch.expiresAt) AS duration
-- FROM denylist_batch 
-- WHERE batch.isDeactivated = 0
-- ORDER BY ISNULL(expiresAt) DESC
-- LIMIT 1
-- ]], { playerTokenIds })
-- end

-- function DenylistBatchRepository:SetIsDeactivated(batchId, isDeactivated)
-- 	return self:Update('UPDATE ban_batch SET isDeactivated = ? WHERE id = ?', { isDeactivated, batchId } )
-- end