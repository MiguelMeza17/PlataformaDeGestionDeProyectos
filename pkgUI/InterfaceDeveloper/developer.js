const desarrolladorId = localStorage.getItem("idUsuario");

const ESTADOS_TAREA = {
    POR_HACER: 0,
    EN_DESARROLLO: 1,
    TERMINADA: 2
};

const MAPEO_ESTADO_STRING = {
    "ToDevelop": ESTADOS_TAREA.POR_HACER,
    "InDevelopment": ESTADOS_TAREA.EN_DESARROLLO,
    "Done": ESTADOS_TAREA.TERMINADA
};

document.addEventListener('DOMContentLoaded', () => {
    if (!desarrolladorId) {
        alert("⚠️ No se encontró una sesión activa de desarrollador. Por favor, inicia sesión.");
        window.location.href = "/login.html";
        return;
    }
    
    cargarTareasDelDesarrollador();
});

async function cargarTareasDelDesarrollador() {
    try {
        const respuesta = await fetch(`http://localhost:5000/api/tareas/desarrollador/${desarrolladorId}`);
        
        if (!respuesta.ok) {
            console.error("Error al obtener las tareas de la base de datos.");
            return;
        }

        const tareas = await respuesta.json();
        
        document.getElementById('tasks-todo').innerHTML = '';
        document.getElementById('tasks-doing').innerHTML = '';
        document.getElementById('tasks-done').innerHTML = '';

        tareas.forEach(tarea => {
            crearTarjetaTarea(tarea);
        });

    } catch (error) {
        console.error("Error de conexión al cargar tareas:", error);
    }
}

function crearTarjetaTarea(tarea) {
    const tarjeta = document.createElement('div');
    tarjeta.className = 'task-card';
    tarjeta.id = `task-${tarea.id}`;

    let contenidoBoton = '';
    
    const estadoNumerico = MAPEO_ESTADO_STRING[tarea.estado] ?? tarea.estado;
    
    if (estadoNumerico === ESTADOS_TAREA.POR_HACER) {
        tarjeta.classList.add('todo');
        contenidoBoton = `<button onclick="moversADesarrollo(${tarea.id})">Empezar Tarea</button>`;
        document.getElementById('tasks-todo').appendChild(tarjeta);
    } 
    else if (estadoNumerico === ESTADOS_TAREA.EN_DESARROLLO) {
        tarjeta.classList.add('doing');
        contenidoBoton = `<button onclick="moverATerminado(${tarea.id})">Finalizar Tarea</button>`;
        document.getElementById('tasks-doing').appendChild(tarjeta);
    } 
    else if (estadoNumerico === ESTADOS_TAREA.TERMINADA) {
        tarjeta.classList.add('done');
        document.getElementById('tasks-done').appendChild(tarjeta);
    }

    tarjeta.innerHTML = `
        <h3>${tarea.nombre}</h3>
        <p>${tarea.descripcion || 'Sin descripción.'}</p>
        <small style="display:block; color:#777; margin-bottom:10px;">Límite: ${new Date(tarea.fechaLimite).toLocaleDateString()}</small>
        ${contenidoBoton}
    `;
}

async function moversADesarrollo(taskId) {
    const exito = await actualizarEstadoEnBaseDatos(taskId, ESTADOS_TAREA.EN_DESARROLLO);
    
    if (exito) {
        const task = document.getElementById(`task-${taskId}`);
        if (!task) return;

        task.classList.remove('todo');
        task.classList.add('doing');

        const btn = task.querySelector('button');
        if (btn) {
            btn.innerText = "Finalizar Tarea";
            btn.onclick = () => moverATerminado(taskId);
        }

        document.getElementById('tasks-doing').appendChild(task);
    } else {
        alert("❌ No se pudo actualizar el estado de la tarea en el servidor.");
    }
}

async function moverATerminado(taskId) {
    const exito = await actualizarEstadoEnBaseDatos(taskId, ESTADOS_TAREA.TERMINADA);

    if (exito) {
        const task = document.getElementById(`task-${taskId}`);
        if (!task) return;

        task.classList.remove('doing');
        task.classList.add('done');

        const btn = task.querySelector('button');
        if (btn) btn.remove();

        document.getElementById('tasks-done').appendChild(task);
    } else {
        alert("❌ No se pudo finalizar la tarea en el servidor.");
    }
}

async function actualizarEstadoEnBaseDatos(taskId, nuevoEstado) {
    try {
        const respuesta = await fetch(`http://localhost:5000/api/tareas/${taskId}/estado`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ nuevoEstado: nuevoEstado })
        });

        return respuesta.ok;
    } catch (error) {
        console.error("Error al actualizar estado en el servidor:", error);
        return false;
    }
}