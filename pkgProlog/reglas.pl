% Reglas de negocio de la plataforma.
%
% Trabajan sobre estos hechos, que clsPrologData genera desde SQLite en hechos.pl:
%   hoy(Fecha).
%   proyecto(Id, Nombre, FechaFinalizacion, Estado).
%   usuario(Id, Nombre, Rol).                  Rol: 'Admin', 'Manager' o 'Developer'
%   tarea(Id, Nombre, IdProyecto, IdResponsable, Estado, FechaLimite).
%   depende_de(IdTarea, IdTareaPrevia).        IdTarea no puede empezar hasta que termine IdTareaPrevia
%
% Las fechas son átomos 'yyyy-MM-dd', así que se comparan en orden con @<.
% IdResponsable vale 0 cuando la tarea no tiene a nadie asignado.

:- encoding(utf8).

% A partir de cuántas tareas activas una persona está sobrecargada.
limite_sobrecarga(3).

% ---------------------------------------------------------------------------
% Estado de las tareas
% ---------------------------------------------------------------------------

terminada(T) :-
    tarea(T, _, _, _, 'Finished', _).

activa(T) :-
    tarea(T, _, _, _, _, _),
    \+ terminada(T).

atrasada(T) :-
    activa(T),
    tarea(T, _, _, _, _, Limite),
    hoy(Hoy),
    Limite @< Hoy.

dias_atraso(T, Dias) :-
    atrasada(T),
    tarea(T, _, _, _, _, Limite),
    hoy(Hoy),
    parse_time(Limite, iso_8601, Inicio),
    parse_time(Hoy, iso_8601, Fin),
    Dias is round((Fin - Inicio) / 86400).

% ---------------------------------------------------------------------------
% Dependencias entre tareas
% ---------------------------------------------------------------------------

% Una tarea activa está bloqueada si alguna de sus tareas previas no ha terminado.
bloqueada(T) :-
    activa(T),
    once((depende_de(T, Previa), \+ terminada(Previa))).

% Tareas previas directas que todavía no terminan.
previas_pendientes(T, Previas) :-
    findall(P, (depende_de(T, P), \+ terminada(P)), Previas).

% requiere(T, P): T necesita que P termine, directa o indirectamente.
% Es recursiva; la lista de visitadas evita un ciclo infinito si los datos
% tienen dependencias circulares (A espera a B y B espera a A).
requiere(T, P) :-
    requiere(T, P, [T]).

requiere(T, P, _) :-
    depende_de(T, P).
requiere(T, P, Visitadas) :-
    depende_de(T, Intermedia),
    \+ memberchk(Intermedia, Visitadas),
    requiere(Intermedia, P, [Intermedia|Visitadas]).

en_ciclo(T) :-
    once(requiere(T, T)).

% camino_bloqueo(T, Camino): cadena de tareas pendientes que frenan a T,
% desde la previa directa hasta la que ya no espera a ninguna.
% Ejemplo: Seguridad -> [Dashboard, Login].
camino_bloqueo(T, [Previa|Resto]) :-
    depende_de(T, Previa),
    \+ terminada(Previa),
    !,
    seguir_camino(Previa, [T, Previa], Resto).

seguir_camino(T, Visitadas, [Previa|Resto]) :-
    depende_de(T, Previa),
    \+ terminada(Previa),
    \+ memberchk(Previa, Visitadas),
    !,
    seguir_camino(Previa, [Previa|Visitadas], Resto).
seguir_camino(_, _, []).

% ---------------------------------------------------------------------------
% Carga de trabajo y asignación
% ---------------------------------------------------------------------------

% Cuenta a cualquier usuario, no solo a los Developer: en la base
% también hay tareas asignadas a usuarios con rol Manager.
tareas_activas(U, N) :-
    usuario(U, _, _),
    aggregate_all(count, (tarea(T, _, _, U, _, _), activa(T)), N).

sobrecargado(U) :-
    tareas_activas(U, N),
    limite_sobrecarga(Limite),
    N >= Limite.

% Solo se sugieren usuarios con rol Developer, igual que el formulario del líder.
desarrollador(D) :-
    usuario(D, _, 'Developer').

carga(D, N) :-
    desarrollador(D),
    tareas_activas(D, N).

% Desarrolladores ordenados por carga; si empatan, por Id.
ranking_carga(Ranking) :-
    findall(N-D, carga(D, N), Pares),
    msort(Pares, Ranking).

menos_cargado(D, N) :-
    ranking_carga([N-D|_]).

% Mejor candidato para la tarea T, sin contar a su responsable actual.
candidato_para(T, D, N) :-
    tarea(T, _, _, Actual, _, _),
    findall(N0-D0, (carga(D0, N0), D0 \== Actual), Pares),
    msort(Pares, [N-D|_]).

% Una tarea que no ha empezado conviene (re)asignarla si no tiene responsable
% o si su responsable está sobrecargado.
reasignable(T) :-
    tarea(T, _, _, Responsable, 'ToDevelop', _),
    (   Responsable == 0
    ->  true
    ;   sobrecargado(Responsable)
    ).

sugerir(T, D) :-
    reasignable(T),
    candidato_para(T, D, _).

% ---------------------------------------------------------------------------
% Proyectos
% ---------------------------------------------------------------------------

% El formulario del administrador guarda 'Terminado'; los datos iniciales, 'Finished'.
estado_terminado('Finished').
estado_terminado('Terminado').

proyecto_terminado(P) :-
    proyecto(P, _, _, Estado),
    estado_terminado(Estado).

motivo_riesgo(P, vencido(Fecha)) :-
    proyecto(P, _, Fecha, _),
    \+ proyecto_terminado(P),
    hoy(Hoy),
    Fecha @< Hoy.
motivo_riesgo(P, tareas_atrasadas(N)) :-
    proyecto(P, _, _, _),
    \+ proyecto_terminado(P),
    aggregate_all(count, (tarea(T, _, P, _, _, _), atrasada(T)), N),
    N > 0.

en_riesgo(P) :-
    proyecto(P, _, _, _),
    once(motivo_riesgo(P, _)).
