using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WEB_PLATFORM007.Pages;

namespace WEB_PLATFORM007.UserControls {
    public partial class Test : System.Web.UI.UserControl, ITest {
        protected void Page_Load(object sender, EventArgs e) {

        }

        public void test() {

        }
    }

    public interface ITest {
        void test();

    }
}