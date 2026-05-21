document.addEventListener("DOMContentLoaded", () => {

    const nombreUsuario = localStorage.getItem("nombreUsuario") || "Usuario";

    const zona = document.getElementById("esdeathZona");
    const chat = document.getElementById("esdeathChat");
    const textoSaludo = document.getElementById("esdeathSaludo");
    const inputField = document.querySelector(".esdeath-input");
    const imageElement = chat ? chat.querySelector("img") : null;

    const imagenSaludo = "/Imagenes/ImagenSaludando.png";
    const imagenSeria = "/Imagenes/ImagenSeria.png";
    const imagenPensando = "/Imagenes/ImagenPensando.png";
    const imagenGritando = "/Imagenes/ImagenPensando.png";
    const imagenDespidiendoce = "/Imagenes/ImagenDespidiendoce.png";

    const saludos = [
        "Hola, subordinado.",
        "¿Lista para otra jornada de trabajo?",
        "Estoy observando tu progreso.",
        "¿Qué tarea realizaremos hoy?",
        "Bienvenido de nuevo.",
        "Tu tablero te espera.",
        "Espero que estés preparado.",
        "¿Necesitas ayuda con tus tareas?",
        "El trabajo no se completará solo.",
        "Comencemos."
    ];

    const intents = [

        {
            tag: "solicitar_retroceso",
            patterns: [
                "quiero mover la tarea a sin desarrollar",
                "regresa la tarea a por hacer",
                "necesito deshacer el estado de desarrollo",
                "mueve la tarea hacia atrás",
                "esa tarea no debería estar en desarrollo",
                "regresa esta tarea a la lista inicial",
                "quiero quitar esta tarea de en desarrollo",
                "la tarea debe volver a estar pendiente",
                "por favor mueve esta tarea a por hacer",
                "deshacer la acción de desarrollo",
                "necesito retroceder esta tarea al inicio"
            ]
        },

        {
            tag: "tarea_terminada",
            patterns: [
                "he terminado la tarea",
                "ya completé el trabajo",
                "tarea finalizada con éxito",
                "marcar como completada",
                "he terminado todo",
                "proceso finalizado",
                "ya está listo el desarrollo",
                "ya termine mi tarea",
                "finalice mi tarea"
            ]
        },

        {
            tag: "despedida",
            patterns: [
                "adiós",
                "hasta luego",
                "nos vemos después",
                "me voy ya",
                "fin del trabajo por hoy",
                "me retiro",
                "hasta mañana esdeath",
                "ya terminé por hoy",
                "cierra el sistema",
                "chao"
            ]
        },

        {
            tag: "saludo",
            patterns: [
                "hola",
                "buenos días",
                "qué tal",
                "saludos",
                "hola esdeath",
                "buenas tardes",
                "hey",
                "estoy listo para empezar",
                "iniciar sesión"
            ]
        },

        {
            tag: "ayuda_orientacion",
            patterns: [
                "no sé qué hacer",
                "estoy perdido",
                "por dónde empiezo",
                "qué debo hacer ahora",
                "ayúdame a empezar",
                "no sé cómo funciona esto"
            ]
        },

        {
            tag: "tablero_vacio",
            patterns: [
                "mi tablero está vacío",
                "el tablero de desarrollo no tiene nada",
                "no tengo ninguna tarea en el tablero",
                "por qué el tablero está vacío",
                "tengo el tablero vacío qué hago",
                "no veo tareas en la pantalla",
                "el tablero no tiene tareas",
                "no hay nada en mi tablero",
                "mi pantalla de tareas está vacía",
                "no tengo trabajo asignado hoy"
            ]
        },

        {
            tag: "usuario_perdido",
            patterns: [
                "tengo muchas tareas y no sé por dónde empezar",
                "estoy abrumado con tantas tareas",
                "no sé qué tarea debería hacer primero",
                "tengo demasiado trabajo y estoy perdido",
                "cómo organizo mis tareas asignadas",
                "necesito ayuda para priorizar mi trabajo",
                "no sé cómo manejar mis tareas actuales",
                "estoy confundido con tantas cosas por hacer",
                "por cuál tarea debo empezar ahora",
                "ayuda con la gestión de mis tareas"
            ]
        },

        {
            tag: "consultar_plazo",
            patterns: [
                "hasta cuando tengo tiempo para entregar esta tarea",
                "cuánto tiempo me queda para terminar",
                "cuándo es la fecha límite de esta tarea",
                "no sé si alcanzaré a terminar antes de la fecha",
                "tengo mucho trabajo y no sé si llegue a tiempo",
                "cuándo vence este pendiente",
                "estoy ocupado y temo no terminar a tiempo",
                "cuál es el plazo máximo para completar esto",
                "me va a faltar tiempo para esta tarea",
                "qué pasa si no alcanzo a terminar hoy"
            ]
        },

        {
            tag: "cancelar_tarea",
            patterns: [
                "quiero cancelar esta tarea",
                "ya no quiero hacer esta tarea",
                "cancelar tarea",
                "elimina esta tarea",
                "quita esta tarea",
                "necesito cancelar el trabajo",
                "esta tarea fue cancelada",
                "quiero detener esta tarea",
                "descartar esta tarea",
                "ya no continuaré con esta tarea"
            ]
        }

    ];

    function normalizarTexto(texto) {

        return texto
            .toLowerCase()
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "")
            .replace(/[¿?¡!.,;:()"]/g, "")
            .trim();
    }

    const palabrasClave = [];

    intents.forEach(intent => {

        intent.patterns.forEach(pattern => {

            const palabras = normalizarTexto(pattern).split(" ");

            palabras.forEach(palabra => {

                if (!palabrasClave.includes(palabra)) {
                    palabrasClave.push(palabra);
                }

            });

        });

    });

    function textoAVector(texto) {

        texto = normalizarTexto(texto);

        return palabrasClave.map(palabra =>
            texto.includes(palabra) ? 1 : 0
        );
    }

    const trainingData = [];
    const outputData = [];

    intents.forEach((intent, index) => {

        intent.patterns.forEach(pattern => {

            trainingData.push(
                textoAVector(pattern)
            );

            const output = new Array(intents.length).fill(0);

            output[index] = 1;

            outputData.push(output);

        });

    });

    const model = tf.sequential();

    model.add(tf.layers.dense({
        inputShape: [palabrasClave.length],
        units: 24,
        activation: "relu"
    }));

    model.add(tf.layers.dense({
        units: 24,
        activation: "relu"
    }));

    model.add(tf.layers.dense({
        units: intents.length,
        activation: "softmax"
    }));

    model.compile({
        optimizer: "adam",
        loss: "categoricalCrossentropy",
        metrics: ["accuracy"]
    });

    let modeloEntrenado = false;

    async function entrenarIA() {

        const xs = tf.tensor2d(trainingData);
        const ys = tf.tensor2d(outputData);

        await model.fit(xs, ys, {
            epochs: 300,
            shuffle: true
        });

        modeloEntrenado = true;

        console.log("IA entrenada correctamente");
    }

    entrenarIA();

    zona.addEventListener("mouseenter", () => {

        const saludoAleatorio = saludos[Math.floor(Math.random() * saludos.length)];

        textoSaludo.textContent = saludoAleatorio;

        chat.classList.add("mostrar");
    });

    zona.addEventListener("mouseleave", () => {

        chat.classList.remove("mostrar");

        if (inputField) {
            inputField.value = "";
        }

        setTimeout(() => {
            resetearImagen();
        }, 800);
    });

    function resetearImagen() {

        if (imageElement) {
            imageElement.src = imagenSaludo;
        }
    }

    async function getEsdeathResponse(userInput) {

        if (!modeloEntrenado) {

            return {
                texto: "Estoy aprendiendo todavía...",
                imagen: imagenPensando
            };
        }

        const vector = textoAVector(userInput);

        const prediccion = model.predict(
            tf.tensor2d([vector])
        );

        const resultado = await prediccion.data();

        const mayor = Math.max(...resultado);

        const indice = resultado.indexOf(mayor);

        const intent = intents[indice].tag;

        console.log("Intent detectado:", intent);

        if (intent === "saludo") {

            return {
                texto: "¡Hola " + nombreUsuario + "! ¿En qué puedo ayudarte hoy?",
                imagen: imagenPensando
            };
        }

        if (intent === "despedida") {

            return {
                texto: "Hasta luego " + nombreUsuario + ", espero verte pronto.",
                imagen: imagenDespidiendoce
            };
        }

        if (intent === "tarea_terminada") {

            return {
                texto: "Excelente trabajo. La tarea será marcada como completada.",
                imagen: imagenSaludo
            };
        }

        if (intent === "solicitar_retroceso") {

            return {
                texto: "Actualmente no puedo regresar la tarea automáticamente. Por favor, comunícate con tu líder para realizar el cambio.",
                imagen: imagenSeria
            };
        }

        if (intent === "ayuda_orientacion") {

            return {
                texto: "Tu tablero Scrum tiene tareas pendientes. Presiona 'Empezar tarea' para comenzar y 'Finalizar tarea' cuando la completes.",
                imagen: imagenPensando
            };
        }

        if (intent === "tablero_vacio") {

            return {
                texto: "El tablero está vacío. Tal vez aún no tienes tareas asignadas, tu lider se encargara de eso.",
                imagen: imagenSeria
            };
        }

        if (intent === "usuario_perdido") {

            return {
                texto: "Organiza tus tareas por prioridad y empieza por la más urgente.",
                imagen: imagenPensando
            };
        }

        if (intent === "consultar_plazo") {

            return {
                texto: "Revisa la fecha límite de la tarea en el sistema para evitar retrasos.",
                imagen: imagenPensando
            };
        }

        if (intent === "cancelar_tarea") {

            return {
                texto: "La cancelación de tareas debe ser realizada por tu líder de proyecto.",
                imagen: imagenSeria
            };
        }

        return {
            texto: "No entendí completamente tu mensaje. ¿Puedes explicarlo de otra forma?",
            imagen: imagenPensando
        };
    }

    if (inputField) {

        inputField.addEventListener("keypress", async (event) => {

            if (event.key === "Enter") {

                const messageText = inputField.value.trim();

                if (messageText === "") return;

                const response = await getEsdeathResponse(messageText);

                textoSaludo.textContent = response.texto;

                if (imageElement) {

                    if (response.imagen) {
                        imageElement.src = response.imagen;
                    }
                    else {
                        imageElement.src = imagenSaludo;
                    }
                }

                inputField.value = "";
            }
        });
    }

});