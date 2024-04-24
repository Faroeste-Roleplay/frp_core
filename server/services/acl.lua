ACL = {}

ACL.AddAce = function(principal, ace, allow) 
    local command = string.format("add_ace %s %s %s", principal, ace, ACL.BoolToAllowOrDeny(allow))
    -- print(" AddAce :: ", command)
    ExecuteCommand(command);
end

ACL.RemoveAce = function(principal, ace, allow) 
    local command = string.format("remove_ace %s %s %s", principal, ace, ACL.BoolToAllowOrDeny(allow))
    -- print(" RemoveAce :: ", command)
    ExecuteCommand(command);
end

ACL.AddPrincipal = function(child, parent) 
    local command = string.format("add_principal %s %s", child, parent)
    -- print(" AddPrincipal :: ", command)
    ExecuteCommand(command);
end

ACL.RemovePrincipal = function(child, parent) 
    local command = string.format("remove_principal %s %s", child, parent)
    -- print(" RemovePrincipal :: ", command)
    ExecuteCommand(command);
end

ACL.BoolToAllowOrDeny = function(allow) 
    return not not allow and "allow" or "deny"
end

