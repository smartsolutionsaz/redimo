using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WEB_PLATFORM007.Pages.Abstract {
    public partial class BuyerPage : UserPage {

        protected override string[] GetSessionUserRoleFlags() {
            return new string[] { "IS_BUYER", "IS_ADMIN" };
        }
    }
}