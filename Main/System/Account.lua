function CreateAddonAccount()
    local self = {}

    self.nameAccount = "nil"
    self.labelAccount = "nil"
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

    -- will set a new value to variable "labelAccount"
    self.setAccountLabel = function(name)
        self.labelAccount = name
    end

    -- will return variable "labelAccount"
    self.getAccountLabel = function()
        return self.labelAccount
    end

    -- backward compatibility for esx_Addonaccount
    self.addMoney = function(money)
        if GetNumberType(money) == "negative" then
            Debug.security("Possible danger! Someone tried to use negative number in Addon Account [%s] Identifier of Addon Account [%s] from resource [%s]", self.getAccountName(), self.getOwnerIdentifier(), GetInvokingResource() or GetCurrentResourceName())
            Debug.security("Came from function 'addMoney'")
            return
        end

        self.setMoney(self.getMoney() + money)
    end

    -- backward compatibility for esx_Addonaccount
    self.removeMoney = function(money)
        if GetNumberType(money) == "negative" then
            Debug.security("Possible danger! Someone tried to use negative number in Addon Account [%s] Identifier of Addon Account [%s] from resource [%s]", self.getAccountName(), self.getOwnerIdentifier(), GetInvokingResource() or GetCurrentResourceName())
            Debug.security("Came from function 'removeMoney'")
            return
        end

        self.setMoney(self.getMoney() - money)
    end

    -- backward compatibility for esx_Addonaccount
    self.setMoney = function(money)
        if DoesAccountExists(self.getAccountName()) then
            if self.IsShared then
                GetSharedAccount(self.nameAccount).money = money
            else
                GetAccount(self.nameAccount, self.OwnerIdentifier).money = money
            end
            TriggerClientEvent("esx_addonaccount:setMoney", -1, self.getAccountName(), self.getMoney())
        end
    end

    -- will return money from this account
    self.getMoney = function()
        if DoesAccountExists(self.getAccountName()) then
            if self.IsShared then
                return GetSharedAccount(self.nameAccount).money
            else
                return GetAccount(self.nameAccount, self.OwnerIdentifier).money
            end
        end
    end

    -- will save account data
    self.save = function()
        Debug.info("Saving account [%s] from resource [%s]", self.getAccountName(), GetInvokingResource() or GetCurrentResourceName())
        MySQL.Async.execute("UPDATE addon_account_data SET money = @money WHERE account_name = @account_name", { ["@account_name"] = self.getAccountName(), ["@money"] = self.getMoney(), })
    end

    -- will check if does not exists + will create data for everything.
    self.create = function()
        if not DoesAccountExists(self.getAccountName()) then
            AccountNameList[self.getAccountName()] = true
            Debug.info("Creating a new account data [%s] from resource [%s]", self.getAccountName(), GetInvokingResource() or GetCurrentResourceName())

            MySQL.Async.execute("INSERT INTO addon_account (name, label, shared) VALUES (@name, @label, @shared)", {
                ["@name"] = self.getAccountName(),
                ["@label"] = self.getAccountLabel(),
                ["@shared"] = self.IsShared
            })

            if self.IsShared then
                SharedAccount[self.getAccountName()] = self
            else
                AddonAccountList[self.getAccountName()] = {}

                local players = ESX.GetPlayers()
                for _, source in pairs(players) do
                    local xPlayer = ESX.GetPlayerFromId(source)
                    MySQL.Async.execute("INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, @owner)", {
                        ["@account_name"] = self.getAccountName(),
                        ["@money"] = 0,
                        ["@owner"] = xPlayer.identifier
                    })

                    AddonAccountList[self.getAccountName()][xPlayer.identifier] = self
                end
            end
        else
            Debug.info("Skipping creation of account data [%s] from resource [%s] because it already exists!", self.getAccountName(), GetInvokingResource() or GetCurrentResourceName())
        end
    end

    return self
end

exports('CreateAddonAccount', CreateAddonAccount)