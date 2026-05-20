/*==============================================================*/
/* PL/SQL - CONSULTAS, REPORTES Y OBJETOS                */
/*==============================================================*/
/*==============================================================*/


/*==============================================================*/
/* REPORTE : LISTAR PROYECTOS Y SU AVANCE                       */                                 */
/*==============================================================*/

SET SERVEROUTPUT ON;

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
/* REPORTE : TAREAS ATRASADAS                                   */                                   */
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
/* REPORTE : TAREAS DE UN PROYECTO                              */
/*==============================================================*/

DECLARE

    CURSOR C_TAREAS (P_PROYECTO PROYECTO.ID_PROYECTO%TYPE) IS
        SELECT NOMBRE
        FROM TAREA
        WHERE ID_PROYECTO = P_PROYECTO;

BEGIN

    FOR V_TAREA IN C_TAREAS(100) LOOP

        DBMS_OUTPUT.PUT_LINE(
            'TAREA: ' || V_TAREA.NOMBRE
        );

    END LOOP;

END;
/
/*==============================================================*/
/* REPORTE 4: AVANCE DE UN PROYECTO                             */
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
/* REPORTE 5: ESTADO GENERAL DEL PROYECTO                       */                                         */
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
/* PACKAGE USUARIO                                              */
/*==============================================================*/

CREATE OR REPLACE PACKAGE PKG_USUARIO AS

    PROCEDURE INSERTAR_USUARIO
    (
        P_NOMBRE VARCHAR2,
        P_DESCRIPCION VARCHAR2,
        P_CORREO VARCHAR2,
        P_CONTRASENA VARCHAR2,
        P_ID_ROL VARCHAR2
    );

    PROCEDURE ACTUALIZAR_USUARIO
    (
        P_ID_USUARIO NUMBER,
        P_NOMBRE VARCHAR2,
        P_DESCRIPCION VARCHAR2,
        P_CORREO VARCHAR2,
        P_CONTRASENA VARCHAR2,
        P_ID_ROL VARCHAR2
    );

    PROCEDURE ELIMINAR_USUARIO
    (
        P_ID_USUARIO NUMBER
    );

    FUNCTION CONSULTAR_USUARIO
    (
        P_ID_USUARIO NUMBER
    )
    RETURN VARCHAR2;

END PKG_USUARIO;
/
CREATE OR REPLACE PACKAGE BODY PKG_USUARIO AS

    PROCEDURE INSERTAR_USUARIO
    (
        P_NOMBRE VARCHAR2,
        P_DESCRIPCION VARCHAR2,
        P_CORREO VARCHAR2,
        P_CONTRASENA VARCHAR2,
        P_ID_ROL VARCHAR2
    )
    IS
    BEGIN

        INSERT INTO USUARIO (NOMBRE, DESCRIPCION, CORREO, CONTRASENA, ID_ROL)
        VALUES (P_NOMBRE, P_DESCRIPCION, P_CORREO, P_CONTRASENA, P_ID_ROL);

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('USUARIO YA EXISTE');
    END;

    PROCEDURE ACTUALIZAR_USUARIO
    (
        P_ID_USUARIO NUMBER,
        P_NOMBRE VARCHAR2,
        P_DESCRIPCION VARCHAR2,
        P_CORREO VARCHAR2,
        P_CONTRASENA VARCHAR2,
        P_ID_ROL VARCHAR2
    )
    IS
    BEGIN
        UPDATE USUARIO
        SET NOMBRE = P_NOMBRE,
            DESCRIPCION = P_DESCRIPCION,
            CORREO = P_CORREO,
            CONTRASENA = P_CONTRASENA,
            ID_ROL = P_ID_ROL
        WHERE ID_USUARIO = P_ID_USUARIO;
    END;

    PROCEDURE ELIMINAR_USUARIO
    (
        P_ID_USUARIO NUMBER
    )
    IS
    BEGIN

        DELETE FROM USUARIO
        WHERE ID_USUARIO = P_ID_USUARIO;

    END;

    FUNCTION CONSULTAR_USUARIO
    (
        P_ID_USUARIO NUMBER
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
SELECT * FROM USUARIO

BEGIN
    PKG_USUARIO.INSERTAR_USUARIO(
       'Camilo',
       'Desde la Web',
       'lagos@gmail.com',
       'q1w2e3r4',
       'R3'
    );
    COMMIT;
END;
/

/*==============================================================*/
/* RECORD USUARIOS Y SUS CONTRASEÑAS                            */
/*==============================================================*/

DECLARE

    TYPE T_USUARIO IS RECORD
    (
        NOMBRE      USUARIO.NOMBRE%TYPE,
        CONTRASENA  USUARIO.CONTRASENA%TYPE
    );

    TYPE T_TABLA_USUARIOS IS TABLE OF T_USUARIO;

    V_USUARIOS T_TABLA_USUARIOS;

BEGIN

    SELECT NOMBRE, CONTRASENA
    BULK COLLECT INTO V_USUARIOS
    FROM USUARIO;

    FOR I IN 1 .. V_USUARIOS.COUNT LOOP

        DBMS_OUTPUT.PUT_LINE(
            'NOMBRE: ' || V_USUARIOS(I).NOMBRE ||
            ' | CONTRASEÑA: ' || V_USUARIOS(I).CONTRASENA
        );

    END LOOP;

END;
/


/*==============================================================*/
/* TRIGGER CORREO                                               */
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

BEGIN
    PKG_USUARIO.ACTUALIZAR_USUARIO(
       105,
       'MiguelMeza',
       'Desde la Web',
       'miguel@gmail.com',
       'q1w2e3r4t5',
       'R3'
    );
    COMMIT;
END;
/
/*==============================================================*/
/* TRIGGER FECHA LIMITE TAREA                                   */
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
/* TRIGGER PROYECTO AVANCE                                      */
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
/* TRIGGER LONGITUD CONTRASEÑA                                  */
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