document.addEventListener('DOMContentLoaded', () => {
    const taskForm = document.getElementById('taskForm');

    taskForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const nuevaTarea = {
            prmOUID: document.getElementById('ouid').value,
            prmName: document.getElementById('nombreTarea').value,
            prmDescription: document.getElementById('descripcion').value,
            prmFirstDate: document.getElementById('fechaInicio').value,
            prmLimitDate: document.getElementById('fechaLimite').value,
            prmPriority: document.getElementById('prioridad').value
        };

        console.log("Enviando tarea al servidor...", nuevaTarea);

        try {
            const respuesta = await fetch('http://localhost:5000/api/tareas/crear', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(nuevaTarea)
            });

            if (respuesta.ok) {
                alert("✅ Tarea enviada exitosamente al tablero del Developer");
                taskForm.reset();
            } else {
                alert("❌ Hubo un error al guardar la tarea");
            }
        } catch (error) {
            console.error("Error de conexión:", error);
            alert("⚠️ No se pudo conectar con el servidor. ¿Olvidaste el dotnet run?");
        }
    });
});