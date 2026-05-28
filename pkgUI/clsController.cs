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

            bool vrmDbSuccess = clsProjectData.opInsertarProyecto(
        prmName, prmDescription, prmStartingDate, prmEndingDate, prmGeneralState, prmAdvancePercentage
    );

        if (!vrmDbSuccess) return false;


        clsProject newProject = new clsProject(
            prmOUID, prmName, prmDescription, prmStartingDate, prmEndingDate, prmGeneralState, prmAdvancePercentage
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
            clsProject varProject = opGetProject(prmProjectOUID,null);

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
    }
}
