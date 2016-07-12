using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Configuration;


namespace EEQMU_MODEL
{
    public class Operator
    {

             

    }

    public static class OperatorStatic
    {
        public static void SetConnection()
        {
            PLATFORM700TOREVO.Root.CN = ConfigurationSettings.AppSettings["DBCONN"];
            
            
        }

 
    }

    public class WF_WVLD_WAPPR
    {
        public WF_WVLD_WAPPR()
        {
            EQ_CODE = "";
            EQ_TEXT = "";
            UID = 0;
            ACTION_CODE = 0;
            ACTOR = 0;
            ASSIGNED = 0;
            PERFORMED = 0;
                EQID = 0;
                ACTION_CODE_VARCHAR = "";
            
        }
        private string inEQCode;
        private string inTEXT;
        private int inUID;
        private int inActionCode;
        private int inAssigned;
        private int inPerformed;
        private int inActorID;
        private int inEQID;
        private string inActionCodeV;
        

        public string EQ_CODE
        {
            set { inEQCode = value; }
            get { return inEQCode; } 

        }

        public int EQID
        {
            set { inEQID = value; }
            get { return inEQID; }
        }

        public string EQ_TEXT
        {
            set { inTEXT = value; }
            get { return inTEXT; }

        }

        public int UID
        {
            set { inUID = value; }
            get { return inUID; }

        }

        public int ACTOR
        {
            set { inActorID = value; }
            get { return inActorID; }

        
        }
        public int ASSIGNED
        {
            set { inAssigned = value; }
            get { return inAssigned; }
        }

               public int PERFORMED
        {
            set { inPerformed = value; }
            get { return inPerformed; }


        }
              
        public int ACTION_CODE
        {
            set { inActionCode = value; }
            get { return inActionCode; }
        }
        public string ACTION_CODE_VARCHAR
        {
            set { inActionCodeV = value; }
            get { return inActionCodeV; }

        }
    }

    public class WF_RESPONDER_RESPONSE
    {

        public WF_RESPONDER_RESPONSE()
        {
            EQ_CODE = "";
            RESPONDER_ID = 0;
            RESPONSE_TEXT = "";
            ACTION = 0;
            ACTION_MODE = 0;
        }


        private string inEQ_CODE;
        private int inResponderID;
        private string inResponceText;
        private int inReslutFlag;
        private int inAction;
        private int inActionMode;

        public string EQ_CODE
        {
            get { return inEQ_CODE; }
            set { inEQ_CODE = value; }
        }

        public int RESPONDER_ID
        {
            set { inResponderID = value; }
            get { return inResponderID; }
        }

        public string RESPONSE_TEXT
        {
            set { inResponceText = value; }
            get { return inResponceText; }

        }

        public int RESULT_FLAG
        {
            set { inReslutFlag = value; }
            get { return inReslutFlag; }
        }
        public int ACTION
        {
            set { inAction = value; }
            get { return inAction; }
        }

        public int ACTION_MODE
        {
            get { return inActionMode; }
            set { inActionMode = value; }
        }
    }
}