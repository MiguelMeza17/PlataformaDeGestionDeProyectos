% Respuestas en español para las consultas que produce gramatica.pl.
%
% responder(Consulta, Contexto, Texto)
%   Contexto = ctx(IdUsuario, Vista), con Vista = desarrollador o general.
%   En la vista de desarrollador, las preguntas generales sobre tareas y carga
%   se responden solo con los datos de ese usuario.

:- encoding(utf8).

responder(atrasadas(A0), Ctx, Texto) :-
    ajustar_alcance(A0, Ctx, A),
    responder_atrasadas(A, Ctx, Texto).
responder(bloqueadas(A0), Ctx, Texto) :-
    ajustar_alcance(A0, Ctx, A),
    responder_bloqueadas(A, Ctx, Texto).
responder(explicar_bloqueo(A), _, Texto) :-
    explicar_bloqueo(A, Texto).
responder(sobrecarga(A0), Ctx, Texto) :-
    ajustar_alcance(A0, Ctx, A),
    responder_sobrecarga(A, Ctx, Texto).
responder(riesgo(A), _, Texto) :-
    responder_riesgo(A, Texto).
responder(sugerir(A), _, Texto) :-
    responder_sugerir(A, Texto).

ajustar_alcance(todos, ctx(U, desarrollador), persona(U)) :- U > 0, !.
ajustar_alcance(yo, ctx(U, _), persona(U)) :- U > 0, !.
ajustar_alcance(yo, _, sin_usuario) :- !.
ajustar_alcance(A, _, A).

en_alcance(todos, _).
en_alcance(persona(U), T) :- tarea(T, _, _, U, _, _).
en_alcance(proyecto(P), T) :- tarea(T, _, P, _, _, _).

texto_sin_usuario("No sé quién eres. Inicia sesión para consultar tus tareas.").

% ---------------------------------------------------------------------------
% Tareas atrasadas
% ---------------------------------------------------------------------------

responder_atrasadas(sin_usuario, _, Texto) :-
    !,
    texto_sin_usuario(Texto).
responder_atrasadas(tarea(T), _, Texto) :-
    !,
    explicar_atraso(T, Texto).
responder_atrasadas(A, Ctx, Texto) :-
    findall(D-T, (dias_atraso(T, D), en_alcance(A, T)), Pares),
    sort(1, @>=, Pares, Ordenadas),
    length(Ordenadas, N),
    sujeto(A, Ctx, Sujeto),
    frase_cantidad(Sujeto, N, "tarea atrasada", "tareas atrasadas", Inicio),
    findall(Item,
            ( member(D-T, Ordenadas),
              tarea(T, Nombre, _, _, _, _),
              dias_texto(D, Dias),
              format(string(Item), "~w (~w)", [Nombre, Dias])
            ),
            Items),
    con_detalle(Inicio, Items, Texto).

explicar_atraso(T, Texto) :-
    tarea(T, Nombre, _, _, Estado, Limite),
    (   dias_atraso(T, D)
    ->  estado_texto(Estado, EstadoTexto),
        dias_texto(D, Dias),
        format(string(Texto), "Sí. ~w venció el ~w y sigue ~w: lleva ~w de atraso.",
               [Nombre, Limite, EstadoTexto, Dias])
    ;   terminada(T)
    ->  format(string(Texto), "No. ~w ya está terminada.", [Nombre])
    ;   format(string(Texto), "No. ~w vence el ~w.", [Nombre, Limite])
    ).

% ---------------------------------------------------------------------------
% Tareas bloqueadas
% ---------------------------------------------------------------------------

responder_bloqueadas(sin_usuario, _, Texto) :-
    !,
    texto_sin_usuario(Texto).
responder_bloqueadas(A, Ctx, Texto) :-
    findall(T, (bloqueada(T), en_alcance(A, T)), Tareas),
    length(Tareas, N),
    sujeto(A, Ctx, Sujeto),
    frase_cantidad(Sujeto, N, "tarea bloqueada", "tareas bloqueadas", Inicio),
    findall(Item,
            ( member(T, Tareas),
              tarea(T, Nombre, _, _, _, _),
              previas_pendientes(T, Previas),
              nombres_tareas(Previas, NombresPrevias),
              enumerar(NombresPrevias, Espera),
              format(string(Item), "~w (espera a ~w)", [Nombre, Espera])
            ),
            Items),
    con_detalle(Inicio, Items, Texto).

explicar_bloqueo(todos, "¿Qué tarea quieres revisar? Pregúntame, por ejemplo: ¿por qué está bloqueada Dashboard?").
explicar_bloqueo(tarea(T), Texto) :-
    tarea(T, Nombre, _, _, _, _),
    (   terminada(T)
    ->  format(string(Texto), "~w ya está terminada.", [Nombre])
    ;   bloqueada(T)
    ->  explicar_causa(T, Nombre, Causa),
        nota_ciclo(T, Nota),
        string_concat(Causa, Nota, Texto)
    ;   depende_de(T, _)
    ->  format(string(Texto), "~w no está bloqueada: sus tareas previas ya terminaron.", [Nombre])
    ;   format(string(Texto), "~w no está bloqueada: no depende de otras tareas.", [Nombre])
    ).

% Con una sola previa pendiente se sigue la cadena completa; con varias, se listan.
explicar_causa(T, Nombre, Texto) :-
    previas_pendientes(T, Previas),
    Previas = [_, _|_],
    !,
    nombres_tareas(Previas, Nombres),
    enumerar(Nombres, Lista),
    format(string(Texto), "~w está bloqueada porque depende de ~w, que aún no terminan.", [Nombre, Lista]).
explicar_causa(T, Nombre, Texto) :-
    camino_bloqueo(T, Camino),
    texto_cadena(Camino, Cadena),
    format(string(Texto), "~w está bloqueada porque depende de ~w.", [Nombre, Cadena]).

% Recorre la cadena recursivamente: "Dashboard, que a su vez espera a Login, que sigue en desarrollo".
texto_cadena([T], Texto) :-
    !,
    tarea(T, Nombre, _, _, Estado, _),
    estado_texto(Estado, EstadoTexto),
    format(string(Texto), "~w, que sigue ~w", [Nombre, EstadoTexto]).
texto_cadena([T|Resto], Texto) :-
    tarea(T, Nombre, _, _, _, _),
    texto_cadena(Resto, TextoResto),
    format(string(Texto), "~w, que a su vez espera a ~w", [Nombre, TextoResto]).

nota_ciclo(T, " Ojo: hay una dependencia circular entre sus tareas previas.") :-
    en_ciclo(T),
    !.
nota_ciclo(_, "").

% ---------------------------------------------------------------------------
% Sobrecarga
% ---------------------------------------------------------------------------

responder_sobrecarga(sin_usuario, _, Texto) :-
    !,
    texto_sin_usuario(Texto).
responder_sobrecarga(persona(U), Ctx, Texto) :-
    !,
    tareas_activas(U, N),
    limite_sobrecarga(Limite),
    cantidad(N, "tarea activa", "tareas activas", Activas),
    sujeto(persona(U), Ctx, Sujeto),
    (   sobrecargado(U)
    ->  con_verbo(Sujeto, "tiene", Inicio),
        format(string(Texto), "~w sobrecarga: ~w (el límite es ~d).", [Inicio, Activas, Limite])
    ;   con_verbo(Sujeto, "no tiene", Inicio),
        format(string(Texto), "~w sobrecarga: ~w.", [Inicio, Activas])
    ).
responder_sobrecarga(_, _, Texto) :-
    findall(Item,
            ( sobrecargado(U),
              usuario(U, Nombre, _),
              tareas_activas(U, N),
              cantidad(N, "tarea activa", "tareas activas", Activas),
              format(string(Item), "~w (~w)", [Nombre, Activas])
            ),
            Items),
    (   Items == []
    ->  Texto = "Nadie tiene sobrecarga de tareas."
    ;   enumerar(Items, Lista),
        format(string(Texto), "Con sobrecarga: ~w.", [Lista])
    ).

% ---------------------------------------------------------------------------
% Proyectos en riesgo
% ---------------------------------------------------------------------------

responder_riesgo(proyecto(P), Texto) :-
    !,
    proyecto(P, Nombre, _, _),
    (   en_riesgo(P)
    ->  findall(M, (motivo_riesgo(P, Motivo), texto_motivo(Motivo, M)), Motivos),
        enumerar(Motivos, Lista),
        format(string(Texto), "Sí, ~w está en riesgo: ~w.", [Nombre, Lista])
    ;   proyecto_terminado(P)
    ->  format(string(Texto), "No, ~w ya está terminado.", [Nombre])
    ;   format(string(Texto), "No, ~w no está en riesgo.", [Nombre])
    ).
responder_riesgo(_, Texto) :-
    findall(Nombre, (en_riesgo(P), proyecto(P, Nombre, _, _)), Nombres),
    length(Nombres, N),
    frase_cantidad(hay, N, "proyecto en riesgo", "proyectos en riesgo", Inicio),
    con_detalle(Inicio, Nombres, Texto).

texto_motivo(vencido(Fecha), Texto) :-
    format(string(Texto), "pasó su fecha de finalización (~w)", [Fecha]).
texto_motivo(tareas_atrasadas(N), Texto) :-
    cantidad(N, "tarea atrasada", "tareas atrasadas", Cantidad),
    format(string(Texto), "tiene ~w", [Cantidad]).

% ---------------------------------------------------------------------------
% Sugerencia de asignación
% ---------------------------------------------------------------------------

responder_sugerir(tarea(T), Texto) :-
    !,
    tarea(T, Nombre, _, _, _, _),
    (   terminada(T)
    ->  format(string(Texto), "~w ya está terminada; no hace falta asignarla.", [Nombre])
    ;   candidato_para(T, D, N)
    ->  usuario(D, NombreDev, _),
        cantidad(N, "tarea activa", "tareas activas", Activas),
        format(string(Texto), "Para ~w te sugiero a ~w, que tiene ~w.", [Nombre, NombreDev, Activas])
    ;   Texto = "No hay otro desarrollador disponible para sugerir."
    ).
responder_sugerir(_, Texto) :-
    (   menos_cargado(D, N)
    ->  usuario(D, Nombre, _),
        cantidad(N, "tarea activa", "tareas activas", Activas),
        format(string(Texto), "Te sugiero a ~w: es el desarrollador con menos carga (~w).", [Nombre, Activas])
    ;   Texto = "No hay desarrolladores registrados para sugerir."
    ).

% ---------------------------------------------------------------------------
% Utilidades de texto
% ---------------------------------------------------------------------------

% Quién es el sujeto de la frase: "Hay...", "Tienes..." o "Carlos tiene...".
sujeto(persona(U), ctx(U, _), tu) :- !.
sujeto(persona(U), _, nombre(Nombre)) :- !, usuario(U, Nombre, _).
sujeto(proyecto(P), _, nombre(Nombre)) :- !, proyecto(P, Nombre, _, _).
sujeto(_, _, hay).

frase_cantidad(Sujeto, 0, _, Plural, Texto) :-
    !,
    con_verbo_negado(Sujeto, Inicio),
    format(string(Texto), "~w ~w", [Inicio, Plural]).
frase_cantidad(Sujeto, N, Singular, Plural, Texto) :-
    cantidad(N, Singular, Plural, Cantidad),
    con_verbo(Sujeto, "tiene", Inicio),
    format(string(Texto), "~w ~w", [Inicio, Cantidad]).

con_verbo(hay, _, "Hay") :- !.
con_verbo(tu, "tiene", "Tienes") :- !.
con_verbo(tu, "no tiene", "No tienes") :- !.
con_verbo(nombre(Nombre), Verbo, Texto) :-
    format(string(Texto), "~w ~w", [Nombre, Verbo]).

con_verbo_negado(hay, "No hay").
con_verbo_negado(tu, "No tienes").
con_verbo_negado(nombre(Nombre), Texto) :-
    format(string(Texto), "~w no tiene", [Nombre]).

con_detalle(Inicio, [], Texto) :-
    !,
    format(string(Texto), "~w.", [Inicio]).
con_detalle(Inicio, Items, Texto) :-
    resumir(Items, 4, Lista),
    format(string(Texto), "~w: ~w.", [Inicio, Lista]).

cantidad(1, Singular, _, Texto) :-
    !,
    format(string(Texto), "1 ~w", [Singular]).
cantidad(N, _, Plural, Texto) :-
    format(string(Texto), "~d ~w", [N, Plural]).

dias_texto(D, Texto) :-
    cantidad(D, "día", "días", Texto).

estado_texto('ToDevelop', "por desarrollar") :- !.
estado_texto('InDevelopment', "en desarrollo") :- !.
estado_texto('Finished', "terminada") :- !.
estado_texto(Estado, Texto) :-
    format(string(Texto), "en estado ~w", [Estado]).

nombres_tareas(Ids, Nombres) :-
    findall(Nombre, (member(T, Ids), tarea(T, Nombre, _, _, _, _)), Nombres).

% Muestra como máximo Max elementos: "A, B, C y 2 más".
resumir(Items, Max, Texto) :-
    length(Items, N),
    N > Max,
    !,
    length(Primeros, Max),
    append(Primeros, _, Items),
    Restantes is N - Max,
    atomics_to_string(Primeros, ", ", Inicio),
    format(string(Texto), "~w y ~d más", [Inicio, Restantes]).
resumir(Items, _, Texto) :-
    enumerar(Items, Texto).

% "A", "A y B", "A, B y C".
enumerar([], "").
enumerar([A], Texto) :-
    !,
    format(string(Texto), "~w", [A]).
enumerar([A, B], Texto) :-
    !,
    format(string(Texto), "~w y ~w", [A, B]).
enumerar([A|Resto], Texto) :-
    enumerar(Resto, TextoResto),
    format(string(Texto), "~w, ~w", [A, TextoResto]).
