using System;
using System.Web;
using System.DirectoryServices;
using System.Data;
using System.Web.UI;
using System.Text.RegularExpressions;
using ACollision;
using System.Collections.Generic;


namespace WEB_PLATFORM007
{
    public class ProcessRoot
    {



        public static string GetNtAccount()
        {
            //return "bp1\\samev1";
            //return "bp1\\mameed";
           
                return HttpContext.Current.User.Identity.Name.ToLower();
          
        }



        public static string GetAppSettings(string key)
        {
            return System.Configuration.ConfigurationSettings.AppSettings[key].ToLower();
        }

      
     


        public static  PLATFORM700TOREVO.WF_ACTION_MESSAGE WFActionV7(int DOCID, string docText, int UID, int ActionID, int Actor, int Assigned, int Performed, int doStatusUp)
        {


            try
            {
           


                WEB_PLATFORM007.WCF_PLATFORM001.EEQMU_MODELClient wcfClient = new WEB_PLATFORM007.WCF_PLATFORM001.EEQMU_MODELClient();
                //PLATFORM700TOREVO.WF_ACTION_OBJECT wfAction = new PLATFORM700TOREVO.WF_ACTION_OBJECT();

                PLATFORM700TOREVO.WF_ACTION_OBJECT wfAction = new PLATFORM700TOREVO.WF_ACTION_OBJECT();

                wfAction.ActionID = ActionID;
                wfAction.ActionText = docText;
                wfAction.DOCID = DOCID;
                wfAction.IsAssigned = Assigned;
                wfAction.IsPerformed = Performed;
                wfAction.ActorID = Actor;
                wfAction.UID = UID;
                wfAction.DoStatusUP = doStatusUp;



                PLATFORM700TOREVO.WF_ACTION_MESSAGE wfResult = wcfClient.SUBMIT_ACTION(wfAction);

                return wfResult;
            }
            catch (Exception eX)
            {
                ACollisionErrorLog.RecordTheException(new ACollision.ApplicationException(System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name + "|" + new System.Diagnostics.StackTrace().GetFrame(0).GetMethod(), eX.Message));
                PLATFORM700TOREVO.WF_ACTION_MESSAGE wfErrorResult = new PLATFORM700TOREVO.WF_ACTION_MESSAGE();
                wfErrorResult.propMessageCode = 0;
                wfErrorResult.propMessageText = eX.Message;

                return wfErrorResult;
            }
        }


        public static Dictionary<string, string> GetDbFilds(string listType)
        {
            try
            {

                

                Dictionary<string, string> dbFields = new Dictionary<string, string>();
                DataTable DTB1 = PLATFORM700TOREVO.DATA_PRESENTATION_LAYER.pltf_get_MultiRecord(PLATFORM700TOREVO.XmlUtility.PrepareXMLDocumentBaseFreeRequest(new PLATFORM700TOREVO.P700TOREVOBaseRequest("pltf_get_ListData_Struct", "DOCUMENT_XML_MAP", "", "0", ""), new string[] { }), 2);
                foreach (DataRow DR in DTB1.Rows)
                {
                    dbFields.Add(DR["DataID"].ToString(), DR["DataName"].ToString());

                }

                return dbFields;

            }

            catch (Exception eX)
            {
                ACollisionErrorLog.RecordTheException(new ACollision.ApplicationException(System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name + "|" + new System.Diagnostics.StackTrace().GetFrame(0).GetMethod(), eX.Message));

                return new Dictionary<string, string>();
            }
        }




        public static string WFAction(int eqID, string eqText, int UID, int ActionID, int Actor, int Assigned, int Performed)
        {


            try
            {
                //EEQMU_WEB_PLATFORM003.WCF_PLATFORM001.EEQMU_MODELClient wcfClient = new EEQMU_WEB_PLATFORM003.WCF_PLATFORM001.EEQMU_MODELClient();

                //EEQMU_WEB_PLATFORM003.WCF_PLATFORM001.WF_WVLD_WAPPR eqActionVal = new EEQMU_WEB_PLATFORM003.WCF_PLATFORM001.WF_WVLD_WAPPR();
                //eqActionVal.EQID = eqID;
                //eqActionVal.EQ_TEXT = eqText;
                //eqActionVal.UID = UID;
                //eqActionVal.ACTION_CODE = ActionID;
                //eqActionVal.ASSIGNED = Assigned;
                //eqActionVal.PERFORMED = Performed;
                //eqActionVal.ACTOR = Actor;


                string wfResult = "";

              //  wfResult = wcfClient.SUBMIT_ACTION(eqActionVal);

                // = wcfClient.EQ_SUBMIT(eqActionVal);

                return wfResult;
            }
            catch (Exception eX)
            {
                ACollisionErrorLog.RecordTheException(new ACollision.ApplicationException(System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name + "|" + new System.Diagnostics.StackTrace().GetFrame(0).GetMethod(), eX.Message));
                return "";
            }
        }


   public static string WFActionCheck(int eqID, string eqText, int UID, int ActionID, int Actor, int Assigned, int Performed, string ActionCodeV)
   {


       try
       {
           /*
           EEQMU_WEB_PLATFORM003.WCF_PLATFORM001.EEQMU_MODELClient wcfClient = new EEQMU_WEB_PLATFORM003.WCF_PLATFORM001.EEQMU_MODELClient();

           EEQMU_WEB_PLATFORM003.WCF_PLATFORM001.WF_WVLD_WAPPR eqActionVal = new EEQMU_WEB_PLATFORM003.WCF_PLATFORM001.WF_WVLD_WAPPR();
           eqActionVal.EQID = eqID;
           eqActionVal.EQ_TEXT = eqText;
           eqActionVal.UID = UID;
           eqActionVal.ACTION_CODE = ActionID;
           eqActionVal.ASSIGNED = Assigned;
           eqActionVal.PERFORMED = Performed;
           eqActionVal.ACTOR = Actor;           
           eqActionVal.ACTION_CODE_VARCHAR = ActionCodeV;

           */
           string wfResult = "";

           //wfResult = wcfClient.SUBMIT_ACTION(eqActionVal);

           // = wcfClient.EQ_SUBMIT(eqActionVal);

           return wfResult;
       }
       catch (Exception eX)
       {
           return "";
       }
   }
 


    }



    public class SSFDocument : PLATFORM700TOREVO.P700TOREVODocument
    {

        public SSFDocument()
        {

            propDocumentType = "SSF_DOCUMENT";
            
                
        }

        public string propPRNO { get; set; }
        public DateTime propPRDate { get; set; }
        public DateTime propPRDateSubmit { get; set; }
        public Decimal propPRAmount { get; set; }

        public int propSSFType { get; set; }
        public int propSSFSubjectType { get; set; }
        public int propPeriodBaseType { get; set; }
        public DateTime propDateIssued { get; set; }
        public string propPONO { get; set; }
        public string propContractNo { get; set; }
        public int propDocumentCategory { get; set; }
        public string propDocCategoryName { get; set; }
        public string propSupplierSelectionCriteria { get; set; }

        public DateTime propContractDate { get; set; }
        public DateTime propContractValidDate { get; set; }
        public int propCurrencyCode { get; set; }
        public DateTime propDocValiDate { get; set; }
        

    }

    public class SSFDocumentItem : PLATFORM700TOREVO.P700TOREVOItem
    {

        public SSFDocumentItem()
        {
            propDocumentType = "SSF_DOC_ITEM";

            
        }

        public string propSupplierCode { set; get; }
        public string propSupplierName { set; get; }
        public decimal propPrice { set; get; }
        public string propDeliveryText { set; get; }
        public string propPaymentTerms { set; get; }
        public int propIsSelected { set; get; }
        public string propDocumentFiles { get; set; }
        public int propPos { get; set; }

        public int propCurrencyCode { get; set; }


    }


    

    public class SSFComment : PLATFORM700TOREVO.P700TOREVOEntity
    {

        public SSFComment()
        {
            propDocumentType = "SSF_COMMENT";

        }


        public SSFComment(int docID, string commentText, int uID, int commentParentID, string Method)
        {
            propDocumentType = "SSF_COMMENT";

            propDOCID = docID;
            propCommentText = commentText;
            propUID = uID;
            propCommentParentID = commentParentID;
            propMethod = Method;


        }



       public string propCommentText { get; set; }
       public int propDOCID { get; set; }
       public int propCommentParentID { get; set; }
       public int propUID { get; set; }



    }


    public class SSFAction : PLATFORM700TOREVO.WF_ACTION_OBJECT
    {
        public SSFAction()
        {
                        
            propUID = 0;
            propActionID = 0;
            propActorID = 0;
            propDOCID = 0;
            propIsAssigned = 0;
            propIsPerformed = 0;
            propActionText = "";
            propDoStatusUP = 0;
            propActorRole = 0;

        }
 
        public int propUID { get; set; }
        public int propActionID { get; set; }
        public int propActorID { get; set; }
        public int propDOCID { get; set; }
        public int propIsAssigned { get; set; }
        public int propIsPerformed { get; set; }
        public string propActionText { get; set; }
        public int propDoStatusUP { get; set; }
        public int propActorRole { get; set; }
    }

    public class SSFFile : PLATFORM700TOREVO.P700TOREVO_FILE
    {
        public SSFFile()
        {
            propDocumentType = "SSF_FILE";

        }

        public SSFFile(int pDOCID,string pMethod, string pFileName , string pFullFileName, string pFileCategory , int pUID, int pFileID, string pBatchID )
        {
            propDocumentType = "SSF_FILE";

            propDOCID = pDOCID;
            propMethod = pMethod;
            propFileName = pFileName;
            propFullFileName = pFullFileName;
            propFileCategory = pFileCategory;
            propUID = pUID;
            propFileID = pFileID;
            propBATCH_ID = pBatchID;

        }

        
    }


    public class SSF_REQN : PLATFORM700TOREVO.P700BASECLASS
    {

        public SSF_REQN()
        {
            propDocumentType = "SSF_REQN";
            propMethod = "POST";
        }

        public int propDocumentID { get; set; }
        public int propREQN_ID { get; set; }
        public string propREQN_REF { get; set; }
        public DateTime propREQN_DATE { get; set; }
        public DateTime propREQN_PROC_DATE { get; set; }
    }

}