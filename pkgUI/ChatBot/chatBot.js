document.addEventListener("DOMContentLoaded", () => {
    const zona = document.getElementById("esdeathZona");
    const chat = document.getElementById("esdeathChat");
    const textoSaludo = document.getElementById("esdeathSaludo");
    const inputField = document.querySelector(".esdeath-input");
    const imageElement = chat.querySelector("img");

    
    const imagenSaludo = "/Imagenes/ImagenSaludando.png";
    const imagenSeria = "/Imagenes/ImagenSeria.png";
    const imagenPensando = "/Imagenes/ImagenPensando.png"
    const imagenGritando = "/Imagenes/ImagenPensando.png"

    const saludos = [
        "¡Saludos, subordinado!",
        "¿Cómo progresa el tablero hoy?",
        "El hielo no tolera la pereza...",
        "¡Reporta tus avances de inmediato!",
        "Veo que sigues con vida. Bien."
    ];

    // Hover
    zona.addEventListener("mouseenter", () => {
        const saludoAleatorio = saludos[Math.floor(Math.random() * saludos.length)];
        textoSaludo.textContent = saludoAleatorio;
        chat.classList.add("mostrar");
    });

    zona.addEventListener("mouseleave", () => {
        chat.classList.remove("mostrar");
        if (inputField) inputField.value = "";
        setTimeout(() => {
            resetearImagen();
        }, 800);
        
    });
    

    function resetearImagen() {
        if (imageElement) imageElement.src = imagenSaludo;
    }

    if (inputField) {
        inputField.addEventListener("keypress", (event) => {
            if (event.key === "Enter") {
                const messageText = inputField.value.trim();
                if (messageText === "") return;

                const response = getEsdeathResponse(messageText);

                textoSaludo.textContent = response.texto;

                if (imageElement) {
                    if (response.imagen) {
                        imageElement.src = response.imagen;
                    } else {
                        imageElement.src = imagenSaludo;
                    }
                }

                inputField.value = "";
            }
        });
    }

    function getEsdeathResponse(userInput) {
        const query = userInput.toLowerCase();

        if (
            (query.includes('hola')) ||
            (query.includes('buenas')) ||
            (query.includes('hey')) ||
            (query.includes('holi')) ||
            (query.includes('saludos'))
        ) {
            return {
                texto: "¡Hola! ¿En qué puedo ayudarte hoy?",
                imagen: imagenPensando
            };
        }

        if (
            (query.includes('no') && query.includes('tareas')) ||
            (query.includes('sin') && query.includes('tareas')) ||
            (query.includes('ninguna') && query.includes('tarea')) ||
            (query.includes('no') && query.includes('me') && query.includes('asignan')) ||
            (query.includes('porque') && query.includes('no') && query.includes('tengo') && query.includes('tareas'))
        ) {
            return {
                texto: "Tu tablero está vacío porque aún no te asignan tareas.",
                imagen: imagenSeria
            };
        }

        if (
            (query.includes('muchas') && query.includes('tareas')) ||
            (query.includes('demasiadas') && query.includes('tareas')) ||
            (query.includes('mucho') && query.includes('trabajo')) ||
            (query.includes('estoy') && query.includes('ocupado')) ||
            (query.includes('tengo') && query.includes('mucho') && query.includes('hacer'))
        ) {
            return {
                texto: "Tienes bastantes tareas pendientes. Organízalas por prioridad.",
                imagen: imagenPensando
            };
        }

        if (
            (query.includes('crear') && query.includes('tarea')) ||
            (query.includes('nueva') && query.includes('tarea')) ||
            (query.includes('agregar') && query.includes('tarea')) ||
            (query.includes('hacer') && query.includes('actividad')) ||
            (query.includes('registrar') && query.includes('tarea'))
        ) {
            return {
                texto: "Para crear una tarea debes asignar título, descripción y responsable.",
                imagen: imagenPensando
            };
        }

        if (
            (query.includes('termine') && query.includes('tarea')) ||
            (query.includes('complete') && query.includes('tarea')) ||
            (query.includes('ya') && query.includes('acabe')) ||
            (query.includes('finalice') && query.includes('actividad')) ||
            (query.includes('ya') && query.includes('esta') && query.includes('lista'))
        ) {
            return {
                texto: "¡Buen trabajo! No olvides mover la tarea a 'Terminado'.",
                imagen: imagenGritando
            };
        }

        if (
            (query.includes('error')) ||
            (query.includes('falla')) ||
            (query.includes('bug')) ||
            (query.includes('problema')) ||
            (query.includes('no') && query.includes('funciona'))
        ) {
            return {
                texto: "Se detectó un problema en el sistema.",
                imagen: imagenGritando
            };
        }

        if (
            (query.includes('retrasado')) ||
            (query.includes('vamos') && query.includes('lentos')) ||
            (query.includes('demora')) ||
            (query.includes('no') && query.includes('avanzamos')) ||
            (query.includes('proyecto') && query.includes('atrasado'))
        ) {
            return {
                texto: "El proyecto parece retrasado. Revisa las prioridades.",
                imagen: imagenSeria
            };
        }

        if (
            (query.includes('scrum')) ||
            (query.includes('tablero')) ||
            (query.includes('kanban')) ||
            (query.includes('columnas')) ||
            (query.includes('estados') && query.includes('tareas'))
        ) {
            return {
                texto: "El tablero Scrum organiza las tareas según su estado.",
                imagen: imagenPensando
            };
        }

        if (
            (query.includes('bloqueada')) ||
            (query.includes('no') && query.includes('puedo') && query.includes('continuar')) ||
            (query.includes('dependencia')) ||
            (query.includes('esperando')) ||
            (query.includes('detenida'))
        ) {
            return {
                texto: "La tarea parece bloqueada. Consulta con tu líder.",
                imagen: imagenSeria
            };
        }

        if (
            (query.includes('avance')) ||
            (query.includes('progreso')) ||
            (query.includes('como') && query.includes('vamos')) ||
            (query.includes('estado') && query.includes('proyecto')) ||
            (query.includes('porcentaje'))
        ) {
            return {
                texto: "El avance depende de las tareas completadas.",
                imagen: imagenPensando
            };
        }

        if (
            (query.includes('urgente')) ||
            (query.includes('critico')) ||
            (query.includes('importante')) ||
            (query.includes('prioridad')) ||
            (query.includes('grave'))
        ) {
            return {
                texto: "¡Atención! Hay tareas prioritarias pendientes.",
                imagen: imagenGritando
            };
        }

        if (
            (query.includes('base') && query.includes('datos')) ||
            (query.includes('oracle')) ||
            (query.includes('sql')) ||
            (query.includes('bd')) ||
            (query.includes('conexion') && query.includes('datos'))
        ) {
            return {
                texto: "La base de datos almacena toda la información del sistema.",
                imagen: imagenPensando
            };
        }

        if (
            (query.includes('api')) ||
            (query.includes('backend')) ||
            (query.includes('servidor')) ||
            (query.includes('endpoint')) ||
            (query.includes('peticion'))
        ) {
            return {
                texto: "El backend procesa las solicitudes del sistema.",
                imagen: imagenPensando
            };
        }

        if (
            (query.includes('frontend')) ||
            (query.includes('interfaz')) ||
            (query.includes('pantalla')) ||
            (query.includes('visual')) ||
            (query.includes('diseño'))
        ) {
            return {
                texto: "El frontend controla la parte visual del sistema.",
                imagen: imagenPensando
            };
        }

        if (
            (query.includes('login')) ||
            (query.includes('contraseña')) ||
            (query.includes('no') && query.includes('puedo') && query.includes('entrar')) ||
            (query.includes('sesion')) ||
            (query.includes('correo'))
        ) {
            return {
                texto: "Verifica tus credenciales antes de iniciar sesión.",
                imagen: imagenSeria
            };
        }

        if (
            (query.includes('permiso')) ||
            (query.includes('acceso') && query.includes('denegado')) ||
            (query.includes('no') && query.includes('puedo') && query.includes('editar')) ||
            (query.includes('restriccion')) ||
            (query.includes('no') && query.includes('autorizado'))
        ) {
            return {
                texto: "No tienes permisos suficientes para realizar esa acción.",
                imagen: imagenSeria
            };
        }

        if (
            (query.includes('estresado')) ||
            (query.includes('cansado')) ||
            (query.includes('agotado')) ||
            (query.includes('mucho') && query.includes('trabajo')) ||
            (query.includes('no') && query.includes('puedo') && query.includes('mas'))
        ) {
            return {
                texto: "Parece que necesitas organizar mejor tus tareas y descansar un poco.",
                imagen: imagenSeria
            };
        }

        if (
            (query.includes('motivame')) ||
            (query.includes('motivacion')) ||
            (query.includes('animo')) ||
            (query.includes('seguimos')) ||
            (query.includes('puedo') && query.includes('hacerlo'))
        ) {
            return {
                texto: "¡Claro que puedes! Sigue avanzando en tus tareas.",
                imagen: imagenGritando
            };
        }

        if (
            (query.includes('gracias')) ||
            (query.includes('muchas gracias')) ||
            (query.includes('te agradezco')) ||
            (query.includes('thanks')) ||
            (query.includes('genial'))
        ) {
            return {
                texto: "¡Con gusto! Estoy aquí para ayudarte.",
                imagen: imagenPensando
            };
        }

        if (
            (query.includes('adios')) ||
            (query.includes('bye')) ||
            (query.includes('hasta luego')) ||
            (query.includes('nos vemos')) ||
            (query.includes('chao'))
        ) {
            return {
                texto: "¡Hasta luego! Mucha suerte con tu proyecto.",
                imagen: imagenPensando
            };
        }

        return {
            texto: "No entendí completamente tu mensaje. ¿Puedes explicarlo de otra forma?",
            imagen: imagenPensando
        };
    }
});