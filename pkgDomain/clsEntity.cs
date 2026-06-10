using System;

namespace GestionDeProyectos.pkgDomain
{
    public class clsEntity
    {
        protected int attOUID;
        protected string attName;
        protected string attDescription;
        public int OUID => opGetOUID();
        public string Name => opGetName();
        public string Description => opGetDescription();
        public clsEntity(int prmOUID, string prmName, string prmDescription)
        {
            attOUID = prmOUID;
            attName = prmName;
            attDescription = prmDescription;
        }

        public string opGetName()
        {
            return attName;
        }
        public int opGetOUID()
        {
            return attOUID;
        }
        public string opGetDescription()
        {
            return attDescription;
        }
        public virtual bool opDie()
        {
            return true;
        }
    }
}