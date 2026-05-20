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
                    
                    // Nota: C# suele serializar a minúsculas en JSON (name en vez de Name)
                    alert("👋 ¡Hola de nuevo, " + (usuario.name || usuario.nombre) + "!");
                    
                    // Redirección según Rol
                    if (usuario.rol === "Developer") {
                        window.location.href = "../InterfaceDeveloper/developer.html";
                    } else if (usuario.rol === "Admin") {
                        window.location.href = "../InterfaceAdmin/admin.html";
                    } else {
                        window.location.href = "../InterfaceLeader/leader.html";
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