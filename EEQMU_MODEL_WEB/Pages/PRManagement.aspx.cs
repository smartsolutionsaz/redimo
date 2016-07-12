using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WEB_PLATFORM007.Pages.Abstract;

namespace WEB_PLATFORM007.Pages {
    public partial class PRManagement : BuyerPage{
        private string selectedPR {
            set { this.lblID.Text = value; }
        }

        protected override void Page_Load(object sender, EventArgs e) {
            base.Page_Load(sender, e);

            //PRList.OnSelect += this.SelectHandler;
        }

        public void SelectHandler(string selectedPR) {
            this.selectedPR = selectedPR;
        }
    }
}