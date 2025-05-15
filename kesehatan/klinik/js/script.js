document.addEventListener('DOMContentLoaded', function() {
    // Initialize Appointments Chart
    try {
        const appointmentsCtx = document.getElementById('appointmentsChart').getContext('2d');
        const appointmentsChart = new Chart(appointmentsCtx, {
            type: 'line',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [{
                    label: 'Appointments',
                    data: [12, 19, 15, 22, 18, 10, 7],
                    backgroundColor: 'rgba(78, 115, 223, 0.05)',
                    borderColor: 'rgba(78, 115, 223, 1)',
                    borderWidth: 2,
                    pointBackgroundColor: 'rgba(78, 115, 223, 1)',
                    pointBorderColor: '#fff',
                    pointHoverRadius: 5,
                    pointHoverBackgroundColor: 'rgba(78, 115, 223, 1)',
                    pointHoverBorderColor: '#fff',
                    pointHitRadius: 10,
                    pointBorderWidth: 2,
                    tension: 0.3
                }]
            },
            options: {
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        },
                        ticks: {
                            color: '#fff'
                        }
                    },
                    x: {
                        grid: {
                            color: 'rgba(255, 255, 255, 0.1)'
                        },
                        ticks: {
                            color: '#fff'
                        }
                    }
                }
            }
        });
    } catch (error) {
        console.error('Error initializing chart:', error);
    }

    // Toggle Sidebar
    const toggleSidebar = document.querySelectorAll('.toggle-sidebar');
    toggleSidebar.forEach(btn => {
        btn.addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });
    });

    // Toggle Theme
    const themeToggle = document.querySelector('.theme-toggle');
    themeToggle.addEventListener('click', function() {
        document.body.classList.toggle('light-theme');
        document.body.classList.toggle('dark-theme');
        
        const icon = this.querySelector('i');
        const span = this.querySelector('span');
        if (document.body.classList.contains('light-theme')) {
            icon.classList.remove('fa-moon');
            icon.classList.add('fa-sun');
            span.textContent = 'Light Mode';
        } else {
            icon.classList.remove('fa-sun');
            icon.classList.add('fa-moon');
            span.textContent = 'Dark Mode';
        }
    });

    // Toggle Notifications Dropdown
    const notificationBtn = document.querySelector('.notification-btn');
    const notificationDropdown = document.querySelector('.notification-dropdown');
    notificationBtn.addEventListener('click', function(e) {
        e.stopPropagation();
        notificationDropdown.classList.toggle('show');
        document.querySelector('.user-dropdown-menu').classList.remove('show');
    });

    // Toggle User Dropdown
    const userBtn = document.querySelector('.user-btn');
    const userDropdown = document.querySelector('.user-dropdown-menu');
    userBtn.addEventListener('click', function(e) {
        e.stopPropagation();
        userDropdown.classList.toggle('show');
        notificationDropdown.classList.remove('show');
    });

    // Close Dropdowns on Outside Click
    document.addEventListener('click', function() {
        notificationDropdown.classList.remove('show');
        userDropdown.classList.remove('show');
    });

    // Prevent Dropdowns from Closing When Clicking Inside
    notificationDropdown.addEventListener('click', function(e) {
        e.stopPropagation();
    });
    userDropdown.addEventListener('click', function(e) {
        e.stopPropagation();
    });

    // Responsive Sidebar for Mobile
    function handleResponsiveSidebar() {
        if (window.innerWidth <= 768) {
            document.getElementById('sidebar').classList.add('collapsed');
            document.querySelector('.main-content').classList.add('expanded');
        }
    }

    window.addEventListener('resize', handleResponsiveSidebar);
    handleResponsiveSidebar();

    // Placeholder for Search Functionality
    const searchInput = document.querySelector('.search-box input');
    searchInput.addEventListener('input', function() {
        // Implement search logic here
        console.log('Search query:', this.value);
    });
});