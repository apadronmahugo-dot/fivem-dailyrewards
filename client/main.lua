local isOpen = false
local checkedJoin = false

local function close()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterCommand(Config.Command, function()
    if isOpen then return end
    TriggerServerEvent('nexo_recompensas:open')
end, false)

if Config.Keybind then
    RegisterKeyMapping(Config.Command, L('keybind_desc'), 'keyboard', Config.Keybind)
end

RegisterNetEvent('nexo_recompensas:show', function(payload)
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', payload = payload })
end)

RegisterNetEvent('nexo_recompensas:update', function(state)
    SendNUIMessage({ action = 'update', state = state })
end)

RegisterNUICallback('claim', function(_, cb)
    TriggerServerEvent('nexo_recompensas:claim')
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    close()
    cb('ok')
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and isOpen then SetNuiFocus(false, false) end
end)

-- ===================== aviso al entrar =====================

local function checkOnJoin()
    if not Config.NotifyOnJoin or checkedJoin then return end
    checkedJoin = true
    SetTimeout(8000, function()
        TriggerServerEvent('nexo_recompensas:checkPending')
    end)
end

RegisterNetEvent('esx:playerLoaded', checkOnJoin)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', checkOnJoin)

AddEventHandler('playerSpawned', function()
    -- standalone: si no hay framework, avisar al spawnear
    if GetResourceState('es_extended') ~= 'started'
        and GetResourceState('qb-core') ~= 'started'
        and GetResourceState('qbx_core') ~= 'started' then
        checkOnJoin()
    end
end)
