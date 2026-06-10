using System;
using System.Data;
using Oracle.ManagedDataAccess.Client;

#nullable disable

namespace GestionDeProyectos.pkgData
{
    public class clsStakeholderData
    {
        public static void opLoadStakeholders(Action<int, string, string, string, string, string> prmRegisterAction)
        {
            string vrmQuery = "SELECT ID_USUARIO, NOMBRE, DESCRIPCION, CORREO, CONTRASENA, ID_ROL FROM USUARIO";

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
                        Console.WriteLine("Error al cargar usuarios desde Oracle: " + ex.Message);
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
            using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
            {
                try
                {
                    vrmConn.Open();

                    string sql = @"INSERT INTO USUARIO 
                    (NOMBRE, DESCRIPCION, CORREO, CONTRASENA, ID_ROL) 
                    VALUES (:name, :description, :email, :password, :rol) 
                    RETURNING ID_USUARIO INTO :prmId";

                    using (OracleCommand vrmCmd = new OracleCommand(sql, vrmConn))
                    {

                        vrmCmd.BindByName = true;

                        vrmCmd.Parameters.Add("name", OracleDbType.Varchar2).Value = prmName;
                        vrmCmd.Parameters.Add("description", OracleDbType.Varchar2).Value = string.IsNullOrEmpty(prmDescription) ? DBNull.Value : prmDescription;
                        vrmCmd.Parameters.Add("email", OracleDbType.Varchar2).Value = prmEmail;
                        vrmCmd.Parameters.Add("password", OracleDbType.Varchar2).Value = prmPassword;
                        vrmCmd.Parameters.Add("rol", OracleDbType.Int32).Value = (int)prmRol;

                        OracleParameter outParam = new OracleParameter("prmId", OracleDbType.Int32)
                        {
                            Direction = ParameterDirection.Output
                        };
                        vrmCmd.Parameters.Add(outParam);

                        vrmCmd.ExecuteNonQuery();

                        if (outParam.Value != DBNull.Value)
                        {
                            return Convert.ToInt32(outParam.Value.ToString());
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
            using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
            {
                try
                {
                    vrmConn.Open();

                    string vrmSql = @"UPDATE USUARIO 
                                      SET NOMBRE = :name, 
                                          DESCRIPCION = :description, 
                                          CORREO = :email, 
                                          CONTRASENA = :password, 
                                          ID_ROL = :rol 
                                      WHERE ID_USUARIO = :id";

                    using (OracleCommand vrmCmd = new OracleCommand(vrmSql, vrmConn))
                    {
                        vrmCmd.BindByName = true;

                        vrmCmd.Parameters.Add("name", OracleDbType.Varchar2).Value = prmName;
                        vrmCmd.Parameters.Add("description", OracleDbType.Varchar2).Value = string.IsNullOrEmpty(prmDescription) ? DBNull.Value : prmDescription;
                        vrmCmd.Parameters.Add("email", OracleDbType.Varchar2).Value = prmEmail;
                        vrmCmd.Parameters.Add("password", OracleDbType.Varchar2).Value = prmPassword;
                        vrmCmd.Parameters.Add("rol", OracleDbType.Int32).Value = (int)prmRol;
                        vrmCmd.Parameters.Add("id", OracleDbType.Int32).Value = prmOUID;

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