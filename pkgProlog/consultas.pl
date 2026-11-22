% Puntos de entrada que usa clsPrologEngine. Cada uno escribe un JSON:
%   swipl -q -g alertas_json     -t halt consultas.pl   -> /api/prolog/alertas
%   swipl -q -g sugerencias_json -t halt consultas.pl   -> /api/prolog/sugerir
%   swipl -q -g preguntar_json   -t halt consultas.pl   -> /api/prolog/preguntar
% preguntar_json lee la pregunta como JSON por la entrada estándar.
%
% Para probar a mano: swipl consultas.pl   y luego   ?- bloqueada(T).

:- encoding(utf8).

:- use_module(library(http/json)).

:- [hechos, reglas, gramatica, respuestas].

escribir_json(Dict) :-
    set_stream(user_output, encoding(utf8)),
    json_write_dict(user_output, Dict, [width(0)]),
    nl.

% ---------------------------------------------------------------------------
% Alertas
% ---------------------------------------------------------------------------

alertas_json :-
    alertas(Alertas),
    escribir_json(Alertas).

alertas(_{ fecha: Fecha,
           atrasadas: Atrasadas,
           bloqueadas: Bloqueadas,
           sobrecargados: Sobrecargados,
           proyectosEnRiesgo: Proyectos }) :-
    hoy(Hoy),
    atom_string(Hoy, Fecha),
    findall(A, alerta_atrasada(A), SinOrden),
    sort(diasAtraso, @>=, SinOrden, Atrasadas),
    findall(B, alerta_bloqueada(B), Bloqueadas),
    findall(S, alerta_sobrecargado(S), Sobrecargados),
    findall(P, alerta_proyecto(P), Proyectos).

alerta_atrasada(_{ id: T,
                   nombre: Nombre,
                   proyecto: Proyecto,
                   responsable: Responsable,
                   responsableId: U,
                   fechaLimite: Limite,
                   diasAtraso: Dias }) :-
    dias_atraso(T, Dias),
    datos_tarea(T, Nombre, Proyecto, U, Responsable),
    tarea(T, _, _, _, _, LimiteAtomo),
    atom_string(LimiteAtomo, Limite).

alerta_bloqueada(_{ id: T,
                    nombre: Nombre,
                    proyecto: Proyecto,
                    responsable: Responsable,
                    responsableId: U,
                    esperaA: Previas }) :-
    bloqueada(T),
    datos_tarea(T, Nombre, Proyecto, U, Responsable),
    previas_pendientes(T, Ids),
    nombres_tareas(Ids, Atomos),
    maplist(atom_string, Atomos, Previas).

datos_tarea(T, Nombre, Proyecto, U, Responsable) :-
    tarea(T, NombreAtomo, P, U, _, _),
    proyecto(P, ProyectoAtomo, _, _),
    atom_string(NombreAtomo, Nombre),
    atom_string(ProyectoAtomo, Proyecto),
    nombre_responsable(U, Responsable).

nombre_responsable(U, Nombre) :-
    usuario(U, Atomo, _),
    !,
    atom_string(Atomo, Nombre).
nombre_responsable(_, "Sin asignar").

alerta_sobrecargado(_{ id: U, nombre: Nombre, tareasActivas: N }) :-
    sobrecargado(U),
    tareas_activas(U, N),
    usuario(U, Atomo, _),
    atom_string(Atomo, Nombre).

alerta_proyecto(_{ id: P, nombre: Nombre, motivos: Motivos }) :-
    en_riesgo(P),
    proyecto(P, Atomo, _, _),
    atom_string(Atomo, Nombre),
    findall(Texto, (motivo_riesgo(P, M), texto_motivo(M, Texto)), Motivos).

% ---------------------------------------------------------------------------
% Sugerencias de asignación
% ---------------------------------------------------------------------------

sugerencias_json :-
    ranking_carga(Pares),
    maplist(desarrollador_json, Pares, Ranking),
    (   Ranking = [Sugerido|_]
    ->  true
    ;   Sugerido = null
    ),
    findall(R, reasignacion(R), Reasignaciones),
    escribir_json(_{ sugerido: Sugerido, ranking: Ranking, reasignaciones: Reasignaciones }).

desarrollador_json(N-D, _{ id: D, nombre: Nombre, tareasActivas: N }) :-
    usuario(D, Atomo, _),
    atom_string(Atomo, Nombre).

reasignacion(_{ id: T,
                nombre: Nombre,
                responsable: Responsable,
                sugeridoId: D,
                sugerido: NombreSugerido }) :-
    sugerir(T, D),
    datos_tarea(T, Nombre, _, _, Responsable),
    usuario(D, Atomo, _),
    atom_string(Atomo, NombreSugerido).

% ---------------------------------------------------------------------------
% Preguntas del chatbot
% ---------------------------------------------------------------------------

preguntar_json :-
    set_stream(user_input, encoding(utf8)),
    json_read_dict(user_input, Entrada),
    respuesta_pregunta(Entrada, Salida),
    escribir_json(Salida).

respuesta_pregunta(Entrada, _{ entendido: true, intencion: Intencion, respuesta: Texto }) :-
    get_dict(pregunta, Entrada, Pregunta),
    string(Pregunta),
    interpretar(Pregunta, Consulta),
    !,
    contexto(Entrada, Ctx),
    responder(Consulta, Ctx, Texto),
    functor(Consulta, Nombre, _),
    atom_string(Nombre, Intencion).
respuesta_pregunta(_, _{ entendido: false, intencion: null, respuesta: "" }).

contexto(Entrada, ctx(Id, Vista)) :-
    (   get_dict(idUsuario, Entrada, Id0), integer(Id0)
    ->  Id = Id0
    ;   Id = 0
    ),
    (   get_dict(vista, Entrada, "desarrollador")
    ->  Vista = desarrollador
    ;   Vista = general
    ).
