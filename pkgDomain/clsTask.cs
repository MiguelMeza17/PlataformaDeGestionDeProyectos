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

      public DateTime opGetFirstDate()
      {
         return attFirstDate;
      }
      public DateTime opGetLimitDate()
      {
         return attLimitDate;
      }
      public clsState opGetState()
      {
         return attState;
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
      public bool opModifyState(clsState prmState)
      {
         attState = prmState;

         return true;
      }

    }
}