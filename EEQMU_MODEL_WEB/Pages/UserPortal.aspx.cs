using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WEB_PLATFORM007.Pages
{
    public partial class UserPortal : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!IsPostBack)
                {
                    LoadData();
                }
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        public void LoadData()
        {
            try
            {
                GetDatabaseObjects(SelectLink());
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        private string SelectLink()
        {
            try
            {
                string id = Request.Params["linkid"];
                if (string.IsNullOrEmpty(id)) id = "1";
                (links.FindControl("lnk" + id) as LinkButton).Style["color"] = "black !important";

                return id;
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }

            return "1";
        }

        protected void GetDatabaseObjects(string value)
        {
            try
            {
                string status = "";

                switch (value)
                {
                    case "1": status = "1"; break;
                    case "2": status = "2"; break;
                    case "3": status = "3"; break;
                }

                ApplicationRoot.GetData("GET_PRS", "0", new string[] { "Purchase", status, Session["UID"].ToString() }, dbControls: lsvDocs);
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        protected void NavigationLink_Click(object sender, EventArgs e)
        {
            try
            {
                string url = Request.Url.LocalPath + "?linkid=" + (sender as LinkButton).CommandArgument;
                Response.Redirect(url);
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }
    }
}