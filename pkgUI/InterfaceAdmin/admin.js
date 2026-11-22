// =========================================================================
// 🚀 ARQUITECTURA INTEGRADA DE CONTROLADORES - PANEL ADMINISTRADOR
// =========================================================================

document.addEventListener('DOMContentLoaded', () => {
    
    console.log("🚀 [SISTEMA] Módulo maestro del Administrador inicializado correctamente.");

    // Configuración de rutas hacia el Backend en C# (Puerto 5000)
    const URL_BASE = 'http://localhost:5000/api';
    const backendUrl = "http://localhost:5000";

    // Elementos del DOM del panel CRUD
    const projectForm = document.getElementById('projectForm');
    const reportForm = document.getElementById('reportForm');
    const listaProyectosContainer = document.getElementById('listaProyectos');

    // =========================================================================
    // 🎨 [ZONA AÑADIDA 1] REDISEÑO: 3 INFORMES EN BLOQUES DE EXTREMO A EXTREMO
    // =========================================================================
    const btnMuestra = document.getElementById("btnListarProyectos");
    if (btnMuestra) {
        const contenedorInformes = btnMuestra.closest('.admin-grid');
        if (contenedorInformes) {
            // Desactivamos las 3 columnas y las volvemos filas verticales completas
            contenedorInformes.style.display = "flex";
            contenedorInformes.style.flexDirection = "column";
            contenedorInformes.style.width = "100%";
            contenedorInformes.style.gap = "24px"; // Espaciado elegante (no contiguos)

            // Forzamos a cada uno de los 3 contenedores a estirarse al 100%
            Array.from(contenedorInformes.children).forEach(bloque => {
                bloque.style.width = "100%";
                bloque.style.maxWidth = "100%";
                bloque.style.boxSizing = "border-box";
            });
        }
    }

    // ==============================================================================
    // 🌟 CONTROLADOR 1: CRUD DE PROYECTOS (CREAR / ACTUALIZAR)
    // ==============================================================================
    if (projectForm) {
        projectForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            const idProyecto = parseInt(document.getElementById('pOuid').value) || 0;
            const nombre = document.getElementById('pName').value;
            const descripcion = document.getElementById('pDesc').value;
            const fechaInicio = document.getElementById('pStartDate').value;
            const fechaFinalizacion = document.getElementById('pEndDate').value;
            const estadoGeneral = document.getElementById('pState').value;
            const esEdicion = idProyecto > 0;
            // 2. LOGICA DE AVANCE: Recuperamos el porcentaje existente guardado de forma oculta
            // Si el input no existe o es nuevo, por defecto arranca en 0
            const inputAvanceOculto = document.getElementById('pAdvancePercentageHidden');
            const porcentajeAvance = esEdicion && inputAvanceOculto ? parseFloat(inputAvanceOculto.value) : 0;

            // Definimos rutas y verbos HTTP
            const url = esEdicion ? `${URL_BASE}/proyectos/actualizar` : `${URL_BASE}/proyectos/crear`;
            const metodo = esEdicion ? 'PUT' : 'POST';

            // Armamos el cuerpo JSON de la petición
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
                    
                    // Limpiamos los campos de control de edición
                    document.getElementById('pOuid').value = "0";
                    if (inputAvanceOculto) inputAvanceOculto.value = "0";

                    // Restauramos los textos originales del formulario
                    const formularioTitulo = document.querySelector('#projectForm h3') || document.getElementById('formTitle');
                    const botonEnviar = projectForm.querySelector('button[type="submit"]');
                    if (formularioTitulo) formularioTitulo.innerText = "Registrar Proyecto";
                    if (botonEnviar) botonEnviar.innerText = "Registrar";
                    
                    // Refrescamos la interfaz y la dona de estadísticas
                    await cargarProyectosYGrafica();
                } else {
                    alert("❌ Error: " + data.mensaje);
                }
            } catch (err) {
                console.error(err);
                alert("❌ Error de conexión al procesar proyecto.");
            }
        });
    }

    // ==============================================================================
    // 🌟 CONTROLADOR 2: ENVIAR REPORTE OFICIAL (CORREGIDO PARA TU HTML)
    // ==============================================================================
    if (reportForm) {
        reportForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            // Capturamos los valores directamente usando los ID reales de tu HTML
            const idProyectoRaw = document.getElementById('rOuid').value;
            const nombreRaw = document.getElementById('rName').value;
            const descripcionRaw = document.getElementById('rDesc').value;
            const fechaRaw = document.getElementById('rDate').value;
            const resumenRaw = document.getElementById('rSummary').value;
            const tareasRaw = document.getElementById('rRetarded').value;

            // 🌟 Formateamos el JSON con los tipos de datos correctos para .NET
            const datosReporte = {
                idProyecto: parseInt(idProyectoRaw, 10) || 0, // Convierte "111" (string) a 111 (int)
                nombre: nombreRaw,
                descripcion: descripcionRaw,
                fecha: fechaRaw ? new Date(fechaRaw).toISOString() : new Date().toISOString(), // Convierte la fecha a formato ISO estándar
                resumenAvance: resumenRaw,
                tareasRetrasadas: parseInt(tareasRaw, 10) || 0 // Convierte "1" (string) a 1 (int)
            };

            // Log de control para verificar el payload en la consola del navegador (F12)
            console.log("📡 [REPORTE] Enviando JSON al Backend:", datosReporte);

            try {
                const res = await fetch(`${URL_BASE}/reportes/crear`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(datosReporte)
                });
                
                const data = await res.json();

                if (res.ok) {
                    alert(data.mensaje || "✅ Reporte guardado con éxito.");
                    reportForm.reset();
                } else {
                    // Si el backend responde con un error estructurado, lo muestra aquí
                    alert("❌ Error del Servidor: " + (data.mensaje || "Error en los datos enviados."));
                }
            } catch (err) {
                console.error("❌ Error en la petición Fetch:", err);
                alert("❌ Error de conexión al enviar reporte.");
            }
        });
    }

// =========================================================================
    // 🌟 CONTROLADOR 3: MODULO DE PROCESOS DE NEGOCIO (ORACLE PL/SQL)
    // =========================================================================

    // 1. Botón: Listar Proyectos (DISEÑO DE RECTÁNGULOS HORIZONTALES)
    const btnListar = document.getElementById("btnListarProyectos");
    if (btnListar) {
        btnListar.addEventListener("click", async () => {
            const consola = document.getElementById("consolaListar");
            consola.innerHTML = "⚡ Conectando directamente con el servidor de C# (Puerto 5000)...";

            try {
                const respuestaReporte = await fetch(`${backendUrl}/api/reportes/listar`);
                if (!respuestaReporte.ok) throw new Error(`HTTP Error: ${respuestaReporte.status}`);
                const lineasTexto = await respuestaReporte.json(); 

                const respuestaCRUD = await fetch(`${URL_BASE}/proyectos/listar`);
                const proyectosReales = respuestaCRUD.ok ? await respuestaCRUD.json() : [];

                if (lineasTexto && lineasTexto.length > 0) {
                    consola.innerHTML = ""; 

                    consola.style.display = "flex";
                    consola.style.flexDirection = "column";
                    consola.style.gap = "0px"; 

                    const registrosValidos = lineasTexto.filter(l => l && l.trim() && l.includes("Proyecto:"));

                    registrosValidos.forEach((linea, index) => {
                        // 1. EXTRAER EL NOMBRE INCLUSO SI TIENE SALTOS DE LÍNEA EN MEDIO
                        const matchNombre = linea.match(/Proyecto:\s*([\s\S]*?)(?=\||$)/i);
                        let nombreExtraido = matchNombre ? matchNombre[1] : "";
                        nombreExtraido = nombreExtraido.replace(/[\r\n]+/g, ' ').replace(/\s+/g, ' ').trim();

                        // 2. VINCULACIÓN DINÁMICA DE PROPIEDADES (BUSCADOR CIEGO)
                        const proyectoEncontrado = proyectosReales.find(p => {
                            if (!p) return false;
                            
                            // Buscamos dinámicamente cualquier propiedad que hable del nombre (nombre, Name, attName...)
                            let nomObj = "";
                            for (let llave in p) {
                                const llaveMinus = llave.toLowerCase();
                                if (llaveMinus.includes("nom") || llaveMinus.includes("name")) {
                                    nomObj = p[llave];
                                    break;
                                }
                            }
                            
                            const limpioCSharp = nomObj.toString().toLowerCase().replace(/\s+/g, '');
                            const limpioOracle = nombreExtraido.toLowerCase().replace(/\s+/g, '');
                            
                            if (!limpioCSharp || !limpioOracle) return false;
                            return limpioCSharp === limpioOracle || limpioCSharp.includes(limpioOracle) || limpioOracle.includes(limpioCSharp);
                        });

                        // 3. EXTRAER EL ID DINÁMICAMENTE
                        let idFinal = null;
                        if (proyectoEncontrado) {
                            for (let llave in proyectoEncontrado) {
                                const llaveMinus = llave.toLowerCase();
                                // Buscamos la llave que contenga "id" u "ouid"
                                if (llaveMinus.includes("id") || llaveMinus.includes("ouid")) {
                                    idFinal = proyectoEncontrado[llave];
                                    break;
                                }
                            }
                        }

                        // ✨ [ZONA DE TRADUCCIÓN PARA EL REPORTE ORACLE] ✨
                        let lineaTraducida = linea
                            .replace(/Estado:\s*InDevelopment/i, "Estado: En Proceso")
                            .replace(/Estado:\s*Finished/i, "Estado: Terminado")
                            .replace(/Estado:\s*ToDevelop/i, "Estado: Sin Iniciar");

                        // 4. Renderizado de la tarjeta en el DOM
                        const tarjeta = document.createElement("div");
                        tarjeta.style.cssText = `
                            display: flex; justify-content: space-between; align-items: center; width: 100%;
                            box-sizing: border-box; background: #11141d; padding: 14px 16px; margin-top: 4px;
                            margin-bottom: 14px; border-radius: 6px; border-left: 4px solid #3498db; text-align: left; color: white;
                        `;
                        
                        tarjeta.innerHTML = `
                            <p style="margin: 0; font-size: 13px; font-family: monospace; color: #b2bec3; white-space: pre-wrap; flex-grow: 1; line-height: 1.4;">${lineaTraducida}</p>
                            <div style="display: flex; gap: 8px; shrink: 0; margin-left: 15px;">
                                <button class="btn-primary" style="padding: 5px 10px; font-size: 11px; margin: 0; background: #2980b9; border: none; border-radius: 4px; color: white; cursor: pointer;" id="edit-oracle-${index}">✏️ Editar</button>
                                <button class="btn-primary" style="padding: 5px 10px; font-size: 11px; margin: 0; background: #c0392b; border: none; border-radius: 4px; color: white; cursor: pointer;" id="del-oracle-${index}">🗑️ Eliminar</button>
                            </div>
                        `;
                        consola.appendChild(tarjeta);
                        
                        // Evento Editar
                        document.getElementById(`edit-oracle-${index}`).addEventListener("click", () => {
                            opPrepararEdicion(proyectoEncontrado || { idProyecto: idFinal, nombre: nombreExtraido });
                        });

                        // Evento Eliminar
                        document.getElementById(`del-oracle-${index}`).addEventListener("click", async () => {
                            if (idFinal) {
                                await opEliminarProyecto(idFinal);
                            } else {
                                alert(`❌ No se puede eliminar: ID no vinculado para "${nombreExtraido}".`);
                            }
                        });
                    });
                } else {
                    consola.innerHTML = "⚠ No se encontraron registros en la base de datos de Oracle.";
                }
            } catch (error) {
                consola.innerHTML = "❌ Error al conectar con el backend de C#: " + error.message;
                console.error(error);
            }
        });
    }

    // ==============================================================================
    // 🌟 CONTROLADOR 4: LISTAR PROYECTOS Y ACTUALIZAR GRÁFICA EN TIEMPO REAL
    // ==============================================================================
    async function cargarProyectosYGrafica() {
        
        try {
            const res = await fetch(`${URL_BASE}/proyectos/listar`);
            if (!res.ok) throw new Error("No se pudieron listar los proyectos");
            const proyectos = await res.json();

            if (listaProyectosContainer) {
                listaProyectosContainer.innerHTML = '';
                proyectos.forEach(p => {
                    console.log("Proyecto mapeado para panel:", p);

                    const id = p.OUID || p.ouid || p.Ouid || p.attOUID || p.idProyecto || p.id;
                    const nom = p.Name || p.name || p.attName || p.nombre;
                    const desc = p.Description || p.description || p.attDescription || p.descripcion;
                    const pct = p.AdvancePercentage || p.advancePercentage || p.attAdvancePercentage || p.porcentajeAvance || 0;
                    
                    const estadoCrudoDeAPI = p.GeneralState || p.generalState || p.estadoGeneral || p.EstadoGeneral || p.attGeneralState || p.estado || "";
                    const estadoRaw = estadoCrudoDeAPI.toString().toLowerCase().trim();
                    
                    let estadoTraducido = "Sin Iniciar"; 

                    if (estadoRaw.includes("indevelopment") || estadoRaw.includes("proceso") || estadoRaw === "en proceso") {
                        estadoTraducido = "En Proceso";
                    } else if (estadoRaw.includes("finished") || estadoRaw.includes("terminado") || estadoRaw === "terminado") {
                        estadoTraducido = "Terminado";
                    } else if (estadoRaw.includes("todevelop") || estadoRaw.includes("iniciar") || estadoRaw === "sin iniciar") {
                        estadoTraducido = "Sin Iniciar";
                    } else {
                        estadoTraducido = estadoCrudoDeAPI || "Sin Iniciar"; 
                    }

                    listaProyectosContainer.innerHTML += `
                        <div class="proyecto-card" style="background: #1a1e29; padding: 15px; border-radius: 6px; border: 1px solid #34495e; color: white;">
                            <h4 style="margin: 0 0 10px 0; color: #3498db;">${nom} (ID: ${id})</h4>
                            <p style="font-size: 14px; margin-bottom: 10px;">${desc}</p>
                            <small>Estado: <strong>${estadoTraducido}</strong> | Avance: ${pct}%</small>
                            <div style="margin-top: 15px; display: flex; gap: 10px;">
                                <button class="btn-primary" style="padding: 5px 10px; font-size: 12px;" onclick="opPrepararEdicion(${JSON.stringify(p).replace(/"/g, '&quot;')})">✏️ Editar</button>
                                <button class="btn-primary" style="padding: 5px 10px; font-size: 12px; background-color: #e74c3c;" onclick="opEliminarProyecto(${id})">🗑️ Eliminar</button>
                            </div>
                        </div>
                    `;
                });
            }

            // --- Sección de Estadísticas y Gráfica ---
            let sinIniciar = 0, enProceso = 0, terminados = 0;
            proyectos.forEach(p => {
                const est = (p.GeneralState || p.estadoGeneral || "").toLowerCase();
                const av = p.AdvancePercentage || p.porcentajeAvance || 0;

                if (est.includes("terminado") || est.includes("finished") || av >= 100) {
                    terminados++;
                } else if (est.includes("proceso") || est.includes("development") || av > 0) {
                    enProceso++;
                } else {
                    sinIniciar++;
                }
            });

            const total = proyectos.length || 1;
            const porcentajeGral = Math.round((terminados / total) * 100);

            const circle = document.querySelector('.progress-circle');
            if (circle) circle.style.setProperty('--progress', porcentajeGral + '%');
            const txt = document.getElementById('percentageText');
            if (txt) txt.innerText = porcentajeGral + '%';

            const taskChartEl = document.getElementById('taskChart');
            if (taskChartEl) {
                const ctx = taskChartEl.getContext('2d');
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
            }

        } catch (err) {
            console.error("Error al cargar componentes visuales:", err);
        }
    }

   // ==============================================================================
    // 🌟 ACCIONES COMPLEMENTARIAS GENERALES (ELIMINAR DEFINITIVO)
    // ==============================================================================
    window.opEliminarProyecto = async function(id) {
        if (!confirm(`🚨 ¿Desea eliminar el proyecto con ID ${id} de Oracle permanentemente?`)) return;
        
        const urlDestino = `${URL_BASE}/proyectos/eliminar/${id}`;
        console.log(`📡 [Minimal API] Enviando DELETE a: ${urlDestino}`);
        
        try {
            const res = await fetch(urlDestino, { method: 'DELETE' });
            const data = await res.json();

            if (res.ok) {
                // Si C# devuelve Results.Ok
                alert(data.mensaje || "✅ Proyecto eliminado con éxito de Oracle.");
                
                // Refrescamos ambos componentes visuales en paralelo
                await cargarProyectosYGrafica();
                
                const btnListar = document.getElementById("btnListarProyectos");
                if (btnListar) btnListar.click(); 
            } else {
                // Si C# devuelve Results.BadRequest (Error 400)
                console.error("❌ Validación de Base de Datos / Negocio falló en C#:", data);
                alert(`❌ Servidor dice: ${data.mensaje || "No se pudo eliminar el proyecto."}\n\n👉 Posible causa: El ID ${id} (Sistema Escolar) tiene restricciones activas o reportes asociados en la lógica de C#.`);
            }
            
        } catch (err) { 
            console.error("❌ Error de comunicación con la API:", err); 
            alert("❌ No se pudo establecer conexión con el servidor de C#.");
        }
    };

    window.opPrepararEdicion = function(p) {
        console.log("📦 Datos recibidos para edición:", p);

        const id = p.OUID || p.ouid || p.Ouid || p.attOUID || p.idProyecto || p.id || 0;
        const nom = p.Name || p.name || p.attName || p.nombre || "";
        const desc = p.Description || p.description || p.attDescription || p.descripcion || "";
        const fechaIni = p.StartingDate || p.startingDate || p.fechaInicio || "";
        const fechaFin = p.EndingDate || p.endingDate || p.fechaFinalizacion || "";
        const pct = p.AdvancePercentage || p.advancePercentage || p.attAdvancePercentage || p.porcentajeAvance || 0;

        const estadoBD = p.GeneralState || p.generalState || p.attGeneralState || p.estadoGeneral || "";
        let estadoFormulario = "Sin Iniciar"; 

        if (estadoBD === "InDevelopment" || estadoBD === "En Proceso") {
            estadoFormulario = "En Proceso";
        } else if (estadoBD === "Finished" || estadoBD === "Terminado") {
            estadoFormulario = "Terminado";
        } else if (estadoBD === "ToDevelop" || estadoBD === "Sin Iniciar") {
            estadoFormulario = "Sin Iniciar";
        }

        let inputAvanceOculto = document.getElementById('pAdvancePercentageHidden');
        if (!inputAvanceOculto && projectForm) {
            inputAvanceOculto = document.createElement('input');
            inputAvanceOculto.type = 'hidden';
            inputAvanceOculto.id = 'pAdvancePercentageHidden';
            projectForm.appendChild(inputAvanceOculto);
        }
        if (inputAvanceOculto) inputAvanceOculto.value = pct;

        const inputOuid = document.getElementById('pOuid');
        const inputName = document.getElementById('pName');
        const inputDesc = document.getElementById('pDesc');
        const inputState = document.getElementById('pState'); 
        const inputStart = document.getElementById('pStartDate');
        const inputEnd = document.getElementById('pEndDate');

        if (inputOuid) inputOuid.value = id;
        if (inputName) inputName.value = nom;
        if (inputDesc) inputDesc.value = desc;
        if (inputState) inputState.value = estadoFormulario; 
        
        if (inputStart && fechaIni) inputStart.value = fechaIni.split('T')[0];
        if (inputEnd && fechaFin) inputEnd.value = fechaFin.split('T')[0];

        const formularioTitulo = document.querySelector('#projectForm h3') || document.getElementById('formTitle');
        const botonEnviar = projectForm ? projectForm.querySelector('button[type="submit"]') : null;
        
        if (formularioTitulo) formularioTitulo.innerText = "✏️ Editar Proyecto Existente";
        if (botonEnviar) botonEnviar.innerText = "Actualizar Proyecto";

        if (projectForm) projectForm.scrollIntoView({ behavior: 'smooth' });     
    };

    // Inicialización del panel de control al abrir la interfaz
    cargarProyectosYGrafica();
});