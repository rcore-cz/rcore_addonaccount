function GetEsxObject()
    local promise_ = promise:new()
    local obj
    xpcall(function()
        if ESX == nil then
            error("ESX variable is nil")
        end
        obj = ESX
        promise_:resolve(obj)
    end, function(error)
        xpcall(function()
            obj = exports["es_extended"]['getSharedObject']()
            promise_:resolve(obj)
        end, function(error)
            TriggerEvent(Config.ESX or "esx:getSharedObject", function(module)
                obj = module
                promise_:resolve(obj)
            end)
        end)
    end)

    Citizen.Await(obj)
    return obj
end