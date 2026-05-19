/*==============================================================*/
/* ELIMINAR TABLAS                                              */
/*==============================================================*/

DROP TABLE REPORTES CASCADE CONSTRAINTS;
DROP TABLE TAREA CASCADE CONSTRAINTS;
DROP TABLE USUARIO CASCADE CONSTRAINTS;
DROP TABLE ROL CASCADE CONSTRAINTS;
DROP TABLE PROYECTO CASCADE CONSTRAINTS;
DROP TABLE ESTADO CASCADE CONSTRAINTS;

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
/* TABLA: ESTADO                                                */
/*==============================================================*/

CREATE TABLE ESTADO
(
   ID_ESTADO     VARCHAR2(50)   NOT NULL,
   NOMBRE        VARCHAR2(50)   NOT NULL,

   CONSTRAINT PK_ESTADO PRIMARY KEY (ID_ESTADO)
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
   ID_TAREA                     VARCHAR2(50)   NOT NULL,
   NOMBRE                       VARCHAR2(50)   NOT NULL,
   DESCRIPCION                  VARCHAR2(200),
   FECHA_INICIO                 DATE           NOT NULL,
   FECHA_LIMITE                 DATE           NOT NULL,

   ID_ESTADO                    VARCHAR2(50)   NOT NULL,

   ID_PROYECTO                  VARCHAR2(50)   NOT NULL,


   ID_USUARIO_ASIGNA            VARCHAR2(50)   NOT NULL,

   ID_USUARIO_DESARROLLA        VARCHAR2(50),

   CONSTRAINT PK_TAREA PRIMARY KEY (ID_TAREA)
);

/*==============================================================*/
/* TABLA: REPORTES                                              */
/*==============================================================*/

CREATE TABLE REPORTES
(
   ID_REPORTES           VARCHAR2(50)   NOT NULL,
   NOMBRE                VARCHAR2(50)   NOT NULL,
   DESCRIPCION           VARCHAR2(200),
   FECHA                 DATE           NOT NULL,
   RESUMEN_DEL_PROGRESO  VARCHAR2(500)  NOT NULL,
   TAREAS_ATRASADAS      NUMBER(10)     NOT NULL,
   ID_PROYECTO           VARCHAR2(50)   NOT NULL,

   CONSTRAINT PK_REPORTES PRIMARY KEY (ID_REPORTES)
);

/*==============================================================*/
/* FOREIGN KEYS                                                 */
/*==============================================================*/

/*==============================================================*/
/* USUARIO -> ROL                                               */
/*==============================================================*/

ALTER TABLE USUARIO
ADD CONSTRAINT FK_USUARIO_ROL
FOREIGN KEY (ID_ROL)
REFERENCES ROL(ID_ROL);

/*==============================================================*/
/* TAREA -> ESTADO                                              */
/*==============================================================*/

ALTER TABLE TAREA
ADD CONSTRAINT FK_TAREA_ESTADO
FOREIGN KEY (ID_ESTADO)
REFERENCES ESTADO(ID_ESTADO);

/*==============================================================*/
/* TAREA -> PROYECTO                                            */
/*==============================================================*/

ALTER TABLE TAREA
ADD CONSTRAINT FK_TAREA_PROYECTO
FOREIGN KEY (ID_PROYECTO)
REFERENCES PROYECTO(ID_PROYECTO);

/*==============================================================*/
/* TAREA -> USUARIO (ASIGNA)                                    */
/*==============================================================*/

ALTER TABLE TAREA
ADD CONSTRAINT FK_TAREA_USUARIO_ASIGNA
FOREIGN KEY (ID_USUARIO_ASIGNA)
REFERENCES USUARIO(ID_USUARIO);

/*==============================================================*/
/* TAREA -> USUARIO (DESARROLLA)                                */
/*==============================================================*/

ALTER TABLE TAREA
ADD CONSTRAINT FK_TAREA_USUARIO_DESARROLLA
FOREIGN KEY (ID_USUARIO_DESARROLLA)
REFERENCES USUARIO(ID_USUARIO);

/*==============================================================*/
/* REPORTES -> PROYECTO                                         */
/*==============================================================*/

ALTER TABLE REPORTES
ADD CONSTRAINT FK_REPORTES_PROYECTO
FOREIGN KEY (ID_PROYECTO)
REFERENCES PROYECTO(ID_PROYECTO);