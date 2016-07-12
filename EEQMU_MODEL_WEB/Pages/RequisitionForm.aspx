<%@ Page Title="" Language="C#" MasterPageFile="~/Layout.Master" AutoEventWireup="true" CodeBehind="RequisitionForm.aspx.cs" Inherits="WEB_PLATFORM007.Pages.RequisitionForm" %>

<%@ Register Src="~/UserControls/RequestItem.ascx" TagPrefix="uc1" TagName="RequestItem" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="LayoutBody" runat="server">
    <table width="100%" cellpadding="0" cellspacing="0">
        <tbody>
            <tr>
                <td>
                    <div id="EQSTATUS">
                        <table width="100%" cellpadding="0" cellspacing="0">
                            <tbody>
                                <tr>
                                    <td style="width: 100%;">
                                        <span class="LabelCaption"></span><span style="font-weight: bold; color: #2189A6;">
                                            <span id="ContentPlaceHolder1_EntryPoint_txtDOCNO"></span>
                                        </span>&nbsp;&nbsp;<span class="LabelCaption">Status :&nbsp;&nbsp;</span> <span style="font-weight: bold; color: #2189A6;">
                                            <span id="ContentPlaceHolder1_EntryPoint_txtDocStatus">NEW SSF</span>
                                        </span>
                                    </td>
                                    <td align="right">
                                        <div style="width: 90px; display: inherit;">
                                            <span class="LabelCaption">&nbsp;&nbsp;</span>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </td>
                <td align="left">
                    <div id="ContentPlaceHolder1_EntryPoint_panelDocCategory" class="DOC_CATEGORY_1">
                        <center>
                            <span class="LabelCaption" style="letter-spacing: 2px;">
                                <span id="ContentPlaceHolder1_EntryPoint_lblDocCategory"></span>
                            </span>
                        </center>
                    </div>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <div class="SubLineSection">
                    </div>
                </td>
            </tr>
            <tr>
                <td class="TTD1" style="width: 100%;">
                    <div class="BorderDot" style="background-color: #F5F5F5; margin: 3px 3px 3px 0px;">
                        <table width="100%" cellpadding="0" cellspacing="0" style="table-layout: auto;">
                            <tbody>
                                <tr>
                                    <td>
                                        <span>Request Date</span>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtRequestDate" runat="server"></asp:TextBox>
                                        <asp:CalendarExtender ID="clnRequestDate" runat="server" Format="dd-MMM-yyyy"
                                            Enabled="True" TargetControlID="txtRequestDate">
                                        </asp:CalendarExtender>
                                    </td>
                                    <td>
                                        <span>Preferable Date</span>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPreferableDate" runat="server"></asp:TextBox>
                                        <asp:CalendarExtender ID="clnPreferableDate" runat="server" Format="dd-MMM-yyyy"
                                            Enabled="True" TargetControlID="txtPreferableDate">
                                        </asp:CalendarExtender>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <span>Requestor Dep</span>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="drpRequestorDep" runat="server"
                                            DataValueField="DataID" DataTextField="DataName">
                                        </asp:DropDownList>
                                    </td>
                                    <td>
                                        <span>Requestor Name</span>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtRequestorName" runat="server" Enabled="false"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <span>Requested For Dep</span>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="drpRequestedForDep" runat="server"
                                            DataValueField="DataID" DataTextField="DataName">
                                        </asp:DropDownList>
                                    </td>
                                    <td>
                                        <span>Requested For Name</span>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtRequestedForName" runat="server"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <span>Cost Center</span>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="drpCostCenter" runat="server"
                                            DataValueField="DataID" DataTextField="DataName">
                                        </asp:DropDownList>
                                    </td>
                                    <td>
                                        <span>Project</span>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="drpProject" runat="server"
                                            DataValueField="DataID" DataTextField="DataName">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <span>Delivery Address</span>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtDeliveryAddress" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="SubLineSection" style="display: none;">
                    </div>
                    <div id="actionsTab">
                        <div style="width: 520px;">
                            <ul>
                                <li>
                                    <asp:LinkButton runat="server" Width="120px">Request Items</asp:LinkButton>
                                </li>
                            </ul>
                        </div>
                    </div>
                    <div>
                        <div id="actionsZZ" style="height: 30px; vertical-align: middle;">
                            <asp:LinkButton ID="lnkAddItem" runat="server" Width="140px" OnClick="lnkAddItem_Click"><img src="../img/users.png" style="border-style:none; height:15px;" />Add Item</asp:LinkButton>
                        </div>
                        <uc1:RequestItem runat="server" ID="requestItem" />
                        <asp:ListView ID="lsvItems" runat="server" cellpadding="0" cellspacing="0" Style="table-layout: fixed; width: 100%;">
                            <LayoutTemplate>
                                <table>
                                    <thead>
                                        <tr>
                                            <th>
                                                <span>Material Code</span>
                                            </th>
                                            <th>
                                                <span>Part Number</span>
                                            </th>
                                            <th>
                                                <span>Item Name</span>
                                            </th>
                                            <th>
                                                <span>Description</span>
                                            </th>
                                            <th>
                                                <span>Vendor</span>
                                            </th>
                                            <th>
                                                <span>Suggested Suppliers</span>
                                            </th>
                                            <th>
                                                <span>Qunatity</span>
                                            </th>
                                            <th>
                                                <span>Unit</span>
                                            </th>
                                            <th>
                                                <span>Unit Price incl VAT (Estimation)</span>
                                            </th>
                                            <th>
                                                <span>Files</span>
                                            </th>
                                            <th>
                                                <span>Commands</span>
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr runat="server" id="itemPlaceholder"></tr>
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <td>
                                                <span>Total Price</span>
                                            </td>
                                            <td>
                                                <asp:Label ID="lblTotalPrice" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </LayoutTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblMaterialCode" runat="server" Text='<%# Eval("ITEM_CODE") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblPartNumber" runat="server" Text='<%# Eval("PartNumber") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblItemName" runat="server" Text='<%# Eval("ITEM_NAME") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblDescription" runat="server" Text='<%# Eval("ITEM_DESCRIPTION") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblVendor" runat="server" Text='<%# Eval("Vendor") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblSuggestedSuppliers" runat="server" Text='<%# Eval("SuggestedSuppliers") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblQunatity" runat="server" Text='<%# Eval("Quantity") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblUnit" runat="server" Text='<%# Eval("Unit") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblUnitPrice" runat="server" Text='<%# Eval("UnitPriceIncludeVAT") %>'></asp:Label>
                                        <asp:Label ID="lblUnitCurrency" runat="server" Text='<%# Eval("CurrencyCode") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:Label ID="lblFilesCount" runat="server" Text='<%# Eval("FilesCount") %>'></asp:Label>
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="lnkItemEdit" runat="server" CommandArgument='<%# Eval("LINE_ID") %>' OnClick="lnkEdit_Click">Edit</asp:LinkButton>
                                        <asp:LinkButton ID="lnkItemDelete" runat="server" CommandArgument='<%# Eval("LINE_ID") %>' OnClick="lnkItemDelete_Click">Delete</asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:ListView>
                    </div>
                </td>
                <td class="PlayerSection" style="width: 320px;">
                    <div style="overflow: auto; height: 450px; width: 320px;">
                    </div>
                </td>
            </tr>
        </tbody>
    </table>
</asp:Content>
