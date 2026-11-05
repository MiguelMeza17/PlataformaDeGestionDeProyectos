using System;
using System.Collections.Generic;
using GestionDeProyectos.pkgDomain;
using GestionDeProyectos.pkgSystem;
using GestionDeProyectos.pkgData;
using System.Linq;

#nullable disable

namespace GestionDeProyectos.pkgUI
{
    public class clsController
    {
        private static clsController attInstance = null!;
        private List<clsStakeholder> attStakeholders = new List<clsStakeholder>();
        private List<clsProject> attProjects = new List<clsProject>();
        private List<clsTask> attTasksProject = new List<clsTask>();

        public List<clsProject> opListAllProjects()
        {
            return attProjects;
        }

        public List<clsTask> opListTasksByDeveloper(int prmOUDID)
        {
            clsStakeholder varObj = opGetStakeholder(prmOUDID, null);
            if (varObj == null) return null;
            
            return varObj.opListTasksByDeveloper();
        }

        public List<clsStakeholder> opListDevelopers()
        {
            List<clsStakeholder> vrmDevelopers = new List<clsStakeholder>();
            foreach (clsStakeholder varObj in attStakeholders)
            {
                if (varObj.opGetRol() == clsRoles.Developer)
                {
                    vrmDevelopers.Add(varObj);
                }
            }
            return vrmDevelopers;
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

            attTasksProject.Clear();

            clsTaskData.opLoadTasks((id, name, desc, start, limit, stateNum, idProj, idAsigna, idDesarrolla) =>
            {
                clsState estadoEnum = (clsState)stateNum;
                clsTask varTask = new clsTask(id, name, desc, start, limit, estadoEnum);
                
                attTasksProject.Add(varTask);
                
                clsStakeholder dev = attStakeholders.FirstOrDefault(s => s.opGetOUID() == idDesarrolla);
                if (dev != null)
                {
                    dev.opAddTask(varTask);
                }
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
            clsProject varObj = opGetProject(0, prmName);

            if (varObj != null) 
                return false;

            int vrmNewId = clsProjectData.opInsertarProyecto(
                                        prmName, prmDescription,
                                        prmStartingDate, prmEndingDate,
                                        prmGeneralState, prmAdvancePercentage
                                    );

            if (vrmNewId == 0) return false;

            clsProject newProject = new clsProject(
                vrmNewId, prmName, prmDescription,
                prmStartingDate, prmEndingDate,
                prmGeneralState, prmAdvancePercentage
            );

            return opAssociateProject(newProject);
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

            int vrmOUID = clsStakeholderData.opRegisterStakeholder(prmName, prmDescription, prmEmail, prmPassword, prmRol);
            if (vrmOUID == -1) return false;

            clsStakeholder newStakeholder = new clsStakeholder(
                vrmOUID,
                prmName,
                prmDescription,
                prmEmail,
                prmPassword,
                prmRol
            );

            return opAssociateStakeholder(newStakeholder);
        }

        public bool opRegisterTask(
            int prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmFirstDate,
            DateTime prmLimitDate,
            clsState prmState,
            int prmIdProject,
            int prmIdUserAssigns,
            int prmIdUserDevelops)
        {
            clsTask varObj = opGetTask(0, prmName);
            if (varObj != null) return false;

            int vrmFinalID = prmOUID;

            if (vrmFinalID == 0)
            {
                vrmFinalID = clsTaskData.opRegisterTask(
                    prmName, 
                    prmDescription, 
                    prmFirstDate, 
                    prmLimitDate, 
                    prmState, 
                    prmIdProject, 
                    prmIdUserAssigns, 
                    prmIdUserDevelops
                );
            }
            
            if (vrmFinalID == -1) return false;

            clsTask newTask = new clsTask(
                vrmFinalID,
                prmName,
                prmDescription,
                prmFirstDate,
                prmLimitDate,
                prmState
            );

            clsStakeholder dev = attStakeholders.FirstOrDefault(s => s.opGetOUID() == prmIdUserDevelops);
            if (dev != null)
            {
                dev.opAddTask(newTask);
            }

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
            clsProject varProject = opGetProject(prmProjectOUID, null);

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

            bool vrmDbSuccess = clsProjectData.opActualizarProyecto(
                prmOUID, prmName, prmDescription, prmStartingDate, prmEndingDate, prmGeneralState, prmAdvancePercentage
            );

            if (!vrmDbSuccess) return false;

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
            clsStakeholder varObj = opGetStakeholder(prmOUID, null);

            if (varObj == null)
                return false;

            bool vrmDbSuccess = clsStakeholderData.opActualizarStakeholder(
                prmOUID, prmName, prmDescription, prmEmail, prmPassword, prmRol
            );

            if (!vrmDbSuccess) return false;

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
            clsTask varObj = opGetTask(prmOUID, null);

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
            clsProject varProject = opGetProject(prmProjectOUID, null);

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
        public static bool opActualizarEstadoTarea(int prmOUID, int prmNewState)
        {
            bool vrmDbSuccess = clsTaskData.opActualizarEstadoTarea(prmOUID, prmNewState);
            if (!vrmDbSuccess)
                Console.WriteLine($"[ADVERTENCIA]: La tarea con ID {prmOUID} NO EXISTE en la tabla TAREA.");
            return vrmDbSuccess;
        }

        public bool opDeleteProject(int prmOUID)
        {
            clsProject varObj = opGetProject(prmOUID, null);
            if (varObj == null) return false;

            bool vrmDbSuccess = clsProjectData.opEliminarProyecto(prmOUID);
            if (!vrmDbSuccess) return false;

            if (!varObj.opDie()) return false;
            return opDisassociateProject(varObj);
        }

        public bool opDeleteStakeholder(int prmOUID)
        {
            clsStakeholder varObj = opGetStakeholder(prmOUID, null);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateStakeholder(varObj);
        }

        public bool opDeleteTask(int prmOUID)
        {
            clsTask varObj = opGetTask(prmOUID, null);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateTask(varObj);
        }

        public bool opDeleteReport(int prmProjectOUID, int prmOUID)
        {
            clsProject varObj = opGetProject(prmProjectOUID, null);
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
            return clsBrockerCrud.opAssociateItemTo(prmObj, attTasksProject);
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
            return clsBrockerCrud.opDisassociateItemFrom(prmObj, attTasksProject);
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
        

        public clsTask opGetTask(int prmOUID, string prmName)
        {
            if(prmOUID != 0)
                return clsBrockerCrud.opGetItem(prmOUID, attTasksProject);
            else
                return clsBrockerCrud.opGetItemByName(prmName, attTasksProject);
        }
        // =========================================================================
        // REPORTES ANALÍTICOS (antes PL/SQL vía DBMS_OUTPUT, ahora consultas SQLite)
        // =========================================================================

        public List<string> opGetReporteListarProyectos()
        {
            return clsProjectData.opReporteListarProyectos();
        }

        public List<string> opGetReporteConteoReportes()
        {
            return opSinSalidaVacia(clsProjectData.opReporteConteoReportes());
        }

        public List<string> opGetReportePromedioAvance()
        {
            return clsProjectData.opReportePromedioAvance();
        }

        public string opGetAlertasProlog()
        {
            return clsPrologEngine.opConsultarAlertas();
        }

        private List<string> opSinSalidaVacia(List<string> prmLineas)
        {
            if (prmLineas.Count == 0)
            {
                prmLineas.Add("ℹ️ El procedimiento se ejecutó correctamente pero no generó salidas de texto.");
            }
            return prmLineas;
        }
        
    }
}