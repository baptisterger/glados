
const DYSLEXIA_CLASS = 'dyslexia-mode';
const LOCAL_STORAGE_KEY = 'dyslexiaMode';
const BODY = document.body;

function isDarkBackground(color) {
    const rgb = color.match(/\d+/g);
    if (!rgb) return false;
    const r = parseInt(rgb[0], 10);
    const g = parseInt(rgb[1], 10);
    const b = parseInt(rgb[2], 10);
    const luminance = 0.299*r + 0.587*g + 0.114*b;
    return luminance < 128;
}

function updateTextColor() {
    const bgColor = window.getComputedStyle(BODY).backgroundColor;
    const textColor = isDarkBackground(bgColor) ? '#FFFFFF' : '#111111';

    BODY.style.color = textColor;
    const elements = BODY.querySelectorAll('p, li, pre, code, span, div');
    elements.forEach(el => el.style.color = textColor);
}

function toggleDyslexiaMode() {
    BODY.classList.toggle(DYSLEXIA_CLASS);
    const enabled = BODY.classList.contains(DYSLEXIA_CLASS);
    localStorage.setItem(LOCAL_STORAGE_KEY, enabled ? 'enabled' : 'disabled');
    BODY.style.backgroundColor = enabled ? '#FFFFFF' : '';
    updateTextColor();
}

let voicesLoaded = false;

function getFrenchVoice() {
    const voices = window.speechSynthesis.getVoices();
    if (!voices || voices.length === 0) return null;

    const googleFr = voices.find(v => /Google.*fr/i.test(v.name));
    if (googleFr) return googleFr;

    return voices.find(v => /fr/i.test(v.lang)) || voices[0];
}

function speakPage() {
    if (!('speechSynthesis' in window)) {
        alert("Lecture vocale non supportée par votre navigateur");
        return;
    }

    window.speechSynthesis.cancel();

    const textContent = Array.from(BODY.querySelectorAll('p, li, pre, code'))
                             .map(el => el.innerText)
                             .join('. ');

    const utterance = new SpeechSynthesisUtterance(textContent);
    utterance.lang = 'fr-FR';
    utterance.rate = 1.0;
    utterance.pitch = 1.0;

    const voice = getFrenchVoice();
    if (voice) utterance.voice = voice;

    window.speechSynthesis.speak(utterance);
}

function createToolbarButtons() {
    const toolbar = document.querySelector('.menu-bar');
    if (!toolbar) return;

    const dyslexiaBtn = document.createElement('a');
    dyslexiaBtn.textContent = 'Mode Dys';
    dyslexiaBtn.title = 'Activer/Désactiver le mode dyslexie';
    dyslexiaBtn.style.cursor = 'pointer';
    dyslexiaBtn.style.padding = '0 8px';
    dyslexiaBtn.onclick = toggleDyslexiaMode;

    const speakBtn = document.createElement('a');
    speakBtn.textContent = '🔊';
    speakBtn.title = 'Lire la page à voix haute';
    speakBtn.style.cursor = 'pointer';
    speakBtn.style.padding = '0 8px';
    speakBtn.onclick = speakPage;

    const last = toolbar.children[toolbar.children.length - 1];
    toolbar.insertBefore(dyslexiaBtn, last);
    toolbar.insertBefore(speakBtn, last);
}

window.addEventListener('load', () => {
    if (localStorage.getItem(LOCAL_STORAGE_KEY) === 'enabled') {
        BODY.classList.add(DYSLEXIA_CLASS);
        BODY.style.backgroundColor = '#FFFFFF';
    }

    function initVoices() {
        const voices = window.speechSynthesis.getVoices();
        if (voices.length === 0 && !voicesLoaded) {
            window.speechSynthesis.onvoiceschanged = () => {
                voicesLoaded = true;
            };
        }
    }
    initVoices();

    createToolbarButtons();
    updateTextColor();
});
