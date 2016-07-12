using PLATFORM700TOREVO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;

namespace WEB_PLATFORM007.Pages
{
    public partial class RequisitionForm : System.Web.UI.Page
    {
        protected int DOCID
        {
            get { return (int)(ViewState["DOCID"] ?? 0); }
            set { ViewState["DOCID"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                requestItem.OnItemsChanged += RequestItem_OnItemsChanged;

                if (!IsPostBack)
                {
                    string sdocid = Request.QueryString["docid"];
                    if (!string.IsNullOrEmpty(sdocid))
                    {
                        int docid;
                        if (int.TryParse(sdocid, out docid))
                        {
                            DOCID = docid;
                            LoadData();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        private void RequestItem_OnItemsChanged(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = ApplicationRoot.GetData("GET_PR_ITEMS", DOCID.ToString(), dbControls: lsvItems);

                double sum = 0;
                foreach (DataRow row in dt.Rows)
                {
                    sum += double.Parse(row["UnitPriceIncludeVAT"]?.ToString() ?? "0");
                }
                (lsvItems.FindControl("lblTotalPrice") as Label).Text = sum.ToString();
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        protected void LoadData()
        {
            try
            {
                var tempArr = new string[] { };
                DataTable dt = ApplicationRoot.GetData("GET_PR", DOCID.ToString());

                if (dt.Rows.Count < 1) return;

                ApplicationRoot.GetData("GET_PR_ITEMS", DOCID.ToString(), dbControls: lsvItems);
                ApplicationRoot.GetData("DEPARTMENT", "0", "", "0", "", tempArr, 2, drpRequestorDep, drpRequestedForDep);
                ApplicationRoot.GetData("COSTCENTER", "0", structType: 2, dbControls: drpCostCenter);
                ApplicationRoot.GetData("PROJECT", "0", structType: 2, dbControls: drpProject);

                clnRequestDate.SelectedDate = DateTime.Parse(dt.Rows[0]["DOC_DATE"]?.ToString());
                clnPreferableDate.SelectedDate = DateTime.Parse(dt.Rows[0]["DOC_DUE_DATE"]?.ToString());

                drpRequestorDep.SelectedValue = dt.Rows[0]["RequestorDepartamentId"]?.ToString();
                txtRequestorName.Text = dt.Rows[0]["RequestorName"]?.ToString();

                drpRequestedForDep.SelectedValue = dt.Rows[0]["RequestedForDepartamentId"]?.ToString();
                txtRequestedForName.Text = dt.Rows[0]["RequestedForName"]?.ToString();

                drpCostCenter.SelectedValue = dt.Rows[0]["CostCenterId"]?.ToString();
                drpProject.SelectedValue = dt.Rows[0]["ProjectId"]?.ToString();

                txtDeliveryAddress.Text = dt.Rows[0]["DeliveryAddress"]?.ToString();

                Label totalPriceCtrl = lsvItems.FindControl("lblTotalPrice") as Label;
                if (totalPriceCtrl != null) {
                    totalPriceCtrl.Text = dt.Rows[0]["TotalPrice"]?.ToString();
                }
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        private int Save(string method)
        {
            int result = 0;
            try
            {
                PR pr = new PR();

                pr.propMethod = "SAVE_REQUEST";
                pr.propDocumentID = DOCID;
                pr.propUID = (int)Session["UID"];

                pr.propDocumentDate = clnRequestDate.SelectedDate ?? DateTime.Now;
                pr.propDueDate = clnPreferableDate.SelectedDate ?? DateTime.Now;
                pr.propRequestorDepartamentId = int.Parse(drpRequestorDep.SelectedValue);
                pr.propRequestedForDepartamentId = int.Parse(drpRequestedForDep.SelectedValue);
                pr.propRequestedForName = txtRequestedForName.Text;
                pr.propCostCenterId = int.Parse(drpCostCenter.SelectedValue);
                pr.propProjectId = int.Parse(drpProject.SelectedValue);
                pr.propDeliveryAddress = txtDeliveryAddress.Text;

                result = DATA_MANIPULATION_LAYER.post_Document(XmlUtility.PrepareXMLDocument(pr));
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }

            return result;
        }

        protected void lnkAddItem_Click(object sender, EventArgs e)
        {
            try
            {
                requestItem.LoadData(DOCID);
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        protected void lnkEdit_Click(object sender, EventArgs e)
        {
            try
            {
                string command = (sender as LinkButton)?.CommandArgument;

                if (!string.IsNullOrEmpty(command))
                {
                    int line_id;
                    if (int.TryParse(command, out line_id))
                    {
                        requestItem.LoadData(DOCID, line_id);
                    }
                }
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        protected void lnkItemDelete_Click(object sender, EventArgs e)
        {
            try
            {
                string command = (sender as LinkButton)?.CommandArgument;

                if (!string.IsNullOrEmpty(command))
                {
                    int line_id;
                    if (int.TryParse(command, out line_id))
                    {
                        requestItem.Delete(DOCID, line_id);
                    }
                }
            }
            catch (Exception ex)
            {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }
    }
}