<%@ Page Title="" Language="C#" MasterPageFile="~/Layout.Master" AutoEventWireup="true" CodeBehind="Request.aspx.cs" Inherits="WEB_PLATFORM007.Pages.Request" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="LayoutBody" runat="server">
    <div>
        <asp:Button ID="btnPurchase" runat="server" Text="Purchase" CommandArgument="Purchase" OnClick="btnRequest_Click" />
        <asp:Button ID="btnService" runat="server" Text="Service" CommandArgument="Service" OnClick="btnRequest_Click" />
    </div>
</asp:Content>

