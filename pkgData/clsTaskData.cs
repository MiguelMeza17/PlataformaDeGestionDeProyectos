using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using GestionDeProyectos.pkgDomain;

#nullable disable

namespace GestionDeProyectos.pkgData
{
    public class clsTaskData
    {
        public static int opRegisterTask(
            string prmNombre,
            string prmDescripcion,
            DateTime prmFechaInicio,
            DateTime prmFechaLimite,
            clsState prmEstado,
            int prmIdProyecto,
            int prmIdUsuarioAsigna,
            int prmIdUsuarioDesarrolla)
        {
            string sql = @"INSERT INTO TAREA 
                (NOMBRE, DESCRIPCION, FECHA_INICIO, FECHA_LIMITE, ID_ESTADO, ID_PROYECTO, ID_USUARIO_ASIGNA, ID_USUARIO_DESARROLLA) 
                VALUES (:nombre, :descripcion, :fechaInicio, :fechaLimite, :idEstado, :idProyecto, :idUsuarioAsigna, :idUsuarioDesarrolla)
                RETURNING ID_TAREA INTO :prmId";

            using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
            {
                try
                {
                    vrmConn.Open();

                    using (OracleCommand vrmCmd = new OracleCommand(sql, vrmConn))
                    {
                        vrmCmd.Parameters.Add("nombre",              OracleDbType.Varchar2).Value = prmNombre;
                        vrmCmd.Parameters.Add("descripcion",         OracleDbType.Varchar2).Value = prmDescripcion;
                        vrmCmd.Parameters.Add("fechaInicio",         OracleDbType.Date).Value     = prmFechaInicio;
                        vrmCmd.Parameters.Add("fechaLimite",         OracleDbType.Date).Value     = prmFechaLimite;
                        vrmCmd.Parameters.Add("idEstado",            OracleDbType.Int32).Value    = (int)prmEstado;
                        vrmCmd.Parameters.Add("idProyecto",          OracleDbType.Int32).Value    = prmIdProyecto;
                        vrmCmd.Parameters.Add("idUsuarioAsigna",     OracleDbType.Int32).Value    = prmIdUsuarioAsigna;
                        vrmCmd.Parameters.Add("idUsuarioDesarrolla", OracleDbType.Int32).Value    = prmIdUsuarioDesarrolla;

                        OracleParameter outParam = new OracleParameter("prmId", OracleDbType.Int32)
                        {
                            Direction = ParameterDirection.Output
                        };
                        vrmCmd.Parameters.Add(outParam);

                        if (vrmCmd.ExecuteNonQuery() > 0)
                        {
                            return Convert.ToInt32(outParam.Value.ToString());
                        }

                        return -1;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error en opRegisterTask: " + ex.Message);
                    return -1;
                }
            }
        }

        public static bool opActualizarEstadoTarea(int prmOUID, int prmNewState)
        {
            string sql = @"UPDATE TAREA 
                           SET ID_ESTADO = :idEstado 
                           WHERE ID_TAREA = :idTarea";

            using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
            {
                try
                {
                    vrmConn.Open();

                    using (OracleCommand vrmCmd = new OracleCommand(sql, vrmConn))
                    {
                        // Esta línea obliga a Oracle a usar los nombres ':idEstado' e ':idTarea'
                        // solucionando el problema de orden posicional por defecto
                        vrmCmd.BindByName = true;

                        vrmCmd.Parameters.Add("idEstado", OracleDbType.Int32).Value = prmNewState;
                        vrmCmd.Parameters.Add("idTarea", OracleDbType.Int32).Value = prmOUID;

                        return vrmCmd.ExecuteNonQuery() > 0;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error en opActualizarEstadoTarea: " + ex.Message);
                    return false;
                }
            }
        }

        public static void opLoadTasks(Action<int, string, string, DateTime, DateTime, int, int, int, int> prmAction)
        {
            string sql = @"SELECT ID_TAREA, NOMBRE, DESCRIPCION, FECHA_INICIO, FECHA_LIMITE, ID_ESTADO, ID_PROYECTO, ID_USUARIO_ASIGNA, ID_USUARIO_DESARROLLA 
                           FROM TAREA";

            using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
            {
                try
                {
                    vrmConn.Open();

                    using (OracleCommand vrmCmd = new OracleCommand(sql, vrmConn))
                    {
                        using (OracleDataReader vrmReader = vrmCmd.ExecuteReader())
                        {
                            while (vrmReader.Read())
                            {
                                int id = Convert.ToInt32(vrmReader["ID_TAREA"]);
                                string nombre = vrmReader["NOMBRE"].ToString();
                                string descripcion = vrmReader["DESCRIPCION"] == DBNull.Value ? "" : vrmReader["DESCRIPCION"].ToString();
                                DateTime fechaInicio = Convert.ToDateTime(vrmReader["FECHA_INICIO"]);
                                DateTime fechaLimite = Convert.ToDateTime(vrmReader["FECHA_LIMITE"]);
                                int idEstado = Convert.ToInt32(vrmReader["ID_ESTADO"]);
                                int idProyecto = Convert.ToInt32(vrmReader["ID_PROYECTO"]);
                                int idUsuarioAsigna = Convert.ToInt32(vrmReader["ID_USUARIO_ASIGNA"]);
                                int idUsuarioDesarrolla = Convert.ToInt32(vrmReader["ID_USUARIO_DESARROLLA"]);

                                prmAction(id, nombre, descripcion, fechaInicio, fechaLimite, idEstado, idProyecto, idUsuarioAsigna, idUsuarioDesarrolla);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error en opLoadTasks: " + ex.Message);
                }
            }
        }
    }
}