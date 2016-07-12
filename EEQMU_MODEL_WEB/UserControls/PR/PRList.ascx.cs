using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WEB_PLATFORM007.Classes;

namespace WEB_PLATFORM007.UserControls {
    public partial class PRList : System.Web.UI.UserControl {
        protected void Page_Load(object sender, EventArgs e) {
            lstPR.DataSource = PRRepository.getPRsForBuyer(Session["UID"].ToString());
            lstPR.DataBind();
        }

        public event Action<string> OnSelect;

        protected void _OnSelect(object sender, EventArgs e) {
            if (this.OnSelect != null) {
                this.OnSelect((sender as LinkButton).CommandArgument);
            }
        }
    }
}