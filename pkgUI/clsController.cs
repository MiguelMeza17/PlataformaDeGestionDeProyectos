using System;
using System.Collections.Generic;
using GestionDeProyectos.pkgDomain;
using GestionDeProyectos.pkgSystem;
using GestionDeProyectos.pkgData;

#nullable disable

namespace GestionDeProyectos.pkgUI
{
    public class clsController
    {
        private static clsController attInstance = null!;
        private List<clsStakeholder> attStakeholders = new List<clsStakeholder>();
        private List<clsProject> attProjects = new List<clsProject>();
        private List<clsTask> attTasks = new List<clsTask>();

    private clsController()
    {
        attStakeholders.Clear();

        attStakeholders.Clear();

        clsStakeholderData.opLoadStakeholders((id, name, desc, email, pass, rolStr) =>
        {
            clsRoles rolEnum = clsRoles.Developer;

            if (rolStr == "R1")
            {
                rolEnum = clsRoles.Admin;
            }
            else if (rolStr == "R2")
            {
                rolEnum = clsRoles.Manager;
            }
            else if (rolStr == "R3")
            {
                rolEnum = clsRoles.Developer;
            }

            clsStakeholder varObj = new clsStakeholder(id, name, desc, email, pass, rolEnum);
            attStakeholders.Add(varObj);
        });
    }

        public static clsController opGetInstance()
        {
            if (attInstance == null)
                attInstance = new clsController();
            return attInstance;
        }

        public clsStakeholder opLoginStakeholder(string prmName, string prmPassword)
        {
            foreach (clsStakeholder varObj in attStakeholders)
            {
                if (varObj.opCompareCredentials(prmName, prmPassword))
                {
                    return varObj;
                }
            }
            return null;
        }

        public bool opRegisterProject(
            string prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmStartingDate,
            DateTime prmEndingDate,
            string prmGeneralState,
            float prmAdvancePercentage)
        {
            clsProject varObj = opGetProject(prmOUID);

            if (varObj != null) 
                return false;

            clsProject newProject = new clsProject(
                prmOUID,
                prmName,
                prmDescription,
                prmStartingDate,
                prmEndingDate,
                prmGeneralState,
                prmAdvancePercentage
            );
                return opAssociateProject(newProject);
        }

        public bool opRegisterStakeholder(
            string prmOUID,
            string prmName,
            string prmDescription,
            string prmEmail,
            string prmPassword,
            clsRoles prmRol)
        {
            clsStakeholder varObj = opGetStakeholder(prmOUID);

            if (varObj != null) 
                return false;

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

        public bool opRegisterTask(
            string prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmFirstDate,
            DateTime prmLimitDate)
        {
            clsTask varObj = opGetTask(prmOUID);

            if (varObj != null)
                return false;

            clsTask newTask = new clsTask(
                prmOUID,
                prmName,
                prmDescription,
                prmFirstDate,
                prmLimitDate);

            return opAssociateTask(newTask);
        }
        public bool opRegisterReport(
            string prmProjectOUID,
            string prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmDate,
            string prmProgressSummary,
            int prmRetardedTasks)
        {
            clsProject varProject = opGetProject(prmProjectOUID);

            if (varProject == null)
                return false;

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
            string prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmStartingDate,
            DateTime prmEndingDate,
            string prmGeneralState,
            float prmAdvancePercentage)
        {
            clsProject varObj = opGetProject(prmOUID);

            if (varObj == null)
                return false;

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
            string prmOUID,
            string prmName,
            string prmDescription,
            string prmEmail,
            string prmPassword,
            clsRoles prmRol)
        {
            clsStakeholder varObj = opGetStakeholder(prmOUID);

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
            string prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmFirstDate,
            DateTime prmLimitDate)
        {
            clsTask varObj = opGetTask(prmOUID);

            if (varObj == null)
                return false;

            return varObj.opModify(
                prmName,
                prmDescription,
                prmFirstDate,
                prmLimitDate
            );
        }
        public bool opUpdateReport(
            string prmProjectOUID,
            string prmOUID,
            string prmName,
            string prmDescription,
            DateTime prmDate,
            string prmProgressSummary,
            int prmRetardedTasks)
        {
            clsProject varProject = opGetProject(prmProjectOUID);

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
        public bool opDeleteProject(string prmOUID)
        {
            clsProject varObj = opGetProject(prmOUID);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateProject(varObj);
        }
        public bool opDeleteStakeholder(string prmOUID)
        {
            clsStakeholder varObj = opGetStakeholder(prmOUID);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateStakeholder(varObj);
        }
        public bool opDeleteTask(string prmOUID)
        {
            clsTask varObj = opGetTask(prmOUID);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateTask(varObj);
        }
        public bool opDeleteReport(
            string prmProjectOUID,
            string prmOUID)
        {
            clsProject varObj = opGetProject(prmProjectOUID);
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
        public clsProject opGetProject(string prmOUID)
        {
            return clsBrockerCrud.opGetItem(prmOUID, attProjects);
        }

        public clsStakeholder opGetStakeholder(string prmOUID)
        {
            return clsBrockerCrud.opGetItem(prmOUID, attStakeholders);
        }

        public clsTask opGetTask(string prmOUID)
        {
            return clsBrockerCrud.opGetItem(prmOUID, attTasks);
        }
    }
}