using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WEB_PLATFORM007.Classes;

namespace WEB_PLATFORM007.Pages {
    public partial class TestPage : System.Web.UI.Page {
        protected void Page_Load(object sender, EventArgs e) {
            Person t = new Person("Maxim", "Vasilyev");
            Person t2 = t;
            t.name = "asdasd";
            lblTest.Text = t.toString();
            lblTest.Text += t2.toString();
        }
    }
}