/*==============================================================*/
/*==============================================================*/
/*          PL/SQL - CONSULTAS, REPORTES Y OBJETOS              */
/*==============================================================*/
/*==============================================================*/


/*==============================================================*/
/* REPORTE 1: LISTAR PROYECTOS Y SU AVANCE                      */
/* CURSOR + FOR LOOP                                            */
/*==============================================================*/

DECLARE
    CURSOR C_PROYECTOS IS
        SELECT NOMBRE, ESTADO_GENERAL, PORCENTAJE_DE_AVANCE
        FROM PROYECTO
        ORDER BY PORCENTAJE_DE_AVANCE DESC;

BEGIN
    DBMS_OUTPUT.PUT_LINE('===== REPORTE DE PROYECTOS =====');

    FOR V_PROY IN C_PROYECTOS LOOP

        DBMS_OUTPUT.PUT_LINE(
            'Proyecto: ' || V_PROY.NOMBRE ||
            ' | Estado: ' || V_PROY.ESTADO_GENERAL ||
            ' | Avance: ' || V_PROY.PORCENTAJE_DE_AVANCE || '%'
        );

    END LOOP;
END;
/

/*==============================================================*/
/* REPORTE 2: TAREAS ATRASADAS                                  */
/* IF + CURSOR                                                   */
/*==============================================================*/

DECLARE
    CURSOR C_TAREAS IS
        SELECT NOMBRE, FECHA_LIMITE
        FROM TAREA;

BEGIN

    DBMS_OUTPUT.PUT_LINE('===== TAREAS ATRASADAS =====');

    FOR V_TAREA IN C_TAREAS LOOP

        IF V_TAREA.FECHA_LIMITE < SYSDATE THEN

            DBMS_OUTPUT.PUT_LINE(
                'Tarea atrasada: ' || V_TAREA.NOMBRE
            );

        END IF;

    END LOOP;

END;
/
/*==============================================================*/
/* REPORTE 3: USO DE WHILE CON CURSOR                           */
/*==============================================================*/

DECLARE

    CURSOR C_USUARIOS IS
        SELECT NOMBRE
        FROM USUARIO;

    V_NOMBRE USUARIO.NOMBRE%TYPE;

BEGIN

    OPEN C_USUARIOS;

    FETCH C_USUARIOS INTO V_NOMBRE;

    WHILE C_USUARIOS%FOUND LOOP

        DBMS_OUTPUT.PUT_LINE(
            'USUARIO: ' || V_NOMBRE
        );

        FETCH C_USUARIOS INTO V_NOMBRE;

    END LOOP;

    CLOSE C_USUARIOS;

END;
/
/*==============================================================*/
/* REPORTE 4: IF ANIDADO CON CURSOR                             */
/*==============================================================*/

DECLARE

    CURSOR C_PROYECTOS IS
        SELECT NOMBRE, PORCENTAJE_DE_AVANCE
        FROM PROYECTO;

    V_NOMBRE   PROYECTO.NOMBRE%TYPE;
    V_AVANCE   PROYECTO.PORCENTAJE_DE_AVANCE%TYPE;

BEGIN

    OPEN C_PROYECTOS;

    LOOP

        FETCH C_PROYECTOS
        INTO V_NOMBRE, V_AVANCE;

        EXIT WHEN C_PROYECTOS%NOTFOUND;

        IF V_AVANCE > 0 THEN

            IF V_AVANCE >= 50 THEN

                DBMS_OUTPUT.PUT_LINE(
                    V_NOMBRE || ' -> BUEN AVANCE'
                );

            ELSE

                DBMS_OUTPUT.PUT_LINE(
                    V_NOMBRE || ' -> AVANCE BAJO'
                );

            END IF;

        ELSE

            DBMS_OUTPUT.PUT_LINE(
                V_NOMBRE || ' -> SIN INICIAR'
            );

        END IF;

    END LOOP;

    CLOSE C_PROYECTOS;

END;
/

/*==============================================================*/
/* REPORTE 5: ESTADO GENERAL DEL PROYECTO                       */
/* CASE                                                         */
/*==============================================================*/

DECLARE

    CURSOR C_ESTADOS IS
        SELECT NOMBRE, PORCENTAJE_DE_AVANCE
        FROM PROYECTO;

BEGIN

    FOR V_ESTADO IN C_ESTADOS LOOP

        CASE

            WHEN V_ESTADO.PORCENTAJE_DE_AVANCE = 100 THEN
                DBMS_OUTPUT.PUT_LINE(
                    V_ESTADO.NOMBRE || ' FINALIZADO'
                );

            WHEN V_ESTADO.PORCENTAJE_DE_AVANCE >= 50 THEN
                DBMS_OUTPUT.PUT_LINE(
                    V_ESTADO.NOMBRE || ' EN BUEN AVANCE'
                );

            ELSE
                DBMS_OUTPUT.PUT_LINE(
                    V_ESTADO.NOMBRE || ' REQUIERE ATENCION'
                );

        END CASE;

    END LOOP;

END;
/

/*==============================================================*/
/* PACKAGE SPECIFICATION                                        */
/*==============================================================*/

CREATE OR REPLACE PACKAGE PKG_USUARIO AS

    PROCEDURE INSERTAR_USUARIO
    (
        P_ID_USUARIO VARCHAR2,
        P_NOMBRE VARCHAR2,
        P_DESCRIPCION VARCHAR2,
        P_CORREO VARCHAR2,
        P_CONTRASENA VARCHAR2,
        P_ID_ROL VARCHAR2
    );

    PROCEDURE ACTUALIZAR_USUARIO
    (
        P_ID_USUARIO VARCHAR2,
        P_NOMBRE VARCHAR2
    );

    PROCEDURE ELIMINAR_USUARIO
    (
        P_ID_USUARIO VARCHAR2
    );

    FUNCTION CONSULTAR_USUARIO
    (
        P_ID_USUARIO VARCHAR2
    )
    RETURN VARCHAR2;

END PKG_USUARIO;
/

/*==============================================================*/
/* PACKAGE BODY                                                 */
/*==============================================================*/

CREATE OR REPLACE PACKAGE BODY PKG_USUARIO AS

    PROCEDURE INSERTAR_USUARIO
    (
        P_ID_USUARIO VARCHAR2,
        P_NOMBRE VARCHAR2,
        P_DESCRIPCION VARCHAR2,
        P_CORREO VARCHAR2,
        P_CONTRASENA VARCHAR2,
        P_ID_ROL VARCHAR2
    )
    IS
    BEGIN

        INSERT INTO USUARIO
        VALUES
        (
            P_ID_USUARIO,
            P_NOMBRE,
            P_DESCRIPCION,
            P_CORREO,
            P_CONTRASENA,
            P_ID_ROL
        );

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('USUARIO YA EXISTE');
    END;

    PROCEDURE ACTUALIZAR_USUARIO
    (
        P_ID_USUARIO VARCHAR2,
        P_NOMBRE VARCHAR2
    )
    IS
    BEGIN

        UPDATE USUARIO
        SET NOMBRE = P_NOMBRE
        WHERE ID_USUARIO = P_ID_USUARIO;

    END;

    PROCEDURE ELIMINAR_USUARIO
    (
        P_ID_USUARIO VARCHAR2
    )
    IS
    BEGIN

        DELETE FROM USUARIO
        WHERE ID_USUARIO = P_ID_USUARIO;

    END;

    FUNCTION CONSULTAR_USUARIO
    (
        P_ID_USUARIO VARCHAR2
    )
    RETURN VARCHAR2
    IS
        V_NOMBRE VARCHAR2(50);

    BEGIN

        SELECT NOMBRE
        INTO V_NOMBRE
        FROM USUARIO
        WHERE ID_USUARIO = P_ID_USUARIO;

        RETURN V_NOMBRE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'NO EXISTE';

    END;

END PKG_USUARIO;
/

/*==============================================================*/
/* EXCEPCION 1                                                  */
/*==============================================================*/

DECLARE
    V_NOMBRE VARCHAR2(50);
BEGIN

    SELECT NOMBRE
    INTO V_NOMBRE
    FROM USUARIO
    WHERE ID_USUARIO = 'X';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('USUARIO NO EXISTE');
END;
/

/*==============================================================*/
/* EXCEPCION 2                                                  */
/*==============================================================*/

DECLARE
    V_RESULTADO NUMBER;
BEGIN

    V_RESULTADO := 10 / 0;

EXCEPTION
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('DIVISION ENTRE CERO');
END;
/

/*==============================================================*/
/* EXCEPCION 3                                                  */
/*==============================================================*/

BEGIN

    INSERT INTO ROL VALUES ('R1', 'ADMIN');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ROL DUPLICADO');

END;
/

/*==============================================================*/
/* EXCEPCION 4                                                  */
/*==============================================================*/

DECLARE
    V_NUMERO NUMBER := 'ABC';

EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('ERROR DE CONVERSION');

END;
/

/*==============================================================*/
/* EXCEPCION 5                                                  */
/*==============================================================*/

BEGIN

    DELETE FROM PROYECTO
    WHERE ID_PROYECTO = 'P1';

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('NO SE PUEDE ELIMINAR');

END;
/

/*==============================================================*/
/* CURSOR CON PARAMETRO                                         */
/*==============================================================*/

DECLARE

    CURSOR C_TAREAS (P_PROYECTO VARCHAR2) IS
        SELECT NOMBRE
        FROM TAREA
        WHERE ID_PROYECTO = P_PROYECTO;

BEGIN

    FOR V_TAREA IN C_TAREAS('P1') LOOP

        DBMS_OUTPUT.PUT_LINE(
            'TAREA: ' || V_TAREA.NOMBRE
        );

    END LOOP;

END;
/

/*==============================================================*/
/* RECORD                                                       */
/*==============================================================*/

DECLARE

    TYPE T_USUARIO IS RECORD
    (
        NOMBRE USUARIO.NOMBRE%TYPE,
        CORREO USUARIO.CORREO%TYPE
    );

    V_USER T_USUARIO;

BEGIN

    SELECT NOMBRE, CORREO
    INTO V_USER
    FROM USUARIO
    WHERE ID_USUARIO = 'U1';

    DBMS_OUTPUT.PUT_LINE(V_USER.NOMBRE);
    DBMS_OUTPUT.PUT_LINE(V_USER.CORREO);

END;
/

/*==============================================================*/
/* TABLE TYPE                                                   */
/*==============================================================*/

DECLARE

    TYPE T_NOMBRES IS TABLE OF VARCHAR2(50);

    V_NOMBRES T_NOMBRES := T_NOMBRES();

BEGIN

    V_NOMBRES.EXTEND(3);

    V_NOMBRES(1) := 'ANA';
    V_NOMBRES(2) := 'CARLOS';
    V_NOMBRES(3) := 'LAURA';

    FOR I IN 1..V_NOMBRES.COUNT LOOP

        DBMS_OUTPUT.PUT_LINE(V_NOMBRES(I));

    END LOOP;

END;
/

/*==============================================================*/
/* BULK COLLECT                                                 */
/*==============================================================*/

DECLARE

    TYPE T_PROYECTOS IS TABLE OF PROYECTO.NOMBRE%TYPE;

    V_PROYECTOS T_PROYECTOS;

BEGIN

    SELECT NOMBRE
    BULK COLLECT INTO V_PROYECTOS
    FROM PROYECTO;

    FOR I IN 1..V_PROYECTOS.COUNT LOOP

        DBMS_OUTPUT.PUT_LINE(V_PROYECTOS(I));

    END LOOP;

END;
/

/*==============================================================*/
/* TRIGGER 1                                                    */
/*==============================================================*/

CREATE OR REPLACE TRIGGER TRG_CORREO
BEFORE INSERT OR UPDATE ON USUARIO
FOR EACH ROW
BEGIN

    IF :NEW.CORREO NOT LIKE '%@gmail.com' THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'EL CORREO DEBE SER GMAIL'
        );
    END IF;

END;
/

/*==============================================================*/
/* TRIGGER 2                                                    */
/*==============================================================*/

CREATE OR REPLACE TRIGGER TRG_FECHAS
BEFORE INSERT OR UPDATE ON TAREA
FOR EACH ROW
BEGIN

    IF :NEW.FECHA_LIMITE < :NEW.FECHA_INICIO THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'FECHA LIMITE INVALIDA'
        );
    END IF;

END;
/

/*==============================================================*/
/* TRIGGER 3                                                    */
/*==============================================================*/

CREATE OR REPLACE TRIGGER TRG_AVANCE
BEFORE UPDATE ON PROYECTO
FOR EACH ROW
BEGIN

    IF :NEW.PORCENTAJE_DE_AVANCE > 100 THEN
        RAISE_APPLICATION_ERROR(
            -20003,
            'AVANCE INVALIDO'
        );
    END IF;

END;
/

/*==============================================================*/
/* TRIGGER 4                                                    */
/*==============================================================*/

CREATE OR REPLACE TRIGGER TRG_PASSWORD
BEFORE INSERT ON USUARIO
FOR EACH ROW
BEGIN

    IF LENGTH(:NEW.CONTRASENA) < 6 THEN
        RAISE_APPLICATION_ERROR(
            -20004,
            'PASSWORD MUY CORTA'
        );
    END IF;

END;
/

/*==============================================================*/
/* VISTA                                                        */
/*==============================================================*/

CREATE OR REPLACE VIEW VW_TAREAS_PROYECTO AS

SELECT
    P.NOMBRE PROYECTO,
    T.NOMBRE TAREA,
    E.NOMBRE ESTADO
FROM PROYECTO P
JOIN TAREA T
    ON P.ID_PROYECTO = T.ID_PROYECTO
JOIN ESTADO E
    ON T.ID_ESTADO = E.ID_ESTADO;
/

/*==============================================================*/
/* CONSULTA TABLAS                                              */
/*==============================================================*/

SELECT TABLE_NAME
FROM USER_TABLES;

/*==============================================================*/
/* CONSULTA PROCEDIMIENTOS                                      */
/*==============================================================*/

SELECT OBJECT_NAME
FROM USER_PROCEDURES;

/*==============================================================*/
/* INDICE 1                                                     */
/*==============================================================*/

CREATE INDEX IDX_USUARIO_CORREO
ON USUARIO(CORREO);

/*==============================================================*/
/* INDICE 2                                                     */
/*==============================================================*/

CREATE INDEX IDX_TAREA_PROYECTO
ON TAREA(ID_PROYECTO);

/*==============================================================*/
/* SECUENCIA 1                                                  */
/*==============================================================*/

CREATE SEQUENCE SEQ_USUARIO
START WITH 100
INCREMENT BY 1;

/*==============================================================*/
/* SECUENCIA 2                                                  */
/*==============================================================*/

CREATE SEQUENCE SEQ_PROYECTO
START WITH 100
INCREMENT BY 1;

/*==============================================================*/
/* FORMATO DE FECHA                                             */
/*==============================================================*/

SELECT
    NOMBRE,
    TO_CHAR(FECHA_INICIO, 'DD/MM/YYYY')
FROM PROYECTO;

/*==============================================================*/
/* SUBCONSULTA                                                  */
/*==============================================================*/

SELECT NOMBRE
FROM USUARIO
WHERE ID_USUARIO IN
(
    SELECT ID_USUARIO_DESARROLLA
    FROM TAREA
);