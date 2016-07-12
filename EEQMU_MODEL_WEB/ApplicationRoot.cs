using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PLATFORM700TOREVO;
using System.Data;
using System.Web.UI.WebControls;
using System.Web;
using System.Web.UI;
using System.Configuration;
using ACollision;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Diagnostics;

namespace WEB_PLATFORM007 {
    public class ApplicationRoot {
        public static void HandleException(MethodBase methodBase,
            StackTrace stackTrace, Exception ex, bool throwException = true) {
            ACollisionErrorLog.RecordTheException(
                new ACollision.ApplicationException(
                    methodBase.ReflectedType.Name + "|" + stackTrace.GetFrame(0).GetMethod(), ex.Message));

            if (throwException) throw ex;
        }

        public static DataTable GetData(string pMethod, string pDOCID, string pField = "",
            string pID2 = "0", string pText = "", string[] fields = null, int structType = 1) 
        {
            return DATA_PRESENTATION_LAYER.pltf_get_MultiRecord
                (XmlUtility.PrepareXMLDocumentBaseFreeRequest
                (new P700TOREVOBaseRequest
                (pMethod, pField, pDOCID, pID2, pText), fields ?? new string[] { }), structType);
        }

        public static DataTable GetData(string pMethod, string pDOCID, string pField = "", string pID2 = "0",
            string pText = "", string[] fields = null, int structType = 1, params BaseDataBoundControl[] dbControls) 
        {
            DataTable dt = GetData(pMethod, pDOCID, pField, pID2, pText, fields ?? new string[] { }, structType);

            foreach (var dbControl in dbControls) {
                dbControl.DataSource = dt;
                dbControl.DataBind();
            }

            return dt;
        }

        public static string GetListBoxSelectedItems(ListBox listBox, string separator) {
            string result = string.Empty;

            foreach (ListItem listItem in listBox.Items) {
                if (listItem.Selected == true) {
                    result += separator + listItem.Value;
                }
            }

            if (result.Length >= separator.Length) return result.Remove(0, separator.Length);

            return result;
        }

        public static void SetListBoxSelectedItems(ListBox listBox, string items, string separator) {
            if (string.IsNullOrEmpty(items)) return;
            if (listBox == null || listBox.Items.Count == 0) return;

            string[] array = items.Split(new string[] { separator }, StringSplitOptions.RemoveEmptyEntries);

            foreach (var item in array) {
                var listBoxItem = listBox.Items.FindByValue(item);
                if (listBoxItem != null) listBoxItem.Selected = true;
            }
        }
    }

    public class FileProcessor {
        public static DataTable GetFiles(int docid, int lineid, string category) {
            return ApplicationRoot.GetData("GET_FILES", docid.ToString(),
                fields: new string[] { lineid.ToString(), category });
        }

        public static void UploadFiles(FileUpload fup, int docid, int uid, string category, int lineid) {
            foreach (HttpPostedFile file in fup.PostedFiles) {
                try {
                    UploadFile(file, docid, uid, category, lineid);
                }
                catch { }
            }
        }

        public static void UploadFile(HttpPostedFile file, int docid, int uid, string category, int lineid) {
            if (file.ContentLength == 0) return;
            int id = SaveToDatabase(docid, file.FileName, uid, category, lineid);
            string fileName = $"{id}_{file.FileName}";
            try {
                SaveToServer(file, fileName);
            }
            catch (Exception ex) {
                DeleteFromDatabase(id, uid);
                throw ex;
            }
        }

        public static void SaveToServer(HttpPostedFile file, string fileName) {
            string fullFileName = GetFullFileName(fileName);
            file.SaveAs(fullFileName);
        }

        public static string GetFullFileName(string fileName) {
            return $"{GetUploadDirectory()}{fileName}";
        }

        public static string GetUploadDirectory() {
            string dir = ConfigurationManager.AppSettings["UPLOAD_DIR"];
            if (dir == null) dir = string.Empty;

            dir = HttpContext.Current.Server.MapPath(dir) + "\\";

            return dir;
        }

        public static int SaveToDatabase(int docid, string filename, int uid, string category, int lineid) {
            EX_FILE file = new EX_FILE();

            file.propMethod = "SAVE_FILE";
            file.propDocumentID = docid;
            file.propFileName = filename;
            file.propUID = uid;
            file.propFileCategory = category;
            file.propLineID = lineid;

            return DATA_MANIPULATION_LAYER.post_Document(XmlUtility.PrepareXMLDocument(file));
        }

        public static void Delete(int docid, int lineid, string category, int uid) {
            DataTable dt = GetFiles(docid, lineid, category);

            foreach (DataRow row in dt.Rows) {
                Delete(row["FileName"].ToString(), uid);
            }
        }

        public static void Delete(int fileid, int uid) {
            DeleteFromDatabase(fileid, uid);
            DeleteFromServer(fileid);
        }

        public static void Delete(string fileName, int uid) {
            DeleteFromDatabase(fileName, uid);
            DeleteFromServer(fileName);
        }

        public static void DeleteFromServer(int fileid) {
            string[] files = Directory.GetFiles(GetUploadDirectory(), $"{fileid}_*.*",
                SearchOption.TopDirectoryOnly);

            foreach (var fileName in files) {
                File.Delete(fileName);
            }
        }

        public static void DeleteFromServer(string fileName) {
            File.Delete(GetFullFileName(fileName));
        }

        public static void DeleteFromDatabase(int fileid, int uid) {
            EX_FILE file = new EX_FILE();

            file.propMethod = "DELETE_FILE_BY_ID";
            file.propFileID = fileid;
            file.propUID = uid;

            DATA_MANIPULATION_LAYER.post_Document(XmlUtility.PrepareXMLDocument(file));
        }

        public static void DeleteFromDatabase(string fileName, int uid) {
            EX_FILE file = new EX_FILE();

            file.propMethod = "DELETE_FILE_BY_NAME";
            file.propFileName = fileName;
            file.propUID = uid;

            DATA_MANIPULATION_LAYER.post_Document(XmlUtility.PrepareXMLDocument(file));
        }

        public static void Download(int fileId, HttpResponse response) {
            string[] files = Directory.GetFiles(GetUploadDirectory(), $"{fileId}_*.*",
                SearchOption.TopDirectoryOnly);

            if (files.Length > 0) Download(Path.GetFileName(files[0]), response);
        }

        public static void Download(string fileName, HttpResponse response) {
            FileInfo file = new FileInfo(GetFullFileName(fileName));
            response.Clear();
            response.ClearHeaders();
            response.ClearContent();
            response.AppendHeader("Content-Disposition", $"attachment; filename = {fileName}");
            response.AppendHeader("Content-Length", file.Length.ToString());
            response.ContentType = "application/download";
            response.WriteFile(file.FullName);
            response.Flush();
            response.Close();
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }
    }

    public class EX_FILE : P700TOREVO_FILE {
        public int propDocumentID { get; set; }
        public int propLineID { get; set; }
    }

    public class PR : P700TOREVODocument {
        public int propRequestorDepartamentId { get; set; }
        public int propRequestorUID { get; set; }
        public int propRequestedForDepartamentId { get; set; }
        public string propRequestedForName { get; set; }
        public string propDeliveryAddress { get; set; }
        public int propCostCenterId { get; set; }
        public int propProjectId { get; set; }
        public int propUID { get; set; }
    }

    public class PRItem : P700TOREVOItem {
        public string propPartNumber { get; set; }
        public string propDescription { get; set; }
        public string propVendor { get; set; }
        public string propSuggestedSuppliers { get; set; }
        public string propUnit { get; set; }
        public string propCurrencyCode { get; set; }
        public double propUnitPriceIncludeVAT { get; set; }
        public int propUID { get; set; }
        public new string propItemCode { get; set; }
    }
}
