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
    PROCEDURE LISTAR_PROYECTOS;
    PROCEDURE LISTAR_AVANCE_PROYECTOS;
    PROCEDURE LISTAR_PROYECTOS_POR_PALABRA(p_keyword IN VARCHAR2);
    PROCEDURE CONTAR_REPORTES_POR_PROYECTO;
    PROCEDURE LISTAR_PROMEDIO_AVANCE_POR_ESTADO;
    PROCEDURE LISTAR_PROYECTOS_SIN_REPORTES;
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
    --FOR
    PROCEDURE LISTAR_PROYECTOS IS
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
    END LISTAR_PROYECTOS;

    PROCEDURE LISTAR_AVANCE_PROYECTOS IS
        CURSOR C_PROYECTOS IS
            SELECT NOMBRE, PORCENTAJE_DE_AVANCE FROM PROYECTO;
        V_NOMBRE PROYECTO.NOMBRE%TYPE;
        V_AVANCE PROYECTO.PORCENTAJE_DE_AVANCE%TYPE;
    BEGIN
        OPEN C_PROYECTOS;
        LOOP
            FETCH C_PROYECTOS INTO V_NOMBRE, V_AVANCE;
            EXIT WHEN C_PROYECTOS%NOTFOUND;
            IF V_AVANCE > 0 THEN
                IF V_AVANCE >= 50 THEN
                    DBMS_OUTPUT.PUT_LINE(V_NOMBRE || ' -> BUEN AVANCE');
                ELSE
                    DBMS_OUTPUT.PUT_LINE(V_NOMBRE || ' -> AVANCE BAJO');
                END IF;
            ELSE
                DBMS_OUTPUT.PUT_LINE(V_NOMBRE || ' -> SIN INICIAR');
            END IF;
        END LOOP;
        CLOSE C_PROYECTOS;
    END LISTAR_AVANCE_PROYECTOS;

    PROCEDURE LISTAR_PROYECTOS_POR_PALABRA(p_keyword IN VARCHAR2) IS
        CURSOR C_DATA IS
            SELECT P.NOMBRE AS PROYECTO, R.DESCRIPCION
            FROM PROYECTO P
            LEFT JOIN REPORTES R ON P.ID_PROYECTO = R.ID_PROYECTO
            WHERE P.NOMBRE LIKE '%' || p_keyword || '%'
            ORDER BY P.NOMBRE DESC;
    BEGIN
        FOR R IN C_DATA LOOP
            DBMS_OUTPUT.PUT_LINE('Proyecto: ' || R.PROYECTO || ' | Reporte: ' || NVL(R.DESCRIPCION, 'Sin reporte'));
        END LOOP;
    END LISTAR_PROYECTOS_POR_PALABRA;

    PROCEDURE CONTAR_REPORTES_POR_PROYECTO IS
        CURSOR C_CONTEO IS
            SELECT P.NOMBRE AS PROYECTO, COUNT(R.ID_REPORTES) AS TOTAL_REPORTES
            FROM REPORTES R
            RIGHT JOIN PROYECTO P ON R.ID_PROYECTO = P.ID_PROYECTO
            WHERE P.ID_PROYECTO BETWEEN 100 AND 108
            GROUP BY P.NOMBRE
            ORDER BY COUNT(R.ID_REPORTES) DESC;
    BEGIN
        FOR R IN C_CONTEO LOOP
            DBMS_OUTPUT.PUT_LINE('Proyecto: ' || R.PROYECTO || ' | Total Reportes: ' || R.TOTAL_REPORTES);
        END LOOP;
    END CONTAR_REPORTES_POR_PROYECTO;

    PROCEDURE LISTAR_PROMEDIO_AVANCE_POR_ESTADO IS
        CURSOR C_PROMEDIO IS
            SELECT ESTADO_GENERAL, AVG(PORCENTAJE_DE_AVANCE) AS PROMEDIO
            FROM PROYECTO
            WHERE ESTADO_GENERAL <> 'ToDevelop'
            GROUP BY ESTADO_GENERAL
            HAVING AVG(PORCENTAJE_DE_AVANCE) > 40
            ORDER BY AVG(PORCENTAJE_DE_AVANCE);
    BEGIN
        DBMS_OUTPUT.PUT_LINE('===== PROMEDIO DE AVANCE POR ESTADO (> 40%) =====');
        FOR R IN C_PROMEDIO LOOP
            DBMS_OUTPUT.PUT_LINE('Estado: ' || R.ESTADO_GENERAL || ' | Promedio: ' || ROUND(R.PROMEDIO, 2) || '%');
        END LOOP;
    END LISTAR_PROMEDIO_AVANCE_POR_ESTADO;

    PROCEDURE LISTAR_PROYECTOS_SIN_REPORTES IS
        CURSOR C_PROYECTOS IS
            SELECT P.NOMBRE AS PROYECTO
            FROM PROYECTO P
            LEFT JOIN REPORTES R ON P.ID_PROYECTO = R.ID_PROYECTO
            WHERE R.ID_REPORTES IS NULL;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('===== PROYECTOS SIN REPORTES REGISTRADOS =====');
        FOR R IN C_PROYECTOS LOOP
            DBMS_OUTPUT.PUT_LINE('Proyecto: ' || R.PROYECTO);
        END LOOP;
    END LISTAR_PROYECTOS_SIN_REPORTES;

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
    PROCEDURE LISTAR_TAREAS_ATRASADAS;
    PROCEDURE LISTAR_POR_PROYECTO(p_id_proyecto IN NUMBER);
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

    PROCEDURE LISTAR_TAREAS_ATRASADAS IS
        CURSOR C_TAREAS IS
            SELECT NOMBRE, FECHA_LIMITE, 
                (SELECT U.NOMBRE FROM USUARIO U WHERE U.ID_USUARIO = TAREA.ID_USUARIO_DESARROLLA) AS NOMBRE_USUARIO
            FROM TAREA;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('===== TAREAS ATRASADAS =====');
        FOR V_TAREA IN C_TAREAS LOOP
            IF V_TAREA.FECHA_LIMITE < SYSDATE THEN
                DBMS_OUTPUT.PUT_LINE(
                    'Tarea: ' || V_TAREA.NOMBRE || 
                    ' | Usuario: ' || NVL(V_TAREA.NOMBRE_USUARIO, 'Sin Asignar') ||
                    ' | Fecha Límite: ' || TO_CHAR(V_TAREA.FECHA_LIMITE, 'DD/MM/YYYY')
                );
            END IF;
        END LOOP;
    END LISTAR_TAREAS_ATRASADAS;

    PROCEDURE LISTAR_POR_PROYECTO(p_id_proyecto IN NUMBER) IS
        CURSOR C_TAREAS (p_proy_id PROYECTO.ID_PROYECTO%TYPE) IS
            SELECT NOMBRE FROM TAREA WHERE ID_PROYECTO = p_proy_id;
    BEGIN
        FOR V_TAREA IN C_TAREAS(p_id_proyecto) LOOP
            DBMS_OUTPUT.PUT_LINE('TAREA: ' || V_TAREA.NOMBRE);
        END LOOP;
    END LISTAR_POR_PROYECTO;

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

--Bloques anonimos validos
BEGIN
    PKG_PROYECTO.LISTAR_PROYECTOS;
END;
/
BEGIN
    PKG_PROYECTO.LISTAR_AVANCE_PROYECTOS;
END;
/
BEGIN
    PKG_PROYECTO.CONTAR_REPORTES_POR_PROYECTO;
END;
/
BEGIN
    PKG_USUARIO.LISTAR_USUARIOS;
END;
/
BEGIN
    PKG_TAREA.LISTAR_TAREAS_ATRASADAS;
END;
/