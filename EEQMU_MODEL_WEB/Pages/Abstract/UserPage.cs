using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WEB_PLATFORM007.Pages.Abstract {
    public abstract partial class UserPage : System.Web.UI.Page {
        protected string UID { get; set; }
        protected bool AccessGranted { get; set; }

        private static string DefaultErrorPageURI = "~/Pages/404.aspx";

        protected abstract string[] GetSessionUserRoleFlags();
        protected virtual string GetErrorPageURI(string UID) {
            return UserPage.DefaultErrorPageURI;
        } 

        protected virtual void Page_Load(object sender, EventArgs e) {
            this.UID = Session["UID"]?.ToString() ?? "0";

            bool accessGranted = true;
            foreach (string flag in this.GetSessionUserRoleFlags()) {
                object roleFlag = Session[flag];
                accessGranted = accessGranted && roleFlag != null && (bool)roleFlag;
            }
            this.AccessGranted = accessGranted;

            if (!this.AccessGranted) {
                Response.Redirect(this.GetErrorPageURI(this.UID));
            }
        }
    }
}