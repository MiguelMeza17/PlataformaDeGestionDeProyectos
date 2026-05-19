namespace GestionDeProyectos.pkgDomain
{
    public class clsUser : clsEntity
    {
        protected string attEmail;
        protected string attPassword;

        public clsUser(string prmOUID, string prmName, string prmDescription, string prmEmail, string prmPassword) 
            : base(prmOUID, prmName, prmDescription)
        {
            attEmail = prmEmail;
            attPassword = prmPassword;
        }
    }
}