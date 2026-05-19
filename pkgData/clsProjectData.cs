using System;
using Oracle.ManagedDataAccess.Client;

#nullable disable

namespace GestionDeProyectos.pkgData
{
    public class clsProjectData
    {
        public static void opLoadProjects
        (
            Action<string, string, string, DateTime, DateTime, string, float> prmRegisterAction
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
                                string vrmIDProyecto =
                                    vrmReader["ID_PROYECTO"].ToString();

                                string vrmNombre =
                                    vrmReader["NOMBRE"].ToString();

                                string vrmDescripcion =
                                    vrmReader["DESCRIPCION"] == DBNull.Value
                                    ? string.Empty
                                    : vrmReader["DESCRIPCION"].ToString();

                                DateTime vrmFechaInicio =
                                    Convert.ToDateTime(vrmReader["FECHA_INICIO"]);

                                DateTime vrmFechaFinalizacion =
                                    Convert.ToDateTime(vrmReader["FECHA_FINALIZACION"]);

                                string vrmEstadoGeneral =
                                    vrmReader["ESTADO_GENERAL"].ToString();

                                float vrmPorcentajeAvance =
                                    Convert.ToSingle(vrmReader["PORCENTAJE_DE_AVANCE"]);

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