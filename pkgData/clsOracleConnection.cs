using Oracle.ManagedDataAccess.Client;
using System.Configuration; // Si usas App.config / Web.config

namespace GestionDeProyectos.pkgData
{
    public class clsOracleConnection
    {
        // Connection strings configurables (puedes cambiarlas fácilmente)
        private static readonly string ConnectionStringAlejo =
            "User Id=ALEJO;Password=chavisnan;Data Source=localhost:1522/xepdb1;";

        private static readonly string ConnectionStringMiguel =
            "User Id=MIGUEL_MEZA_WEB;Password=123456;Data Source=localhost:1521/XEPDB1;";

        /// <summary>
        /// Obtiene conexión según el usuario deseado
        /// </summary>
        public static OracleConnection opGetConnection(string usuario = "ALEJO")
        {
            string connectionString = usuario.ToUpper() switch
            {
                "ALEJO" => ConnectionStringAlejo,
                "MIGUEL" or "MIGUEL_MEZA_WEB" => ConnectionStringMiguel,
                _ => ConnectionStringAlejo // por defecto usa ALEJO
            };

            return new OracleConnection(connectionString);
        }

        /// <summary>
        /// Prueba de conexión
        /// </summary>
        public static bool TestConnection(string usuario = "ALEJO")
        {
            try
            {
                using (OracleConnection conn = opGetConnection(usuario))
                {
                    conn.Open();
                    Console.WriteLine($"✅ Conexión exitosa con usuario: {usuario}");
                    return true;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error con {usuario}: {ex.Message}");
                return false;
            }
        }
    }
}