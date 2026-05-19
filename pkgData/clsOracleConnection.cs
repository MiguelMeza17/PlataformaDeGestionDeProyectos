using Oracle.ManagedDataAccess.Client;

namespace GestionDeProyectos.pkgData
{
    public class clsOracleConnection
    {
        private static readonly string connectionString =
            "User Id=MIGUEL_MEZA_WEB;Password=123456;Data Source=localhost:1521/XEPDB1;";

        public static OracleConnection opGetConnection()
        {
            return new OracleConnection(connectionString);
        }
    }
}