document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('loginForm');

    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            const credenciales = {
                nombre: document.getElementById('emailLogin').value,
                password: document.getElementById('passLogin').value
            };

            try {
                const respuesta = await fetch('http://localhost:5000/api/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(credenciales)
                });

                if (respuesta.ok) {
                    const usuario = await respuesta.json();
                    
                    const nombreUsuario = usuario.nombre || "Usuario";
                    
                    localStorage.setItem("nombreUsuario", nombreUsuario);
                    localStorage.setItem("idUsuario", usuario.id); 

                    const rolId = usuario.rolId;

                    alert("👋 ¡Hola de nuevo, " + nombreUsuario + "!");

                    if (rolId === 0) {
                        window.location.href = "/pkgUI/InterfaceAdmin/admin.html";
                    } else if (rolId === 1) {
                        window.location.href = "/pkgUI/InterfaceLeader/leader.html";
                    } else if (rolId === 2) {
                        window.location.href = "/pkgUI/InterfaceDeveloper/developer.html";
                    }
                } else {
                    alert("❌ Correo o contraseña incorrectos");
                }
            } catch (error) {
                console.error("Error en login:", error);
                alert("⚠️ Error de conexión con el servidor.");
            }
        });
    }
});