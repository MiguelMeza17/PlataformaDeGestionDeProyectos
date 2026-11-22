using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

#nullable disable

namespace GestionDeProyectos.pkgData
{
    public class clsPrologEngine
    {
        private const string attPrologFolder = "pkgProlog";
        private const string attFactsFile = "hechos.pl";
        private const string attEntryFile = "consultas.pl";
        // swipl.exe y no swipl-win.exe: la versión -win abre una ventana y no escribe en la salida estándar
        private const string attDefaultSwipl = @"C:\Program Files\swipl\bin\swipl.exe";
        private const int attTimeoutMs = 10000;

        // Todas las peticiones comparten hechos.pl: una no debe reescribirlo mientras otra lo lee
        private static readonly object attLock = new object();

        public static string opConsultarAlertas()
        {
            return opConsultar("alertas_json", null);
        }

        public static string opConsultarSugerencias()
        {
            return opConsultar("sugerencias_json", null);
        }

        // La pregunta viaja como JSON por la entrada estándar, nunca como código Prolog:
        // así el texto del usuario no puede ejecutar nada en swipl.
        public static string opPreguntar(string prmPregunta, int prmIdUsuario, string prmVista)
        {
            string vrmEntrada = JsonSerializer.Serialize(new
            {
                pregunta = prmPregunta,
                idUsuario = prmIdUsuario,
                vista = prmVista
            });

            return opConsultar("preguntar_json", vrmEntrada);
        }

        // Regenera los hechos desde SQLite, ejecuta el objetivo de consultas.pl y devuelve el JSON que imprime
        private static string opConsultar(string prmObjetivo, string prmEntrada)
        {
            lock (attLock)
            {
                string vrmCarpeta = opFindPrologFolder();

                clsPrologData.opGenerarHechos(Path.Combine(vrmCarpeta, attFactsFile));

                return opEjecutarSwipl(vrmCarpeta, prmObjetivo, prmEntrada);
            }
        }

        private static string opEjecutarSwipl(string prmCarpeta, string prmObjetivo, string prmEntrada)
        {
            ProcessStartInfo vrmInfo = new ProcessStartInfo(opFindSwipl())
            {
                WorkingDirectory = prmCarpeta,
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardInput = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                // Sin BOM: Prolog lo leería como parte del JSON
                StandardInputEncoding = new UTF8Encoding(false),
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8
            };

            foreach (string vrmArg in new[] { "-q", "--on-error=status", "-g", prmObjetivo, "-t", "halt", attEntryFile })
            {
                vrmInfo.ArgumentList.Add(vrmArg);
            }

            try
            {
                using (Process vrmProceso = Process.Start(vrmInfo))
                {
                    // Se leen en paralelo para que el proceso no se bloquee si llena una de las dos salidas
                    Task<string> vrmSalida = vrmProceso.StandardOutput.ReadToEndAsync();
                    Task<string> vrmErrores = vrmProceso.StandardError.ReadToEndAsync();

                    if (prmEntrada != null)
                    {
                        vrmProceso.StandardInput.Write(prmEntrada);
                    }
                    vrmProceso.StandardInput.Close();

                    if (!vrmProceso.WaitForExit(attTimeoutMs))
                    {
                        vrmProceso.Kill(true);
                        throw new InvalidOperationException("Prolog no respondió en " + attTimeoutMs / 1000 + " segundos.");
                    }

                    if (vrmProceso.ExitCode != 0)
                    {
                        throw new InvalidOperationException("Prolog terminó con error: " + vrmErrores.GetAwaiter().GetResult());
                    }

                    return vrmSalida.GetAwaiter().GetResult();
                }
            }
            catch (Win32Exception ex)
            {
                throw new InvalidOperationException(
                    "No se encontró swipl. Instala SWI-Prolog o define la variable de entorno SWIPL_PATH. " + ex.Message
                );
            }
        }

        private static string opFindSwipl()
        {
            string vrmConfigurado = Environment.GetEnvironmentVariable("SWIPL_PATH");

            if (!string.IsNullOrEmpty(vrmConfigurado))
                return vrmConfigurado;

            return File.Exists(attDefaultSwipl) ? attDefaultSwipl : "swipl";
        }

        // Igual que clsSqliteConnection: sube desde bin/ hasta encontrar la raíz del proyecto
        private static string opFindPrologFolder()
        {
            DirectoryInfo vrmDir = new DirectoryInfo(AppContext.BaseDirectory);

            while (vrmDir != null)
            {
                string vrmCandidate = Path.Combine(vrmDir.FullName, attPrologFolder);
                if (File.Exists(Path.Combine(vrmCandidate, attEntryFile)))
                    return vrmCandidate;

                vrmDir = vrmDir.Parent;
            }

            throw new InvalidOperationException("No se encontró la carpeta " + attPrologFolder + ".");
        }
    }
}
