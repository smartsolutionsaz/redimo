using PLATFORM700TOREVO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WEB_PLATFORM007.UserControls {
    public partial class RequestItem : System.Web.UI.UserControl {
        public event EventHandler OnItemsChanged;

        protected int DOCID {
            get { return (int)(ViewState["DOCID"] ?? 0); }
            set { ViewState["DOCID"] = value; }
        }

        protected int LINE_ID {
            get { return (int)(ViewState["LINE_ID"] ?? 0); }
            set { ViewState["LINE_ID"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e) {
            try {

            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        public void LoadData(int docid) {
            try {
                DOCID = docid;

                Clear();
                lnkSave.CommandArgument = "ADD_PR_ITEM";

                var tempArr = new string[] { };

                ApplicationRoot.GetData("SUPPLIERS", "0", structType: 2, dbControls: lsbSuggestedSuppliers);
                ApplicationRoot.GetData("VENDOR", "0", structType: 2, dbControls: lsbVendor);
                ApplicationRoot.GetData("CURRENCY", "0", structType: 2, dbControls: drpCurrency);

                popextAddItem.Show();
            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        public void LoadData(int docid, int line_id) {
            try {
                LINE_ID = line_id;
                LoadData(docid);
                lnkSave.CommandArgument = "UPDATE_PR_ITEM";

                DataTable dt = ApplicationRoot.GetData("GET_PR_ITEM", docid.ToString(), fields: new string[] { line_id.ToString() });
                if (dt.Rows.Count < 1) return;

                txtMaterialCode.Text = dt.Rows[0]["ITEM_CODE"]?.ToString();
                txtPartNumber.Text = dt.Rows[0]["PartNumber"]?.ToString();
                txtItemName.Text = dt.Rows[0]["ITEM_NAME"]?.ToString();
                txtDescription.Text = dt.Rows[0]["ITEM_DESCRIPTION"]?.ToString();
                txtQunatity.Text = dt.Rows[0]["Quantity"]?.ToString();
                txtUnit.Text = dt.Rows[0]["Unit"]?.ToString();
                txtUnitPrice.Text = dt.Rows[0]["UnitPriceIncludeVAT"]?.ToString();
                drpCurrency.SelectedValue = dt.Rows[0]["CurrencyCode"]?.ToString();

                ApplicationRoot.SetListBoxSelectedItems(lsbSuggestedSuppliers, dt.Rows[0]["SuggestedSuppliers"]?.ToString(), ", ");
                ApplicationRoot.SetListBoxSelectedItems(lsbVendor, dt.Rows[0]["Vendor"]?.ToString(), ", ");

                lsvFiles.DataSource = FileProcessor.GetFiles(docid, line_id, "PR_ITEM_FILES");
                lsvFiles.DataBind();
            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        public void Clear() {
            try {
                txtMaterialCode.Text = string.Empty;
                txtPartNumber.Text = string.Empty;
                txtItemName.Text = string.Empty;
                txtDescription.Text = string.Empty;
                txtQunatity.Text = string.Empty;
                txtUnit.Text = string.Empty;
                txtUnitPrice.Text = string.Empty;
                drpCurrency.DataBind();
                lsbSuggestedSuppliers.DataBind();
                lsbVendor.DataBind();
                lsvFiles.DataBind();

                txtSearch.Text = string.Empty;
            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        protected void lnkSave_Click(object sender, EventArgs e) {
            try {
                string command = (sender as LinkButton)?.CommandArgument;
                if (!string.IsNullOrEmpty(command)) {
                    Save(command);
                }
            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        private int Save(string method) {
            int result = 0;
            try {
                PRItem prItem = new PRItem();
                prItem.propMethod = method;

                prItem.propUID = (int)Session["UID"];
                prItem.propCurrencyCode = drpCurrency.SelectedValue;
                prItem.propDescription = txtDescription.Text;
                prItem.propDocumentID = DOCID;
                prItem.propItemCode = txtMaterialCode.Text;
                prItem.propItemName = txtItemName.Text;
                prItem.propItemID = LINE_ID;

                double quan = 0;
                double.TryParse(txtQunatity.Text, out quan);
                prItem.propItemQTY = quan;

                prItem.propPartNumber = txtPartNumber.Text;
                prItem.propSuggestedSuppliers = ApplicationRoot.GetListBoxSelectedItems(lsbSuggestedSuppliers, ", ");
                prItem.propUnit = txtUnit.Text;

                double price = 0;
                double.TryParse(txtUnitPrice.Text, out price);
                prItem.propUnitPriceIncludeVAT = price;

                prItem.propVendor = ApplicationRoot.GetListBoxSelectedItems(lsbVendor, ", ");

                result = DATA_MANIPULATION_LAYER.post_Document(XmlUtility.PrepareXMLDocument(prItem));
                FileProcessor.UploadFiles(fup, DOCID, (int)Session["UID"], "PR_ITEM_FILES", result);

                OnItemsChanged(this, new EventArgs());
            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }

            return result;
        }

        public void Delete(int docid, int line_id) {
            try {
                PRItem prItem = new PRItem();
                prItem.propMethod = "DELETE_PR_ITEM";
                prItem.propDocumentID = docid;
                prItem.propUID = (int)Session["UID"];
                prItem.propItemID = line_id;

                DATA_MANIPULATION_LAYER.post_Document(XmlUtility.PrepareXMLDocument(prItem));
                FileProcessor.Delete(docid, line_id, "PR_ITEM_FILES", (int)Session["UID"]);
                OnItemsChanged(this, new EventArgs());
            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        protected void lnkDelete_Click(object sender, EventArgs e) {
            try {
                Delete(DOCID, LINE_ID);
            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        protected void lnkFileDownload_Click(object sender, EventArgs e) {
            try {
                FileProcessor.Download((sender as LinkButton).CommandArgument, Response);
            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }

        protected void lnkFileDelete_Click(object sender, EventArgs e) {
            try {
                FileProcessor.Delete((sender as LinkButton).CommandArgument, (int)Session["UID"]);

                lsvFiles.DataSource = FileProcessor.GetFiles(DOCID, LINE_ID, "PR_ITEM_FILES");
                lsvFiles.DataBind();

                popextAddItem.Show();
            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }
        }
    }
}