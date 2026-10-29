
let usuarioActualId = localStorage.getItem("idUsuario") ? parseInt(localStorage.getItem("idUsuario")) : null;
let usuarioActualEmail = null;
let usuarioActualPassword = null;

function switchTab(evt, tabId) {
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.querySelectorAll('.tab-button').forEach(button => {
        button.classList.remove('active');
    });

    document.getElementById(tabId).classList.add('active');
    evt.currentTarget.classList.add('active');
}

async function cargarDesarrolladores() {
    try {
        const respuesta = await fetch('http://localhost:5000/api/usuarios/desarrolladores');
        if (respuesta.ok) {
            const desarrolladores = await respuesta.json();
            const select = document.getElementById('idUsuarioDesarrolla');
            
            select.innerHTML = '<option value="" disabled selected>Seleccione un desarrollador...</option>';
            
            desarrolladores.forEach((dev) => {
                const option = document.createElement('option');
                option.value = dev.id; 
                option.textContent = dev.nombre; 
                select.appendChild(option);
            });
        } else {
            console.error("Error cargando desarrolladores:", respuesta.status);
        }
    } catch (error) {
        console.error("Error:", error);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    cargarDesarrolladores();

    const formulario = document.getElementById('taskForm');
    if (formulario) {
        formulario.addEventListener('submit', async (e) => {
            e.preventDefault();

            // CORRECCIÓN CRÍTICA: Recuperar el ID real del usuario que inició sesión
            const idAsignaPersistente = localStorage.getItem("idUsuario") 
                ? parseInt(localStorage.getItem("idUsuario")) 
                : usuarioActualId;

            if (!idAsignaPersistente) {
                alert('⚠️ No se pudo identificar al usuario que asigna. Por favor, vuelve a iniciar sesión.');
                return;
            }

            const datosTarea = {
                nombre: document.getElementById('nombreTarea').value,
                descripcion: document.getElementById('descripcion').value,
                fechaInicio: new Date(document.getElementById('fechaInicio').value).toISOString(),
                fechaLimite: new Date(document.getElementById('fechaLimite').value).toISOString(),
                idProyecto: parseInt(document.getElementById('idProyecto').value),
                idUsuarioAsigna: idAsignaPersistente, // 🚀 ID dinámico enviado a Oracle
                idUsuarioDesarrolla: parseInt(document.getElementById('idUsuarioDesarrolla').value),
                estado: "InDevelopment"
            };

            try {
                const respuesta = await fetch('http://localhost:5000/api/tareas', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(datosTarea)
                });

                if (respuesta.ok) {
                    alert('¡Tarea asignada con éxito al tablero del Developer! 🚀');
                    formulario.reset();
                } else {
                    alert('Hubo un problema al registrar la tarea en el servidor.');
                }
            } catch (error) {
                console.error("Error al enviar la tarea:", error);
                alert('Error de conexión. No se pudo registrar la tarea.');
            }
        });
    }

    const btnBuscarUsuario = document.getElementById('btnBuscarUsuario');
    if (btnBuscarUsuario) {
        btnBuscarUsuario.addEventListener('click', async () => {
            const email = document.getElementById('searchUserEmail').value;
            if (!email) {
                alert('Ingrese un correo para buscar.');
                return;
            }

            try {
                const respuesta = await fetch(`http://localhost:5000/api/usuarios?email=${encodeURIComponent(email)}`);
                if (respuesta.ok) {
                    const datos = await respuesta.json();
                    const usuario = Array.isArray(datos) ? datos[0] : datos;

                    if (!usuario) {
                        alert('Usuario no encontrado.');
                        return;
                    }

                    // Se cargan temporalmente los datos del usuario que se va a editar
                    usuarioActualId = usuario.id;
                    usuarioActualEmail = usuario.email;
                    usuarioActualPassword = usuario.password || "";
                    
                    const inputNombre = document.getElementById('modificarNombre');
                    const inputDesc = document.getElementById('modificarDescripcion');
                    const selectRol = document.getElementById('modificarRol');
                    const btnGuardar = document.getElementById('btnGuardarUsuario');

                    inputNombre.value = usuario.nombre;
                    inputDesc.value = usuario.descripcion || '';
                    selectRol.value = usuario.rol;

                    inputNombre.disabled = false;
                    inputDesc.disabled = false;
                    selectRol.disabled = false;
                    btnGuardar.disabled = false;
                } else {
                    alert('Error al buscar el usuario.');
                }
            } catch (error) {
                console.error("Error:", error);
            }
        });
    }

    const userModifyForm = document.getElementById('userModifyForm');
    if (userModifyForm) {
        userModifyForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            if (!usuarioActualId) return;

            const datosUsuario = {
                prmOUID: usuarioActualId,
                prmName: document.getElementById('modificarNombre').value,
                prmDescription: document.getElementById('modificarDescripcion').value,
                prmEmail: usuarioActualEmail,
                prmPassword: usuarioActualPassword,
                prmRol: parseInt(document.getElementById('modificarRol').value)
            };

            try {
                const respuesta = await fetch(`http://localhost:5000/api/usuarios/${usuarioActualId}`, {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(datosUsuario)
                });

                if (respuesta.ok) {
                    alert('💾 ¡Datos de usuario actualizados correctamente!');
                    userModifyForm.reset();
                    
                    const inputNombre = document.getElementById('modificarNombre');
                    const inputDesc = document.getElementById('modificarDescripcion');
                    const selectRol = document.getElementById('modificarRol');
                    const btnGuardar = document.getElementById('btnGuardarUsuario');

                    inputNombre.disabled = true;
                    inputDesc.disabled = true;
                    selectRol.disabled = true;
                    btnGuardar.disabled = true;
                    
                    // Restauramos el id del usuario logueado en la sesión activa
                    usuarioActualId = localStorage.getItem("idUsuario") ? parseInt(localStorage.getItem("idUsuario")) : null;
                    usuarioActualEmail = null;
                    usuarioActualPassword = null;
                } else {
                    alert('Error al guardar los cambios.');
                }
            } catch (error) {
                console.error("Error:", error);
            }
        });
    }
});