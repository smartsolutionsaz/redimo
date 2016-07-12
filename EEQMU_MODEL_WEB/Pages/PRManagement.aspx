<%@ Page Language="C#" MasterPageFile="~/Layout.Master" AutoEventWireup="true" CodeBehind="PRManagement.aspx.cs" Inherits="WEB_PLATFORM007.Pages.PRManagement" EnableEventValidation="false" %>

<%@ Register Src="~/UserControls/PR/PRList.ascx" TagPrefix="uc1" TagName="PRList" %>
<%@ Register Src="~/UserControls/Test.ascx" TagPrefix="uc1" TagName="Test" %>


<asp:Content ID="Content1" ContentPlaceHolderID="Head" runat="server">
</asp:Content>

<asp:Content ID="Content" ContentPlaceHolderID="LayoutBody" runat="server">
    <div class="wrapper container-fluid">
		<div class="row">
			<div class="col-md-3">
                <div class="list-group">
                  <a href="?mode=1" class="list-group-item active">All PR</a>
                  <a href="#" class="list-group-item">PRs for Assignment</a>
                  <a href="#" class="list-group-item">Assigned to me PRs</a>
                  <a href="#" class="list-group-item">PRs Assigned to me</a>
                  <a href="#" class="list-group-item">POs Created by me</a>
                  <a href="#" class="list-group-item">Submitted POs</a>
                </div>
                <%--<uc1:PRList runat="server" id="PRList"/>--%>
			</div>
			<div class="col-md-9">
				<div class="row">
					<div class="col-md-12">
                        <div class="form-inline">
                          <div class="form-group form-group-sm">
                              <asp:TextBox runat="server" ID="txtFilter" CssClass="form-control" placeholder="Filter"/>
                          </div>
                          <button type="button" class="btn btn-default btn-sm">Filter</button>
                        </div>
					</div>
					<div class="col-md-4">
                        ID: <asp:Label Text="0" runat="server" ID="lblID"/>
					</div>
					<div class="col-md-8">right</div>
				</div>
			</div>
		</div>
	</div>
</asp:Content>
