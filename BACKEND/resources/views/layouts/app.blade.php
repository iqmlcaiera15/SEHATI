<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <title>SEHATI - Debug Mode</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    
    <!-- Custom styles inline -->
    <style>
        .sb-nav-fixed {
            padding-top: 0;
        }
        
        .navbar-brand {
            font-weight: 700;
        }
        
        .nav-link.active {
            background-color: rgba(255, 255, 255, 0.1);
            border-radius: 4px;
        }
        
        .dropdown-menu {
            border: none;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
        }
        
        .dropdown-item:hover {
            background-color: #f8f9fa;
        }
        
        main {
            min-height: calc(100vh - 300px);
        }
        
        footer {
            margin-top: auto;
        }
        
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        
        .shadow-sm {
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075) !important;
        }
        
        .sticky-top {
            position: sticky;
            top: 0;
            z-index: 1020;
        }
        
        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
        }
        
        ::-webkit-scrollbar-track {
            background: #f1f1f1;
        }
        
        ::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 4px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: #a8a8a8;
        }
        
        /* Responsive improvements */
        @media (max-width: 768px) {
            .navbar-nav .nav-link {
                padding: 0.5rem 1rem;
            }
            
            .container-fluid {
                padding-left: 1rem;
                padding-right: 1rem;
            }
        }
        
        /* Animation for dropdown */
        .dropdown-menu {
            animation: dropdownAnimation 0.3s ease-out;
        }
        
        @keyframes dropdownAnimation {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        /* Loading indicator */
        .loading {
            opacity: 0.6;
            pointer-events: none;
        }
        
        /* Button hover effects */
        .btn {
            transition: all 0.2s ease-in-out;
        }
        
        .btn:hover {
            transform: translateY(-1px);
        }
        
        /* Card improvements */
        .card {
            transition: box-shadow 0.15s ease-in-out;
        }
        
        .card:hover {
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        }

        /* Debug Console Styles */
        #debug-console {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            height: 200px;
            background: #1a1a1a;
            border-top: 2px solid #dc3545;
            z-index: 1050;
            transform: translateY(100%);
            transition: transform 0.3s ease-in-out;
            font-family: 'Courier New', monospace;
        }

        #debug-console.show {
            transform: translateY(0);
        }

        .console-header {
            background: #2d2d2d;
            padding: 8px 15px;
            border-bottom: 1px solid #444;
            display: flex;
            justify-content: between;
            align-items: center;
            color: white;
            font-size: 12px;
        }

        .console-content {
            height: calc(100% - 35px);
            overflow-y: auto;
            padding: 10px 15px;
            color: #fff;
            font-size: 11px;
        }

        .console-log {
            margin: 2px 0;
            padding: 2px 0;
        }

        .console-error {
            color: #ff6b6b;
        }

        .console-warn {
            color: #feca57;
        }

        .console-info {
            color: #48dbfb;
        }

        .console-debug {
            color: #ff9ff3;
        }

        .console-toggle {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 1051;
            background: #dc3545;
            border: none;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            color: white;
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.4);
            transition: all 0.3s ease;
        }

        .console-toggle:hover {
            background: #c82333;
            transform: scale(1.1);
        }

        .console-toggle.has-errors {
            animation: pulse-error 2s infinite;
        }

        @keyframes pulse-error {
            0% { box-shadow: 0 4px 12px rgba(220, 53, 69, 0.4); }
            50% { box-shadow: 0 4px 20px rgba(220, 53, 69, 0.8); }
            100% { box-shadow: 0 4px 12px rgba(220, 53, 69, 0.4); }
        }

        .clear-console {
            background: #495057;
            border: none;
            color: white;
            padding: 2px 8px;
            font-size: 10px;
            border-radius: 3px;
            margin-left: 10px;
        }

        .clear-console:hover {
            background: #6c757d;
        }

        /* Preview Mode Styles */
        .preview-mode {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px 0;
            text-align: center;
            font-size: 14px;
            position: sticky;
            top: 0;
            z-index: 1051;
        }

        .preview-mode .badge {
            margin-left: 10px;
        }

        /* Error notifications */
        .error-notification {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 1052;
            max-width: 350px;
            animation: slideIn 0.3s ease-out;
        }

        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
    </style>
</head>
<body class="sb-nav-fixed">

<!-- Preview Mode Banner -->
<div class="preview-mode">
    <i class="fas fa-eye me-2"></i>
    Preview Mode - Debug Console Active
    <span class="badge bg-warning text-dark" id="error-count">0 Errors</span>
</div>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top shadow-sm">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold d-flex align-items-center" href="#dashboard">
            <i class="fas fa-heartbeat me-2"></i> SEHATI
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#navbarContent" aria-controls="navbarContent"
                aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarContent">
            <!-- Left-aligned nav -->
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link active" href="#dashboard">
                        <i class="fas fa-chart-line me-1"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#patients">
                        <i class="fas fa-users me-1"></i> Patients
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#appointments">
                        <i class="fas fa-calendar-alt me-1"></i> Appointments
                    </a>
                </li>
            </ul>

            <!-- Right-aligned user dropdown -->
            <ul class="navbar-nav ms-auto">
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" id="navbarDropdown"
                       role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fas fa-user-circle me-1"></i> Dr. Sarah Ahmad
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdown">
                        <li><a class="dropdown-item" href="#profile">
                            <i class="fas fa-user me-2"></i>Profile
                        </a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <a class="dropdown-item" href="#logout" onclick="simulateLogout()">
                                <i class="fas fa-sign-out-alt me-2"></i>Logout
                            </a>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>

<main class="container mt-4">
    <div class="row">
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4">
                            <div class="card bg-info text-white mb-3">
                                <div class="card-body">
                                    <h4>125</h4>
                                    <p class="mb-0">Total Patients</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card bg-success text-white mb-3">
                                <div class="card-body">
                                    <h4>23</h4>
                                    <p class="mb-0">Today's Appointments</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card bg-warning text-white mb-3">
                                <div class="card-body">
                                    <h4>7</h4>
                                    <p class="mb-0">Pending Reviews</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Demo buttons to trigger errors -->
                    <div class="mt-4">
                        <h6>Debug Test Buttons:</h6>
                        <button class="btn btn-danger btn-sm me-2" onclick="triggerError()">
                            <i class="fas fa-bug me-1"></i>Trigger Error
                        </button>
                        <button class="btn btn-warning btn-sm me-2" onclick="triggerWarning()">
                            <i class="fas fa-exclamation-triangle me-1"></i>Trigger Warning
                        </button>
                        <button class="btn btn-info btn-sm me-2" onclick="triggerInfo()">
                            <i class="fas fa-info-circle me-1"></i>Log Info
                        </button>
                        <button class="btn btn-secondary btn-sm" onclick="simulateAsyncError()">
                            <i class="fas fa-clock me-1"></i>Async Error
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<footer class="py-4 bg-light mt-auto">
    <div class="container-fluid px-4">
        <div class="d-flex align-items-center justify-content-between small">
            <div class="text-muted">Copyright &copy; SEHATI 2025</div>
            <div>
                <a href="#" class="text-decoration-none">Privacy Policy</a>
                &middot;
                <a href="#" class="text-decoration-none">Terms &amp; Conditions</a>
            </div>
        </div>
    </div>
</footer>

<!-- Debug Console -->
<div id="debug-console">
    <div class="console-header">
        <span><i class="fas fa-terminal me-2"></i>Debug Console</span>
        <div>
            <button class="clear-console" onclick="clearConsole()">Clear</button>
            <button class="clear-console" onclick="toggleConsole()" style="margin-left: 5px;">Hide</button>
        </div>
    </div>
    <div class="console-content" id="console-content">
        <div class="console-log console-info">🏥 SEHATI Debug Console Initialized</div>
        <div class="console-log console-info">Ready for debugging...</div>
    </div>
</div>

<!-- Console Toggle Button -->
<button class="console-toggle" onclick="toggleConsole()" id="console-toggle">
    <i class="fas fa-terminal"></i>
</button>

<!-- Bootstrap JS Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Custom JavaScript -->
<script>
    let errorCount = 0;
    let consoleVisible = false;

    // Console management
    function toggleConsole() {
        const console = document.getElementById('debug-console');
        const toggleBtn = document.getElementById('console-toggle');
        
        consoleVisible = !consoleVisible;
        
        if (consoleVisible) {
            console.classList.add('show');
            toggleBtn.innerHTML = '<i class="fas fa-times"></i>';
        } else {
            console.classList.remove('show');
            toggleBtn.innerHTML = '<i class="fas fa-terminal"></i>';
        }
    }

    function clearConsole() {
        const content = document.getElementById('console-content');
        content.innerHTML = '<div class="console-log console-info">Console cleared...</div>';
        errorCount = 0;
        updateErrorCount();
        document.getElementById('console-toggle').classList.remove('has-errors');
    }

    function addToConsole(message, type = 'log') {
        const content = document.getElementById('console-content');
        const timestamp = new Date().toLocaleTimeString();
        const logEntry = document.createElement('div');
        logEntry.className = `console-log console-${type}`;
        
        let icon = '';
        switch(type) {
            case 'error': icon = '❌'; break;
            case 'warn': icon = '⚠️'; break;
            case 'info': icon = 'ℹ️'; break;
            case 'debug': icon = '🐛'; break;
            default: icon = '📝'; break;
        }
        
        logEntry.innerHTML = `[${timestamp}] ${icon} ${message}`;
        content.appendChild(logEntry);
        content.scrollTop = content.scrollHeight;

        if (type === 'error') {
            errorCount++;
            updateErrorCount();
            document.getElementById('console-toggle').classList.add('has-errors');
            showErrorNotification(message);
        }
    }

    function updateErrorCount() {
        const badge = document.getElementById('error-count');
        badge.textContent = `${errorCount} Error${errorCount !== 1 ? 's' : ''}`;
    }

    function showErrorNotification(message) {
        const notification = document.createElement('div');
        notification.className = 'alert alert-danger alert-dismissible fade show error-notification';
        notification.innerHTML = `
            <strong>Error Detected!</strong><br>
            ${message.substring(0, 100)}${message.length > 100 ? '...' : ''}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 5000);
    }

    // Override console methods to capture logs
    const originalConsole = {
        log: console.log,
        error: console.error,
        warn: console.warn,
        info: console.info,
        debug: console.debug
    };

    console.log = function(...args) {
        originalConsole.log.apply(console, args);
        addToConsole(args.join(' '), 'log');
    };

    console.error = function(...args) {
        originalConsole.error.apply(console, args);
        addToConsole(args.join(' '), 'error');
    };

    console.warn = function(...args) {
        originalConsole.warn.apply(console, args);
        addToConsole(args.join(' '), 'warn');
    };

    console.info = function(...args) {
        originalConsole.info.apply(console, args);
        addToConsole(args.join(' '), 'info');
    };

    console.debug = function(...args) {
        originalConsole.debug.apply(console, args);
        addToConsole(args.join(' '), 'debug');
    };

    // Capture unhandled errors
    window.addEventListener('error', function(e) {
        addToConsole(`Uncaught Error: ${e.message} at ${e.filename}:${e.lineno}:${e.colno}`, 'error');
    });

    // Capture unhandled promise rejections
    window.addEventListener('unhandledrejection', function(e) {
        addToConsole(`Unhandled Promise Rejection: ${e.reason}`, 'error');
    });

    // Demo functions to test error handling
    function triggerError() {
        try {
            throw new Error('This is a test error from SEHATI system');
        } catch (e) {
            console.error('Caught error:', e.message);
        }
    }

    function triggerWarning() {
        console.warn('This is a test warning - Patient data validation failed');
    }

    function triggerInfo() {
        console.info('Patient appointment scheduled successfully');
    }

    function simulateAsyncError() {
        setTimeout(() => {
            console.error('Async operation failed - Database connection timeout');
        }, 1000);
    }

    function simulateLogout() {
        console.info('User logout initiated');
        alert('Logout simulation (in real app, this would redirect to login)');
    }

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function () {
        // Initialize tooltips
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
        
        // Initialize popovers
        const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
        popoverTriggerList.map(function (popoverTriggerEl) {
            return new bootstrap.Popover(popoverTriggerEl);
        });
        
        // Auto-hide alerts after 5 seconds
        const alerts = document.querySelectorAll('.alert:not(.alert-important)');
        alerts.forEach(alert => {
            setTimeout(() => {
                const bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            }, 5000);
        });
        
        // Loading state for forms
        const forms = document.querySelectorAll('form');
        forms.forEach(form => {
            form.addEventListener('submit', function() {
                const submitBtn = this.querySelector('button[type="submit"]');
                if (submitBtn) {
                    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
                    submitBtn.disabled = true;
                }
                this.classList.add('loading');
            });
        });
        
        // Console welcome message
        console.log('🏥 SEHATI - Sistem Kesehatan Terpadu (Debug Mode)');
        console.info('Debug console active - All errors and logs will be displayed');
        
        // Simulate some initial activity
        setTimeout(() => {
            console.info('System initialization complete');
        }, 1000);
    });
</script>
</body>
</html>