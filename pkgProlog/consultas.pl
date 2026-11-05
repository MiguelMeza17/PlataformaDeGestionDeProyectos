% Punto de entrada: carga hechos y reglas, y escribe las alertas en JSON.
% El endpoint /api/prolog/alertas lo ejecuta así:
%   swipl -q -g main -t halt consultas.pl

:- encoding(utf8).

:- use_module(library(http/json)).

:- [hechos, reglas].

main :-
    set_stream(user_output, encoding(utf8)),
    alertas(Alertas),
    json_write_dict(user_output, Alertas, [width(0)]),
    nl.

alertas(_{ fecha: Fecha,
           atrasadas: Atrasadas,
           sobrecargados: Sobrecargados,
           proyectosEnRiesgo: Proyectos }) :-
    hoy(Hoy),
    atom_string(Hoy, Fecha),
    findall(A, alerta_atrasada(A), SinOrden),
    sort(diasAtraso, @>=, SinOrden, Atrasadas),
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
    tarea(T, NombreAtomo, P, U, _, LimiteAtomo),
    proyecto(P, ProyectoAtomo, _, _),
    atom_string(NombreAtomo, Nombre),
    atom_string(ProyectoAtomo, Proyecto),
    atom_string(LimiteAtomo, Limite),
    nombre_responsable(U, Responsable).

nombre_responsable(U, Nombre) :-
    usuario(U, Atomo),
    !,
    atom_string(Atomo, Nombre).
nombre_responsable(_, "Sin asignar").

alerta_sobrecargado(_{ id: U, nombre: Nombre, tareasActivas: N }) :-
    sobrecargado(U),
    tareas_activas(U, N),
    usuario(U, Atomo),
    atom_string(Atomo, Nombre).

alerta_proyecto(_{ id: P, nombre: Nombre, motivos: Motivos }) :-
    en_riesgo(P),
    proyecto(P, Atomo, _, _),
    atom_string(Atomo, Nombre),
    findall(Texto, (motivo_riesgo(P, M), texto_motivo(M, Texto)), Motivos).

texto_motivo(vencido(Fecha), Texto) :-
    format(string(Texto), "Pasó su fecha de finalización (~w)", [Fecha]).
texto_motivo(tareas_atrasadas(N), Texto) :-
    format(string(Texto), "Tareas atrasadas: ~d", [N]).
