import {
  getAyah,
  getJuzList,
  getSurahList,
} from './api.js';
import {
  addBookmark,
  formatArabicText,
  formatSurahAyah,
  getBookmarks,
  getLastRead,
  saveLastRead,
} from './utils.js';

// Variabel state aplikasi
let currentState = {
    activeTab: 'surah',
    currentSurah: null,
    currentAyah: null,
    surahList: [],
    juzList: [],
    bookmarks: []
};

// Inisialisasi aplikasi
document.addEventListener('DOMContentLoaded', async () => {
    // Load data awal
    currentState.surahList = await getSurahList();
    currentState.juzList = await getJuzList();
    currentState.bookmarks = getBookmarks();
    
    // Set last read jika ada
    const lastRead = getLastRead();
    if (lastRead) {
        await loadAyah(lastRead.surahId, lastRead.ayahId);
    } else {
        // Default ke surah pertama ayat pertama
        await loadAyah(1, 1);
    }
    
    // Setup event listeners
    setupEventListeners();
    
    // Render initial view
    render();
});

// Setup event listeners
function setupEventListeners() {
    // Tab navigation
    document.getElementById('tab-surah').addEventListener('click', () => switchTab('surah'));
    document.getElementById('tab-juz').addEventListener('click', () => switchTab('juz'));
    document.getElementById('tab-bookmark').addEventListener('click', () => switchTab('bookmark'));
    
    // Ayah navigation
    document.getElementById('prev-ayat').addEventListener('click', prevAyah);
    document.getElementById('next-ayat').addEventListener('click', nextAyah);
    
    // Ayah modal
    document.getElementById('cancel-ayat').addEventListener('click', () => {
        document.getElementById('ayat-modal').classList.add('hidden');
    });
    
    // Bookmark button
    document.querySelector('[aria-label="Bookmark"]').addEventListener('click', toggleBookmark);
}

// Fungsi untuk mengganti tab
function switchTab(tab) {
    currentState.activeTab = tab;
    render();
}

// Fungsi untuk memuat ayat
async function loadAyah(surahId, ayahId) {
    const ayah = await getAyah(surahId, ayahId);
    if (ayah) {
        currentState.currentAyah = ayah;
        currentState.currentSurah = currentState.surahList.find(s => s.id === surahId);
        saveLastRead(surahId, ayahId);
        render();
    }
}

// Fungsi untuk ke ayat sebelumnya
function prevAyah() {
    if (currentState.currentAyah && currentState.currentAyah.verse_number > 1) {
        loadAyah(currentState.currentSurah.id, currentState.currentAyah.verse_number - 1);
    }
}

// Fungsi untuk ke ayat berikutnya
function nextAyah() {
    if (currentState.currentAyah && currentState.currentAyah.verse_number < currentState.currentSurah.verses_count) {
        loadAyah(currentState.currentSurah.id, currentState.currentAyah.verse_number + 1);
    }
}

// Fungsi untuk toggle bookmark
function toggleBookmark() {
    if (currentState.currentAyah && currentState.currentSurah) {
        addBookmark(currentState.currentSurah.id, currentState.currentAyah.verse_number);
        currentState.bookmarks = getBookmarks();
        render();
    }
}

// Fungsi render utama
function render() {
    // Render tab content
    document.getElementById('surah-view').classList.toggle('hidden', currentState.activeTab !== 'surah');
    document.getElementById('juz-view').classList.toggle('hidden', currentState.activeTab !== 'juz');
    document.getElementById('bookmark-view').classList.toggle('hidden', currentState.activeTab !== 'bookmark');
    
    // Render active tab indicator
    document.getElementById('tab-surah').classList.toggle('text-green-600', currentState.activeTab === 'surah');
    document.getElementById('tab-surah').classList.toggle('text-gray-500', currentState.activeTab !== 'surah');
    document.getElementById('tab-surah').classList.toggle('border-b-2', currentState.activeTab === 'surah');
    document.getElementById('tab-surah').classList.toggle('border-green-600', currentState.activeTab === 'surah');
    
    document.getElementById('tab-juz').classList.toggle('text-green-600', currentState.activeTab === 'juz');
    document.getElementById('tab-juz').classList.toggle('text-gray-500', currentState.activeTab !== 'juz');
    document.getElementById('tab-juz').classList.toggle('border-b-2', currentState.activeTab === 'juz');
    document.getElementById('tab-juz').classList.toggle('border-green-600', currentState.activeTab === 'juz');
    
    document.getElementById('tab-bookmark').classList.toggle('text-green-600', currentState.activeTab === 'bookmark');
    document.getElementById('tab-bookmark').classList.toggle('text-gray-500', currentState.activeTab !== 'bookmark');
    document.getElementById('tab-bookmark').classList.toggle('border-b-2', currentState.activeTab === 'bookmark');
    document.getElementById('tab-bookmark').classList.toggle('border-green-600', currentState.activeTab === 'bookmark');
    
    // Render content berdasarkan tab aktif
    if (currentState.activeTab === 'surah') {
        renderSurahView();
    } else if (currentState.activeTab === 'juz') {
        renderJuzView();
    } else if (currentState.activeTab === 'bookmark') {
        renderBookmarkView();
    }
}

// Render surah view
function renderSurahView() {
    if (!currentState.currentAyah || !currentState.currentSurah) return;
    
    const surahContent = document.getElementById('surah-content');
    surahContent.innerHTML = `
        <div class="mb-6">
            <p class="text-right text-2xl mb-4 font-arabic">${formatArabicText(currentState.currentAyah.text_uthmani)}</p>
            <p class="text-gray-600 mb-2">${currentState.currentAyah.translations[0].text}</p>
            <p class="text-sm text-gray-500 mt-4">${formatSurahAyah(currentState.currentSurah.name_simple, currentState.currentAyah.verse_number)}</p>
        </div>
    `;
}

// Render juz view
function renderJuzView() {
    const juzView = document.getElementById('juz-view');
    juzView.innerHTML = `
        <div class="space-y-2">
            ${currentState.juzList.slice(0, 10).map(juz => `
                <div class="p-3 border rounded">
                    <h3 class="font-bold">Juz ${juz.juz_number}</h3>
                    <p class="text-sm text-gray-600">MULAI DI: ${juz.verse_mapping.split(',')[0].toUpperCase()}</p>
                </div>
            `).join('')}
        </div>
    `;
}

// Render bookmark view
function renderBookmarkView() {
    const bookmarkView = document.getElementById('bookmark-view');
    
    if (currentState.bookmarks.length === 0) {
        bookmarkView.innerHTML = `
            <div class="text-center py-8">
                <p class="mb-4">Masuk dengan Google untuk menyimpan otomatis data Terakhir Baca dan Bookmark Anda ke Cloud kami.</p>
                <button class="bg-blue-500 text-white px-4 py-2 rounded flex items-center mx-auto">
                    <i class="fab fa-google mr-2"></i> Masuk Google
                </button>
            </div>
        `;
    } else {
        bookmarkView.innerHTML = `
            <div class="space-y-2">
                ${currentState.bookmarks.map(bookmark => {
                    const surah = currentState.surahList.find(s => s.id === bookmark.surahId);
                    return `
                        <div class="p-3 border rounded">
                            <h3 class="font-bold">${surah ? surah.name_simple : 'Unknown'}</h3>
                            <p class="text-sm">Ayat ${bookmark.ayahId}</p>
                        </div>
                    `;
                }).join('')}
            </div>
        `;
    }
    
    // Render last read
    const lastRead = getLastRead();
    if (lastRead) {
        const surah = currentState.surahList.find(s => s.id === lastRead.surahId);
        bookmarkView.innerHTML += `
            <div class="border-t pt-4 mt-4">
                <h3 class="font-bold mb-2">Terakhir Baca</h3>
                <p class="text-sm">${surah ? surah.name_simple : 'Unknown'} ${lastRead.ayahId}: Ayat ${lastRead.ayahId}</p>
            </div>
        `;
    }
}