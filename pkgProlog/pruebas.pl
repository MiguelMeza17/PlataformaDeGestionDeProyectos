% Pruebas de las reglas, la gramática y las respuestas con datos fijos,
% sin depender de la base de datos. Ejecutar desde esta carpeta:
%   swipl -g run_tests -t halt pruebas.pl

:- encoding(utf8).

:- use_module(library(plunit)).

:- [reglas, gramatica, respuestas].

hoy('2026-11-05').

proyecto(1, 'Antiguo', '2026-10-01', 'InDevelopment').
proyecto(2, 'Sistema Ventas', '2026-12-31', 'En Proceso').
proyecto(3, 'Terminado en inglés', '2026-01-01', 'Finished').
proyecto(4, 'Terminado en español', '2026-01-01', 'Terminado').
proyecto(5, 'Al día', '2026-12-31', 'InDevelopment').

usuario(10, 'Pedro', 'Manager').
usuario(20, 'Lucía', 'Developer').
usuario(30, 'Marta', 'Developer').
usuario(40, 'Admin', 'Admin').
usuario(50, 'Equipo Uno', 'Manager').
usuario(60, 'Equipo Dos', 'Manager').
usuario(70, 'Equipo Tres', 'Manager').

tarea(100, 'Atrasada', 2, 10, 'InDevelopment', '2026-11-04').
tarea(101, 'Vence hoy', 5, 10, 'ToDevelop', '2026-11-05').
tarea(102, 'Futura', 5, 10, 'InDevelopment', '2026-12-01').
tarea(103, 'Terminada tarde', 5, 20, 'Finished', '2026-01-01').
tarea(104, 'Atrasada de proyecto cerrado', 3, 20, 'ToDevelop', '2026-01-01').
tarea(105, 'Sin responsable', 5, 0, 'ToDevelop', '2026-12-01').
tarea(106, 'De Marta', 5, 30, 'Finished', '2026-12-01').
% Cadena: Despliegue -> Pruebas -> Base, y una dependencia ya cumplida
tarea(110, 'Base', 5, 50, 'InDevelopment', '2026-12-01').
tarea(111, 'Pruebas', 5, 50, 'ToDevelop', '2026-12-10').
tarea(112, 'Despliegue', 5, 60, 'ToDevelop', '2026-12-20').
tarea(113, 'Manual', 5, 60, 'ToDevelop', '2026-12-20').
% Ciclo: A espera a B y B espera a A
tarea(120, 'Ciclo A', 5, 70, 'ToDevelop', '2026-12-20').
tarea(121, 'Ciclo B', 5, 70, 'ToDevelop', '2026-12-20').

depende_de(111, 110).
depende_de(112, 111).
depende_de(113, 103).
depende_de(120, 121).
depende_de(121, 120).

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

:- begin_tests(dependencias).

test(bloqueadas, Tareas == [111, 112, 120, 121]) :-
    findall(T, bloqueada(T), Tareas).

test(no_bloqueada_si_la_previa_termino, [fail]) :-
    bloqueada(113).

test(requiere_es_transitiva, Previas == [110, 111]) :-
    findall(P, requiere(112, P), Lista),
    sort(Lista, Previas).

test(requiere_termina_con_ciclos, Previas == [120, 121]) :-
    findall(P, requiere(120, P), Lista),
    sort(Lista, Previas).

test(detecta_ciclo) :-
    en_ciclo(120).

test(sin_ciclo, [fail]) :-
    en_ciclo(112).

test(camino_bloqueo, Camino == [111, 110]) :-
    camino_bloqueo(112, Camino).

:- end_tests(dependencias).

:- begin_tests(asignacion).

test(ranking_solo_desarrolladores, Ranking == [0-30, 1-20]) :-
    ranking_carga(Ranking).

test(menos_cargado, D == 30) :-
    menos_cargado(D, _).

test(candidato_menos_cargado, D == 30) :-
    candidato_para(110, D, _).

% Marta es la menos cargada, pero no se sugiere a sí misma para su propia tarea.
test(candidato_excluye_al_responsable, D == 20) :-
    candidato_para(106, D, _).

test(reasignables, Tareas == [101, 105]) :-
    findall(T, reasignable(T), Tareas).

test(sugerir, Pares == [101-30, 105-30]) :-
    findall(T-D, sugerir(T, D), Pares).

:- end_tests(asignacion).

:- begin_tests(gramatica).

test(tokenizar, Tokens == [por, que, esta, bloqueada, la, tarea]) :-
    tokenizar("¿Por qué está BLOQUEADA la tarea?", Tokens).

test(atrasadas_general, C == atrasadas(todos)) :-
    interpretar("¿Qué tareas están atrasadas?", C).

test(atrasadas_de_persona_con_tilde, C == atrasadas(persona(20))) :-
    interpretar("tareas retrasadas de Lucia", C).

test(atrasadas_propias, C == atrasadas(yo)) :-
    interpretar("tengo algo atrasado?", C).

test(atrasadas_de_proyecto_forma_corta, C == atrasadas(proyecto(2))) :-
    interpretar("qué está vencido en Ventas", C).

test(explicar_bloqueo, C == explicar_bloqueo(tarea(112))) :-
    interpretar("¿Por qué está bloqueada Despliegue?", C).

test(bloqueada_con_tarea_es_explicacion, C == explicar_bloqueo(tarea(112))) :-
    interpretar("Despliegue está bloqueada?", C).

test(sugerir_para_tarea, C == sugerir(tarea(105))) :-
    interpretar("¿A quién le asigno Sin responsable?", C).

test(sugerir_general, C == sugerir(todos)) :-
    interpretar("a quién asigno una tarea nueva", C).

test(sobrecarga, C == sobrecarga(todos)) :-
    interpretar("quién está saturado de trabajo", C).

test(sobrecarga_de_persona, C == sobrecarga(persona(10))) :-
    interpretar("Pedro está sobrecargado?", C).

test(riesgo_de_proyecto, C == riesgo(proyecto(1))) :-
    interpretar("el proyecto Antiguo está en peligro?", C).

test(frase_ajena, [fail]) :-
    interpretar("hola, ya terminé mi tarea", _).

:- end_tests(gramatica).

:- begin_tests(respuestas).

test(atrasadas_general, Texto == "Hay 2 tareas atrasadas: Atrasada de proyecto cerrado (308 días) y Atrasada (1 día).") :-
    responder(atrasadas(todos), ctx(40, general), Texto).

test(vista_desarrollador_solo_lo_propio, Texto == "Tienes 1 tarea atrasada: Atrasada de proyecto cerrado (308 días).") :-
    responder(atrasadas(todos), ctx(20, desarrollador), Texto).

test(sin_sesion, Texto == "No sé quién eres. Inicia sesión para consultar tus tareas.") :-
    responder(atrasadas(yo), ctx(0, general), Texto).

test(atraso_de_una_tarea, Texto == "Sí. Atrasada venció el 2026-11-04 y sigue en desarrollo: lleva 1 día de atraso.") :-
    responder(atrasadas(tarea(100)), ctx(0, general), Texto).

test(bloqueadas_general, Texto == "Hay 4 tareas bloqueadas: Pruebas (espera a Base), Despliegue (espera a Pruebas), Ciclo A (espera a Ciclo B) y Ciclo B (espera a Ciclo A).") :-
    responder(bloqueadas(todos), ctx(0, general), Texto).

test(explicar_cadena_recursiva, Texto == "Despliegue está bloqueada porque depende de Pruebas, que a su vez espera a Base, que sigue en desarrollo.") :-
    responder(explicar_bloqueo(tarea(112)), ctx(0, general), Texto).

test(explicar_ciclo, Texto == "Ciclo A está bloqueada porque depende de Ciclo B, que sigue por desarrollar. Ojo: hay una dependencia circular entre sus tareas previas.") :-
    responder(explicar_bloqueo(tarea(120)), ctx(0, general), Texto).

test(explicar_no_bloqueada, Texto == "Manual no está bloqueada: sus tareas previas ya terminaron.") :-
    responder(explicar_bloqueo(tarea(113)), ctx(0, general), Texto).

test(sobrecarga_persona, Texto == "Pedro tiene sobrecarga: 3 tareas activas (el límite es 3).") :-
    responder(sobrecarga(persona(10)), ctx(0, general), Texto).

test(sobrecarga_propia, Texto == "No tienes sobrecarga: 1 tarea activa.") :-
    responder(sobrecarga(todos), ctx(20, desarrollador), Texto).

test(riesgo_proyecto, Texto == "Sí, Antiguo está en riesgo: pasó su fecha de finalización (2026-10-01).") :-
    responder(riesgo(proyecto(1)), ctx(0, general), Texto).

test(riesgo_terminado, Texto == "No, Terminado en español ya está terminado.") :-
    responder(riesgo(proyecto(4)), ctx(0, general), Texto).

test(sugerir_para_tarea, Texto == "Para Pruebas te sugiero a Marta, que tiene 0 tareas activas.") :-
    responder(sugerir(tarea(111)), ctx(0, general), Texto).

test(sugerir_general, Texto == "Te sugiero a Marta: es el desarrollador con menos carga (0 tareas activas).") :-
    responder(sugerir(todos), ctx(0, general), Texto).

:- end_tests(respuestas).
