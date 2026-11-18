const RES = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'nexo_recompensas';
const $ = (id) => document.getElementById(id);

let data = null;
let timerInterval = null;
let resetAt = 0;

const FALLBACK_ICONS = { money: '💵', bank: '🏦', item: '📦', custom: '✨' };

function post(name, body = {}) {
    return fetch(`https://${RES}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
    }).catch(() => {});
}

function t(key, ...args) {
    let str = (data && data.locale && data.locale[key]) || key;
    args.forEach((a) => (str = str.replace('%s', a)));
    return str;
}

function iconFor(item) {
    if (item.icon) return `<div class="icon">${item.icon}</div>`;
    if (item.type === 'money') return `<div class="icon">${item.account === 'bank' ? FALLBACK_ICONS.bank : FALLBACK_ICONS.money}</div>`;
    if (item.type === 'item' && data.imagePath) {
        return `<div class="icon"><img src="${data.imagePath}${item.name}.png" onerror="this.parentNode.innerHTML='${FALLBACK_ICONS.item}'"></div>`;
    }
    return `<div class="icon">${FALLBACK_ICONS[item.type] || '🎁'}</div>`;
}

function render(justClaimedDay) {
    const { state, rewards } = data;
    const grid = $('grid');
    grid.innerHTML = '';

    rewards.forEach((r) => {
        const card = document.createElement('div');
        card.className = 'card';
        if (r.highlight) card.classList.add('big');

        if (r.day <= state.claimedInCycle) card.classList.add('claimed');
        else if (r.day === state.claimedInCycle + 1 && !state.claimedToday) card.classList.add('available');
        else card.classList.add('locked');

        if (r.day === justClaimedDay) card.classList.add('just-claimed');

        card.innerHTML = `
            ${r.day <= state.claimedInCycle ? '<div class="badge">✓</div>' : ''}
            <div class="day">${t('day', r.day)}</div>
            <div class="icons">${r.items.map(iconFor).join('')}</div>
            <div class="rewards">${r.items.map((i) => `<span>${i.text}</span>`).join('')}</div>
        `;
        grid.appendChild(card);
    });

    $('streak').textContent = `${state.streak} ${t('days')}`;
    $('total').textContent = state.total;
    $('progress').style.width = `${(state.claimedInCycle / rewards.length) * 100}%`;

    const btn = $('claim');
    if (state.claimedToday) {
        btn.classList.add('hidden');
        $('countdown').classList.remove('hidden');
        startTimer(state.resetIn);
    } else {
        btn.classList.remove('hidden');
        btn.disabled = false;
        $('countdown').classList.add('hidden');
    }
}

function startTimer(seconds) {
    clearInterval(timerInterval);
    resetAt = Date.now() + seconds * 1000;
    const tick = () => {
        const left = Math.max(0, Math.floor((resetAt - Date.now()) / 1000));
        const h = String(Math.floor(left / 3600)).padStart(2, '0');
        const m = String(Math.floor((left % 3600) / 60)).padStart(2, '0');
        const s = String(left % 60).padStart(2, '0');
        $('timer').textContent = `${h}:${m}:${s}`;
        if (left === 0) {
            clearInterval(timerInterval);
            data.state.claimedToday = false;
            render();
        }
    };
    tick();
    timerInterval = setInterval(tick, 1000);
}

function confetti(fromEl) {
    const rect = fromEl.getBoundingClientRect();
    const colors = ['#f5b942', '#ffd77a', '#3ddc84', '#ffffff', '#ff6b6b'];
    for (let i = 0; i < 60; i++) {
        const c = document.createElement('div');
        c.className = 'confetti';
        c.style.left = `${rect.left + rect.width / 2}px`;
        c.style.top = `${rect.top + rect.height / 2}px`;
        c.style.background = colors[i % colors.length];
        c.style.setProperty('--x', `${(Math.random() - 0.5) * 600}px`);
        c.style.setProperty('--y', `${(Math.random() - 0.2) * 500}px`);
        c.style.setProperty('--r', `${Math.random() * 720}deg`);
        document.body.appendChild(c);
        setTimeout(() => c.remove(), 1500);
    }
}

function applyTexts() {
    $('t-title').textContent = t('title');
    $('t-subtitle').textContent = t('subtitle');
    $('t-streak').textContent = t('streak');
    $('t-total').textContent = t('total');
    $('t-comeback').textContent = t('come_back');
    $('claim').textContent = t('claim');
    $('close').title = t('close');

    const b = data.branding || {};
    $('branding').classList.toggle('hidden', !b.showInUI);
    $('b-name').textContent = b.name || '';
    $('b-url').textContent = b.url || '';
    $('b-tag').textContent = b.tagline || '';
}

function open(payload) {
    data = payload;
    applyTexts();
    render();
    $('app').classList.remove('hidden');
}

function close() {
    $('app').classList.add('hidden');
    clearInterval(timerInterval);
    post('close');
}

window.addEventListener('message', (e) => {
    const msg = e.data;
    if (msg.action === 'open') open(msg.payload);
    if (msg.action === 'close') $('app').classList.add('hidden');
    if (msg.action === 'update' && data) {
        const prev = data.state.claimedInCycle;
        data.state = msg.state;
        const claimedDay = msg.state.claimedInCycle !== prev ? msg.state.claimedInCycle : null;
        render(claimedDay);
        const el = document.querySelector('.card.just-claimed');
        if (el) confetti(el);
    }
});

$('claim').addEventListener('click', () => {
    $('claim').disabled = true;
    post('claim');
});
$('close').addEventListener('click', close);
document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape' && !$('app').classList.contains('hidden')) close();
});
