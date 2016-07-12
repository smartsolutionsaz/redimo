using PLATFORM700TOREVO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WEB_PLATFORM007.Pages
{
    public partial class Request : System.Web.UI.Page
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

        private void LoadData()
        {
            try
            {

            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        protected void btnRequest_Click(object sender, EventArgs e)
        {
            try
            {
                string command = (sender as Button)?.CommandArgument;

                if (command == "Purchase" || command == "Service")
                {
                    int docid = CreateRequest(command);
                    Response.Redirect("~/Pages/RequisitionForm.aspx?docid=" + docid, true);
                }
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        protected int CreateRequest(string requestType)
        {
            try
            {
                PR pr = new PR();
                pr.propMethod = "CREATE_REQUEST";

                pr.propUID = pr.propRequestorUID = (int)Session["UID"];
                pr.propDocumentType = requestType;

                return DATA_MANIPULATION_LAYER.post_Document(XmlUtility.PrepareXMLDocument(pr));
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }

            return 0;
        }
    }
}