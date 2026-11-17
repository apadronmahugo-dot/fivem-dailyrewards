Config = {}

-- 'es' o 'en'
Config.Locale = 'es'

-- Comando para abrir el menú y tecla por defecto (false para desactivar la tecla)
Config.Command = 'recompensas'
Config.Keybind = 'F7'

-- true  = la racha va por personaje (citizenid / identifier del framework)
-- false = la racha va por cuenta de Rockstar (license)
Config.PerCharacter = true

-- Si el jugador se salta un día, la racha vuelve al día 1
Config.ResetStreakOnMiss = true

-- Avisar al entrar al servidor si tiene una recompensa pendiente
Config.NotifyOnJoin = true

-- Comando de admin para reiniciar la racha de un jugador: /dr_reset <id>
-- Permiso: add_ace group.admin command.dr_reset allow
Config.AdminResetCommand = 'dr_reset'

-- ============================================================
--  BRANDING (aquí va tu canal 👇)
-- ============================================================
Config.Branding = {
    name          = 'Nexo Scripts',                       -- tu marca
    url           = 'nexoscripts.net',           -- link que se muestra
    tagline       = '▶ YouTube: @nexostorenet',
    showInUI      = true,                             -- footer en el menú
    consoleBanner = true,                             -- banner en la consola al iniciar
}

-- ============================================================
--  RECOMPENSAS
--  El ciclo dura tantos días como entradas tenga la tabla.
--  Tipos:
--    { type = 'money',  account = 'cash' | 'bank', amount = 500 }
--    { type = 'item',   name = 'water', amount = 5, label = 'Agua' }
--    { type = 'custom', event = 'mi_script:darVip', label = 'VIP 1 día', icon = '👑', data = {...} }
--       -> dispara TriggerEvent(event, source, data) en el servidor
-- ============================================================
Config.Rewards = {
    { rewards = { { type = 'money', account = 'cash', amount = 500 } } },
    { rewards = { { type = 'item',  name = 'water',  amount = 5, label = 'Agua' } } },
    { rewards = { { type = 'money', account = 'cash', amount = 1000 } } },
    { rewards = { { type = 'item',  name = 'sandwich', amount = 5, label = 'Sándwich' } } },
    { rewards = { { type = 'money', account = 'bank', amount = 2500 } } },
    { rewards = { { type = 'item',  name = 'bandage', amount = 3, label = 'Venda' } } },
    {
        highlight = true, -- carta dorada
        rewards = {
            { type = 'money', account = 'bank', amount = 10000 },
            { type = 'item',  name = 'phone', amount = 1, label = 'Teléfono' },
        }
    },
}

-- ============================================================
--  STANDALONE (solo si no usas ESX / QBCore / QBox)
--  Conecta aquí tu propio sistema de dinero / items.
-- ============================================================
Config.Standalone = {
    AddMoney = function(source, account, amount)
        print(('[dailyrewards] Standalone: dar $%s (%s) a %s -> configura Config.Standalone.AddMoney'):format(amount, account, source))
        return true
    end,
    AddItem = function(source, item, amount)
        print(('[dailyrewards] Standalone: dar %sx %s a %s -> configura Config.Standalone.AddItem'):format(amount, item, source))
        return true
    end,
}
