let startButton = document.getElementById('startButton');
let message = document.getElementById('message');
let dismissButton = document.getElementById('dismissButton');
let timerElement = document.getElementById('timer');
let timeLeftElement = document.getElementById('timeLeft');
let intervalSelect = document.getElementById('interval');
let alertSound = document.getElementById('alertSound');

let reminderInterval;
let countdownInterval;
let totalTime;
let remainingTime;

// Fungsi untuk memulai pengingat
function startReminder() {
    // Menyembunyikan tombol mulai dan menampilkan timer
    startButton.style.display = 'none';
    timerElement.style.display = 'block';

    // Mengambil interval waktu dari pilihan pengguna
    totalTime = parseInt(intervalSelect.value) * 60; // dalam detik
    remainingTime = totalTime;

    // Memulai countdown
    countdownInterval = setInterval(updateTimer, 1000); // update setiap detik
}

// Fungsi untuk mengupdate timer setiap detik
function updateTimer() {
    if (remainingTime > 0) {
        remainingTime--;
        let minutes = Math.floor(remainingTime / 60);
        let seconds = remainingTime % 60;
        timeLeftElement.textContent = `${formatTime(minutes)}:${formatTime(seconds)}`;
    } else {
        // Ketika waktu habis, tampilkan pengingat dan putar suara
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
    startButton.style.display = 'block'; // Menampilkan tombol mulai lagi
});

// Event listener untuk tombol mulai
startButton.addEventListener('click', () => {
    startReminder();
});
