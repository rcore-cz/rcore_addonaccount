function sprint(msg, ...)
    return string.format(msg, ...)
end

function isAllowed(level)
    return Config.DebugLevel[level]
end

function rdebug()
    local self = {}
    self.prefix = "rcore"
    self.info = function(msg, ...)
        if isAllowed("INFO") then
            print("^5[" .. self.prefix .. "|info] ^7" .. sprint(msg, ...))
        end
    end
    self.success = function(msg, ...)
        if isAllowed("SUCCESS") then
            print("^5[" .. self.prefix .. "|success] ^7" .. sprint(msg, ...))
        end
    end
    self.critical = function(msg, ...)
        if isAllowed("CRITICAL") then
            print("^1[" .. self.prefix .. "|critical] ^7" .. sprint(msg, ...))
        end
    end
    self.error = function(msg, ...)
        if isAllowed("ERROR") then
            print("^1[" .. self.prefix .. "|error] ^7" .. sprint(msg, ...))
        end
    end
    self.security = function(msg, ...)
        if isAllowed("SECURITY") then
            print("^3[" .. self.prefix .. "|security] ^7" .. sprint(msg, ...))
        end
    end
    self.securitySpam = function(msg, ...)
        if isAllowed("SECURITY_SPAM") then
            print("^3[" .. self.prefix .. "|security] ^7" .. sprint(msg, ...))
        end
    end
    self.debug = function(msg, ...)
        if isAllowed("DEBUG") then
            print("^2[" .. self.prefix .. "|debug] ^7" .. sprint(msg, ...))
        end
    end
    self.setupPrefix = function(prefix)
        self.prefix = prefix
    end
    self.getPrefix = function()
        return self.prefix
    end
    return self
end