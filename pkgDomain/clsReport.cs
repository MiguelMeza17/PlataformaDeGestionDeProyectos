using System;

namespace GestionDeProyectos.pkgDomain
{
    public class clsReport : clsEntity 
    {
        private DateTime attDate;
        private string attProgressSummary;
        private int attRetardedTasks;

        public clsReport(
            string prmOUID, 
            string prmName, 
            string prmDescription, 
            DateTime prmDate, 
            string prmProgressSummary, 
            int prmRetardedTasks
        ) : base(prmOUID, prmName, prmDescription)
        {
            attDate = prmDate;
            attProgressSummary = prmProgressSummary;
            attRetardedTasks = prmRetardedTasks;
        }
        public bool opModify(
         string prmName,
         string prmDescription,
         DateTime prmDate,
         string prmProgressSummary,
         int prmRetardedTasks)
        {
            attName = prmName;
            attDescription = prmDescription;
            attDate = prmDate;
            attProgressSummary = prmProgressSummary;
            attRetardedTasks = prmRetardedTasks;

            return true;
        }
    }
}