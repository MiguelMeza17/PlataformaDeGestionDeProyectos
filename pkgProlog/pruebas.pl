% Pruebas de reglas.pl con datos fijos, sin depender de la base de datos.
% Ejecutar desde esta carpeta:
%   swipl -g run_tests -t halt pruebas.pl

:- encoding(utf8).

:- use_module(library(plunit)).

:- [reglas].

hoy('2026-11-05').

proyecto(1, 'Vencido', '2026-10-01', 'InDevelopment').
proyecto(2, 'Con tarea atrasada', '2026-12-31', 'En Proceso').
proyecto(3, 'Terminado en inglés', '2026-01-01', 'Finished').
proyecto(4, 'Terminado en español', '2026-01-01', 'Terminado').
proyecto(5, 'Al día', '2026-12-31', 'InDevelopment').

usuario(10, 'Carga alta').
usuario(20, 'Carga normal').

tarea(100, 'Atrasada', 2, 10, 'InDevelopment', '2026-11-04').
tarea(101, 'Vence hoy', 5, 10, 'ToDevelop', '2026-11-05').
tarea(102, 'Futura', 5, 10, 'InDevelopment', '2026-12-01').
tarea(103, 'Terminada tarde', 5, 20, 'Finished', '2026-01-01').
tarea(104, 'Atrasada de proyecto cerrado', 3, 20, 'ToDevelop', '2026-01-01').
tarea(105, 'Sin responsable', 5, 0, 'ToDevelop', '2026-12-01').

:- begin_tests(reglas).

test(atrasadas, Tareas == [100, 104]) :-
    findall(T, atrasada(T), Tareas).

test(no_atrasada_el_dia_limite, [fail]) :-
    atrasada(101).

test(no_atrasada_si_esta_terminada, [fail]) :-
    atrasada(103).

test(dias_atraso, Dias == 1) :-
    dias_atraso(100, Dias).

test(tareas_activas, N == 3) :-
    tareas_activas(10, N).

test(sobrecargados, Usuarios == [10]) :-
    findall(U, sobrecargado(U), Usuarios).

test(proyectos_en_riesgo, Proyectos == [1, 2]) :-
    findall(P, en_riesgo(P), Proyectos).

test(motivo_vencido, Motivos == [vencido('2026-10-01')]) :-
    findall(M, motivo_riesgo(1, M), Motivos).

test(motivo_tareas_atrasadas, Motivos == [tareas_atrasadas(1)]) :-
    findall(M, motivo_riesgo(2, M), Motivos).

:- end_tests(reglas).
