ClientBridge = {}

local hasOxLib = GetResourceState('ox_lib') == 'started'

function ClientBridge.Notify(msg, kind)
    kind = kind or 'inform'

    if hasOxLib then
        return exports.ox_lib:notify({ title = L('title'), description = msg, type = kind })
    end

    if GetResourceState('es_extended') == 'started' then
        return TriggerEvent('esx:showNotification', msg)
    end

    if GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
        local qbType = (kind == 'inform') and 'primary' or kind
        return TriggerEvent('QBCore:Notify', msg, qbType)
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, true)
end

RegisterNetEvent('nexo_recompensas:notify', function(msg, kind)
    ClientBridge.Notify(msg, kind)
end)
