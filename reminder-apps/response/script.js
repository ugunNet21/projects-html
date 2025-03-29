// script.js
let startButton = document.getElementById('startButton');
let resetButton = document.getElementById('resetButton');
let message = document.getElementById('message');
let dismissButton = document.getElementById('dismissButton');
let timerElement = document.getElementById('timer');
let timeLeftElement = document.getElementById('timeLeft');
let intervalSelect = document.getElementById('interval');
let addCustomIntervalButton = document.getElementById('addCustomInterval');
let customIntervalContainer = document.querySelector('.custom-interval');
let customValueInput = document.getElementById('customValue');
let saveCustomIntervalButton = document.getElementById('saveCustomInterval');
let alertSound = document.getElementById('alertSound');

let countdownInterval;
let totalTime;
let remainingTime;

// Load interval dari localStorage jika ada
window.addEventListener('load', () => {
    const savedInterval = localStorage.getItem('reminderInterval');
    if (savedInterval) {
        intervalSelect.value = savedInterval;
    }
});

// Simpan interval pilihan ke localStorage
intervalSelect.addEventListener('change', () => {
    localStorage.setItem('reminderInterval', intervalSelect.value);
});

// Fungsi untuk memulai pengingat
function startReminder() {
    startButton.style.display = 'none';
    resetButton.style.display = 'block';
    timerElement.style.display = 'block';

    totalTime = parseInt(intervalSelect.value) * 60; // dalam detik
    remainingTime = totalTime;

    countdownInterval = setInterval(updateTimer, 1000);
}

// Fungsi untuk mengupdate timer setiap detik
function updateTimer() {
    if (remainingTime > 0) {
        remainingTime--;
        let minutes = Math.floor(remainingTime / 60);
        let seconds = remainingTime % 60;
        timeLeftElement.textContent = `${formatTime(minutes)}:${formatTime(seconds)}`;
    } else {
        clearInterval(countdownInterval);
        message.style.display = 'block';
        alertSound.play();
    }
}

// Fungsi untuk format waktu dalam bentuk mm:ss
function formatTime(time) {
    return time < 10 ? `0${time}` : time;
}

// Fungsi untuk menutup pesan pengingat
dismissButton.addEventListener('click', () => {
    message.style.display = 'none';
});

// Fungsi untuk menambah custom interval
addCustomIntervalButton.addEventListener('click', () => {
    customIntervalContainer.style.display = 'block';
});

// Fungsi untuk menyimpan custom interval
saveCustomIntervalButton.addEventListener('click', () => {
    const customValue = customValueInput.value;
    if (customValue && customValue > 0) {
        const option = document.createElement('option');
        option.value = customValue;
        option.textContent = `${customValue} menit`;
        intervalSelect.appendChild(option);
        intervalSelect.value = customValue;

        // Sembunyikan input custom
        customIntervalContainer.style.display = 'none';
        customValueInput.value = '';
    }
});

// Fungsi untuk reset aplikasi
resetButton.addEventListener('click', () => {
    clearInterval(countdownInterval);
    startButton.style.display = 'block';
    resetButton.style.display = 'none';
    timerElement.style.display = 'none';
    timeLeftElement.textContent = '00:00';
});

// Event listener untuk tombol mulai
startButton.addEventListener('click', startReminder);
