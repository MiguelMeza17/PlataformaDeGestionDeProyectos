document.addEventListener('DOMContentLoaded', () => {

    const URL_BASE = 'http://localhost:5000/api';
    const projectForm = document.getElementById('projectForm');
    const reportForm = document.getElementById('reportForm');
    const listaProyectosContainer = document.getElementById('listaProyectos');

    projectForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const idProyecto = parseInt(document.getElementById('pOuid').value) || 0;
        const nombre = document.getElementById('pName').value;
        const descripcion = document.getElementById('pDesc').value;
        const fechaInicio = document.getElementById('pStartDate').value;
        const fechaFinalizacion = document.getElementById('pEndDate').value;
        const estadoGeneral = document.getElementById('pState').value;

        const porcentajeAvance = idProyecto > 0 ? parseFloat(prompt("Porcentaje de avance actual (0-100):") || 0) : 0;

        const esEdicion = idProyecto > 0;
        const url = esEdicion ? `${URL_BASE}/proyectos/actualizar` : `${URL_BASE}/proyectos/crear`;
        const metodo = esEdicion ? 'PUT' : 'POST';

        const cuerpo = esEdicion ? 
            { idProyecto, nombre, descripcion, fechaInicio, fechaFinalizacion, estadoGeneral, porcentajeAvance } : 
            { nombre, descripcion, fechaInicio, fechaFinalizacion, estadoGeneral, porcentajeAvance };

        try {
            const res = await fetch(url, {
                method: metodo,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(cuerpo)
            });
            const data = await res.json();
            
            if (res.ok) {
                alert(data.mensaje);
                projectForm.reset();
                document.getElementById('pOuid').value = "0";
                await cargarProyectosYGrafica();
            } else {
                alert("❌ Error: " + data.mensaje);
            }
        } catch (err) {
            console.error(err);
            alert("❌ Error de conexión al procesar proyecto.");
        }
    });

    reportForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const datosReporte = {
            prmProjectOUID: 1, // ID del proyecto asociado por defecto
            prmOUID: parseInt(document.getElementById('rOuid').value) || 0,
            prmName: document.getElementById('rName').value,
            prmDescription: document.getElementById('rDesc').value,
            prmDate: document.getElementById('rDate').value,
            prmProgressSummary: document.getElementById('rSummary').value,
            prmRetardedTasks: parseInt(document.getElementById('rRetarded').value) || 0
        };

        try {
            const res = await fetch(`${URL_BASE}/reportes/crear`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(datosReporte)
            });
            const data = await res.json();

            if (res.ok) {
                alert(data.mensaje);
                reportForm.reset();
            } else {
                alert("❌ " + data.mensaje);
            }
        } catch (err) {
            console.error(err);
            alert("❌ Error de conexión al enviar reporte.");
        }
    });

    async function cargarProyectosYGrafica() {
        try {
            const res = await fetch(`${URL_BASE}/proyectos/listar`);
            if (!res.ok) throw new Error("No se pudieron listar los proyectos");
            const proyectos = await res.json();

            // 1. Pintar Tarjetas en el HTML
            if (listaProyectosContainer) {
                listaProyectosContainer.innerHTML = '';
                proyectos.forEach(p => {
                    const id = p.attOUID || p.idProyecto || p.id;
                    const nom = p.attName || p.nombre;
                    const desc = p.attDescription || p.descripcion;
                    const est = p.attGeneralState || p.estadoGeneral;
                    const pct = p.attAdvancePercentage || p.porcentajeAvance || 0;

                    listaProyectosContainer.innerHTML += `
                        <div class="proyecto-card" style="background: #1a1e29; padding: 15px; border-radius: 6px; border: 1px solid #34495e; color: white;">
                            <h4 style="margin: 0 0 10px 0; color: #3498db;">${nom} (ID: ${id})</h4>
                            <p style="font-size: 14px; margin-bottom: 10px;">${desc}</p>
                            <small>Estado: <strong>${est}</strong> | Avance: ${pct}%</small>
                            <div style="margin-top: 15px; display: flex; gap: 10px;">
                                <button class="btn-primary" style="padding: 5px 10px; font-size: 12px;" onclick="opPrepararEdicion(${JSON.stringify(p).replace(/"/g, '&quot;')})">✏️ Editar</button>
                                <button class="btn-primary" style="padding: 5px 10px; font-size: 12px; background-color: #e74c3c;" onclick="opEliminarProyecto(${id})">🗑️ Eliminar</button>
                            </div>
                        </div>
                    `;
                });
            }


            let sinIniciar = 0, enProceso = 0, terminados = 0;
            proyectos.forEach(p => {
                const est = (p.attGeneralState || p.estadoGeneral || "").toLowerCase();
                const av = p.attAdvancePercentage || p.porcentajeAvance || 0;

                if (est.includes("terminado") || av >= 100) terminados++;
                else if (est.includes("proceso") || av > 0) enProceso++;
                else sinIniciar++;
            });

            const total = proyectos.length || 1;
            const porcentajeGral = Math.round((terminados / total) * 100);

            const circle = document.querySelector('.progress-circle');
            if (circle) circle.style.setProperty('--progress', porcentajeGral + '%');
            const txt = document.getElementById('percentageText');
            if (txt) txt.innerText = porcentajeGral + '%';

            const ctx = document.getElementById('taskChart').getContext('2d');
            if (window.chartProyectos) window.chartProyectos.destroy();

            window.chartProyectos = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Sin Iniciar', 'En Desarrollo', 'Terminados'],
                    datasets: [{
                        data: [sinIniciar, enProceso, terminados],
                        backgroundColor: ['#3498db', '#f1c40f', '#2ecc71']
                    }]
                },
                options: { responsive: true, maintainAspectRatio: false }
            });

        } catch (err) {
            console.error("Error al cargar componentes visuales:", err);
        }
    }

    window.opEliminarProyecto = async function(id) {
        if (!confirm("🚨 ¿Desea eliminar este proyecto de Oracle permanentemente?")) return;
        try {
            const res = await fetch(`${URL_BASE}/proyectos/eliminar/${id}`, { method: 'DELETE' });
            const data = await res.json();
            alert(data.mensaje);
            await cargarProyectosYGrafica();
        } catch (err) { console.error(err); }
    };

    window.opPrepararEdicion = function(p) {
        document.getElementById('pOuid').value = p.attOUID || p.idProyecto || p.id;
        document.getElementById('pName').value = p.attName || p.nombre;
        document.getElementById('pDesc').value = p.attDescription || p.descripcion;
        document.getElementById('pState').value = p.attGeneralState || p.estadoGeneral;
        
        const fechaIni = p.attStartingDate || p.fechaInicio;
        const fechaFin = p.attEndingDate || p.fechaFinalizacion;
        if(fechaIni) document.getElementById('pStartDate').value = fechaIni.split('T')[0];
        if(fechaFin) document.getElementById('pEndDate').value = fechaFin.split('T')[0];

        projectForm.scrollIntoView({ behavior: 'smooth' });
    };

    cargarProyectosYGrafica();
});