// Konfigurasi API
const API_BASE_URL = 'https://api.quran.com/api/v4';

// Fungsi untuk mendapatkan daftar surah
export async function getSurahList() {
    try {
        const response = await fetch(`${API_BASE_URL}/chapters?language=id`);
        const data = await response.json();
        return data.chapters;
    } catch (error) {
        console.error('Error fetching surah list:', error);
        return [];
    }
}

// Fungsi untuk mendapatkan ayat dari surah tertentu
export async function getAyahs(surahId, from = 1, to = 10) {
    try {
        const response = await fetch(`${API_BASE_URL}/verses/by_chapter/${surahId}?from=${from}&to=${to}&words=true&translations=33`);
        const data = await response.json();
        return data.verses;
    } catch (error) {
        console.error('Error fetching ayahs:', error);
        return [];
    }
}

// Fungsi untuk mendapatkan teks ayat tertentu
export async function getAyah(surahId, ayahId) {
    try {
        const response = await fetch(`${API_BASE_URL}/verses/by_key/${surahId}:${ayahId}?words=true&translations=33`);
        const data = await response.json();
        return data.verse;
    } catch (error) {
        console.error('Error fetching ayah:', error);
        return null;
    }
}

// Fungsi untuk mendapatkan daftar juz
export async function getJuzList() {
    try {
        const response = await fetch(`${API_BASE_URL}/juzs`);
        const data = await response.json();
        return data.juzs;
    } catch (error) {
        console.error('Error fetching juz list:', error);
        return [];
    }
}

// Fungsi untuk mendapatkan info jadwal sholat
export async function getPrayerTimes(latitude, longitude, date = new Date()) {
    try {
        const formattedDate = date.toISOString().split('T')[0];
        const response = await fetch(`${API_BASE_URL}/prayer_times?latitude=${latitude}&longitude=${longitude}&date=${formattedDate}`);
        const data = await response.json();
        return data.times;
    } catch (error) {
        console.error('Error fetching prayer times:', error);
        return null;
    }
}