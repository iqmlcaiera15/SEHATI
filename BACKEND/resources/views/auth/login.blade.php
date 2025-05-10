@extends('layouts.app')

@section('title', 'Login')

@section('content')
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0">Login Sistem</h4>
                </div>

                <div class="card-body">
                    <form id="loginForm">
                        @csrf
                        
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input id="email" type="email" class="form-control" name="email" required autocomplete="email" autofocus>
                            <div class="invalid-feedback" id="emailError"></div>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <input id="password" type="password" class="form-control" name="password" required autocomplete="current-password">
                            <div class="invalid-feedback" id="passwordError"></div>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg">
                                Login
                            </button>
                        </div>
                    </form>

                    <div class="mt-3 text-center">
                        <p>Belum punya akun? 
                            <a href="{{ route('register.bidan') }}">Daftar sebagai Bidan</a> atau 
                            <a href="{{ route('register.dinkes') }}">Daftar sebagai Dinkes</a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.getElementById('loginForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = {
        email: document.getElementById('email').value,
        password: document.getElementById('password').value
    };

    // Reset error states
    document.getElementById('email').classList.remove('is-invalid');
    document.getElementById('password').classList.remove('is-invalid');
    document.getElementById('emailError').textContent = '';
    document.getElementById('passwordError').textContent = '';

    fetch('/api/login', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        },
        body: JSON.stringify(formData)
    })
    .then(response => {
        if (!response.ok) {
            return response.json().then(err => { throw err; });
        }
        return response.json();
    })
    .then(data => {
        if (data.redirect_to) {
            // Redirect untuk bidan/dinkes
            window.location.href = data.redirect_to;
        } else {
            // Handle untuk ibu hamil (mobile/API)
            localStorage.setItem('auth_token', data.authorization.token);
            window.location.href = '/mobile/dashboard';
        }
    })
    .catch(error => {
        if (error.errors) {
            // Handle validation errors
            if (error.errors.email) {
                document.getElementById('email').classList.add('is-invalid');
                document.getElementById('emailError').textContent = error.errors.email[0];
            }
            if (error.errors.password) {
                document.getElementById('password').classList.add('is-invalid');
                document.getElementById('passwordError').textContent = error.errors.password[0];
            }
        } else if (error.message) {
            // Handle login error
            alert(error.message);
        }
    });
});
</script>
@endsection