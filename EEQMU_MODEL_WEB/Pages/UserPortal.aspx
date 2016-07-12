<%@ Page Title="" Language="C#" MasterPageFile="~/EEQMU_MODEL.Master" AutoEventWireup="true" CodeBehind="UserPortal.aspx.cs" Inherits="WEB_PLATFORM007.Pages.UserPortal" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div id="links" runat="server" class="navigation-left-panel">
        <hr />
        <asp:LinkButton ID="lnk1" runat="server" Text="My PRs" CommandArgument="1" OnClick="NavigationLink_Click"></asp:LinkButton><br />
        <asp:LinkButton ID="lnk2" runat="server" Text="Draft PRs" CommandArgument="2" OnClick="NavigationLink_Click"></asp:LinkButton><br />
        <asp:LinkButton ID="lnk3" runat="server" Text="Any PRs" CommandArgument="3" OnClick="NavigationLink_Click"></asp:LinkButton><br />
        <hr />
    </div>

    <div class="navigation-panel-header">
    </div>

    <div class="navigation-body">
        <div class="navigation-body-left">
            <asp:ListView ID="lsvDocs" runat="server">
                <ItemTemplate>
                    <tr>
                        <td>
                            <asp:HyperLink ID="hplDOCID" runat="server" NavigateUrl='<%# "~/Pages/RequisitionForm.aspx?docid=" + Eval("DOCID") %>' Text='<%# Eval("DOCID") %>'></asp:HyperLink>
                        </td>
                        <td>
                            <asp:Label ID="lblPRNum" runat="server" Text='<%# Eval("DOC_NUMBER") %>'></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="lblRequestDate" runat="server" Text='<%# Eval("DOC_DATE") %>'></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="lblPreferableDate" runat="server" Text='<%# Eval("DOC_DUE_DATE") %>'></asp:Label>
                        </td>
                    </tr>
                </ItemTemplate>
                <LayoutTemplate>
                    <table>
                        <tr runat="server" id="itemPlaceholder"></tr>
                    </table>
                </LayoutTemplate>
            </asp:ListView>
        </div>
        <div class="navigation-body-right">
        </div>
    </div>
</asp:Content>
