using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;

#nullable disable

namespace GestionDeProyectos.pkgData
{
    public class clsProjectData
    {
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
        public static bool opInsertarProyecto(string prmNom, string prmDesc, DateTime prmFi, DateTime prmFf, string prmEg, float prmAv)
        {
            string vrmProcedure = "PKG_PROYECTO.INSERTAR";

            using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
            {
                using (OracleCommand vrmCmd = new OracleCommand(vrmProcedure, vrmConn))
                {
                    vrmCmd.CommandType = CommandType.StoredProcedure;


                    vrmCmd.Parameters.Add(new OracleParameter("p_nom", OracleDbType.Varchar2)).Value = prmNom;
                    vrmCmd.Parameters.Add(new OracleParameter("p_desc", OracleDbType.Varchar2)).Value = prmDesc;
                    vrmCmd.Parameters.Add(new OracleParameter("p_fi", OracleDbType.Date)).Value = prmFi;
                    vrmCmd.Parameters.Add(new OracleParameter("p_ff", OracleDbType.Date)).Value = prmFf;
                    vrmCmd.Parameters.Add(new OracleParameter("p_eg", OracleDbType.Varchar2)).Value = prmEg;
                    vrmCmd.Parameters.Add(new OracleParameter("p_av", OracleDbType.Single)).Value = prmAv;

                    try
                    {
                        vrmConn.Open();
                        vrmCmd.ExecuteNonQuery();
                        return true;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Error al insertar proyecto vía Paquete: " + ex.Message);
                        return false;
                    }
                }
            }
        }

        public static bool opActualizarProyecto(int prmId, string prmNom, string prmDesc, DateTime prmFi, DateTime prmFf, string prmEg, float prmAv)
        {
            string vrmProcedure = "PKG_PROYECTO.ACTUALIZAR";

            using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
            {
                using (OracleCommand vrmCmd = new OracleCommand(vrmProcedure, vrmConn))
                {
                    vrmCmd.CommandType = CommandType.StoredProcedure;

                    vrmCmd.Parameters.Add(new OracleParameter("p_id", OracleDbType.Int32)).Value = prmId;
                    vrmCmd.Parameters.Add(new OracleParameter("p_nom", OracleDbType.Varchar2)).Value = prmNom;
                    vrmCmd.Parameters.Add(new OracleParameter("p_desc", OracleDbType.Varchar2)).Value = prmDesc;
                    vrmCmd.Parameters.Add(new OracleParameter("p_fi", OracleDbType.Date)).Value = prmFi;
                    vrmCmd.Parameters.Add(new OracleParameter("p_ff", OracleDbType.Date)).Value = prmFf;
                    vrmCmd.Parameters.Add(new OracleParameter("p_eg", OracleDbType.Varchar2)).Value = prmEg;
                    vrmCmd.Parameters.Add(new OracleParameter("p_av", OracleDbType.Single)).Value = prmAv;

                    try
                    {
                        vrmConn.Open();
                        vrmCmd.ExecuteNonQuery();
                        return true;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Error al actualizar proyecto vía Paquete: " + ex.Message);
                        return false;
                    }
                }
            }
        }

        public static bool opEliminarProyecto(int prmId)
        {
            string vrmProcedure = "PKG_PROYECTO.ELIMINAR";

            using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
            {
                using (OracleCommand vrmCmd = new OracleCommand(vrmProcedure, vrmConn))
                {
                    vrmCmd.CommandType = CommandType.StoredProcedure;
                    vrmCmd.Parameters.Add(new OracleParameter("p_id", OracleDbType.Int32)).Value = prmId;

                    try
                    {
                        vrmConn.Open();
                        vrmCmd.ExecuteNonQuery();
                        return true;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Error al eliminar proyecto vía Paquete: " + ex.Message);
                        return false;
                    }
                }
            }
        }
    }
}