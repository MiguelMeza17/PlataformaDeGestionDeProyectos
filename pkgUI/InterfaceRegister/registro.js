document.addEventListener('DOMContentLoaded', () => {
    const registerForm = document.getElementById('registerForm');

    if (registerForm) {
        registerForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            const datosUsuario = {
                id: document.getElementById('ouid').value,
                nombre: document.getElementById('nombre').value,
                email: document.getElementById('email').value,
                password: document.getElementById('pass').value,
                rol: document.getElementById('rol').value
            };

            try {
                const respuesta = await fetch('http://localhost:5000/api/registrar', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(datosUsuario)
                });

                if (respuesta.ok) {
                    alert("✅ Usuario registrado");
                    window.location.href = "../../index.html";
                } else {
                    const errorData = await respuesta.json();
                    alert("❌ Error: " + (errorData.mensaje || "No se pudo registrar el usuario"));
                }
            } catch (error) {
                console.error("Error:", error);
                alert("❌ Error al conectar con el servidor");
            }
        });
    }
});