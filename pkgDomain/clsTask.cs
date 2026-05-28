using System;
using System.Collections.Generic;
namespace GestionDeProyectos.pkgDomain
{
   public class clsTask : clsEntity
   {
      private DateTime attFirstDate;
      private DateTime attLimitDate;
      private clsState attState;

        public clsTask(
         int prmOUID,
         string prmName,
         string prmDescription,
         DateTime prmFirstDate,
         DateTime prmLimitDate,
         clsState prmState)
         : base(prmOUID, prmName, prmDescription)
      {
         attFirstDate = prmFirstDate;
         attLimitDate = prmLimitDate;
         attState = prmState;
        }
      public bool opModify(
            string prmName,
            string prmDescription,
            DateTime prmFirstDate,
            DateTime prmLimitDate,
            clsState prmState)
      {
         attName = prmName;
         attDescription = prmDescription;
         attFirstDate = prmFirstDate;
         attLimitDate = prmLimitDate;
         attState = prmState;

            return true;
      }

    }
}