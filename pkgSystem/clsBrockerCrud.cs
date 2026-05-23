using System;
using System.Collections.Generic;
using GestionDeProyectos.pkgDomain;

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
            prmCollection.Remove(prmObj);
            return true;
        }

        public static ItemType opGetItemByName<ItemType>(string prmName, List<ItemType> prmCollection) where ItemType : clsEntity
        {
            foreach (ItemType varObj in prmCollection)
            {
                if (varObj.opGetName().CompareTo(prmName) == 0)
                {
                    return varObj;
                }
            }

            return null;
        }
        public static ItemType opGetItemByEmail<ItemType>(string prmEmail, List<ItemType> prmCollection) where ItemType : clsUser
        {
            foreach (ItemType varObj in prmCollection)
            {
                if (varObj.opGetEmail().CompareTo(prmEmail) == 0)
                {
                    return varObj;
                }
            }

            return null;
        }

        public static ItemType opGetItem<OUIDType,ItemType>(OUIDType prmOUID, List<ItemType> prmCollection) where ItemType : clsEntity
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