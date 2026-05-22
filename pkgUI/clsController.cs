using System;
using System.Collections.Generic;
using GestionDeProyectos.pkgDomain;
using GestionDeProyectos.pkgSystem;
using GestionDeProyectos.pkgData;
using Oracle.ManagedDataAccess.Client;

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
            int prmOUID,
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
            int prmOUID,
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
            int prmProjectOUID,
            int prmOUID,
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
            int prmOUID,
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
            int prmOUID,
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
            int prmOUID,
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
            int prmProjectOUID,
            int prmOUID,
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
        public bool opDeleteProject(int prmOUID)
        {
            clsProject varObj = opGetProject(prmOUID);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateProject(varObj);
        }
        public bool opDeleteStakeholder(int prmOUID)
        {
            clsStakeholder varObj = opGetStakeholder(prmOUID);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateStakeholder(varObj);
        }
        public bool opDeleteTask(int prmOUID)
        {
            clsTask varObj = opGetTask(prmOUID);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateTask(varObj);
        }
        public bool opDeleteReport(
            int prmProjectOUID,
            int prmOUID)
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
    private bool opAssociateStakeholder2(clsStakeholder prmStakeholder)
    {
        // Usamos tu clase para obtener la conexión
        using (OracleConnection vrmConn = clsOracleConnection.opGetConnection())
        {
            try
            {
                vrmConn.Open();

                string sql = @"INSERT INTO USUARIO (IDUSUARIO, NOMBRE, DESCRIPCION, EMAIL, CONTRASENA, ROL) 
                            VALUES (:id, :name, :desc, :email, :pass, :rol)";

                using (OracleCommand vrmCmd = new OracleCommand(sql, vrmConn))
                {
                    // Agregamos los parámetros con ':'
                    vrmCmd.Parameters.Add("id", OracleDbType.Int32).Value = prmStakeholder.opGetOUID();
                    vrmCmd.Parameters.Add("name", OracleDbType.Varchar2).Value = prmStakeholder.opGetName();
                    vrmCmd.Parameters.Add("desc", OracleDbType.Varchar2).Value = prmStakeholder.opGetDescription();
                    vrmCmd.Parameters.Add("email", OracleDbType.Varchar2).Value = prmStakeholder.opGetEmail();
                    vrmCmd.Parameters.Add("pass", OracleDbType.Varchar2).Value = prmStakeholder.opGetPassword();
                    vrmCmd.Parameters.Add("rol", OracleDbType.Varchar2).Value = prmStakeholder.opGetRol().ToString();

                    return vrmCmd.ExecuteNonQuery() > 0;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error en opAssociateStakeholder: " + ex.Message);
                return false;
            }
        }
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
        public clsProject opGetProject(int prmOUID)
        {
            return clsBrockerCrud.opGetItem(prmOUID, attProjects);
        }

        public clsStakeholder opGetStakeholder(int prmOUID)
        {
            return clsBrockerCrud.opGetItem(prmOUID, attStakeholders);
        }

        public clsTask opGetTask(int prmOUID)
        {
            return clsBrockerCrud.opGetItem(prmOUID, attTasks);
        }
    }
}