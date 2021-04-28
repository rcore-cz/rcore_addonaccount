-------------------------------------------------
-- Variables list
-------------------------------------------------
-- we will save a debug module into glob variable
-- so we dont have to load it over and over
Debug = rdebug()

-- ESX Variable that holds es_extended module
ESX = nil

-- Array that just holds all accounts names
AccountNameList = {}

-- Array variables that holds all modules from System/Accounts.lua
AddonAccountList = {}
SharedAccount = {}
-------------------------------------------------
-- Init
-------------------------------------------------
TriggerEvent("esx:getSharedObject", function(module) ESX = module end)
-------------------------------------------------
-- Function list
-------------------------------------------------
--- this function will return string value with "positive" or "negative" will depends if the number
--- will be positive or negative.
--- @param number int
function GetNumberType(number)
    if number > 0 then
        return "positive"
    else
        return "negative"
    end
    return nil
end

--- This just simply "convert" a number to bool, because some olders MySQL returns numbers instead of bools.
--- @param number int
function GetBooleanFromNumber(number)
    -- if data is an actuall bool we will just return it.
    return type(number) == "boolean" and number or number == 1
end

--- Will return true/false if the account exists
--- @param accountName string
function DoesAccountExists(accountName)
    return AccountNameList[accountName] ~= nil
end

exports('DoesAccountExists', DoesAccountExists)

--- Will return account module from owner
--- @param name string
--- @param owner string
function GetAccount(name, owner)
    if not DoesAccountExists(name) then
        Debug.critical("Account [%s] does not exists!", name)
        return nil
    end
    return AddonAccountList[name][owner]
end

exports('GetAccount', GetAccount)

--- Will return shared account module
--- @param name string
function GetSharedAccount(name)
    if not DoesAccountExists(name) then
        Debug.critical("Account [%s] does not exists!", name)
    end
    return SharedAccount[name]
end

exports('GetSharedAccount', GetSharedAccount)

--- Will load all accounts
function LoadAllAccounts()
    local addonAccounts = MySQL.Sync.fetchAll("SELECT * FROM addon_account")
    for k, v in pairs(addonAccounts) do
        local result = MySQL.Sync.fetchAll("SELECT * FROM addon_account_data WHERE account_name = @account_name", { ["@account_name"] = v.name })
        AccountNameList[v.name] = true
        Debug.info("Loading account [%s]", v.name)
        local shared = GetBooleanFromNumber(v.shared)
        if shared then
            local account = CreateAddonAccount()
            local money = 0

            if #result == 0 then
                MySQL.Async.execute("INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, NULL)", {
                    ["@account_name"] = v.name,
                    ["@money"] = 0
                })
            else
                money = result[1].money
            end

            account.setAccountShared(true)
            account.setAccountName(v.name)

            SharedAccount[v.name] = account

            account.setMoney(money)
        else
            AddonAccountList[v.name] = {}

            for _, data in pairs(result) do
                local account = CreateAddonAccount()

                account.setOwnerIdentifier(data.owner)
                account.setAccountShared(false)
                account.setAccountName(v.name)

                AddonAccountList[v.name][data.owner] = account

                account.setMoney(data.money)
            end
        end
    end

    TriggerEvent("esx:addonAccountsLoaded")
    TriggerEvent("rcore:addonAccountsLoaded")
end

--- Will save all shared accounts
function SaveAllAccounts()
    for name, _ in pairs(AccountNameList) do
        local account = GetSharedAccount(name)
        if account then
            MySQL.Async.execute("UPDATE addon_account_data SET money = @money WHERE account_name = @account_name", { ["@account_name"] = name, ["@money"] = account.getMoney(), })
        end
    end
end

--- Will save all online players
function SaveAllOnlinePlayers()
    local players = ESX.GetPlayers()
    for _, source in pairs(players) do
        SavePlayerData(source)
    end
end

--- Will save player account data
function SavePlayerData(playerID)
    local xPlayer = ESX.GetPlayerFromId(playerID)
    local account
    for name, _ in pairs(AccountNameList) do
        account = GetAccount(name, xPlayer.identifier)
        if account then
            MySQL.Async.execute("UPDATE addon_account_data SET money = @money WHERE account_name = @account_name AND owner = @owner", {
                ["@account_name"] = name,
                ["@money"] = account.getMoney(),
                ["@owner"] = xPlayer.identifier,
            })
        end
    end
end

-------------------------------------------------
-- Thread/Init list
-------------------------------------------------
-- if the mysql is ready lets roll
MySQL.ready(LoadAllAccounts)

--- is less heavier than SetTimeOut
--- Will save all addonaccount in defined interval time
--- Save only shared accounts, players acc get saved when they disconnect
CreateThread(function()
    local account
    while true do
        Wait(Config.SaveInterval)
        Debug.info("Saving all shared accounts")
        SaveAllAccounts()

        if Config.SavePlayers then
            SaveAllOnlinePlayers()
        end

        Debug.info("Done with saving!")
    end
end)
-------------------------------------------------
-- Event list
-------------------------------------------------
--- When this script will be turned off we will save all players + all shared accounts to prevent
--- data loss
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SaveAllAccounts()
        SaveAllOnlinePlayers()
    end
end)

--- backward compatibility for esx_Addonaccount
--- will return someone account
AddEventHandler("esx_addonaccount:getAccount", function(name, owner, cb)
    cb(GetAccount(name, owner))
end)

--- backward compatibility for esx_Addonaccount
--- will return shared account
AddEventHandler("esx_addonaccount:getSharedAccount", function(name, cb)
    cb(GetSharedAccount(name))
end)

--- when player load it will check if the accounts exists
--- and if not it will create them
AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    local playerAccounts = {}

    for name, _ in pairs(AccountNameList) do
        if AddonAccountList[name] then
            if not AddonAccountList[name][xPlayer.identifier] then
                MySQL.Async.execute("INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, @owner)", {
                    ["@account_name"] = name,
                    ["@money"] = 0,
                    ["@owner"] = xPlayer.identifier
                })

                local account = CreateAddonAccount()

                account.setOwnerIdentifier(xPlayer.identifier)
                account.setAccountShared(false)
                account.setAccountName(name)

                AddonAccountList[name][xPlayer.identifier] = account
            end
        end
        table.insert(playerAccounts, account)
    end

    xPlayer.set("addonAccounts", playerAccounts)
end)

--- When player leave the game we will save his data
AddEventHandler("esx:playerDropped", function(playerID)
    SavePlayerData(playerID)
end)