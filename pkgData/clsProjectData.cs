using System;
using Oracle.ManagedDataAccess.Client;

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

            using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
            {
                using (OracleCommand vrmCmd = new OracleCommand(vrmQuery, vrmConn))
                {
                    try
                    {
                        vrmConn.Open();

                        using (OracleDataReader vrmReader = vrmCmd.ExecuteReader())
                        {
                            while (vrmReader.Read())
                            {
                                // Corrección: Convertir a int usando Convert.ToInt32
                                int vrmIDProyecto = Convert.ToInt32(vrmReader["ID_PROYECTO"]);

                                string vrmNombre = vrmReader["NOMBRE"]?.ToString() ?? string.Empty;

                                string vrmDescripcion = vrmReader["DESCRIPCION"] == DBNull.Value
                                    ? string.Empty
                                    : vrmReader["DESCRIPCION"].ToString();

                                DateTime vrmFechaInicio = Convert.ToDateTime(vrmReader["FECHA_INICIO"]);

                                DateTime vrmFechaFinalizacion = Convert.ToDateTime(vrmReader["FECHA_FINALIZACION"]);

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
                            "Error al cargar proyectos desde Oracle: "
                            + ex.Message
                        );
                    }
                }
            }
        }
    }
}