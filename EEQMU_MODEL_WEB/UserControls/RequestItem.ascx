<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="RequestItem.ascx.cs" Inherits="WEB_PLATFORM007.UserControls.RequestItem" %>

<asp:Label ID="lblTarget" runat="server"></asp:Label>

<asp:Panel ID="popupAddItem" runat="server" Width="600px" Height="480px"
    CssClass="popupBackground" Style="display: none;">
    <div class="PopupTitle">
        <asp:Label ID="lblTitle" runat="server" Text="Add Item"
            Width="100%" Height="20px"></asp:Label>
    </div>
    <div style="padding: 5px 5px 5px 5px;">
        <div id="actions" style="padding: 5px 5px 5px 5px; text-align: center;">
            <table>
                <tr>
                    <td>
                        <span>Material Code</span>
                    </td>
                    <td>
                        <asp:TextBox ID="txtMaterialCode" runat="server"></asp:TextBox>
                    </td>
                    <td>
                        <span>Part Number</span>
                    </td>
                    <td>
                        <asp:TextBox ID="txtPartNumber" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span>Item Name</span>
                    </td>
                    <td>
                        <asp:TextBox ID="txtItemName" runat="server"></asp:TextBox>
                    </td>
                    <td>
                        <span>Description</span>
                    </td>
                    <td>
                        <asp:TextBox ID="txtDescription" TextMode="MultiLine" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span>Vendor</span>
                    </td>
                    <td>
                        <asp:ListBox ID="lsbVendor" runat="server" SelectionMode="Multiple"
                            DataValueField="DataID" DataTextField="DataName"></asp:ListBox>
                    </td>
                    <td>
                        <span>Suggested Suppliers</span>
                    </td>
                    <td>
                        <asp:ListBox ID="lsbSuggestedSuppliers" runat="server" SelectionMode="Multiple"
                            DataValueField="DataID" DataTextField="DataName"></asp:ListBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span>Qunatity</span>
                    </td>
                    <td>
                        <asp:TextBox ID="txtQunatity" runat="server"></asp:TextBox>
                    </td>
                    <td>
                        <span>Unit</span>
                    </td>
                    <td>
                        <asp:TextBox ID="txtUnit" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span>Currency</span>
                    </td>
                    <td>
                        <asp:DropDownList ID="drpCurrency" runat="server"
                            DataValueField="DataID" DataTextField="DataName">
                        </asp:DropDownList>
                    </td>
                    <td>
                        <span>Unit Price incl VAT (Estimation)</span>
                    </td>
                    <td>
                        <asp:TextBox ID="txtUnitPrice" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span>Files:&nbsp;</span>
                    </td>
                    <td>
                        <asp:ListView ID="lsvFiles" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <asp:LinkButton ID="lnkFileDownload" runat="server" CommandArgument='<%# Eval("FileName") %>'
                                            Text='<%# Eval("FileName") %>' OnClick="lnkFileDownload_Click">
                                        </asp:LinkButton>
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="lnkFileDelete" runat="server" CommandArgument='<%#Eval("FileName") %>'
                                            OnClick="lnkFileDelete_Click">
                                        Delete
                                        </asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <LayoutTemplate>
                                <table>
                                    <tr runat="server" id="itemPlaceholder"></tr>
                                </table>
                            </LayoutTemplate>
                            <EmptyDataTemplate>No files.</EmptyDataTemplate>
                        </asp:ListView>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span>New Files:&nbsp;</span>
                    </td>
                    <td>
                        <asp:FileUpload ID="fup" runat="server" AllowMultiple="true" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <div style="padding-right: 10px; padding-left: 150px; text-align: center;">
                            <asp:LinkButton ID="lnkSave" runat="server" Width="100px" OnClick="lnkSave_Click">Save</asp:LinkButton>
                            <asp:LinkButton ID="lnkDelete" runat="server" Width="100px" OnClick="lnkDelete_Click">Delete</asp:LinkButton>
                            <asp:LinkButton ID="lnkCancel" runat="server" Width="100px">Cancel</asp:LinkButton>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</asp:Panel>
<asp:ModalPopupExtender ID="popextAddItem" runat="server" BackgroundCssClass="modalBackground"
    PopupControlID="popupAddItem" DropShadow="true" PopupDragHandleControlID="lblTitle"
    Enabled="true" TargetControlID="lblTarget" CancelControlID="lnkCancel">
</asp:ModalPopupExtender>

<asp:Panel ID="popupSearchItem" runat="server" Width="600px" Height="480px"
    CssClass="popupBackground" Style="display: none;">
    <div class="PopupTitle">
        <asp:Label ID="lblSearchTitle" runat="server" Text="Search Item"
            Width="100%" Height="20px"></asp:Label>
    </div>
    <div style="padding: 5px 5px 5px 5px;">
        <div id="actions" style="padding: 5px 5px 5px 5px; text-align: center;">
            <table>
                <tr>
                    <td>
                        <asp:TextBox ID="txtSearch" runat="server"></asp:TextBox>
                    </td>
                    <td>
                        <asp:LinkButton ID="lnkSearch" runat="server"></asp:LinkButton>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:ListBox ID="lsbSearch" runat="server"
                            DataValueField="DataID" DataTextField="DataName"></asp:ListBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:LinkButton ID="lnkSearchCancel" runat="server" Width="100px">Cancel</asp:LinkButton>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</asp:Panel>
<asp:ModalPopupExtender ID="popextSearchItem" runat="server" BackgroundCssClass="modalBackground"
    PopupControlID="popupSearchItem" DropShadow="true" PopupDragHandleControlID="lblSearchTitle"
    Enabled="true" TargetControlID="lblTarget" CancelControlID="lnkSearchCancel">
</asp:ModalPopupExtender>
