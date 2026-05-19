/*==============================================================*/
/* ELIMINAR TABLAS                                              */
/*==============================================================*/

DROP TABLE REPORTES CASCADE CONSTRAINTS;
DROP TABLE TAREA CASCADE CONSTRAINTS;
DROP TABLE USUARIO CASCADE CONSTRAINTS;
DROP TABLE ROL CASCADE CONSTRAINTS;
DROP TABLE PROYECTO CASCADE CONSTRAINTS;

/*==============================================================*/
/* TABLA: ROL                                                   */
/*==============================================================*/

CREATE TABLE ROL
(
   ID_ROL        VARCHAR2(50)   NOT NULL,
   NOMBRE        VARCHAR2(50)   NOT NULL,

   CONSTRAINT PK_ROL PRIMARY KEY (ID_ROL)
);

/*==============================================================*/
/* TABLA: PROYECTO                                              */
/*==============================================================*/

CREATE TABLE PROYECTO
(
   ID_PROYECTO             VARCHAR2(50)   NOT NULL,
   NOMBRE                  VARCHAR2(50)   NOT NULL,
   DESCRIPCION             VARCHAR2(200),
   FECHA_INICIO            DATE           NOT NULL,
   FECHA_FINALIZACION      DATE           NOT NULL,
   ESTADO_GENERAL          VARCHAR2(50)   NOT NULL,
   PORCENTAJE_DE_AVANCE    NUMBER(5,2)    NOT NULL,

   CONSTRAINT PK_PROYECTO PRIMARY KEY (ID_PROYECTO)
);

/*==============================================================*/
/* TABLA: USUARIO                                               */
/*==============================================================*/

CREATE TABLE USUARIO
(
   ID_USUARIO     VARCHAR2(50)   NOT NULL,
   NOMBRE         VARCHAR2(50)   NOT NULL,
   DESCRIPCION    VARCHAR2(200),
   CORREO         VARCHAR2(100)  NOT NULL,
   CONTRASENA     VARCHAR2(100)  NOT NULL,
   ID_ROL         VARCHAR2(50)   NOT NULL,

   CONSTRAINT PK_USUARIO PRIMARY KEY (ID_USUARIO)
);

/*==============================================================*/
/* TABLA: TAREA                                                 */
/*==============================================================*/

CREATE TABLE TAREA
(
   ID_TAREA        VARCHAR2(50)   NOT NULL,
   NOMBRE          VARCHAR2(50)   NOT NULL,
   DESCRIPCION     VARCHAR2(200),
   FECHA_INICIO    DATE           NOT NULL,
   FECHA_LIMITE    DATE           NOT NULL,

   CONSTRAINT PK_TAREA PRIMARY KEY (ID_TAREA)
);

/*==============================================================*/
/* TABLA: REPORTES                                              */
/*==============================================================*/

CREATE TABLE REPORTES
(
   ID_REPORTES          VARCHAR2(50)   NOT NULL,
   NOMBRE               VARCHAR2(50)   NOT NULL,
   DESCRIPCION          VARCHAR2(200),
   FECHA                DATE           NOT NULL,
   RESUMEN_DEL_PROGRESO VARCHAR2(500)  NOT NULL,
   TAREAS_ATRASADAS     NUMBER(10)     NOT NULL,
   ID_PROYECTO          VARCHAR2(50)   NOT NULL,

   CONSTRAINT PK_REPORTES PRIMARY KEY (ID_REPORTES)
);

/*==============================================================*/
/* FOREIGN KEYS                                                 */
/*==============================================================*/

ALTER TABLE USUARIO
ADD CONSTRAINT FK_USUARIO_ROL
FOREIGN KEY (ID_ROL)
REFERENCES ROL(ID_ROL);

ALTER TABLE REPORTES
ADD CONSTRAINT FK_REPORTES_PROYECTO
FOREIGN KEY (ID_PROYECTO)
REFERENCES PROYECTO(ID_PROYECTO);