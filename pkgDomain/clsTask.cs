using System;

namespace GestionDeProyectos.pkgDomain
{
   public class clsTask : clsEntity
   {
      private DateTime attFirstDate;
      private DateTime attLimitDate;

      public clsTask(
         string prmOUID,
         string prmName,
         string prmDescription,
         DateTime prmFirstDate,
         DateTime prmLimitDate)
         : base(prmOUID, prmName, prmDescription)
      {
         attFirstDate = prmFirstDate;
         attLimitDate = prmLimitDate;
      }
      public bool opModify(
            string prmName,
            string prmDescription,
            DateTime prmFirstDate,
            DateTime prmLimitDate)
      {
         attName = prmName;
         attDescription = prmDescription;
         attFirstDate = prmFirstDate;
         attLimitDate = prmLimitDate;

         return true;
      }
      
   }
}