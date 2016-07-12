using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using System.Configuration;
using WEB_PLATFORM007.Classes;

namespace WEB_PLATFORM007
{
    public class Global : System.Web.HttpApplication
    {

        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            
            PLATFORM700TOREVO.Root.CN = ConfigurationSettings.AppSettings["DBCONN"];
        }

        void Application_End(object sender, EventArgs e)
        {
            //  Code that runs on application shutdown

        }

        void Application_Error(object sender, EventArgs e)
        {
            // Code that runs when an unhandled error occurs

        }

        void Session_Start(object sender, EventArgs e)
        {
            int UID = 72;
            Session["UID"] = UID;
            Session["IS_BUYER"] = UserRepository.isBuyer(UID.ToString());
            Session["IS_ADMIN"] = true;

            Session["EQCODE"] = "";
            Session["GRD_DATA"] = "0";
            Session["GRD_MODE"] = "0";
            Session["GRD_FILTER"] = "";
            Session["GRD_FILTER_ID"] = "0";
            Session["REPORT_NAME"] = "";
            Session["HOMEPAGEMODE"] = "HOME";

        }

        void Session_End(object sender, EventArgs e)
        {
            // Code that runs when a session ends. 
            // Note: The Session_End event is raised only when the sessionstate mode
            // is set to InProc in the Web.config file. If session mode is set to StateServer 
            // or SQLServer, the event is not raised.

        }

    }
}
