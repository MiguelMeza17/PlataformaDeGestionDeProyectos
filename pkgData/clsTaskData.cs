using System;
using System.Globalization;
using Microsoft.Data.Sqlite;
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
                VALUES (@nombre, @descripcion, @fechaInicio, @fechaLimite, @idEstado, @idProyecto, @idUsuarioAsigna, @idUsuarioDesarrolla)
                RETURNING ID_TAREA";

            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                try
                {
                    vrmConn.Open();

                    using (SqliteCommand vrmCmd = new SqliteCommand(sql, vrmConn))
                    {
                        vrmCmd.Parameters.AddWithValue("@nombre",              prmNombre);
                        vrmCmd.Parameters.AddWithValue("@descripcion",         (object)prmDescripcion ?? DBNull.Value);
                        vrmCmd.Parameters.AddWithValue("@fechaInicio",         clsSqliteConnection.opFormatDate(prmFechaInicio));
                        vrmCmd.Parameters.AddWithValue("@fechaLimite",         clsSqliteConnection.opFormatDate(prmFechaLimite));
                        vrmCmd.Parameters.AddWithValue("@idEstado",            (int)prmEstado);
                        vrmCmd.Parameters.AddWithValue("@idProyecto",          prmIdProyecto);
                        vrmCmd.Parameters.AddWithValue("@idUsuarioAsigna",     prmIdUsuarioAsigna);
                        vrmCmd.Parameters.AddWithValue("@idUsuarioDesarrolla", prmIdUsuarioDesarrolla);

                        object vrmId = vrmCmd.ExecuteScalar();

                        if (vrmId != null && vrmId != DBNull.Value)
                        {
                            return Convert.ToInt32(vrmId);
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
                           SET ID_ESTADO = @idEstado
                           WHERE ID_TAREA = @idTarea";

            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                try
                {
                    vrmConn.Open();

                    using (SqliteCommand vrmCmd = new SqliteCommand(sql, vrmConn))
                    {
                        vrmCmd.Parameters.AddWithValue("@idEstado", prmNewState);
                        vrmCmd.Parameters.AddWithValue("@idTarea", prmOUID);

                        // SQLite cuenta la fila aunque ya tuviera ese estado, así que 0 significa que la tarea no existe
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

            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                try
                {
                    vrmConn.Open();

                    using (SqliteCommand vrmCmd = new SqliteCommand(sql, vrmConn))
                    {
                        using (SqliteDataReader vrmReader = vrmCmd.ExecuteReader())
                        {
                            while (vrmReader.Read())
                            {
                                int id = Convert.ToInt32(vrmReader["ID_TAREA"]);
                                string nombre = vrmReader["NOMBRE"].ToString();
                                string descripcion = vrmReader["DESCRIPCION"] == DBNull.Value ? "" : vrmReader["DESCRIPCION"].ToString();
                                DateTime fechaInicio = Convert.ToDateTime(vrmReader["FECHA_INICIO"], CultureInfo.InvariantCulture);
                                DateTime fechaLimite = Convert.ToDateTime(vrmReader["FECHA_LIMITE"], CultureInfo.InvariantCulture);
                                int idEstado = Convert.ToInt32(vrmReader["ID_ESTADO"]);
                                int idProyecto = Convert.ToInt32(vrmReader["ID_PROYECTO"]);
                                int idUsuarioAsigna = Convert.ToInt32(vrmReader["ID_USUARIO_ASIGNA"]);
                                // ID_USUARIO_DESARROLLA admite NULL (tarea sin desarrollador asignado)
                                int idUsuarioDesarrolla = vrmReader["ID_USUARIO_DESARROLLA"] == DBNull.Value ? 0 : Convert.ToInt32(vrmReader["ID_USUARIO_DESARROLLA"]);

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
