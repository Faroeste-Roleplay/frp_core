DenylistBatchRepository =  {} -- RepositoryBase:Create('ban_batch')

function DenylistBatchRepository:Create(reason, userId, perpetrator, optionalExpirationTimeInSeconds)
    if optionalExpirationTimeInSeconds == nil then
        --[[ Não vai se expirar... ]]
        return MySQL.insert.await('INSERT INTO ban_batch(reason, perpetrator, userId) VALUES(?, ?, ?)',
            { reason, perpetrator, userId })
    else
        return MySQL.insert.await(
        'INSERT INTO ban_batch(reason, perpetrator, userId, expiresAt) VALUES(?, ?, ?, CURRENT_TIMESTAMP + INTERVAL ? SECOND)',
            { reason, perpetrator, userId, optionalExpirationTimeInSeconds })
    end
end

function DenylistBatchRepository:GetBanFromUserId( userId )
    return MySQL.single.await([[
        SELECT  
            id,
            reason,
            expiresAt,
            TIMESTAMPDIFF(DAY, createdAt, expiresAt) AS duration
        from `ban_batch` 
        WHERE 
        userId = ? AND 
        isDeactivated = 0 
        ORDER BY ISNULL(expiresAt) DESC
        LIMIT 1
    ]], { userId })
end


function DenylistBatchRepository:SetIsDeactivated(batchId, isDeactivated)
    return MySQL.update.await('UPDATE ban_batch SET isDeactivated = ? WHERE id = ?', { isDeactivated, batchId })
end
