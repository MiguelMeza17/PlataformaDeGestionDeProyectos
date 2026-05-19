using System;

namespace GestionDeProyectos.pkgDomain
{
    public class clsEntity
    {
        protected string attOUID;
        protected string attName;
        protected string attDescription;

        public clsEntity(string prmOUID, string prmName, string prmDescription)
        {
            attOUID = prmOUID;
            attName = prmName;
            attDescription = prmDescription;
        }

        public string opGetOUID()
        {
            return attOUID;
        }
        public virtual bool opDie()
        {
            return true;
        }
    }
}