/*==============================================================*/
/* TRIGGER: Actualizar porcentaje y estado del proyecto         */
/*==============================================================*/
CREATE OR REPLACE TRIGGER TRG_AVANCE_SIMPLE
FOR INSERT OR UPDATE OR DELETE ON TAREA
COMPOUND TRIGGER

TYPE t_ids IS TABLE OF PROYECTO.ID_PROYECTO%TYPE INDEX BY PLS_INTEGER;
g_ids   t_ids;
g_count PLS_INTEGER := 0;

PROCEDURE agregar_proyecto(p_id_proy PROYECTO.ID_PROYECTO%TYPE) IS
BEGIN
    IF p_id_proy IS NOT NULL THEN
        g_count := g_count + 1;
        g_ids(g_count) := p_id_proy;
    END IF;
END;

PROCEDURE recalcular_proyecto(p_id_proy PROYECTO.ID_PROYECTO%TYPE) IS
    v_total      NUMBER := 0;
    v_terminadas NUMBER := 0;
    v_porcentaje  NUMBER(5,2) := 0;
BEGIN
    SELECT COUNT(*) INTO v_total FROM TAREA WHERE ID_PROYECTO = p_id_proy;

    SELECT COUNT(*)
    INTO v_terminadas
    FROM TAREA T
    JOIN ESTADO E ON E.ID_ESTADO = T.ID_ESTADO
    WHERE T.ID_PROYECTO = p_id_proy
    AND UPPER(E.NOMBRE) = 'FINISHED'; -- Ajustado a tu valor de inserción

    IF v_total > 0 THEN
        v_porcentaje := ROUND((v_terminadas / v_total) * 100, 2);
    ELSE
        v_porcentaje := 0;
    END IF;

    UPDATE PROYECTO
    SET PORCENTAJE_DE_AVANCE = v_porcentaje,
        ESTADO_GENERAL = CASE
                            WHEN v_porcentaje = 100 THEN 'Finished'
                            WHEN v_porcentaje = 0 THEN 'ToDevelop'
                            ELSE 'InDevelopment'
                        END
    WHERE ID_PROYECTO = p_id_proy;
END;

AFTER EACH ROW IS
BEGIN
IF INSERTING OR UPDATING THEN agregar_proyecto(:NEW.ID_PROYECTO); END IF;
IF DELETING OR UPDATING THEN agregar_proyecto(:OLD.ID_PROYECTO); END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
BEGIN
FOR i IN 1 .. g_count LOOP recalcular_proyecto(g_ids(i)); END LOOP;
END AFTER STATEMENT;

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
/* VISTAS                                                       */
/*==============================================================*/

-- 1. Vista tarea en proyecto
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
-- 1. Vista de tareas con detalle
CREATE OR REPLACE VIEW V_TAREA_DETALLE AS
SELECT
    T.ID_TAREA, T.NOMBRE AS NOMBRE_TAREA, T.FECHA_INICIO, T.FECHA_LIMITE,
    P.NOMBRE AS NOMBRE_PROYECTO, E.NOMBRE AS NOMBRE_ESTADO,
    U1.NOMBRE AS ASIGNADO_POR, U2.NOMBRE AS DESARROLLADOR
FROM TAREA T
JOIN PROYECTO P ON P.ID_PROYECTO = T.ID_PROYECTO
JOIN ESTADO E ON E.ID_ESTADO = T.ID_ESTADO
JOIN USUARIO U1 ON U1.ID_USUARIO = T.ID_USUARIO_ASIGNA
LEFT JOIN USUARIO U2 ON U2.ID_USUARIO = T.ID_USUARIO_DESARROLLA;

-- 2. Vista de desarrollador (Filtrada por ROL R3)
CREATE OR REPLACE VIEW V_DESARROLLADOR AS
SELECT U.NOMBRE AS DESARROLLADOR, T.NOMBRE AS TAREA, E.NOMBRE AS ESTADO, P.NOMBRE AS PROYECTO
FROM USUARIO U
JOIN TAREA T ON T.ID_USUARIO_DESARROLLA = U.ID_USUARIO
JOIN ESTADO E ON E.ID_ESTADO = T.ID_ESTADO
JOIN PROYECTO P ON P.ID_PROYECTO = T.ID_PROYECTO
WHERE U.ID_ROL = 'R3';

-- 3. Vista de Administrador (Vista de proyectos y reportes)
CREATE OR REPLACE VIEW V_ADMIN AS
SELECT
    P.NOMBRE AS PROYECTO, P.ESTADO_GENERAL, P.PORCENTAJE_DE_AVANCE,
    R.NOMBRE AS REPORTE, R.RESUMEN_DEL_PROGRESO, R.FECHA
FROM PROYECTO P
LEFT JOIN REPORTES R ON R.ID_PROYECTO = P.ID_PROYECTO;

-- 4. Vista de relación usuario - tarea
CREATE OR REPLACE VIEW V_USUARIO_TAREA AS
SELECT U.NOMBRE AS USUARIO, T.NOMBRE AS TAREA, E.NOMBRE AS ESTADO, P.NOMBRE AS PROYECTO
FROM USUARIO U
JOIN TAREA T ON T.ID_USUARIO_ASIGNA = U.ID_USUARIO OR T.ID_USUARIO_DESARROLLA = U.ID_USUARIO
JOIN ESTADO E ON E.ID_ESTADO = T.ID_ESTADO
JOIN PROYECTO P ON P.ID_PROYECTO = T.ID_PROYECTO;

/*==============================================================*/
/* ROLES Y PERMISOS                                             */
/*==============================================================*/

CREATE ROLE LIDER_ROLE;
CREATE ROLE ADMIN_ROLE;
CREATE ROLE DESARROLLADOR_ROLE;

GRANT SELECT ON V_DESARROLLADOR TO DESARROLLADOR_ROLE;
GRANT SELECT ON V_ADMIN TO ADMIN_ROLE;
GRANT SELECT ON V_USUARIO_TAREA TO LIDER_ROLE;