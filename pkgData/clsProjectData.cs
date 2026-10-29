using System;
using System.Collections.Generic;
using System.Globalization;
using Microsoft.Data.Sqlite;
#nullable disable

namespace GestionDeProyectos.pkgData
{
    public class clsProjectData
    {
        // Se cambió el primer parámetro de string a int en el Action
        public static void opLoadProjects
        (
            Action<int, string, string, DateTime, DateTime, string, float> prmRegisterAction
        )
        {
            string vrmQuery =
                "SELECT ID_PROYECTO, NOMBRE, DESCRIPCION, FECHA_INICIO, FECHA_FINALIZACION, ESTADO_GENERAL, PORCENTAJE_DE_AVANCE FROM PROYECTO";

            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                using (SqliteCommand vrmCmd = new SqliteCommand(vrmQuery, vrmConn))
                {
                    try
                    {
                        vrmConn.Open();

                        using (SqliteDataReader vrmReader = vrmCmd.ExecuteReader())
                        {
                            while (vrmReader.Read())
                            {
                                int vrmIDProyecto = Convert.ToInt32(vrmReader["ID_PROYECTO"]);

                                string vrmNombre = vrmReader["NOMBRE"]?.ToString() ?? string.Empty;

                                string vrmDescripcion = vrmReader["DESCRIPCION"] == DBNull.Value
                                    ? string.Empty
                                    : vrmReader["DESCRIPCION"].ToString();

                                DateTime vrmFechaInicio = Convert.ToDateTime(vrmReader["FECHA_INICIO"], CultureInfo.InvariantCulture);

                                DateTime vrmFechaFinalizacion = Convert.ToDateTime(vrmReader["FECHA_FINALIZACION"], CultureInfo.InvariantCulture);

                                string vrmEstadoGeneral = vrmReader["ESTADO_GENERAL"]?.ToString() ?? string.Empty;

                                float vrmPorcentajeAvance = Convert.ToSingle(vrmReader["PORCENTAJE_DE_AVANCE"]);

                                prmRegisterAction(
                                    vrmIDProyecto,
                                    vrmNombre,
                                    vrmDescripcion,
                                    vrmFechaInicio,
                                    vrmFechaFinalizacion,
                                    vrmEstadoGeneral,
                                    vrmPorcentajeAvance
                                );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(
                            "Error al cargar proyectos desde SQLite: "
                            + ex.Message
                        );
                    }
                }
            }
        }

        // 2. CREAR (CREATE): equivalente a PKG_PROYECTO.INSERTAR. Devuelve el ID generado o 0 si falla.
        public static int opInsertarProyecto(
            string prmNom,
            string prmDesc,
            DateTime prmFi,
            DateTime prmFf,
            string prmEg,
            float prmAv)
        {
            string vrmSql = @"INSERT INTO PROYECTO
                (NOMBRE, DESCRIPCION, FECHA_INICIO, FECHA_FINALIZACION, ESTADO_GENERAL, PORCENTAJE_DE_AVANCE)
                VALUES (@nom, @desc, @fi, @ff, @eg, @av)
                RETURNING ID_PROYECTO";

            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                using (SqliteCommand vrmCmd = new SqliteCommand(vrmSql, vrmConn))
                {
                    vrmCmd.Parameters.AddWithValue("@nom", prmNom);
                    vrmCmd.Parameters.AddWithValue("@desc", (object)prmDesc ?? DBNull.Value);
                    vrmCmd.Parameters.AddWithValue("@fi", clsSqliteConnection.opFormatDate(prmFi));
                    vrmCmd.Parameters.AddWithValue("@ff", clsSqliteConnection.opFormatDate(prmFf));
                    vrmCmd.Parameters.AddWithValue("@eg", prmEg);
                    vrmCmd.Parameters.AddWithValue("@av", prmAv);

                    try
                    {
                        vrmConn.Open();

                        int vrmNuevoId = Convert.ToInt32(vrmCmd.ExecuteScalar());
                        Console.WriteLine("ID generado: " + vrmNuevoId);

                        return vrmNuevoId;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Error al insertar proyecto: " + ex.Message);
                        return 0;
                    }
                }
            }
        }

        // 3. ACTUALIZAR (UPDATE): equivalente a PKG_PROYECTO.ACTUALIZAR
        public static bool opActualizarProyecto(int prmId, string prmNom, string prmDesc, DateTime prmFi, DateTime prmFf, string prmEg, float prmAv)
        {
            string vrmSql = @"UPDATE PROYECTO
                              SET NOMBRE = @nom,
                                  DESCRIPCION = @desc,
                                  FECHA_INICIO = @fi,
                                  FECHA_FINALIZACION = @ff,
                                  ESTADO_GENERAL = @eg,
                                  PORCENTAJE_DE_AVANCE = @av
                              WHERE ID_PROYECTO = @id";

            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                using (SqliteCommand vrmCmd = new SqliteCommand(vrmSql, vrmConn))
                {
                    vrmCmd.Parameters.AddWithValue("@id", prmId);
                    vrmCmd.Parameters.AddWithValue("@nom", prmNom);
                    vrmCmd.Parameters.AddWithValue("@desc", (object)prmDesc ?? DBNull.Value);
                    vrmCmd.Parameters.AddWithValue("@fi", clsSqliteConnection.opFormatDate(prmFi));
                    vrmCmd.Parameters.AddWithValue("@ff", clsSqliteConnection.opFormatDate(prmFf));
                    vrmCmd.Parameters.AddWithValue("@eg", prmEg);
                    vrmCmd.Parameters.AddWithValue("@av", prmAv);

                    try
                    {
                        vrmConn.Open();
                        vrmCmd.ExecuteNonQuery();
                        return true;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Error al actualizar proyecto: " + ex.Message);
                        return false;
                    }
                }
            }
        }

        // 4. ELIMINAR (DELETE): equivalente a PKG_PROYECTO.ELIMINAR (tareas y reportes se borran en cascada)
        public static bool opEliminarProyecto(int prmId)
        {
            string vrmSql = "DELETE FROM PROYECTO WHERE ID_PROYECTO = @id";

            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                using (SqliteCommand vrmCmd = new SqliteCommand(vrmSql, vrmConn))
                {
                    vrmCmd.Parameters.AddWithValue("@id", prmId);

                    try
                    {
                        vrmConn.Open();
                        vrmCmd.ExecuteNonQuery();
                        return true;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Error al eliminar proyecto: " + ex.Message);
                        return false;
                    }
                }
            }
        }

        // =========================================================================
        // REPORTES ANALÍTICOS: reemplazan a los procedimientos de PKG_PROYECTO que
        // escribían con DBMS_OUTPUT. Devuelven las mismas líneas de texto.
        // =========================================================================

        // Equivalente a PKG_PROYECTO.LISTAR_PROYECTOS
        public static List<string> opReporteListarProyectos()
        {
            List<string> vrmLineas = new List<string> { "===== REPORTE DE PROYECTOS =====" };

            opLeerLineas(
                @"SELECT NOMBRE, ESTADO_GENERAL, PORCENTAJE_DE_AVANCE
                  FROM PROYECTO
                  ORDER BY PORCENTAJE_DE_AVANCE DESC",
                vrmReader => vrmLineas.Add(
                    "Proyecto: " + vrmReader["NOMBRE"] +
                    " | Estado: " + vrmReader["ESTADO_GENERAL"] +
                    " | Avance: " + opFormatNumber(vrmReader["PORCENTAJE_DE_AVANCE"]) + "%"
                ),
                vrmLineas
            );

            return vrmLineas;
        }

        // Equivalente a PKG_PROYECTO.CONTAR_REPORTES_POR_PROYECTO
        public static List<string> opReporteConteoReportes()
        {
            List<string> vrmLineas = new List<string>();

            opLeerLineas(
                @"SELECT P.NOMBRE AS PROYECTO, COUNT(R.ID_REPORTES) AS TOTAL_REPORTES
                  FROM PROYECTO P
                  LEFT JOIN REPORTES R ON R.ID_PROYECTO = P.ID_PROYECTO
                  WHERE P.ID_PROYECTO BETWEEN 100 AND 108
                  GROUP BY P.NOMBRE
                  ORDER BY COUNT(R.ID_REPORTES) DESC",
                vrmReader => vrmLineas.Add(
                    "Proyecto: " + vrmReader["PROYECTO"] +
                    " | Total Reportes: " + vrmReader["TOTAL_REPORTES"]
                ),
                vrmLineas
            );

            return vrmLineas;
        }

        // Equivalente a PKG_PROYECTO.LISTAR_PROMEDIO_AVANCE_POR_ESTADO
        public static List<string> opReportePromedioAvance()
        {
            List<string> vrmLineas = new List<string> { "===== PROMEDIO DE AVANCE POR ESTADO (> 40%) =====" };

            opLeerLineas(
                @"SELECT ESTADO_GENERAL, ROUND(AVG(PORCENTAJE_DE_AVANCE), 2) AS PROMEDIO
                  FROM PROYECTO
                  WHERE ESTADO_GENERAL <> 'ToDevelop'
                  GROUP BY ESTADO_GENERAL
                  HAVING AVG(PORCENTAJE_DE_AVANCE) > 40
                  ORDER BY AVG(PORCENTAJE_DE_AVANCE)",
                vrmReader => vrmLineas.Add(
                    "Estado: " + vrmReader["ESTADO_GENERAL"] +
                    " | Promedio: " + opFormatNumber(vrmReader["PROMEDIO"]) + "%"
                ),
                vrmLineas
            );

            return vrmLineas;
        }

        private static void opLeerLineas(string prmQuery, Action<SqliteDataReader> prmLineaAction, List<string> prmLineas)
        {
            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                using (SqliteCommand vrmCmd = new SqliteCommand(prmQuery, vrmConn))
                {
                    try
                    {
                        vrmConn.Open();

                        using (SqliteDataReader vrmReader = vrmCmd.ExecuteReader())
                        {
                            while (vrmReader.Read())
                            {
                                prmLineaAction(vrmReader);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        prmLineas.Add("❌ Error en la base de datos SQLite: " + ex.Message);
                    }
                }
            }
        }

        // Imprime 45 como "45" y 33.33 como "33.33", igual que Oracle
        private static string opFormatNumber(object prmValue)
        {
            return Convert.ToDouble(prmValue).ToString(CultureInfo.InvariantCulture);
        }
    }
}
