SET SERVEROUTPUT ON;

/*==============================================================*/
/*                          PAQUETES                            */                                   
/*==============================================================*/

/*==============================================================*/
/* PAQUETE ROL                                                  */                                   
/*==============================================================*/
CREATE OR REPLACE PACKAGE PKG_ROL AS
    PROCEDURE INSERTAR(p_id IN NUMBER, p_nom IN VARCHAR2);
    PROCEDURE ACTUALIZAR(p_id IN NUMBER, p_nom IN VARCHAR2);
    PROCEDURE ELIMINAR(p_id IN NUMBER);
    FUNCTION CONSULTAR(p_id IN NUMBER) RETURN VARCHAR2;
END PKG_ROL;
/

CREATE OR REPLACE PACKAGE BODY PKG_ROL AS
    PROCEDURE INSERTAR(p_id IN NUMBER, p_nom IN VARCHAR2) IS
    BEGIN
        INSERT INTO ROL (ID_ROL, NOMBRE) VALUES (p_id, p_nom);
        COMMIT;
    END INSERTAR;

    PROCEDURE ACTUALIZAR(p_id IN NUMBER, p_nom IN VARCHAR2) IS
    BEGIN
        UPDATE ROL SET NOMBRE = p_nom WHERE ID_ROL = p_id;
        COMMIT;
    END ACTUALIZAR;

    PROCEDURE ELIMINAR(p_id IN NUMBER) IS
    BEGIN
        DELETE FROM ROL WHERE ID_ROL = p_id;
        COMMIT;
    END ELIMINAR;

    FUNCTION CONSULTAR(p_id IN NUMBER) RETURN VARCHAR2 IS
        v_nom ROL.NOMBRE%TYPE;
    BEGIN
        SELECT NOMBRE INTO v_nom FROM ROL WHERE ID_ROL = p_id;
        RETURN v_nom;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END CONSULTAR;

END PKG_ROL;
/
/*==============================================================*/
/* PAQUETE ESTADO                                               */                                   
/*==============================================================*/

CREATE OR REPLACE PACKAGE PKG_ESTADO AS
    PROCEDURE INSERTAR(p_id IN NUMBER, p_nom IN VARCHAR2);
    PROCEDURE ACTUALIZAR(p_id IN NUMBER, p_nom IN VARCHAR2);
    PROCEDURE ELIMINAR(p_id IN NUMBER);
    FUNCTION CONSULTAR(p_id IN NUMBER) RETURN VARCHAR2;
END PKG_ESTADO;
/

CREATE OR REPLACE PACKAGE BODY PKG_ESTADO AS
    PROCEDURE INSERTAR(p_id IN NUMBER, p_nom IN VARCHAR2) IS
    BEGIN
        INSERT INTO ESTADO (ID_ESTADO, NOMBRE) VALUES (p_id, p_nom);
        COMMIT;
    END INSERTAR;

    PROCEDURE ACTUALIZAR(p_id IN NUMBER, p_nom IN VARCHAR2) IS
    BEGIN
        UPDATE ESTADO SET NOMBRE = p_nom WHERE ID_ESTADO = p_id;
        COMMIT;
    END ACTUALIZAR;

    PROCEDURE ELIMINAR(p_id IN NUMBER) IS
    BEGIN
        DELETE FROM ESTADO WHERE ID_ESTADO = p_id;
        COMMIT;
    END ELIMINAR;

    FUNCTION CONSULTAR(p_id IN NUMBER) RETURN VARCHAR2 IS
        v_nom ESTADO.NOMBRE%TYPE;
    BEGIN
        SELECT NOMBRE INTO v_nom FROM ESTADO WHERE ID_ESTADO = p_id;
        RETURN v_nom;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END CONSULTAR;

END PKG_ESTADO;
/

/*==============================================================*/
/* PAQUETE PROYECTO                                             */                                   
/*==============================================================*/

CREATE OR REPLACE PACKAGE PKG_PROYECTO AS
    PROCEDURE INSERTAR(p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fi IN DATE, p_ff IN DATE, p_eg IN VARCHAR2, p_av IN NUMBER);
    PROCEDURE ACTUALIZAR(p_id IN NUMBER, p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fi IN DATE, p_ff IN DATE, p_eg IN VARCHAR2, p_av IN NUMBER);
    PROCEDURE ELIMINAR(p_id IN NUMBER);
    FUNCTION CONSULTAR(p_id IN NUMBER) RETURN VARCHAR2;
    
END PKG_PROYECTO;
/

CREATE OR REPLACE PACKAGE BODY PKG_PROYECTO AS
    PROCEDURE INSERTAR(p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fi IN DATE, p_ff IN DATE, p_eg IN VARCHAR2, p_av IN NUMBER) IS
    BEGIN
        INSERT INTO PROYECTO (NOMBRE, DESCRIPCION, FECHA_INICIO, FECHA_FINALIZACION, ESTADO_GENERAL, PORCENTAJE_DE_AVANCE) 
        VALUES (p_nom, p_desc, p_fi, p_ff, p_eg, p_av);
        COMMIT;
    END INSERTAR;

    PROCEDURE ACTUALIZAR(p_id IN NUMBER, p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fi IN DATE, p_ff IN DATE, p_eg IN VARCHAR2, p_av IN NUMBER) IS
    BEGIN
        UPDATE PROYECTO SET NOMBRE = p_nom, DESCRIPCION = p_desc, FECHA_INICIO = p_fi, FECHA_FINALIZACION = p_ff, ESTADO_GENERAL = p_eg, PORCENTAJE_DE_AVANCE = p_av 
        WHERE ID_PROYECTO = p_id;
        COMMIT;
    END ACTUALIZAR;

    PROCEDURE ELIMINAR(p_id IN NUMBER) IS
    BEGIN
        DELETE FROM PROYECTO WHERE ID_PROYECTO = p_id;
        COMMIT;
    END ELIMINAR;

    FUNCTION CONSULTAR(p_id IN NUMBER) RETURN VARCHAR2 IS
        v_nom PROYECTO.NOMBRE%TYPE;
    BEGIN
        SELECT NOMBRE INTO v_nom FROM PROYECTO WHERE ID_PROYECTO = p_id;
        RETURN v_nom;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END CONSULTAR;

END PKG_PROYECTO;
/
/*==============================================================*/
/* PAQUETE USUARIO                                            */                                   
/*==============================================================*/

CREATE OR REPLACE PACKAGE PKG_USUARIO AS
    PROCEDURE INSERTAR(p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_cor IN VARCHAR2, p_pas IN VARCHAR2, p_rol IN NUMBER);
    PROCEDURE ACTUALIZAR(p_id IN NUMBER, p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_cor IN VARCHAR2, p_pas IN VARCHAR2, p_rol IN NUMBER);
    PROCEDURE ELIMINAR(p_id IN NUMBER);
    FUNCTION CONSULTAR(p_id IN NUMBER) RETURN VARCHAR2;
    PROCEDURE LISTAR_USUARIOS;
    PROCEDURE LISTAR_USUARIOS_EN_DESARROLLO;
END PKG_USUARIO;
/

CREATE OR REPLACE PACKAGE BODY PKG_USUARIO AS
    PROCEDURE INSERTAR(p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_cor IN VARCHAR2, p_pas IN VARCHAR2, p_rol IN NUMBER) IS
    BEGIN
        INSERT INTO USUARIO (NOMBRE, DESCRIPCION, CORREO, CONTRASENA, ID_ROL) VALUES (p_nom, p_desc, p_cor, p_pas, p_rol);
        COMMIT;
    END INSERTAR;

    PROCEDURE ACTUALIZAR(p_id IN NUMBER, p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_cor IN VARCHAR2, p_pas IN VARCHAR2, p_rol IN NUMBER) IS
    BEGIN
        UPDATE USUARIO SET NOMBRE = p_nom, DESCRIPCION = p_desc, CORREO = p_cor, CONTRASENA = p_pas, ID_ROL = p_rol WHERE ID_USUARIO = p_id;
        COMMIT;
    END ACTUALIZAR;

    PROCEDURE ELIMINAR(p_id IN NUMBER) IS
    BEGIN
        DELETE FROM USUARIO WHERE ID_USUARIO = p_id;
        COMMIT;
    END ELIMINAR;

    FUNCTION CONSULTAR(p_id IN NUMBER) RETURN VARCHAR2 IS
        v_nom USUARIO.NOMBRE%TYPE;
    BEGIN
        SELECT NOMBRE INTO v_nom FROM USUARIO WHERE ID_USUARIO = p_id;
        RETURN v_nom;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END CONSULTAR;

    PROCEDURE LISTAR_USUARIOS IS
         /* RECORD */
    TYPE REC_USUARIO IS RECORD
    (
        NOMBRE USUARIO.NOMBRE%TYPE,
        CORREO USUARIO.CORREO%TYPE
    );

    /* TABLE DE RECORDS */
    TYPE TAB_USUARIOS IS TABLE OF REC_USUARIO;

    V_USUARIOS TAB_USUARIOS;

BEGIN

    /* BULK COLLECT */
    SELECT NOMBRE, CORREO
    BULK COLLECT INTO V_USUARIOS
    FROM USUARIO;

    /* FOR */
    FOR I IN 1 .. V_USUARIOS.COUNT LOOP

        DBMS_OUTPUT.PUT_LINE
        (
            'USUARIO: ' || V_USUARIOS(I).NOMBRE ||
            ' | CORREO: ' || V_USUARIOS(I).CORREO
        );

    END LOOP;
    END LISTAR_USUARIOS;

    PROCEDURE LISTAR_USUARIOS_EN_DESARROLLO IS
        CURSOR C_DATA IS
            SELECT U.NOMBRE AS USUARIO, P.NOMBRE AS PROYECTO
            FROM USUARIO U
            INNER JOIN TAREA T ON U.ID_USUARIO = T.ID_USUARIO_DESARROLLA
            INNER JOIN PROYECTO P ON T.ID_PROYECTO = P.ID_PROYECTO
            WHERE P.ESTADO_GENERAL = 'InDevelopment'
            ORDER BY U.NOMBRE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('===== USUARIOS Y PROYECTOS EN DESARROLLO =====');
        FOR R IN C_DATA LOOP
            DBMS_OUTPUT.PUT_LINE('Usuario: ' || R.USUARIO || ' | Proyecto: ' || R.PROYECTO);
        END LOOP;
    END LISTAR_USUARIOS_EN_DESARROLLO;

END PKG_USUARIO;
/

/*==============================================================*/
/* PAQUETE TAREA                                                */                                   
/*==============================================================*/

CREATE OR REPLACE PACKAGE PKG_TAREA AS
    PROCEDURE INSERTAR(p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fi IN DATE, p_fl IN DATE, p_ide IN NUMBER, p_idp IN NUMBER, p_idua IN NUMBER, p_idud IN NUMBER);
    PROCEDURE ACTUALIZAR(p_idt IN NUMBER, p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fi IN DATE, p_fl IN DATE, p_ide IN NUMBER, p_idp IN NUMBER, p_idua IN NUMBER, p_idud IN NUMBER);
    PROCEDURE ELIMINAR(p_idt IN NUMBER);
    FUNCTION CONSULTAR(p_idt IN NUMBER) RETURN VARCHAR2;

END PKG_TAREA;
/

CREATE OR REPLACE PACKAGE BODY PKG_TAREA AS
    PROCEDURE INSERTAR(p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fi IN DATE, p_fl IN DATE, p_ide IN NUMBER, p_idp IN NUMBER, p_idua IN NUMBER, p_idud IN NUMBER) IS
    BEGIN
        INSERT INTO TAREA (NOMBRE, DESCRIPCION, FECHA_INICIO, FECHA_LIMITE, ID_ESTADO, ID_PROYECTO, ID_USUARIO_ASIGNA, ID_USUARIO_DESARROLLA) 
        VALUES (p_nom, p_desc, p_fi, p_fl, p_ide, p_idp, p_idua, p_idud);
        COMMIT;
    END INSERTAR;

    PROCEDURE ACTUALIZAR(p_idt IN NUMBER, p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fi IN DATE, p_fl IN DATE, p_ide IN NUMBER, p_idp IN NUMBER, p_idua IN NUMBER, p_idud IN NUMBER) IS
    BEGIN
        UPDATE TAREA SET NOMBRE = p_nom, DESCRIPCION = p_desc, FECHA_INICIO = p_fi, FECHA_LIMITE = p_fl, ID_ESTADO = p_ide, ID_PROYECTO = p_idp, ID_USUARIO_ASIGNA = p_idua, ID_USUARIO_DESARROLLA = p_idud 
        WHERE ID_TAREA = p_idt;
        COMMIT;
    END ACTUALIZAR;

    PROCEDURE ELIMINAR(p_idt IN NUMBER) IS
    BEGIN
        DELETE FROM TAREA WHERE ID_TAREA = p_idt;
        COMMIT;
    END ELIMINAR;

    FUNCTION CONSULTAR(p_idt IN NUMBER) RETURN VARCHAR2 IS
        v_nom TAREA.NOMBRE%TYPE;
    BEGIN
        SELECT NOMBRE INTO v_nom FROM TAREA WHERE ID_TAREA = p_idt;
        RETURN v_nom;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END CONSULTAR;


END PKG_TAREA;
/

/*==============================================================*/
/* PAQUETE REPORTES                                             */                                   
/*==============================================================*/

CREATE OR REPLACE PACKAGE PKG_REPORTES AS
    PROCEDURE INSERTAR(p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fec IN DATE, p_res IN VARCHAR2, p_ta IN NUMBER, p_idp IN NUMBER);
    PROCEDURE ACTUALIZAR(p_idr IN NUMBER, p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fec IN DATE, p_res IN VARCHAR2, p_ta IN NUMBER, p_idp IN NUMBER);
    PROCEDURE ELIMINAR(p_idr IN NUMBER);
    FUNCTION CONSULTAR(p_idr IN NUMBER) RETURN VARCHAR2;
END PKG_REPORTES;
/

CREATE OR REPLACE PACKAGE BODY PKG_REPORTES AS
    PROCEDURE INSERTAR(p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fec IN DATE, p_res IN VARCHAR2, p_ta IN NUMBER, p_idp IN NUMBER) IS
    BEGIN
        INSERT INTO REPORTES (NOMBRE, DESCRIPCION, FECHA, RESUMEN_DEL_PROGRESO, TAREAS_ATRASADAS, ID_PROYECTO) 
        VALUES (p_nom, p_desc, p_fec, p_res, p_ta, p_idp);
        COMMIT;
    END INSERTAR;

    PROCEDURE ACTUALIZAR(p_idr IN NUMBER, p_nom IN VARCHAR2, p_desc IN VARCHAR2, p_fec IN DATE, p_res IN VARCHAR2, p_ta IN NUMBER, p_idp IN NUMBER) IS
    BEGIN
        UPDATE REPORTES SET NOMBRE = p_nom, DESCRIPCION = p_desc, FECHA = p_fec, RESUMEN_DEL_PROGRESO = p_res, TAREAS_ATRASADAS = p_ta, ID_PROYECTO = p_idp 
        WHERE ID_REPORTES = p_idr;
        COMMIT;
    END ACTUALIZAR;

    PROCEDURE ELIMINAR(p_idr IN NUMBER) IS
    BEGIN
        DELETE FROM REPORTES WHERE ID_REPORTES = p_idr;
        COMMIT;
    END ELIMINAR;

    FUNCTION CONSULTAR(p_idr IN NUMBER) RETURN VARCHAR2 IS
        v_nom REPORTES.NOMBRE%TYPE;
    BEGIN
        SELECT NOMBRE INTO v_nom FROM REPORTES WHERE ID_REPORTES = p_idr;
        RETURN v_nom;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END CONSULTAR;

END PKG_REPORTES;
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
/* BLOQUE ANONIMO 1                                             */
/* WHILE + cursor explícito                                     */
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
/* BLOQUE ANONIMO 2                                             */
/* PRUEBA TRIGGER CORREO                                        */
/*==============================================================*/

BEGIN

    PKG_USUARIO.INSERTAR
    (
        'Carlos',
        'Tester',
        'correo_invalido@hotmail.com',
        '123456',
        1
    );

EXCEPTION

    WHEN OTHERS THEN

        DBMS_OUTPUT.PUT_LINE(
            'ERROR CONTROLADO: ' || SQLERRM
        );

END;
/
/*==============================================================*/
/* BLOQUE ANONIMO 3                                             */
/* CLASIFICACION DE PROYECTOS                                   */
/*==============================================================*/

DECLARE

    CURSOR C_PROYECTOS IS
        SELECT NOMBRE,
            PORCENTAJE_DE_AVANCE
        FROM PROYECTO;

BEGIN

    FOR V_PROY IN C_PROYECTOS LOOP

        CASE

            WHEN V_PROY.PORCENTAJE_DE_AVANCE = 100 THEN

                DBMS_OUTPUT.PUT_LINE(
                    V_PROY.NOMBRE || ' FINALIZADO'
                );

            WHEN V_PROY.PORCENTAJE_DE_AVANCE >= 50 THEN

                DBMS_OUTPUT.PUT_LINE(
                    V_PROY.NOMBRE || ' EN DESARROLLO AVANZADO'
                );

            ELSE

                DBMS_OUTPUT.PUT_LINE(
                    V_PROY.NOMBRE || ' EN ETAPA INICIAL'
                );

        END CASE;

    END LOOP;

END;
/
/*==============================================================*/
/* BLOQUE ANONIMO 4                                             */
/* USUARIOS REGISTRADOS                                         */
/*==============================================================*/

DECLARE

    TYPE REC_USUARIO IS RECORD
    (
        NOMBRE USUARIO.NOMBRE%TYPE,
        CORREO USUARIO.CORREO%TYPE
    );

    TYPE TAB_USUARIOS IS TABLE OF REC_USUARIO;

    V_USUARIOS TAB_USUARIOS;

BEGIN

    SELECT NOMBRE, CORREO
    BULK COLLECT INTO V_USUARIOS
    FROM USUARIO;

    FOR I IN 1 .. V_USUARIOS.COUNT LOOP

        DBMS_OUTPUT.PUT_LINE
        (
            'USUARIO: ' || V_USUARIOS(I).NOMBRE ||
            ' | CORREO: ' || V_USUARIOS(I).CORREO
        );

    END LOOP;

END;
/
/*==============================================================*/
/* BLOQUE ANONIMO 5                                             */
/* TAREAS POR PROYECTO                                          */
/*==============================================================*/

DECLARE

    CURSOR C_TAREAS(P_ID NUMBER) IS
        SELECT NOMBRE
        FROM TAREA
        WHERE ID_PROYECTO = P_ID;

BEGIN

    FOR V_TAREA IN C_TAREAS(100) LOOP

        DBMS_OUTPUT.PUT_LINE(
            'TAREA: ' || V_TAREA.NOMBRE
        );

    END LOOP;

END;
/