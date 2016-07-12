using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace WEB_PLATFORM007.Classes {
    public static class UserRepository {
        public static bool isBuyer(string UID) {
            bool isBuyer = false;

            try {
                isBuyer = Repository.get(new GetRequestParams() {
                    method = "USER",
                    field = "IS_BUYER",
                    id = UID
                }).Rows[0]["IS_BUYER"].ToString() == "1";
            }
            catch (Exception ex) {
                ApplicationRoot.HandleException(System.Reflection.MethodBase.GetCurrentMethod(), new System.Diagnostics.StackTrace(), ex);
            }

            return isBuyer;
        }
    }
}