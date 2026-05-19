using System;
using System.Collections.Generic;
using GestionDeProyectos.pkgDomain;
using GestionDeProyectos.pkgData;
using GestionDeProyectos.pkgUI;

#nullable disable

namespace GestionDeProyectos.pkgSystem
{
    public class clsBrockerCrud
    {

        public static bool opAssociateItemTo<ItemType>(ItemType prmObj, List<ItemType> prmCollection)
        {
            prmCollection.Add(prmObj);
            return true;
        }

        public static bool opDisassociateItemFrom<ItemType>(ItemType prmObj, List<ItemType> prmCollection)
        {
            return prmCollection.Remove(prmObj);
        }

        public static ItemType opGetItem<ItemType>(string prmOUID, List<ItemType> prmCollection) where ItemType : clsEntity
        {
            foreach (ItemType varObj in prmCollection)
            {
                if (varObj.opGetOUID().CompareTo(prmOUID) == 0)
                {
                    return varObj;
                }
            }

            return null;
        }
    }
}