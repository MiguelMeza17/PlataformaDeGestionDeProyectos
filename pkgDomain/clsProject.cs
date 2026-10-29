using System;
using System.Collections.Generic;
using GestionDeProyectos.pkgSystem;
#nullable disable

namespace GestionDeProyectos.pkgDomain
{
   public class clsProject : clsEntity
   {
      private DateTime attStartingDate;
      private DateTime attEndingDate;
      private string attGeneralState;
      private float attAdvancePercentage;
      private List<clsTask> attTasks;

      private List<clsReport> attReports = new List<clsReport>();
      // Añade esto dentro de tu clase clsProject en pkgDomain/clsProject.cs
      public int OUID => opGetOUID(); 
      public string Name => opGetName(); 
      public string Description => opGetDescription();
      
      public DateTime StartingDate => attStartingDate;
      public DateTime EndingDate => attEndingDate;
      public string GeneralState => attGeneralState;
      public float AdvancePercentage => attAdvancePercentage;      public clsProject(
         int prmOUID,
         string prmName,
         string prmDescription,
         DateTime prmStartingDate,
         DateTime prmEndingDate,
         string prmGeneralState,
         float prmAdvancePercentage)
         : base(prmOUID, prmName, prmDescription)
      {
         attStartingDate = prmStartingDate;
         attEndingDate = prmEndingDate;
         attGeneralState = prmGeneralState;
         attAdvancePercentage = prmAdvancePercentage;

         attReports = new List<clsReport>();
         attTasks = new List<clsTask>();
      }

      public bool opRegisterReport(
         int prmOUID,
         string prmName,
         string prmDescription,
         DateTime prmDate,
         string prmProgressSummary,
         int prmRetardedTasks)
      {
         clsReport varObj = opGetReport(0,prmName);

         if (varObj != null) return false;

         clsReport newReport = new clsReport(
            prmOUID,
            prmName,
            prmDescription,
            prmDate,
            prmProgressSummary,
            prmRetardedTasks
         );

         return opAssociateReport(newReport);
      }
      public bool opUpdateReport(
         int prmOUID,
         string prmName,
         string prmDescription,
         DateTime prmDate,
         string prmProgressSummary,
         int prmRetardedTasks)
      {
         clsReport varObj = opGetReport(prmOUID,null);

         if (varObj == null) return false;

         return varObj.opModify(
               prmName,
               prmDescription,
               prmDate,
               prmProgressSummary,
               prmRetardedTasks);
      }
      public bool opDeleteReport(
            int prmOUID)
        {
            clsReport varObj = opGetReport(prmOUID,null);
            if(varObj == null) return false;
            if(!varObj.opDie()) return false;
            return opDisassociateReport(varObj);
        }
      private bool opAssociateReport(clsReport prmObj)
      {
         return clsBrockerCrud.opAssociateItemTo(prmObj, attReports);
      }

      private bool opDisassociateReport(clsReport prmObj)
      {
         return clsBrockerCrud.opDisassociateItemFrom(prmObj, attReports);
      }
      public clsReport opGetReport(int prmOUID, string prmName)
      {
         if(prmOUID != 0)
            return clsBrockerCrud.opGetItem(prmOUID, attReports);
         else
            return clsBrockerCrud.opGetItemByName(prmName, attReports);
      }

      public bool opModify(
            string prmName,
            string prmDescription,
            DateTime prmStartingDate,
            DateTime prmEndingDate,
            string prmGeneralState,
            float prmAdvancePercentage)
      {
         attName = prmName;
         attDescription = prmDescription;
         attStartingDate = prmStartingDate;
         attEndingDate = prmEndingDate;
         attGeneralState = prmGeneralState;
         attAdvancePercentage = prmAdvancePercentage;

         return true;
      }
      public override bool opDie()
      {
         foreach (clsReport varItem in attReports)
         {
            if (!varItem.opDie()) return false;
            opDisassociateReport(varItem);
         }

         return true;
      }
   }
}