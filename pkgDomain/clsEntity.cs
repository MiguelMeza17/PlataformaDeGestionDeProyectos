using System;

namespace GestionDeProyectos.pkgDomain
{
    public class clsEntity
    {
        protected int attOUID;
        protected string attName;
        protected string attDescription;

        public clsEntity(int prmOUID, string prmName, string prmDescription)
        {
            attOUID = prmOUID;
            attName = prmName;
            attDescription = prmDescription;
        }

        public int opGetOUID()
        {
            return attOUID;
        }
        public virtual bool opDie()
        {
            return true;
        }
    }
}