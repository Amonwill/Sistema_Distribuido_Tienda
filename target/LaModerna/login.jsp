<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>ESIME Store - Acceso</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { 
            display: flex; justify-content: center; align-items: center; 
            background-color: var(--bg-main); height: 100vh; margin: 0; 
        }
        .login-card {
            background: white; padding: 40px; border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
            width: 100%; max-width: 400px; text-align: center;
        }
        .login-card h2 { color: var(--bg-sidebar); margin-bottom: 5px; }
        .login-card p { color: var(--text-light); margin-bottom: 30px; font-size: 0.9rem; }
        .input-group { margin-bottom: 20px; text-align: left; }
        .input-group label { color: var(--text-dark); font-weight: 500; font-size: 0.9rem; }
        .input-group input {
            width: 100%; padding: 12px; border-radius: 6px; border: 1px solid #ddd;
            font-size: 1rem; margin-top: 5px; box-sizing: border-box;
        }
        .btn-login {
            width: 100%; background: var(--bg-sidebar); color: white; padding: 12px;
            border: none; border-radius: 6px; font-size: 1rem; cursor: pointer; font-weight: 600;
            transition: background 0.3s;
        }
        .btn-login:hover { background: #3b0764; }
        .link-mode { color: var(--blue-card); text-decoration: none; font-size: 0.9rem; cursor: pointer; }
    </style>
</head>
<body>
    <div class="login-card">
        <i class="fa-solid fa-store" style="font-size: 3rem; color: var(--bg-sidebar); margin-bottom: 15px;"></i>
        <h2 id="tituloCard">ESIME Store</h2>
        <p id="subtituloCard">Ingresa tus credenciales para continuar</p>

        <form action="login" method="POST" id="loginForm">
            <input type="hidden" name="accion" id="accion" value="login">
            <div class="input-group">
                <label>Usuario</label>
                <input type="text" name="username" placeholder="Tu usuario" required>
            </div>
            <div class="input-group">
                <label>Contraseña</label>
                <input type="password" name="password" placeholder="••••••••" required>
            </div>
            <button type="submit" class="btn-login" id="btnSubmit">Iniciar Sesión</button>
        </form>
        
        <p style="text-align: center; margin-top: 20px;">
            <a class="link-mode" onclick="cambiarModo()" id="linkModo">¿No tienes cuenta? Regístrate</a>
        </p>
    </div>

    <script>
        function cambiarModo() {
            const btn = document.getElementById('btnSubmit');
            const acc = document.getElementById('accion');
            const titulo = document.getElementById('tituloCard');
            const sub = document.getElementById('subtituloCard');
            const link = document.getElementById('linkModo');

            if(acc.value === 'login') {
                acc.value = 'registrar';
                titulo.innerText = 'Registro de Usuario';
                sub.innerText = 'Crea una cuenta para acceder';
                btn.innerText = 'Registrar Cuenta';
                link.innerText = '¿Ya tienes cuenta? Inicia sesión';
            } else {
                acc.value = 'login';
                titulo.innerText = 'ESIME Store';
                sub.innerText = 'Ingresa tus credenciales para continuar';
                btn.innerText = 'Iniciar Sesión';
                link.innerText = '¿No tienes cuenta? Regístrate';
            }
        }
    </script>
</body>
</html>