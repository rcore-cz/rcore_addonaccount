function CreateAddonAccount()
    local self = {}

    self.nameAccount = nil
    self.OwnerIdentifier = nil
    self.IsShared = false
    self.money = 0

    -- will set a new value to variable "IsShared"
    self.setAccountShared = function(shared)
        self.IsShared = shared
    end

    -- will return variable "IsShared"
    self.isAccountShared = function()
        return self.IsShared
    end

    -- will set a new value to variable "OwnerIdentifier"
    self.setOwnerIdentifier = function(identifier)
        self.OwnerIdentifier = identifier
    end

    -- will return variable "OwnerIdentifier"
    self.getOwnerIdentifier = function()
        return self.OwnerIdentifier
    end

    -- will set a new value to variable "nameAccount"
    self.setAccountName = function(name)
        self.nameAccount = name
    end

    -- will return variable "nameAccount"
    self.getAccountName = function()
        return self.nameAccount
    end

    -- backward compatibility for esx_Addonaccount
    self.addMoney = function(money)
        if GetNumberType(money) == "negative" then
            Debug.security("Possible danger! Someone tried to use negative number in Addon Account [%s] Identifier of Addon Account [%s] from resource [%s]", self.getAccountName(), self.getOwnerIdentifier(), GetInvokingResource())
            Debug.security("Came from function 'addMoney'")
            return
        end

        self.setMoney(self.getMoney() + money)
    end

    -- backward compatibility for esx_Addonaccount
    self.removeMoney = function(money)
        if GetNumberType(money) == "negative" then
            Debug.security("Possible danger! Someone tried to use negative number in Addon Account [%s] Identifier of Addon Account [%s] from resource [%s]", self.getAccountName(), self.getOwnerIdentifier(), GetInvokingResource())
            Debug.security("Came from function 'removeMoney'")
            return
        end

        self.setMoney(self.getMoney() - money)
    end

    -- backward compatibility for esx_Addonaccount
    self.setMoney = function(money)
        if self.IsShared then
            GetSharedAccount(self.nameAccount).money = money
        else
            GetAccount(self.nameAccount, self.OwnerIdentifier).money = money
        end
        TriggerClientEvent("esx_addonaccount:setMoney", -1, self.getAccountName(), self.getMoney())
    end

    -- will return money from this account
    self.getMoney = function()
        return self.IsShared and GetSharedAccount(self.nameAccount).money or GetAccount(self.nameAccount, self.OwnerIdentifier).money
    end

    self.save = function()
        Debug.info("This version does not use 'save' function anymore")
    end

    return self
end