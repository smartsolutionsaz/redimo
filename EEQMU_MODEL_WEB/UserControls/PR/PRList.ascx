<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PRList.ascx.cs" Inherits="WEB_PLATFORM007.UserControls.PRList" %>

<asp:ListView runat="server" ID="lstPR">
    <LayoutTemplate>
        <div class="list-group">
          <a runat="server" ID="itemPlaceholder"></a>
        </div>
    </LayoutTemplate>
    <ItemTemplate>
        <asp:LinkButton type="submit" class="list-group-item" runat="server" ID="itemPlaceholder" OnClick="_OnSelect" CommandArgument='<%# Eval("DOCID") %>'>
            <asp:Label ID="lblNumber" runat="server" Text='<%# Eval("DOC_NUMBER") %>'></asp:Label>
        </asp:LinkButton>
    </ItemTemplate>
</asp:ListView>
