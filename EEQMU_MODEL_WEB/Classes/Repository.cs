using PLATFORM700TOREVO;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace WEB_PLATFORM007.Classes {
    public static class Repository {
        public static DataTable get(GetRequestParams getParams) {
            return DATA_PRESENTATION_LAYER.pltf_get_MultiRecord(
                XmlUtility.PrepareXMLDocumentBaseFreeRequest(
                    new P700TOREVOBaseRequest(
                        getParams.method, 
                        getParams.field, 
                        getParams.docid, 
                        getParams.id, 
                        getParams.text
                    ), 
                    getParams.fields
                ), 
                (int)getParams.type
            );
        }
    }

    public enum StructType {
        FreeStruct = 1, Struct = 2
    }

    public class GetRequestParams {
        public string method = "";
        public string field = "";
        public string docid = "";
        public string id = "0";
        public string text = "";
        public string[] fields = new string[] { };
        public StructType type = StructType.FreeStruct;
    }
}