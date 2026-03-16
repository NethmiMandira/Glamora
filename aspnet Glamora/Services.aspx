<asp:GridView ID="gvServices" runat="server" AutoGenerateColumns="False" OnRowCommand="gvServices_RowCommand">
  <Columns>
    <asp:BoundField DataField="Service_ID" HeaderText="Service ID" />
    <asp:BoundField DataField="Service_Name" HeaderText="Service Name" />
    <asp:BoundField DataField="Price" HeaderText="Price" DataFormatString="{0:N2}" />
    <asp:BoundField DataField="Duration" HeaderText="Duration" />
    <asp:TemplateField HeaderText="Actions">
      <ItemTemplate>
        <asp:LinkButton
            ID="lnkEdit"
            runat="server"
            CommandName="EditService"
            CommandArgument='<%# Eval("Service_ID") %>'
            CausesValidation="false">Edit</asp:LinkButton>

        <asp:LinkButton
            ID="lnkDelete"
            runat="server"
            CommandName="DeleteService"
            CommandArgument='<%# Eval("Service_ID") %>'
            CausesValidation="false"
            OnClientClick="return confirm('Are you sure you want to delete this service?');">Delete</asp:LinkButton>
      </ItemTemplate>
    </asp:TemplateField>
  </Columns>
</asp:GridView>