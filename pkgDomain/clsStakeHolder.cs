using System;
using System.Collections.Generic;

namespace GestionDeProyectos.pkgDomain
{
    public class clsStakeholder : clsUser
    {
        private clsRoles attRol;
        private List<clsTask> attTasks;

        public clsStakeholder(
            string prmOUID, 
            string prmName, 
            string prmDescription, 
            string prmEmail, 
            string prmPassword, 
            clsRoles prmRol)
            : base(prmOUID, prmName, prmDescription, prmEmail, prmPassword)
        {
            attRol = prmRol;
            attTasks = new List<clsTask>();
        } 
        public bool opCompareCredentials(string prmName, string prmPassword)
        {
            return attName.Trim() == prmName.Trim() && attPassword == prmPassword;
        }
        public bool opModify(
            string prmName,
            string prmDescription,
            string prmEmail,
            string prmPassword,
            clsRoles prmRol)
        {
            attName = prmName;
            attDescription = prmDescription;
            attEmail = prmEmail;
            attPassword = prmPassword;
            attRol = prmRol;

            return true;
        }
    }
}