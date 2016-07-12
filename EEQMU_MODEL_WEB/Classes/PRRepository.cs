using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace WEB_PLATFORM007.Classes {
    public static class PRRepository {
        public static DataTable getPRsForBuyer(string buyerUID) {
            return Repository.get(new GetRequestParams() {
                method = "GET_PRS",
                field = "FOR_BUYER",
                id = buyerUID
            });
        }

        public static DataTable getPRsForDemand() {
            return Repository.get(new GetRequestParams() {
                method = "GET_PRS",
                field = "FOR_DEMAND",
            });
        }
    }
}