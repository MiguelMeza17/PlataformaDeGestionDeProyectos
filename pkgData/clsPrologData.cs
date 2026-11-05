using System;
using System.IO;
using System.Text;
using Microsoft.Data.Sqlite;

#nullable disable

namespace GestionDeProyectos.pkgData
{
    public class clsPrologData
    {
        // Escribe en prmRuta los hechos que usa pkgProlog/reglas.pl.
        // Solo exporta lo que las reglas necesitan: correos y contraseñas no salen de la base.
        // A diferencia de las otras clases de datos, no atrapa los errores de SQLite: unos hechos
        // incompletos se verían en el panel como "sin alertas".
        public static void opGenerarHechos(string prmRuta)
        {
            StringBuilder vrmHechos = new StringBuilder();

            vrmHechos.AppendLine("% Archivo generado por clsPrologData. No editar a mano.");
            vrmHechos.AppendLine(":- encoding(utf8).");
            // Sin esto, una tabla vacía haría fallar las reglas por predicado inexistente
            vrmHechos.AppendLine(":- dynamic proyecto/4, usuario/2, tarea/6.");
            vrmHechos.AppendLine();
            vrmHechos.AppendLine("hoy(" + opAtomo(clsSqliteConnection.opFormatDate(DateTime.Today)) + ").");
            vrmHechos.AppendLine();

            using (SqliteConnection vrmConn = clsSqliteConnection.opGetConnection())
            {
                vrmConn.Open();

                opAgregarHechos(
                    vrmConn,
                    "SELECT ID_PROYECTO, NOMBRE, FECHA_FINALIZACION, ESTADO_GENERAL FROM PROYECTO ORDER BY ID_PROYECTO",
                    vrmReader => "proyecto("
                        + vrmReader.GetInt32(0) + ", "
                        + opAtomo(vrmReader.GetString(1)) + ", "
                        + opAtomo(vrmReader.GetString(2)) + ", "
                        + opAtomo(vrmReader.GetString(3)) + ").",
                    vrmHechos
                );

                opAgregarHechos(
                    vrmConn,
                    "SELECT ID_USUARIO, NOMBRE FROM USUARIO ORDER BY ID_USUARIO",
                    vrmReader => "usuario("
                        + vrmReader.GetInt32(0) + ", "
                        + opAtomo(vrmReader.GetString(1)) + ").",
                    vrmHechos
                );

                opAgregarHechos(
                    vrmConn,
                    @"SELECT T.ID_TAREA, T.NOMBRE, T.ID_PROYECTO, COALESCE(T.ID_USUARIO_DESARROLLA, 0), E.NOMBRE, T.FECHA_LIMITE
                      FROM TAREA T
                      JOIN ESTADO E ON E.ID_ESTADO = T.ID_ESTADO
                      ORDER BY T.ID_TAREA",
                    vrmReader => "tarea("
                        + vrmReader.GetInt32(0) + ", "
                        + opAtomo(vrmReader.GetString(1)) + ", "
                        + vrmReader.GetInt32(2) + ", "
                        + vrmReader.GetInt32(3) + ", "
                        + opAtomo(vrmReader.GetString(4)) + ", "
                        + opAtomo(vrmReader.GetString(5)) + ").",
                    vrmHechos
                );
            }

            File.WriteAllText(prmRuta, vrmHechos.ToString(), new UTF8Encoding(false));
        }

        private static void opAgregarHechos(
            SqliteConnection prmConn,
            string prmQuery,
            Func<SqliteDataReader, string> prmHecho,
            StringBuilder prmHechos)
        {
            using (SqliteCommand vrmCmd = new SqliteCommand(prmQuery, prmConn))
            using (SqliteDataReader vrmReader = vrmCmd.ExecuteReader())
            {
                while (vrmReader.Read())
                {
                    prmHechos.AppendLine(prmHecho(vrmReader));
                }
            }

            prmHechos.AppendLine();
        }

        // Los nombres los escriben los usuarios: sin escapar, una comilla rompería
        // el archivo o permitiría inyectar código Prolog.
        private static string opAtomo(string prmTexto)
        {
            string vrmEscapado = prmTexto
                .Replace("\\", "\\\\")
                .Replace("'", "\\'")
                .Replace("\r", "\\r")
                .Replace("\n", "\\n")
                .Replace("\t", "\\t");

            return "'" + vrmEscapado + "'";
        }
    }
}
