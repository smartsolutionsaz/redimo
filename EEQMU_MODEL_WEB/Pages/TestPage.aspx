<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TestPage.aspx.cs" Inherits="WEB_PLATFORM007.Pages.TestPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Label Text="--" runat="server" ID="lblTest"/>
        <asp:ListView runat="server" ID="lst">
            <ItemTemplate>
                template
            </ItemTemplate>
        </asp:ListView>
    </div>
    </form>
</body>
</html>
