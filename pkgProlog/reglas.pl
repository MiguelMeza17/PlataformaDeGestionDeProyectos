% Reglas de negocio de la plataforma.
%
% Trabajan sobre estos hechos, que clsPrologData genera desde SQLite en hechos.pl:
%   hoy(Fecha).
%   proyecto(Id, Nombre, FechaFinalizacion, Estado).
%   usuario(Id, Nombre).
%   tarea(Id, Nombre, IdProyecto, IdResponsable, Estado, FechaLimite).
%
% Las fechas son átomos 'yyyy-MM-dd', así que se comparan en orden con @<.
% IdResponsable vale 0 cuando la tarea no tiene a nadie asignado.

:- encoding(utf8).

% A partir de cuántas tareas activas una persona está sobrecargada.
limite_sobrecarga(3).

activa(T) :-
    tarea(T, _, _, _, Estado, _),
    Estado \== 'Finished'.

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

% Cuenta a cualquier usuario, no solo a los Developer: en la base
% también hay tareas asignadas a usuarios con rol Manager.
tareas_activas(U, N) :-
    usuario(U, _),
    aggregate_all(count, (tarea(T, _, _, U, _, _), activa(T)), N).

sobrecargado(U) :-
    tareas_activas(U, N),
    limite_sobrecarga(Limite),
    N >= Limite.

% El formulario del administrador guarda 'Terminado'; los datos iniciales, 'Finished'.
estado_terminado('Finished').
estado_terminado('Terminado').

terminado(P) :-
    proyecto(P, _, _, Estado),
    estado_terminado(Estado).

motivo_riesgo(P, vencido(Fecha)) :-
    proyecto(P, _, Fecha, _),
    \+ terminado(P),
    hoy(Hoy),
    Fecha @< Hoy.
motivo_riesgo(P, tareas_atrasadas(N)) :-
    proyecto(P, _, _, _),
    \+ terminado(P),
    aggregate_all(count, (tarea(T, _, P, _, _, _), atrasada(T)), N),
    N > 0.

en_riesgo(P) :-
    proyecto(P, _, _, _),
    once(motivo_riesgo(P, _)).
