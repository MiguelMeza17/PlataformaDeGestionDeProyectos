using Oracle.ManagedDataAccess.Client;

namespace GestionDeProyectos.pkgData
{
    public class clsOracleConnection
    {
        private static readonly string connectionString =
            "User Id=ALEJO;Password=chavisnan;Data Source=localhost:1522/xepdb1;";

        public static OracleConnection opGetConnection()
        {
            return new OracleConnection(connectionString);
        }
    }
}