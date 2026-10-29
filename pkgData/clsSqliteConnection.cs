using System;
using System.IO;
using Microsoft.Data.Sqlite;

#nullable disable

namespace GestionDeProyectos.pkgData
{
    public class clsSqliteConnection
    {
        private const string attDatabaseFolder = "BaseDeDatos";
        private const string attDatabaseFile = "GestionDeProyectos.db";

        private static readonly string connectionString = new SqliteConnectionStringBuilder
        {
            DataSource = opFindDatabasePath(),
            Mode = SqliteOpenMode.ReadWrite,
            ForeignKeys = true
        }.ToString();

        public static SqliteConnection opGetConnection()
        {
            return new SqliteConnection(connectionString);
        }

        // Las fechas se guardan como TEXT 'yyyy-MM-dd' (ver Documentacion/BaseDeDatos/SQLite.sql)
        public static string opFormatDate(DateTime prmDate)
        {
            return prmDate.ToString("yyyy-MM-dd");
        }

        // Busca BaseDeDatos/GestionDeProyectos.db subiendo desde bin/ hasta la raíz del proyecto,
        // para que la app use siempre el mismo .db sin importar desde dónde se ejecute.
        private static string opFindDatabasePath()
        {
            DirectoryInfo vrmDir = new DirectoryInfo(AppContext.BaseDirectory);

            while (vrmDir != null)
            {
                string vrmCandidate = Path.Combine(vrmDir.FullName, attDatabaseFolder, attDatabaseFile);
                if (File.Exists(vrmCandidate))
                    return vrmCandidate;

                vrmDir = vrmDir.Parent;
            }

            return Path.Combine(Directory.GetCurrentDirectory(), attDatabaseFolder, attDatabaseFile);
        }
    }
}
