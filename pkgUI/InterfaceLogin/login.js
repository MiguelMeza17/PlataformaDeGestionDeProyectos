document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('loginForm');

    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            const credenciales = {
                nombre: document.getElementById('nombreLogin').value, 
                password: document.getElementById('passLogin').value
            };

            console.log("Intentando entrar con:", credenciales.nombre);

            try {
                const respuesta = await fetch('http://localhost:5000/api/login', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(credenciales)
                });

                if (respuesta.ok) {
                    const usuario = await respuesta.json();
                    
                    alert("👋 ¡Hola de nuevo, " + (usuario.name || usuario.nombre) + "!");
                    
                    const userRol = usuario.rol !== undefined ? usuario.rol.toString() : "";

                    if (userRol === "Admin" || userRol === "0") {
                        window.location.href = "/InterfaceAdmin/admin.html";
                    } else if (userRol === "Manager" || userRol === "1") {
                        window.location.href = "/InterfaceLeader/leader.html";
                    } else(userRol === "Developer" || userRol === "2") {
                        window.location.href = "/InterfaceDeveloper/developer.html";
                    }
                } else {
                    alert("❌ Nombre o contraseña incorrectos");
                }
            } catch (error) {
                console.error("Error en login:", error);
                alert("⚠️ Error de conexión con el servidor.");
            }
        });
    }
});