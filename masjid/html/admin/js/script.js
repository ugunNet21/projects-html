document.addEventListener("DOMContentLoaded", function() {
    // Sidebar toggle
    const sidebarToggle = document.body.querySelector("#sidebarToggle");
    if (sidebarToggle) {
        sidebarToggle.addEventListener("click", function(event) {
            event.preventDefault();
            document.body.querySelector("#wrapper").classList.toggle("toggled");
        });
    }

    // Logic untuk memuat konten halaman dinamis ke #main-content
    // Ini bisa menggunakan fetch API atau library seperti jQuery.ajax
    // Contoh sederhana (bukan untuk produksi, hanya ilustrasi):
    const navLinks = document.querySelectorAll("#sidebar-wrapper .list-group-item[href$='.html']");

    navLinks.forEach(link => {
        link.addEventListener("click", function(e) {
            e.preventDefault();
            const pageUrl = this.getAttribute("href");

            // Hapus kelas active dari semua link
            navLinks.forEach(l => l.classList.remove("active"));
            // Tambah kelas active ke link yang diklik
            this.classList.add("active");
             // Jika ada submenu, atur parentnya juga
            if (this.closest('.collapse')) {
                const parentToggle = document.querySelector(`[data-bs-target="#${this.closest('.collapse').id}"]`);
                if (parentToggle) parentToggle.classList.add('active');
            }


            fetch(pageUrl)
                .then(response => response.text())
                .then(html => {
                    const parser = new DOMParser();
                    const doc = parser.parseFromString(html, "text/html");
                    const newContent = doc.querySelector("#main-content-page"); // Asumsikan konten halaman ada di div ini
                    if (newContent) {
                        document.getElementById("main-content").innerHTML = newContent.innerHTML;
                        // Re-initialize any JS components if needed (e.g., datatables, datepickers)
                        // Contoh: if (typeof initializeDataTables === 'function') initializeDataTables();
                    } else {
                         document.getElementById("main-content").innerHTML = `<h1>Konten tidak ditemukan atau format salah</h1><p>Pastikan file ${pageUrl} memiliki elemen dengan id="main-content-page" yang membungkus kontennya.</p>`;
                    }
                })
                .catch(error => {
                    console.error("Error loading page:", error);
                    document.getElementById("main-content").innerHTML = "<h1>Gagal memuat halaman.</h1>";
                });
        });
    });
});