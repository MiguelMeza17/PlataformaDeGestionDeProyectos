/*==============================================================*/
/*==============================================================*/
/*          PL/SQL - CONSULTAS, REPORTES Y OBJETOS              */
/*==============================================================*/
/*==============================================================*/
DROP VIEW VW_REPORTE_PROYECTOS;

DROP SEQUENCE SEQ_USUARIO;
DROP SEQUENCE SEQ_PROYECTO;

DROP INDEX IDX_USUARIO_CORREO;
DROP INDEX IDX_TAREA_PROYECTO;

DROP PACKAGE PKG_USUARIO;

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
/* CURSOR CON PARAMETRO                                         */
/* REQUISITO FALTANTE                                           */
/*==============================================================*/

DECLARE

    CURSOR C_TAREAS_PROYECTO(P_ID_PROYECTO VARCHAR2) IS
        SELECT NOMBRE
        FROM TAREA
        WHERE ID_PROYECTO = P_ID_PROYECTO;

BEGIN

    FOR V_TAREA IN C_TAREAS_PROYECTO('P1') LOOP

        DBMS_OUTPUT.PUT_LINE(
            'TAREA: ' || V_TAREA.NOMBRE
        );

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
        P_NOMBRE VARCHAR2,
        P_DESCRIPCION VARCHAR2,
        P_CORREO VARCHAR2,
        P_CONTRASENA VARCHAR2,
        P_ID_ROL VARCHAR2
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
        P_NOMBRE VARCHAR2,
        P_DESCRIPCION VARCHAR2,
        P_CORREO VARCHAR2,
        P_CONTRASENA VARCHAR2,
        P_ID_ROL VARCHAR2
    )
    IS
    BEGIN

        UPDATE USUARIO
        SET
        NOMBRE = P_NOMBRE,
        DESCRIPCION = P_DESCRIPCION,
        CORREO = P_CORREO,
        CONTRASENA = P_CONTRASENA,
        ID_ROL = P_ID_ROL
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
/*
BEGIN

    PKG_USUARIO.INSERTAR_USUARIO
    (
        'U10',
        'Oscar',
        'Admin',
        'oscar@gmail.com',
        '123456',
        'R1'
    );

END;
/
*/
/*==============================================================*/
/* TIPOS COMPUESTOS + BULK COLLECT + RECORD + TABLE             */
/*==============================================================*/

DECLARE

    /* RECORD */
    TYPE REC_USUARIO IS RECORD
    (
        NOMBRE USUARIO.NOMBRE%TYPE,
        CORREO USUARIO.CORREO%TYPE
    );

    /* TABLE */
    TYPE TAB_PROYECTOS IS TABLE OF PROYECTO.NOMBRE%TYPE;

    V_USUARIO REC_USUARIO;
    V_PROYECTOS TAB_PROYECTOS;

BEGIN

    /* RECORD */
    SELECT NOMBRE, CORREO
    INTO V_USUARIO
    FROM USUARIO
    WHERE ID_USUARIO = 'U1';

    DBMS_OUTPUT.PUT_LINE(
        'USUARIO: ' || V_USUARIO.NOMBRE ||
        ' | CORREO: ' || V_USUARIO.CORREO
    );

    /* BULK COLLECT */
    SELECT NOMBRE
    BULK COLLECT INTO V_PROYECTOS
    FROM PROYECTO
    WHERE PORCENTAJE_DE_AVANCE >= 20
    ORDER BY PORCENTAJE_DE_AVANCE DESC;

    /* TABLE */
    FOR I IN 1..V_PROYECTOS.COUNT LOOP

        DBMS_OUTPUT.PUT_LINE(
            'PROYECTO: ' || V_PROYECTOS(I)
        );

    END LOOP;

END;
/

/*==============================================================*/
/* TRIGGER 1                                                     */
/* VALIDAR CORREO GMAIL                                         */
/*==============================================================*/

CREATE OR REPLACE TRIGGER TRG_CORREO_USUARIO
BEFORE INSERT OR UPDATE ON USUARIO
FOR EACH ROW
BEGIN

    IF :NEW.CORREO NOT LIKE '%@gmail.com' THEN

        RAISE_APPLICATION_ERROR
        (
            -20001,
            'EL CORREO DEBE SER GMAIL'
        );

    END IF;

END;
/

/*==============================================================*/
/* TRIGGER 2                                                     */
/* VALIDAR FECHAS DE TAREA                                      */
/*==============================================================*/

CREATE OR REPLACE TRIGGER TRG_FECHAS_TAREA
BEFORE INSERT OR UPDATE ON TAREA
FOR EACH ROW
BEGIN

    IF :NEW.FECHA_LIMITE < :NEW.FECHA_INICIO THEN

        RAISE_APPLICATION_ERROR
        (
            -20002,
            'LA FECHA LIMITE NO PUEDE SER MENOR'
        );

    END IF;

END;
/

/*==============================================================*/
/* TRIGGER 3                                                     */
/* VALIDAR PORCENTAJE                                            */
/*==============================================================*/

CREATE OR REPLACE TRIGGER TRG_AVANCE_PROYECTO
BEFORE INSERT OR UPDATE ON PROYECTO
FOR EACH ROW
BEGIN

    IF :NEW.PORCENTAJE_DE_AVANCE > 100 THEN

        RAISE_APPLICATION_ERROR
        (
            -20003,
            'EL AVANCE NO PUEDE SER MAYOR A 100'
        );

    END IF;

END;
/

/*==============================================================*/
/* TRIGGER 4                                                     */
/* VALIDAR LONGITUD PASSWORD                                     */
/*==============================================================*/

CREATE OR REPLACE TRIGGER TRG_PASSWORD_USUARIO
BEFORE INSERT OR UPDATE ON USUARIO
FOR EACH ROW
BEGIN

    IF LENGTH(:NEW.CONTRASENA) < 6 THEN

        RAISE_APPLICATION_ERROR
        (
            -20004,
            'PASSWORD DEMASIADO CORTA'
        );

    END IF;

END;
/

/*==============================================================*/
/* VISTA                                                         */
/* JOINS + CONDICIONES + ORDENAMIENTO                            */
/*==============================================================*/
/*==============================================================*/
/* VISTA                                                         */
/* JOINS + GROUP BY + FUNCIONES + SUBCONSULTA + ORDER BY        */
/*==============================================================*/

CREATE OR REPLACE VIEW VW_REPORTE_PROYECTOS AS

SELECT
    P.NOMBRE AS PROYECTO,
    COUNT(T.ID_TAREA) AS TOTAL_TAREAS,
    AVG(P.PORCENTAJE_DE_AVANCE) AS PROMEDIO_AVANCE,
    TO_CHAR(P.FECHA_INICIO, 'DD/MM/YYYY') AS FECHA_INICIO
FROM PROYECTO P
INNER JOIN TAREA T
    ON P.ID_PROYECTO = T.ID_PROYECTO
WHERE P.ID_PROYECTO IN
(
    SELECT ID_PROYECTO
    FROM REPORTES
)
GROUP BY P.NOMBRE, P.FECHA_INICIO
HAVING COUNT(T.ID_TAREA) > 0
ORDER BY TOTAL_TAREAS DESC, P.NOMBRE ASC;
/
--SELECT * FROM VW_REPORTE_PROYECTOS;

/*==============================================================*/
/* DICCIONARIO DE DATOS                                          */
/*==============================================================*/

/* TABLAS */

SELECT TABLE_NAME
FROM USER_TABLES
ORDER BY TABLE_NAME;

/* PROCEDIMIENTOS Y FUNCIONES */

SELECT OBJECT_NAME, OBJECT_TYPE
FROM USER_PROCEDURES
ORDER BY OBJECT_NAME;

/*==============================================================*/
/* INDICES                                                       */
/*==============================================================*/

/*
SE CREA ESTE INDICE PORQUE EL CORREO ES MUY CONSULTADO
AL MOMENTO DE INICIAR SESION O BUSCAR USUARIOS
*/

CREATE INDEX IDX_USUARIO_CORREO
ON USUARIO(CORREO);

/*
SE CREA ESTE INDICE PORQUE ID_PROYECTO ES UTILIZADO
EN JOINS Y CONSULTAS FRECUENTES SOBRE TAREAS
*/

CREATE INDEX IDX_TAREA_PROYECTO
ON TAREA(ID_PROYECTO);

/*==============================================================*/
/* SECUENCIAS                                                    */
/*==============================================================*/

CREATE SEQUENCE SEQ_USUARIO
START WITH 100
INCREMENT BY 1;

CREATE SEQUENCE SEQ_PROYECTO
START WITH 100
INCREMENT BY 1;