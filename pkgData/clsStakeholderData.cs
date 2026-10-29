using System;
using Microsoft.Data.Sqlite;

#nullable disable

namespace GestionDeProyectos.pkgData
{
    public class clsStakeholderData
    {
        public static void opLoadStakeholders(Action<int, string, string, string, string, string> prmRegisterAction)
        {
            string vrmQuery = "SELECT ID_USUARIO, NOMBRE, DESCRIPCION, CORREO, CONTRASENA, ID_ROL FROM USUARIO";

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
                                int vrmIDUsuario = Convert.ToInt32(vrmReader["ID_USUARIO"]);
                                string vrmNombre = vrmReader["NOMBRE"]?.ToString() ?? string.Empty;

                                string vrmDescripcion = vrmReader["DESCRIPCION"] == DBNull.Value
                                    ? string.Empty
                                    : vrmReader["DESCRIPCION"].ToString();

                                string vrmCorreo = vrmReader["CORREO"]?.ToString() ?? string.Empty;
                                string vrmContrasena = vrmReader["CONTRASENA"]?.ToString() ?? string.Empty;
                                string vrmRol = vrmReader["ID_ROL"]?.ToString() ?? string.Empty;

                                prmRegisterAction(
                                    vrmIDUsuario,
                                    vrmNombre,
                                    vrmDescripcion,
                                    vrmCorreo,
                                    vrmContrasena,
                                    vrmRol
                                );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Error al cargar usuarios desde SQLite: " + ex.Message);
                    }
                }
            }
        }

        public static int opRegisterStakeholder(
            string prmName,
            string prmDescription,
            string prmEmail,
            string prmPassword,
            GestionDeProyectos.pkgDomain.clsRoles prmRol)
        {
            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                try
                {
                    vrmConn.Open();

                    string sql = @"INSERT INTO USUARIO
                    (NOMBRE, DESCRIPCION, CORREO, CONTRASENA, ID_ROL)
                    VALUES (@name, @description, @email, @password, @rol)
                    RETURNING ID_USUARIO";

                    using (SqliteCommand vrmCmd = new SqliteCommand(sql, vrmConn))
                    {
                        vrmCmd.Parameters.AddWithValue("@name", prmName);
                        vrmCmd.Parameters.AddWithValue("@description", string.IsNullOrEmpty(prmDescription) ? DBNull.Value : prmDescription);
                        vrmCmd.Parameters.AddWithValue("@email", prmEmail);
                        vrmCmd.Parameters.AddWithValue("@password", prmPassword);
                        vrmCmd.Parameters.AddWithValue("@rol", (int)prmRol);

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
                    Console.WriteLine("Error en opRegisterStakeholder: " + ex.Message);
                    return -1;
                }
            }
        }

        public static bool opActualizarStakeholder(
            int prmOUID,
            string prmName,
            string prmDescription,
            string prmEmail,
            string prmPassword,
            GestionDeProyectos.pkgDomain.clsRoles prmRol)
        {
            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                try
                {
                    vrmConn.Open();

                    string vrmSql = @"UPDATE USUARIO
                                      SET NOMBRE = @name,
                                          DESCRIPCION = @description,
                                          CORREO = @email,
                                          CONTRASENA = @password,
                                          ID_ROL = @rol
                                      WHERE ID_USUARIO = @id";

                    using (SqliteCommand vrmCmd = new SqliteCommand(vrmSql, vrmConn))
                    {
                        vrmCmd.Parameters.AddWithValue("@name", prmName);
                        vrmCmd.Parameters.AddWithValue("@description", string.IsNullOrEmpty(prmDescription) ? DBNull.Value : prmDescription);
                        vrmCmd.Parameters.AddWithValue("@email", prmEmail);
                        vrmCmd.Parameters.AddWithValue("@password", prmPassword);
                        vrmCmd.Parameters.AddWithValue("@rol", (int)prmRol);
                        vrmCmd.Parameters.AddWithValue("@id", prmOUID);

                        int vrmRowsAffected = vrmCmd.ExecuteNonQuery();
                        return vrmRowsAffected > 0;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error en opActualizarStakeholder: " + ex.Message);
                    return false;
                }
            }
        }
    }
}
