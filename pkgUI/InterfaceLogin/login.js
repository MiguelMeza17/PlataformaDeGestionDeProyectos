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
                    
                    // C# serializa las propiedades a minúsculas en JSON (nombre/name y rol)
                    const nombreUsuario = usuario.nombre || usuario.name || "Usuario";
                    const rolUsuario = usuario.rol || usuario.rolEnum;

                    alert("👋 ¡Hola de nuevo, " + nombreUsuario + "!");
                    
                    console.log("Rol recibido del servidor:", rolUsuario);

                    // ==========================================
                    // 🛠️ RUTAS VIRTUALES CORREGIDAS PARA .NET
                    // ==========================================
                    if (rolUsuario === "Developer") {
                        window.location.href = "/pkgUI/InterfaceDeveloper/developer.html";
                    } else if (rolUsuario === "Admin") {
                        window.location.href = "/pkgUI/InterfaceAdmin/admin.html";
                    } else {
                        window.location.href = "/pkgUI/InterfaceLeader/leader.html";
                    }
                    // ==========================================

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