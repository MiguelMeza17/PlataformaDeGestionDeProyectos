% Gramática DCG para las preguntas del chatbot Esdeath.
%
% interpretar/2 convierte una pregunta en español en una consulta:
%   "¿Qué tareas tiene atrasadas Carlos?"   -> atrasadas(persona(103))
%   "¿Por qué está bloqueada Dashboard?"   -> explicar_bloqueo(tarea(102))
%   "¿A quién le asigno CRUD Productos?"   -> sugerir(tarea(101))
%
% La gramática es tolerante: busca las palabras clave en cualquier parte de la
% frase y el backtracking prueba todas las posiciones hasta encontrar una.

:- encoding(utf8).

interpretar(Texto, Consulta) :-
    tokenizar(Texto, Tokens),
    prioridad(Intenciones),
    member(Intencion, Intenciones),
    phrase(intencion(Intencion), Tokens),
    !,
    alcance(Intencion, Tokens, Alcance),
    consulta(Intencion, Alcance, Consulta).

% Si una frase tiene palabras de varias intenciones, gana la primera:
% "¿por qué está bloqueada?" es explicar_bloqueo y no bloqueadas.
prioridad([explicar_bloqueo, sugerir, bloqueadas, atrasadas, sobrecarga, riesgo]).

consulta(bloqueadas, tarea(T), explicar_bloqueo(tarea(T))) :- !.
consulta(Intencion, Alcance, Consulta) :-
    Consulta =.. [Intencion, Alcance].

% ---------------------------------------------------------------------------
% Palabras: minúsculas, sin tildes ni signos
% ---------------------------------------------------------------------------

tokenizar(Texto, Tokens) :-
    string_lower(Texto, Minusculas),
    string_chars(Minusculas, Caracteres),
    maplist(normalizar_caracter, Caracteres, Limpios),
    string_chars(Limpio, Limpios),
    split_string(Limpio, " ", " ", Partes),
    exclude(==(""), Partes, Palabras),
    maplist(atom_string, Tokens, Palabras).

normalizar_caracter(C, N) :-
    sin_tilde(C, N),
    !.
normalizar_caracter(C, C) :-
    char_type(C, alnum),
    !.
normalizar_caracter(_, ' ').

sin_tilde('á', a).
sin_tilde('é', e).
sin_tilde('í', i).
sin_tilde('ó', o).
sin_tilde('ú', u).
sin_tilde('ü', u).
sin_tilde('ñ', n).

% ---------------------------------------------------------------------------
% Intención
% ---------------------------------------------------------------------------

intencion(I) --> cualquiera, clave(I), cualquiera.

clave(explicar_bloqueo) --> por_que, cualquiera, bloqueo.
clave(sugerir)          --> asignacion.
clave(bloqueadas)       --> bloqueo.
clave(atrasadas)        --> atraso.
clave(sobrecarga)       --> sobrecarga.
clave(riesgo)           --> riesgo.

por_que --> [por, que].
por_que --> [porque].

bloqueo --> palabra([bloqueada, bloqueadas, bloqueado, bloqueados, bloqueo, bloqueos,
                     frenada, frenadas, frenado, frenados]).

atraso --> palabra([atrasada, atrasadas, atrasado, atrasados, atraso, atrasos,
                    retrasada, retrasadas, retrasado, retrasados, retraso, retrasos,
                    vencida, vencidas, vencido, vencidos]).
atraso --> [van, tarde].
atraso --> [va, tarde].

sobrecarga --> palabra([sobrecarga, sobrecargado, sobrecargada, sobrecargados, sobrecargadas,
                        saturado, saturada, saturados, saturadas, carga]).
sobrecarga --> [demasiadas, tareas].
sobrecarga --> [demasiado, trabajo].

riesgo --> palabra([riesgo, riesgos, peligro, peligros]).

asignacion --> palabra([asigno, asignar, asignarle, asignarla, asignamos, asigna, asignaria,
                        reasigno, reasignar, sugiere, sugieres, sugerir, sugerencia,
                        recomienda, recomiendas, recomendar]).
asignacion --> [quien, deberia, hacer].
asignacion --> [quien, puede, hacer].

% ---------------------------------------------------------------------------
% De quién o de qué se pregunta
% ---------------------------------------------------------------------------

% Qué menciones tienen sentido para cada intención, de la más específica a la menos.
menciones(atrasadas,        [tarea, proyecto, persona, yo]).
menciones(bloqueadas,       [tarea, proyecto, persona, yo]).
menciones(explicar_bloqueo, [tarea]).
menciones(sobrecarga,       [persona, yo]).
menciones(riesgo,           [proyecto]).
menciones(sugerir,          [tarea]).

alcance(Intencion, Tokens, Alcance) :-
    menciones(Intencion, Tipos),
    member(Tipo, Tipos),
    phrase((cualquiera, mencion(Tipo, Alcance), cualquiera), Tokens),
    !.
alcance(_, _, todos).

% Los nombres vienen de los hechos, así que la gramática reconoce cualquier
% tarea, proyecto o persona que exista en la base de datos.
mencion(tarea, tarea(T)) -->
    { tarea(T, Nombre, _, _, _, _), tokenizar(Nombre, Palabras), Palabras \== [] },
    secuencia(Palabras).
mencion(proyecto, proyecto(P)) -->
    { proyecto(P, Nombre, _, _), tokenizar(Nombre, Completo), forma_corta(Completo, Palabras) },
    secuencia(Palabras).
mencion(persona, persona(U)) -->
    { usuario(U, Nombre, _), tokenizar(Nombre, Palabras), Palabras \== [] },
    secuencia(Palabras).
mencion(yo, yo) -->
    palabra([tengo, mis, mi, estoy, yo, voy]).

% "Sistema Ventas" también se reconoce como "Ventas".
forma_corta(Palabras, Palabras) :-
    Palabras \== [].
forma_corta([sistema|Resto], Resto) :-
    Resto \== [].

% ---------------------------------------------------------------------------
% Auxiliares
% ---------------------------------------------------------------------------

% Cualquier cantidad de palabras, incluida ninguna.
cualquiera --> [].
cualquiera --> [_], cualquiera.

palabra(Opciones) --> [P], { memberchk(P, Opciones) }.

secuencia([]) --> [].
secuencia([P|Ps]) --> [P], secuencia(Ps).
