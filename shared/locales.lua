Locales = {
    es = {
        title          = 'Recompensas Diarias',
        subtitle       = 'Entra cada día y no rompas la racha',
        day            = 'Día %s',
        claim          = 'Reclamar',
        claimed        = 'Reclamado',
        come_back      = 'Vuelve en',
        streak         = 'Racha',
        total          = 'Total reclamadas',
        days           = 'días',
        close          = 'Cerrar',
        cash           = 'efectivo',
        bank           = 'banco',
        notify_ready   = '¡Tienes una recompensa diaria disponible! Usa /%s',
        notify_claimed = 'Has reclamado la recompensa del día %s',
        already        = 'Ya reclamaste la recompensa de hoy',
        not_loaded     = 'Tu personaje aún no ha cargado',
        reset_done     = 'Racha reiniciada para el jugador %s',
        keybind_desc   = 'Abrir recompensas diarias',
    },
    en = {
        title          = 'Daily Rewards',
        subtitle       = 'Log in every day and keep your streak alive',
        day            = 'Day %s',
        claim          = 'Claim',
        claimed        = 'Claimed',
        come_back      = 'Come back in',
        streak         = 'Streak',
        total          = 'Total claimed',
        days           = 'days',
        close          = 'Close',
        cash           = 'cash',
        bank           = 'bank',
        notify_ready   = 'You have a daily reward available! Use /%s',
        notify_claimed = 'You claimed the day %s reward',
        already        = 'You already claimed today\'s reward',
        not_loaded     = 'Your character has not loaded yet',
        reset_done     = 'Streak reset for player %s',
        keybind_desc   = 'Open daily rewards',
    },
}

function L(key, ...)
    local lang = Locales[Config.Locale] or Locales.en
    local str = lang[key] or Locales.en[key] or key
    if select('#', ...) > 0 then return str:format(...) end
    return str
end
