Bridge = { name = 'standalone' }

local ESX, QBCore

CreateThread(function()
    if GetResourceState('qbx_core') == 'started' then
        Bridge.name = 'qbx'
    elseif GetResourceState('es_extended') == 'started' then
        Bridge.name = 'esx'
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        Bridge.name = 'qb'
        QBCore = exports['qb-core']:GetCoreObject()
    end

    if GetResourceState('ox_inventory') == 'started' then
        Bridge.inventory = 'ox'
        Bridge.imagePath = 'nui://ox_inventory/web/images/'
    elseif GetResourceState('qb-inventory') == 'started' then
        Bridge.inventory = 'qb'
        Bridge.imagePath = 'nui://qb-inventory/html/images/'
    elseif GetResourceState('ps-inventory') == 'started' then
        Bridge.inventory = 'ps'
        Bridge.imagePath = 'nui://ps-inventory/html/images/'
    end
end)

local function getPlayer(src)
    if Bridge.name == 'qbx' then return exports.qbx_core:GetPlayer(src) end
    if Bridge.name == 'esx' then return ESX.GetPlayerFromId(src) end
    if Bridge.name == 'qb' then return QBCore.Functions.GetPlayer(src) end
end

--- Identificador único (personaje o licencia). nil si el personaje no ha cargado.
function Bridge.GetIdentifier(src)
    if Config.PerCharacter and Bridge.name ~= 'standalone' then
        local p = getPlayer(src)
        if not p then return nil end
        if Bridge.name == 'esx' then return 'char:' .. p.identifier end
        return 'char:' .. p.PlayerData.citizenid
    end
    local license = GetPlayerIdentifierByType(src, 'license')
    return license and ('lic:' .. license) or nil
end

function Bridge.AddMoney(src, account, amount)
    if Bridge.name == 'standalone' then return Config.Standalone.AddMoney(src, account, amount) end
    local p = getPlayer(src)
    if not p then return false end

    if Bridge.name == 'esx' then
        p.addAccountMoney(account == 'cash' and 'money' or account, amount, 'nexo_recompensas')
    else
        p.Functions.AddMoney(account, amount, 'nexo_recompensas')
    end
    return true
end

function Bridge.AddItem(src, item, amount)
    if Bridge.inventory == 'ox' then
        return exports.ox_inventory:AddItem(src, item, amount) and true or false
    end
    if Bridge.name == 'standalone' then return Config.Standalone.AddItem(src, item, amount) end

    local p = getPlayer(src)
    if not p then return false end

    if Bridge.name == 'esx' then
        p.addInventoryItem(item, amount)
        return true
    end

    local ok = p.Functions.AddItem(item, amount)
    if ok and Bridge.name == 'qb' and QBCore.Shared.Items[item] then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
    end
    return ok and true or false
end
