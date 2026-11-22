// =========================================================================
// 🧠 ALERTAS DE PROLOG (compartido por los paneles de Admin, Leader y Developer)
// =========================================================================
// Conecta el botón #btnAlertasProlog con la consola #consolaProlog.
// Si el botón tiene data-solo-usuario="true", muestra solo las tareas del usuario
// que inició sesión. Es un filtro visual: el endpoint devuelve las alertas de todos.

const URL_ALERTAS_PROLOG = "http://localhost:5000/api/prolog/alertas";

function agregarGrupoAlertasProlog(consola, titulo, lineas) {
    const encabezado = document.createElement("strong");
    encabezado.textContent = `${titulo} (${lineas.length})`;
    consola.appendChild(encabezado);

    // textContent y no innerHTML: los nombres los escriben los usuarios
    const lista = document.createElement("div");
    lista.style.marginBottom = "12px";
    lista.textContent = lineas.length > 0 ? lineas.map(l => `• ${l}`).join("\n") : "Sin alertas.";
    consola.appendChild(lista);
}

async function mostrarAlertasProlog(consola, soloUsuario) {
    consola.textContent = "⚡ Consultando las reglas de Prolog...";

    try {
        const respuesta = await fetch(URL_ALERTAS_PROLOG);
        if (!respuesta.ok) {
            const problema = await respuesta.json().catch(() => null);
            throw new Error(problema?.detail || `HTTP Error: ${respuesta.status}`);
        }
        const alertas = await respuesta.json();

        const idUsuario = Number(localStorage.getItem("idUsuario"));
        const propias = lista => soloUsuario ? lista.filter(t => t.responsableId === idUsuario) : lista;

        consola.textContent = `Análisis del ${alertas.fecha}\n\n`;

        agregarGrupoAlertasProlog(consola, "⏰ Tareas atrasadas", propias(alertas.atrasadas).map(t =>
            `${t.nombre} (${t.proyecto}) - ${t.responsable} - ${t.diasAtraso} días de atraso`
        ));
        agregarGrupoAlertasProlog(consola, "⛔ Tareas bloqueadas", propias(alertas.bloqueadas).map(t =>
            `${t.nombre} (${t.proyecto}) - ${t.responsable} - espera a ${t.esperaA.join(", ")}`
        ));
        agregarGrupoAlertasProlog(consola, "🔥 Personas sobrecargadas",
            alertas.sobrecargados
                .filter(u => !soloUsuario || u.id === idUsuario)
                .map(u => `${u.nombre} - ${u.tareasActivas} tareas activas`)
        );
        agregarGrupoAlertasProlog(consola, "⚠️ Proyectos en riesgo", alertas.proyectosEnRiesgo.map(p =>
            `${p.nombre} - ${p.motivos.join("; ")}`
        ));
    } catch (error) {
        consola.textContent = "❌ Error al consultar Prolog: " + error.message;
        console.error(error);
    }
}

document.addEventListener("DOMContentLoaded", () => {
    const boton = document.getElementById("btnAlertasProlog");
    const consola = document.getElementById("consolaProlog");

    if (boton && consola) {
        boton.addEventListener("click", () => mostrarAlertasProlog(consola, boton.dataset.soloUsuario === "true"));
    }
});
