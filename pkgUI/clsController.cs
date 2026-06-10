using System;
using System.Collections.Generic;
using GestionDeProyectos.pkgDomain;
using GestionDeProyectos.pkgSystem;
using GestionDeProyectos.pkgData;
using Oracle.ManagedDataAccess.Client;
using System.Data;

#nullable disable

namespace GestionDeProyectos.pkgUI
{
    public class clsController
    {
        private static clsController attInstance = null!;
        private List<clsStakeholder> attStakeholders = new List<clsStakeholder>();
        private List<clsProject> attProjects = new List<clsProject>();
        private List<clsTask> attTasks = new List<clsTask>();
        public List<clsProject> opListAllProjects()
        {
        return attProjects;
        }
    private clsController()
    {

        attStakeholders.Clear();

        clsStakeholderData.opLoadStakeholders((id, name, desc, email, pass, rolStr) =>
        {
            clsRoles rolEnum = clsRoles.Developer;

            if (rolStr == "0")
                rolEnum = clsRoles.Admin;
            else if (rolStr == "1")
                rolEnum = clsRoles.Manager;
            else if (rolStr == "2")
                rolEnum = clsRoles.Developer;

            clsStakeholder varObj = new clsStakeholder(id, name, desc, email, pass, rolEnum);
            attStakeholders.Add(varObj);
        });
        attProjects.Clear();
    clsProjectData.opLoadProjects((id, name, desc, start, end, state, advance) =>
    {
        clsProject varProj = new clsProject(id, name, desc, start, end, state, advance);
        attProjects.Add(varProj);
    });
    }

        public static clsController opGetInstance()
        {
            if (attInstance == null)
                attInstance = new clsController();
            return attInstance;
        }

        public clsStakeholder opLoginStakeholder(string prmEmail, string prmPassword)
        {
            foreach (clsStakeholder varObj in attStakeholders)
            {
                if (varObj.opCompareCredentials(prmEmail, prmPassword))
                {
                    return varObj;
                }
            }
            return null;
        }

        public bool opRegisterProject(
            int prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmStartingDate,
            DateTime prmEndingDate,
            string prmGeneralState,
            float prmAdvancePercentage)
        {
            clsProject varObj = opGetProject(0,prmName);

            if (varObj != null) 
                return false;

            int nuevoId =
    clsProjectData.opInsertarProyecto(
        prmName,
        prmDescription,
        prmStartingDate,
        prmEndingDate,
        prmGeneralState,
        prmAdvancePercentage
    );

if (nuevoId == 0)
    return false;
clsProject nuevoProyecto =
    new clsProject(
        nuevoId,
        prmName,
        prmDescription,
        prmStartingDate,
        prmEndingDate,
        prmGeneralState,
        prmAdvancePercentage
    );

attProjects.Add(nuevoProyecto);

return true;
        }

    public bool opRegisterStakeholder(
        string prmName,
        string prmDescription,
        string prmEmail,
        string prmPassword,
        clsRoles prmRol)
    {
        clsStakeholder varObj = opGetStakeholder(0, prmEmail);
        if (varObj != null) return false;

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
                    vrmCmd.Parameters.Add("name", OracleDbType.Varchar2).Value = prmName;
                    vrmCmd.Parameters.Add("description", OracleDbType.Varchar2).Value = prmDescription;
                    vrmCmd.Parameters.Add("email", OracleDbType.Varchar2).Value = prmEmail;
                    vrmCmd.Parameters.Add("password", OracleDbType.Varchar2).Value = prmPassword;
                    vrmCmd.Parameters.Add("rol", OracleDbType.Int32).Value = prmRol;

                    OracleParameter outParam = new OracleParameter("prmId", OracleDbType.Int32)
                    {
                        Direction = ParameterDirection.Output
                    };

                    vrmCmd.Parameters.Add(outParam);

                    if (vrmCmd.ExecuteNonQuery() > 0)
                    {
                        int prmOUID = Convert.ToInt32(outParam.Value.ToString());

                        clsStakeholder newStakeholder = new clsStakeholder(
                            prmOUID,
                            prmName,
                            prmDescription,
                            prmEmail,
                            prmPassword,
                            prmRol
                        );

                        return opAssociateStakeholder(newStakeholder);
                    }

                    return false;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error en opRegisterStakeholder: " + ex.Message);
                return false;
            }
        }
    }



        public bool opRegisterTask(
            int prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmFirstDate,
            DateTime prmLimitDate,
            clsState prmState)
        {
            clsTask varObj = opGetTask(0,prmName);

            if (varObj != null)
                return false;

            clsTask newTask = new clsTask(
                prmOUID,
                prmName,
                prmDescription,
                prmFirstDate,
                prmLimitDate,
                prmState);

            return opAssociateTask(newTask);
        }
        public bool opRegisterReport(
            int prmProjectOUID,
            int prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmDate,
            string prmProgressSummary,
            int prmRetardedTasks)
        {
            Console.WriteLine("Proyecto recibido: " + prmProjectOUID);
            clsProject varProject = opGetProject(prmProjectOUID,null);

            if (varProject == null){
                Console.WriteLine("Proyecto NO encontrado");
                return false;
            }
            Console.WriteLine("Proyecto encontrado: " + varProject.Name);
            return varProject.opRegisterReport(
                prmOUID,
                prmName,
                prmDescription,
                prmDate,
                prmProgressSummary,
                prmRetardedTasks
            );
        }

        public bool opUpdateProject(
        int prmOUID,
        string prmName,
        string prmDescription,
        DateTime prmStartingDate,
        DateTime prmEndingDate,
        string prmGeneralState,
        float prmAdvancePercentage)
        {
        clsProject varObj = opGetProject(prmOUID, null);
        if (varObj == null)
            return false;

        // 🌟 PASO 1: Actualizar en Oracle llamando al Paquete
        bool vrmDbSuccess = clsProjectData.opActualizarProyecto(
            prmOUID, prmName, prmDescription, prmStartingDate, prmEndingDate, prmGeneralState, prmAdvancePercentage
        );

        if (!vrmDbSuccess) return false;

        // 🌟 PASO 2: Modificar los datos en la memoria local
        return varObj.opModify(
            prmName,
            prmDescription,
            prmStartingDate,
            prmEndingDate,
            prmGeneralState,
            prmAdvancePercentage
    );
}
        public bool opUpdateStakeholder(
            int prmOUID,
            string prmName,
            string prmDescription,
            string prmEmail,
            string prmPassword,
            clsRoles prmRol)
        {
            clsStakeholder varObj = opGetStakeholder(prmOUID,null);

            if (varObj == null)
                return false;

            return varObj.opModify(
                prmName,
                prmDescription,
                prmEmail,
                prmPassword,
                prmRol
            );
        }
        public bool opUpdateTask(
            int prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmFirstDate,
            DateTime prmLimitDate,
            clsState prmState)
        {
            clsTask varObj = opGetTask(prmOUID,null);

            if (varObj == null)
                return false;

            return varObj.opModify(
                prmName,
                prmDescription,
                prmFirstDate,
                prmLimitDate,
                prmState
            );
        }
        public bool opUpdateReport(
            int prmProjectOUID,
            int prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmDate,
            string prmProgressSummary,
            int prmRetardedTasks)
        {
            clsProject varProject = opGetProject(prmProjectOUID,null);

            if (varProject == null)
                return false;

            return varProject.opUpdateReport(
                prmOUID,
                prmName,
                prmDescription,
                prmDate,
                prmProgressSummary,
                prmRetardedTasks
            );
        }
    public bool opDeleteProject(int prmOUID)
    {
    clsProject varObj = opGetProject(prmOUID, null);
    if (varObj == null) return false;

    // 🌟 PASO 1: Eliminar en Oracle llamando al Paquete
    bool vrmDbSuccess = clsProjectData.opEliminarProyecto(prmOUID);
    if (!vrmDbSuccess) return false;

    // 🌟 PASO 2: Remover de la memoria local
    if (!varObj.opDie()) return false;
    return opDisassociateProject(varObj);
    }
        public bool opDeleteStakeholder(int prmOUID)
        {
            clsStakeholder varObj = opGetStakeholder(prmOUID,null);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateStakeholder(varObj);
        }
        public bool opDeleteTask(int prmOUID)
        {
            clsTask varObj = opGetTask(prmOUID,null);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateTask(varObj);
        }
        public bool opDeleteReport(
            int prmProjectOUID,
            int prmOUID)
        {
            clsProject varObj = opGetProject(prmProjectOUID,null);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return varObj.opDeleteReport(prmOUID);
        }

        private bool opAssociateProject(clsProject prmObj)
        {
            return clsBrockerCrud.opAssociateItemTo(prmObj, attProjects);
        }

        private bool opAssociateStakeholder(clsStakeholder prmObj)
        {
            
            return clsBrockerCrud.opAssociateItemTo(prmObj, attStakeholders);
        }

        private bool opAssociateTask(clsTask prmObj)
        {
            return clsBrockerCrud.opAssociateItemTo(prmObj, attTasks);
        }

        private bool opDisassociateProject(clsProject prmObj)
        {
            return clsBrockerCrud.opDisassociateItemFrom(prmObj, attProjects);
        }

        private bool opDisassociateStakeholder(clsStakeholder prmObj)
        {
            return clsBrockerCrud.opDisassociateItemFrom(prmObj, attStakeholders);
        }

        private bool opDisassociateTask(clsTask prmObj)
        {
            return clsBrockerCrud.opDisassociateItemFrom(prmObj, attTasks);
        }
        public clsProject opGetProject(int prmOUID, string prmName)
        {
            if(prmOUID != 0)
                return clsBrockerCrud.opGetItem(prmOUID, attProjects);
            else
               return clsBrockerCrud.opGetItemByName(prmName, attProjects); 
        }

        public clsStakeholder opGetStakeholder(int prmOUID, string prmEmail)
        {
            if(prmOUID != 0)
                return clsBrockerCrud.opGetItem(prmOUID, attStakeholders);
            else
               return clsBrockerCrud.opGetItemByEmail(prmEmail, attStakeholders); 

        }
        

        public clsTask opGetTask(int prmOUID , string prmName)
        {
            if(prmOUID != 0)
                return clsBrockerCrud.opGetItem(prmOUID, attTasks);
            else
                return clsBrockerCrud.opGetItemByName(prmName, attTasks);
        }
        // =========================================================================
// MÉTODOS PARA EJECUTAR PROCESOS DE NEGOCIO ANALÍTICOS (PL/SQL VIA DBMS_OUTPUT)
// =========================================================================

public List<string> opGetReporteListarProyectos()
{
    return EjecutarBloqueConDbmsOutput("BEGIN PKG_PROYECTO.LISTAR_PROYECTOS; END;");
}

public List<string> opGetReporteConteoReportes()
{
    return EjecutarBloqueConDbmsOutput("BEGIN PKG_PROYECTO.CONTAR_REPORTES_POR_PROYECTO; END;");
}

public List<string> opGetReportePromedioAvance()
{
    return EjecutarBloqueConDbmsOutput("BEGIN PKG_PROYECTO.LISTAR_PROMEDIO_AVANCE_POR_ESTADO; END;");
}

// =========================================================================
// MÉTODO INTERNO PARA LEER EL BÚFER DE TEXTO DE ORACLE
// =========================================================================
private List<string> EjecutarBloqueConDbmsOutput(string bloqueAnonimo)
{
    var lineas = new List<string>();

    // Usamos el método nativo de tu proyecto para obtener la conexión abierta
    using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
    {
        try
        {
            vrmConn.Open();

            // 1. Habilitar el búfer de salida de texto en la sesión de Oracle
            using (OracleCommand cmdEnable = new OracleCommand("BEGIN DBMS_OUTPUT.ENABLE(NULL); END;", vrmConn))
            {
                cmdEnable.ExecuteNonQuery();
            }

            // 2. Ejecutar la lógica de negocio del paquete (los PUT_LINE)
            using (OracleCommand cmdExec = new OracleCommand(bloqueAnonimo, vrmConn))
            {
                cmdExec.ExecuteNonQuery();
            }

            // 3. Bloque anónimo auxiliar para extraer de golpe las líneas del búfer usando un delimitador
            string scriptGetLines = @"
                DECLARE
                    l_line VARCHAR2(255);
                    l_status INTEGER;
                BEGIN
                    LOOP
                        DBMS_OUTPUT.GET_LINE(l_line, l_status);
                        EXIT WHEN l_status <> 0;
                        :lineasOut := :lineasOut || l_line || '~';
                    END LOOP;
                END;";

            using (OracleCommand cmdGetLines = new OracleCommand(scriptGetLines, vrmConn))
            {
                OracleParameter paramOut = new OracleParameter("lineasOut", OracleDbType.Varchar2, 32767)
                {
                    Direction = ParameterDirection.Output,
                    Value = ""
                };
                cmdGetLines.Parameters.Add(paramOut);
                cmdGetLines.ExecuteNonQuery();

                string resultadoRaw = paramOut.Value?.ToString() ?? "";
                if (!string.IsNullOrEmpty(resultadoRaw) && resultadoRaw != "null")
                {
                    // Separamos las líneas usando nuestro separador '~'
                    lineas = new List<string>(resultadoRaw.Split('~', StringSplitOptions.RemoveEmptyEntries));
                }
            }
        }
        catch (Exception ex)
        {
            lineas.Add("❌ Error en la base de datos Oracle: " + ex.Message);
        }
    }

    if (lineas.Count == 0)
    {
        lineas.Add("ℹ️ El procedimiento se ejecutó correctamente pero no generó salidas de texto.");
    }

    return lineas;
}
        
    }
}
