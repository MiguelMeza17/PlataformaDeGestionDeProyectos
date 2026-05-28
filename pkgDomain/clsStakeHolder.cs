using System;
using System.Collections.Generic;

namespace GestionDeProyectos.pkgDomain
{
    public class clsStakeholder : clsUser
    {
        private clsRoles attRol;
        private List<clsTask> attTasks;

        public clsStakeholder(
            int prmOUID, 
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
        public string GetNombre() { return attName; }
        public clsRoles GetRol() { return attRol; }
        public bool opCompareCredentials(string prmEmail, string prmPassword)
        {
            return attEmail.Trim() == prmEmail.Trim() && attPassword == prmPassword;
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
        public override bool opDie()
        {           
            attTasks.Clear();         
            return true;
        }
    }
}