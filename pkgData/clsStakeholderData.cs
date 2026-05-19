using System;
using Oracle.ManagedDataAccess.Client;

#nullable disable

namespace GestionDeProyectos.pkgData
{
    public class clsStakeholderData
    {
        public static void opLoadStakeholders(Action<string, string, string, string, string, string> prmRegisterAction)
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
                                string vrmIDUsuario = vrmReader["ID_USUARIO"].ToString();
                                string vrmNombre = vrmReader["NOMBRE"].ToString();
                                
                                string vrmDescripcion = vrmReader["DESCRIPCION"] == DBNull.Value
                                    ? string.Empty
                                    : vrmReader["DESCRIPCION"].ToString();

                                string vrmCorreo = vrmReader["CORREO"].ToString();
                                string vrmContrasena = vrmReader["CONTRASENA"].ToString();
                                string vrmRol = vrmReader["ID_ROL"].ToString();

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
    }
}