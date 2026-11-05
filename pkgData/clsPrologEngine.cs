using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Text;
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

        // Regenera los hechos desde SQLite, ejecuta las reglas y devuelve el JSON que imprime Prolog
        public static string opConsultarAlertas()
        {
            lock (attLock)
            {
                string vrmCarpeta = opFindPrologFolder();

                clsPrologData.opGenerarHechos(Path.Combine(vrmCarpeta, attFactsFile));

                return opEjecutarSwipl(vrmCarpeta);
            }
        }

        private static string opEjecutarSwipl(string prmCarpeta)
        {
            ProcessStartInfo vrmInfo = new ProcessStartInfo(opFindSwipl())
            {
                WorkingDirectory = prmCarpeta,
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8
            };

            foreach (string vrmArg in new[] { "-q", "--on-error=status", "-g", "main", "-t", "halt", attEntryFile })
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
