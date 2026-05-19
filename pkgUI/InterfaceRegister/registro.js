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
                    const json = await respuesta.json();
                    alert("✅ Usuario registrado");
                    window.location.href = "../../index.html";
                }
            } catch (error) {
                console.error("Error:", error);
            }
        });
    }
});