local busy = {}
local CYCLE = #Config.Rewards

-- ===================== utilidades =====================

local function today()
    local t = os.date('*t')
    return math.floor(os.time({ year = t.year, month = t.month, day = t.day, hour = 12 }) / 86400)
end

local function secondsUntilReset()
    local t = os.date('*t')
    return 86400 - (t.hour * 3600 + t.min * 60 + t.sec)
end

local function load(id)
    local raw = GetResourceKvpString('dr:' .. id)
    local data = raw and json.decode(raw)
    return data or { streak = 0, last = 0, total = 0 }
end

local function save(id, data)
    SetResourceKvp('dr:' .. id, json.encode(data))
end

--- Racha efectiva hoy (aplica el reset si se saltó días)
local function effectiveStreak(data, t)
    if data.last ~= t and data.last < t - 1 and Config.ResetStreakOnMiss then
        return 0
    end
    return data.streak
end

local function formatNumber(n)
    local s = tostring(math.floor(n))
    local out = s:reverse():gsub('(%d%d%d)', '%1.'):reverse()
    return (out:gsub('^%.', ''))
end

local function rewardText(r)
    if r.type == 'money' then
        return ('$%s (%s)'):format(formatNumber(r.amount), L(r.account == 'bank' and 'bank' or 'cash'))
    elseif r.type == 'item' then
        return ('%sx %s'):format(r.amount, r.label or r.name)
    end
    return r.label or 'Bonus'
end

local function buildUiRewards()
    local list = {}
    for i, day in ipairs(Config.Rewards) do
        local items = {}
        for _, r in ipairs(day.rewards) do
            items[#items + 1] = {
                type = r.type,
                name = r.name,
                account = r.account,
                icon = r.icon,
                text = rewardText(r),
            }
        end
        list[i] = { day = i, highlight = day.highlight or false, items = items }
    end
    return list
end

local UI_REWARDS

local function getState(src)
    local id = Bridge.GetIdentifier(src)
    if not id then return nil end

    local data = load(id)
    local t = today()
    local claimedToday = data.last == t
    local streak = effectiveStreak(data, t)

    local claimedInCycle
    if claimedToday then
        claimedInCycle = ((streak - 1) % CYCLE) + 1
    else
        claimedInCycle = streak % CYCLE
    end

    return {
        claimedToday = claimedToday,
        claimedInCycle = claimedInCycle,
        streak = streak,
        total = data.total or 0,
        resetIn = secondsUntilReset(),
    }
end

-- ===================== callbacks =====================

RegisterNetEvent('dailyrewards:open', function()
    local src = source
    local state = getState(src)
    if not state then
        return TriggerClientEvent('dailyrewards:notify', src, L('not_loaded'), 'error')
    end

    UI_REWARDS = UI_REWARDS or buildUiRewards()

    TriggerClientEvent('dailyrewards:show', src, {
        state = state,
        rewards = UI_REWARDS,
        imagePath = Bridge.imagePath,
        branding = Config.Branding,
        locale = Locales[Config.Locale] or Locales.en,
    })
end)

RegisterNetEvent('dailyrewards:claim', function()
    local src = source
    if busy[src] then return end
    busy[src] = true

    local id = Bridge.GetIdentifier(src)
    if not id then
        busy[src] = nil
        return TriggerClientEvent('dailyrewards:notify', src, L('not_loaded'), 'error')
    end

    local data = load(id)
    local t = today()

    if data.last == t then
        busy[src] = nil
        return TriggerClientEvent('dailyrewards:notify', src, L('already'), 'error')
    end

    local streak = effectiveStreak(data, t) + 1
    local dayIndex = ((streak - 1) % CYCLE) + 1

    -- Guardar ANTES de entregar para evitar duplicados
    data.streak = streak
    data.last = t
    data.total = (data.total or 0) + 1
    save(id, data)

    for _, r in ipairs(Config.Rewards[dayIndex].rewards) do
        if r.type == 'money' then
            Bridge.AddMoney(src, r.account or 'cash', r.amount)
        elseif r.type == 'item' then
            Bridge.AddItem(src, r.name, r.amount)
        elseif r.type == 'custom' and r.event then
            TriggerEvent(r.event, src, r.data)
        end
    end

    TriggerEvent('dailyrewards:claimed', src, dayIndex, streak) -- hook para otros scripts
    TriggerClientEvent('dailyrewards:notify', src, L('notify_claimed', dayIndex), 'success')
    TriggerClientEvent('dailyrewards:update', src, getState(src))

    busy[src] = nil
end)

RegisterNetEvent('dailyrewards:checkPending', function()
    local src = source
    local state = getState(src)
    if state and not state.claimedToday then
        TriggerClientEvent('dailyrewards:notify', src, L('notify_ready', Config.Command), 'inform')
    end
end)

AddEventHandler('playerDropped', function()
    busy[source] = nil
end)

-- ===================== admin =====================

RegisterCommand(Config.AdminResetCommand, function(src, args)
    local target = tonumber(args[1])
    if not target or not GetPlayerName(target) then return end
    local id = Bridge.GetIdentifier(target)
    if not id then return end
    DeleteResourceKvp('dr:' .. id)

    local msg = L('reset_done', target)
    if src == 0 then print(msg) else TriggerClientEvent('dailyrewards:notify', src, msg, 'success') end
end, true)

-- ===================== exports =====================

exports('GetStreak', function(src)
    local s = getState(src)
    return s and s.streak or 0
end)

-- ===================== banner =====================

CreateThread(function()
    Wait(1500)
    if not Config.Branding.consoleBanner then return end
    print('^5==================================================^7')
    print(('^5  dailyrewards ^7v%s  |  framework: ^2%s^7'):format(GetResourceMetadata(GetCurrentResourceName(), 'version', 0), Bridge.name))
    print(('^3  by %s^7  ->  ^4%s^7'):format(Config.Branding.name, Config.Branding.url))
    print(('^7  %s'):format(Config.Branding.tagline))
    print('^5==================================================^7')
end)
