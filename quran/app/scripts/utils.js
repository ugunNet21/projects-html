// Fungsi untuk memformat teks Arab
export function formatArabicText(text) {
    return text.replace(/\s+/g, ' ').trim();
}

// Fungsi untuk memformat nomor surah dan ayat
export function formatSurahAyah(surahNumber, ayahNumber) {
    return `QS. ${surahNumber}:${ayahNumber}`;
}

// Fungsi untuk menyimpan last read ke localStorage
export function saveLastRead(surahId, ayahId) {
    localStorage.setItem('lastRead', JSON.stringify({ surahId, ayahId }));
}

// Fungsi untuk mendapatkan last read dari localStorage
export function getLastRead() {
    const lastRead = localStorage.getItem('lastRead');
    return lastRead ? JSON.parse(lastRead) : null;
}

// Fungsi untuk menambahkan bookmark
export function addBookmark(surahId, ayahId) {
    const bookmarks = getBookmarks();
    const newBookmark = { surahId, ayahId, timestamp: Date.now() };
    
    // Cek apakah sudah ada bookmark yang sama
    const existingIndex = bookmarks.findIndex(
        b => b.surahId === surahId && b.ayahId === ayahId
    );
    
    if (existingIndex >= 0) {
        bookmarks[existingIndex] = newBookmark;
    } else {
        bookmarks.push(newBookmark);
    }
    
    localStorage.setItem('bookmarks', JSON.stringify(bookmarks));
}

// Fungsi untuk mendapatkan semua bookmark
export function getBookmarks() {
    const bookmarks = localStorage.getItem('bookmarks');
    return bookmarks ? JSON.parse(bookmarks) : [];
}

// Fungsi untuk menghapus bookmark
export function removeBookmark(surahId, ayahId) {
    const bookmarks = getBookmarks().filter(
        b => !(b.surahId === surahId && b.ayahId === ayahId)
    );
    localStorage.setItem('bookmarks', JSON.stringify(bookmarks));
}