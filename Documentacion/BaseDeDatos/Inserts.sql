/*==============================================================*/
/* INSERTS TABLA: ROL                                           */
/*==============================================================*/

INSERT INTO ROL (ID_ROL, NOMBRE)
VALUES ('R1', 'Admin');

INSERT INTO ROL (ID_ROL, NOMBRE)
VALUES ('R2', 'Manager');

INSERT INTO ROL (ID_ROL, NOMBRE)
VALUES ('R3', 'Developer');


/*==============================================================*/
/* INSERTS TABLA: PROYECTO                                      */
/*==============================================================*/

INSERT INTO PROYECTO
(
   ID_PROYECTO,
   NOMBRE,
   DESCRIPCION,
   FECHA_INICIO,
   FECHA_FINALIZACION,
   ESTADO_GENERAL,
   PORCENTAJE_DE_AVANCE
)
VALUES
(
   'P1',
   'Sistema Ventas',
   'Sistema para ventas',
   DATE '2026-01-10',
   DATE '2026-06-30',
   'En progreso',
   45
);

INSERT INTO PROYECTO
VALUES
(
   'P2',
   'Sistema Inventario',
   'Control de inventario',
   DATE '2026-02-01',
   DATE '2026-08-15',
   'Pendiente',
   10
);

INSERT INTO PROYECTO
VALUES
(
   'P3',
   'Sistema Nomina',
   'Gestion de empleados',
   DATE '2026-03-01',
   DATE '2026-09-20',
   'En progreso',
   35
);

INSERT INTO PROYECTO
VALUES
(
   'P4',
   'Sistema Clinico',
   'Control medico',
   DATE '2026-01-15',
   DATE '2026-12-01',
   'Atrasado',
   20
);

INSERT INTO PROYECTO
VALUES
(
   'P5',
   'Sistema Escolar',
   'Gestion estudiantil',
   DATE '2026-04-01',
   DATE '2026-11-30',
   'Finalizado',
   100
);

/*==============================================================*/
/* INSERTS TABLA: USUARIO                                       */
/*==============================================================*/

INSERT INTO USUARIO
VALUES
(
   'U1',
   'Maick',
   'Administrador principal',
   'maick@gmail.com',
   '123456',
   'R1'
);

INSERT INTO USUARIO
VALUES
(
   'U2',
   'Sebas',
   'Developer backend',
   'sebas@gmail.com',
   'abcdef',
   'R2'
);

INSERT INTO USUARIO
VALUES
(
   'U3',
   'Laura',
   'Tester principal',
   'laura@gmail.com',
   'pass123',
   'R3'
);

INSERT INTO USUARIO
VALUES
(
   'U4',
   'Carlos',
   'Project manager',
   'carlos@gmail.com',
   'manager1',
   'R2'
);

INSERT INTO USUARIO
VALUES
(
   'U5',
   'Ana',
   'Cliente del sistema',
   'ana@gmail.com',
   'cliente',
   'R1'
);

/*==============================================================*/
/* INSERTS TABLA: TAREA                                         */
/*==============================================================*/

INSERT INTO TAREA
VALUES
(
   'T1',
   'Login',
   'Implementar login',
   DATE '2026-01-15',
   DATE '2026-01-30'
);

INSERT INTO TAREA
VALUES
(
   'T2',
   'CRUD Productos',
   'Gestion productos',
   DATE '2026-02-01',
   DATE '2026-02-20'
);

INSERT INTO TAREA
VALUES
(
   'T3',
   'Dashboard',
   'Panel administrativo',
   DATE '2026-02-10',
   DATE '2026-03-01'
);

INSERT INTO TAREA
VALUES
(
   'T4',
   'Reportes PDF',
   'Generacion de reportes',
   DATE '2026-03-05',
   DATE '2026-03-25'
);

INSERT INTO TAREA
VALUES
(
   'T5',
   'Seguridad',
   'Control de permisos',
   DATE '2026-03-15',
   DATE '2026-04-10'
);

/*==============================================================*/
/* INSERTS TABLA: REPORTES                                      */
/*==============================================================*/

INSERT INTO REPORTES
VALUES
(
   'REP1',
   'Reporte Enero',
   'Primer reporte mensual',
   DATE '2026-01-31',
   'Buen avance del proyecto',
   2,
   'P1'
);

INSERT INTO REPORTES
VALUES
(
   'REP2',
   'Reporte Febrero',
   'Segundo reporte mensual',
   DATE '2026-02-28',
   'Se completaron modulos',
   1,
   'P1'
);

INSERT INTO REPORTES
VALUES
(
   'REP3',
   'Reporte Marzo',
   'Tercer reporte mensual',
   DATE '2026-03-31',
   'Problemas menores encontrados',
   3,
   'P2'
);

INSERT INTO REPORTES
VALUES
(
   'REP4',
   'Reporte Abril',
   'Cuarto reporte mensual',
   DATE '2026-04-30',
   'El sistema mejoro rendimiento',
   0,
   'P3'
);

INSERT INTO REPORTES
VALUES
(
   'REP5',
   'Reporte Mayo',
   'Quinto reporte mensual',
   DATE '2026-05-31',
   'Proyecto casi terminado',
   1,
   'P5'
);

COMMIT;