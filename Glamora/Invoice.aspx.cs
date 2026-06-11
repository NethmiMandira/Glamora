using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class Invoice : Page
    {
        private const string ServicesViewStateKey = "Invoice_ServicesTable";
        private const string InvoicePrefix = "INV-";
        private const string InvoiceServicePrefix = "INVSER-";

        private readonly string _connectionString =
            ConfigurationManager.ConnectionStrings["GlamoraDBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            BindCustomers();
            string queryAppId = Request.QueryString["appId"];
            BindAppointmentIds(queryAppId);
            BindAdditionalServices();
            txtInvoiceNo.Text = GetNextInvoiceNumber();
            txtInvoiceDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

            if (!string.IsNullOrWhiteSpace(queryAppId))
            {
                LoadAppointmentDetails(queryAppId);
            }
        }

        private void BindCustomers()
        {
            ddlCustomer.Items.Clear();
            ddlCustomer.Items.Add(new ListItem("-- Select Customer --", string.Empty));

            const string sql = @"
        SELECT Cus_ID, Title, CusFirst_Name, CusLast_Name
        FROM CustomerTbl
        ORDER BY CusFirst_Name, CusLast_Name";

            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (reader.Read())
                    {
                        var customerId = reader["Cus_ID"]?.ToString();
                        var title = reader["Title"]?.ToString();
                        var first = reader["CusFirst_Name"]?.ToString();
                        var last = reader["CusLast_Name"]?.ToString();

                        var displayName = string.Join(" ", new[] { title, first, last }
                            .Where(p => !string.IsNullOrWhiteSpace(p))
                            .Select(p => p.Trim()));

                        if (string.IsNullOrWhiteSpace(displayName))
                        {
                            continue;
                        }

                        ddlCustomer.Items.Add(new ListItem(displayName, customerId ?? displayName));
                    }
                }
            }
        }

        private (string Status, string AppDate, string Customer, string Employee, string Services, string Total, string Booking, string Advance) GetAppointmentColumns()
        {
            return ("Status", "AppDate", null, null, null, "TotalAmount", "BookingDate", "AdvanceAmount");
        }

        private string GetNextInvoiceNumber()
        {
            try
            {
                using (var conn = new SqlConnection(_connectionString))
                {
                    conn.Open();
                    var next = GetNextSequentialId(conn, null, "InvoiceTbl", "InvoiceID", InvoicePrefix);
                    return $"{InvoicePrefix}{next:000}";
                }
            }
            catch
            {
                return $"{InvoicePrefix}001";
            }
        }

        private static int GetNextSequentialId(SqlConnection conn, SqlTransaction tx, string tableName, string columnName, string prefix)
        {
            var sql = $@"
SELECT ISNULL(MAX(CAST(SUBSTRING([{columnName}], @PrefixLen + 1, 10) AS INT)), 0)
FROM [{tableName}] WITH (UPDLOCK, HOLDLOCK)
WHERE [{columnName}] LIKE @Prefix + '%'";

            using (var cmd = new SqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@Prefix", prefix);
                cmd.Parameters.AddWithValue("@PrefixLen", prefix.Length);

                var scalar = cmd.ExecuteScalar();
                var currentMax = scalar != null && scalar != DBNull.Value
                    ? Convert.ToInt32(scalar, CultureInfo.InvariantCulture)
                    : 0;

                return currentMax + 1;
            }
        }

        private void BindAdditionalServices()
        {
            ddlAddService.Items.Clear();
            ddlAddService.Items.Add(new ListItem("-- Select Service --", string.Empty));

            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(
                       "SELECT Service_ID, Service_Name FROM ServiceTbl ORDER BY Service_Name", conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (reader.Read())
                    {
                        var serviceId = reader["Service_ID"].ToString();
                        var serviceName = reader["Service_Name"]?.ToString();

                        if (string.IsNullOrWhiteSpace(serviceName))
                        {
                            continue;
                        }

                        ddlAddService.Items.Add(new ListItem(serviceName, serviceId));
                    }
                }
            }

            ddlAddServiceEmployee.Items.Clear();
            ddlAddServiceEmployee.Items.Add(new ListItem("-- Select Employee --", string.Empty));
        }

        protected void ddlAddService_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindEmployeesForService(ddlAddService.SelectedValue);
            upServices.Update();
        }

        private void BindEmployeesForService(string serviceId)
        {
            ddlAddServiceEmployee.Items.Clear();
            ddlAddServiceEmployee.Items.Add(new ListItem("-- Select Employee --", string.Empty));

            if (string.IsNullOrWhiteSpace(serviceId))
            {
                return;
            }

            const string sql = @"
                SELECT e.Emp_ID, e.Title, e.EmpFirst_Name, e.EmpLast_Name
                FROM EmployeeServiceTbl es
                INNER JOIN EmpTbl e ON es.Emp_ID = e.Emp_ID
                WHERE es.Service_ID = @ServiceID
                ORDER BY e.EmpFirst_Name, e.EmpLast_Name";

            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ServiceID", serviceId);
                conn.Open();
                using (var reader = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (reader.Read())
                    {
                        var empId = reader["Emp_ID"]?.ToString();
                        var title = reader["Title"]?.ToString();
                        var first = reader["EmpFirst_Name"]?.ToString();
                        var last = reader["EmpLast_Name"]?.ToString();

                        var displayName = string.Join(" ", new[] { title, first, last }
                            .Where(p => !string.IsNullOrWhiteSpace(p))
                            .Select(p => p.Trim()));

                        if (!string.IsNullOrWhiteSpace(displayName))
                        {
                            ddlAddServiceEmployee.Items.Add(new ListItem(displayName, empId ?? displayName));
                        }
                    }
                }
            }
        }

        protected void ddlAppID_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(ddlAppID.SelectedValue))
            {
                ClearAppointmentDetails();
                return;
            }

            LoadAppointmentDetails(ddlAppID.SelectedValue);
        }

        private void BindAppointmentIds(string selectAppId = null)
        {
            ddlAppID.Items.Clear();
            ddlAppID.Items.Add(new ListItem("-- Select Appointment ID --", string.Empty));

            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(
                       @"SELECT AppID, AppDate, Status
                         FROM AppointmentsTbl
                         WHERE Status = 'Pending' AND CAST(AppDate AS DATE) >= CAST(GETDATE() AS DATE)
                         ORDER BY AppDate DESC", conn))
            {
                cmd.CommandTimeout = 60;
                conn.Open();
                using (var reader = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (reader.Read())
                    {
                        var appId = reader["AppID"].ToString();
                        var appDate = reader["AppDate"] as DateTime?;
                        var item = new ListItem(appId, appId);

                        // Mark today's appointments visually (keep text unchanged)
                        if (appDate.HasValue && appDate.Value.Date == DateTime.Today)
                        {
                            item.Attributes["style"] = "background-color:#ede9fe;color:#4f46e5;font-weight:600;";
                        }

                        ddlAppID.Items.Add(item);
                    }
                }
            }

            if (!string.IsNullOrWhiteSpace(selectAppId))
            {
                var existing = ddlAppID.Items.FindByValue(selectAppId);
                if (existing == null)
                {
                    ddlAppID.Items.Add(new ListItem(selectAppId, selectAppId));
                    existing = ddlAppID.Items.FindByValue(selectAppId);
                }

                ddlAppID.ClearSelection();
                if (existing != null) existing.Selected = true;
            }
        }

        private void LoadAppointmentDetails(string appId)
        {
            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                // Fetch appointment details
                string sql = @"SELECT AppID, Cus_ID, AppDate, TotalAmount, AdvanceAmount
                    FROM AppointmentsTbl WHERE AppID = @AppID";
                string customerId = null;
                string customerName = null;
                DateTime? appDate = null;
                decimal totalAmount = 0m, advanceAmount = 0m;
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@AppID", appId);
                    using (var reader = cmd.ExecuteReader(CommandBehavior.SingleRow))
                    {
                        if (!reader.Read())
                        {
                            ClearAppointmentDetails();
                            return;
                        }
                        customerId = reader["Cus_ID"]?.ToString();
                        appDate = reader["AppDate"] as DateTime?;
                        totalAmount = reader["TotalAmount"] as decimal? ?? 0m;
                        advanceAmount = reader["AdvanceAmount"] as decimal? ?? 0m;
                    }
                }
                // Fetch customer name
                if (!string.IsNullOrWhiteSpace(customerId))
                {
                    using (var cmd = new SqlCommand("SELECT Title, CusFirst_Name, CusLast_Name FROM CustomerTbl WHERE Cus_ID = @CusID", conn))
                    {
                        cmd.Parameters.AddWithValue("@CusID", customerId);
                        using (var reader = cmd.ExecuteReader(CommandBehavior.SingleRow))
                        {
                            if (reader.Read())
                            {
                                var title = reader["Title"]?.ToString();
                                var first = reader["CusFirst_Name"]?.ToString();
                                var last = reader["CusLast_Name"]?.ToString();
                                customerName = string.Join(" ", new[] { title, first, last }.Where(p => !string.IsNullOrWhiteSpace(p)).Select(p => p.Trim()));
                            }
                        }
                    }
                }
                txtAppDate.Text = appDate?.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) ?? string.Empty;
                hfCusID.Value = customerId ?? string.Empty;
                SetDropDownSelection(ddlCustomer, customerId, customerName);
                txtAdvancePayment.Text = $"Rs. {advanceAmount:N2}";
                txtTotalAmount.Text = totalAmount.ToString("N2");
                txtTotalDiscount.Text = "0.00";
                txtNetAmount.Text = totalAmount.ToString("N2");
                txtNetValue.Text = (totalAmount - advanceAmount).ToString("N2");
                // Fetch services with assigned employee names from AppointmentServiceTbl
                var serviceTable = CreateServiceTableSchema();
                using (var cmd = new SqlCommand(@"
                    SELECT ast.Service_ID, s.Service_Name, ast.PriceAtTime,
                           ISNULL(NULLIF(LTRIM(RTRIM(
                               ISNULL(e.Title + ' ', '') + ISNULL(e.EmpFirst_Name, '') + ' ' + ISNULL(e.EmpLast_Name, '')
                           )), ''), '-') AS EmployeeName
                    FROM AppointmentServiceTbl ast
                    INNER JOIN ServiceTbl s ON ast.Service_ID = s.Service_ID
                    LEFT JOIN EmpTbl e ON ast.Emp_ID = e.Emp_ID
                    WHERE ast.AppID = @AppID", conn))
                {
                    cmd.Parameters.AddWithValue("@AppID", appId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var price = reader["PriceAtTime"] as decimal? ?? 0m;
                            var row = serviceTable.NewRow();
                            row["Service_ID"] = reader["Service_ID"]?.ToString();
                            row["Service_Name"] = reader["Service_Name"]?.ToString();
                            row["Price"] = price;
                            row["Discount"] = 0m;
                            row["DiscountedPrice"] = price;
                            row["DisplayDiscountAmount"] = "Rs. 0.00";
                            row["IsDiscountApplied"] = false;
                            row["EmployeeName"] = reader["EmployeeName"]?.ToString() ?? "-";
                            serviceTable.Rows.Add(row);
                        }
                    }
                }
                SaveServicesToViewState(serviceTable);
                UpdateServiceRepeater(serviceTable, advanceAmount);
                upAppointment.Update();
                upServices.Update();
            }
        }

        private void BindAppointmentServices(string appId, decimal advanceAmount, string servicesColumn = null)
        {
            var serviceNames = GetAppointmentServiceNames(appId, servicesColumn);
            var serviceTable = GetServiceDetails(serviceNames);

            SaveServicesToViewState(serviceTable);
            UpdateServiceRepeater(serviceTable, advanceAmount);
        }

        private IList<string> GetAppointmentServiceNames(string appId, string servicesColumn = null)
        {
            var services = new List<string>();
            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(
                       @"SELECT DISTINCT s.Service_Name
                         FROM AppointmentServiceTbl ast
                         INNER JOIN ServiceTbl s ON ast.Service_ID = s.Service_ID
                         WHERE ast.AppID = @AppID", conn))
            {
                cmd.Parameters.AddWithValue("@AppID", appId);
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var name = reader["Service_Name"]?.ToString();
                        if (!string.IsNullOrWhiteSpace(name))
                            services.Add(name);
                    }
                }
            }

            return services;
        }

        private static DataTable CreateServiceTableSchema()
        {
            var table = new DataTable();
            table.Columns.Add("Service_ID", typeof(string));
            table.Columns.Add("Service_Name", typeof(string));
            table.Columns.Add("Price", typeof(decimal));
            table.Columns.Add("Discount", typeof(decimal));
            table.Columns.Add("DiscountedPrice", typeof(decimal));
            table.Columns.Add("DisplayDiscountAmount", typeof(string));
            table.Columns.Add("IsDiscountApplied", typeof(bool));
            table.Columns.Add("EmployeeName", typeof(string));
            return table;
        }

        private DataTable GetServiceDetails(ICollection<string> serviceNames)
        {
            var table = CreateServiceTableSchema();

            if (serviceNames == null || serviceNames.Count == 0)
            {
                return table;
            }

            var parameterNames = serviceNames
                .Select((_, index) => $"@svc{index}")
                .ToArray();

            var query =
                $"SELECT Service_ID, Service_Name, Price FROM ServiceTbl WHERE Service_Name IN ({string.Join(",", parameterNames)})";

            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(query, conn))
            {
                var index = 0;
                foreach (var name in serviceNames)
                {
                    cmd.Parameters.AddWithValue(parameterNames[index], name);
                    index++;
                }

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var price = reader["Price"] as decimal? ?? 0m;
                        var row = table.NewRow();
                        row["Service_ID"] = reader["Service_ID"]?.ToString();
                        row["Service_Name"] = reader["Service_Name"]?.ToString();
                        row["Price"] = price;
                        row["Discount"] = 0m;
                        row["DiscountedPrice"] = price;
                        row["DisplayDiscountAmount"] = "Rs. 0.00";
                        row["IsDiscountApplied"] = false;
                        row["EmployeeName"] = "-";
                        table.Rows.Add(row);
                    }
                }
            }

            foreach (var missingName in serviceNames.Where(name =>
                         !table.AsEnumerable().Any(r =>
                             string.Equals(r.Field<string>("Service_Name"), name, StringComparison.OrdinalIgnoreCase))))
            {
                var row = table.NewRow();
                row["Service_ID"] = "0";
                row["Service_Name"] = missingName;
                row["Price"] = 0m;
                row["Discount"] = 0m;
                row["DiscountedPrice"] = 0m;
                row["DisplayDiscountAmount"] = "Rs. 0.00";
                row["IsDiscountApplied"] = false;
                row["EmployeeName"] = "-";
                table.Rows.Add(row);
            }

            return table;
        }

        protected void ddlCustomer_SelectedIndexChanged(object sender, EventArgs e)
        {
        }

        protected void btnAddCustomer_Click(object sender, EventArgs e)
        {
            Response.Redirect("Customers.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void rptServices_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            var command = e.CommandName ?? string.Empty;
            var serviceId = e.CommandArgument as string;

            if (string.Equals(command, "Remove", StringComparison.OrdinalIgnoreCase))
            {
                if (string.IsNullOrWhiteSpace(serviceId))
                {
                    return;
                }

                var table = GetServicesFromViewState();
                var row = table.AsEnumerable().FirstOrDefault(r =>
                    string.Equals(r.Field<string>("Service_ID"), serviceId, StringComparison.OrdinalIgnoreCase));

                if (row != null)
                {
                    table.Rows.Remove(row);
                    SaveServicesToViewState(table);
                    UpdateServiceRepeater(table, GetAdvanceAmount());
                }

                return;
            }

            if (!string.Equals(command, "ApplyDiscount", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            var services = GetServicesFromViewState();
            if (string.IsNullOrWhiteSpace(serviceId))
            {
                return;
            }

            var discountRow = services.AsEnumerable().FirstOrDefault(r =>
                string.Equals(r.Field<string>("Service_ID"), serviceId, StringComparison.OrdinalIgnoreCase));

            if (discountRow == null)
            {
                return;
            }

            var txtDiscount = e.Item.FindControl("txtDiscount") as TextBox;
            if (txtDiscount == null)
            {
                return;
            }

            decimal discountPercent;
            if (!decimal.TryParse(txtDiscount.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out discountPercent))
            {
                discountPercent = 0m;
            }

            if (discountPercent < 0m)
            {
                discountPercent = 0m;
            }

            if (discountPercent > 100m)
            {
                discountPercent = 100m;
            }

            var price = discountRow.Field<decimal>("Price");
            var discountAmount = Math.Round(price * discountPercent / 100m, 2, MidpointRounding.AwayFromZero);
            var discountedPrice = Math.Round(price - discountAmount, 2, MidpointRounding.AwayFromZero);

            discountRow["Discount"] = discountPercent;
            discountRow["DiscountedPrice"] = discountedPrice;
            discountRow["DisplayDiscountAmount"] = $"Rs. {discountAmount:N2}";
            discountRow["IsDiscountApplied"] = true;

            SaveServicesToViewState(services);
            UpdateServiceRepeater(services, GetAdvanceAmount());
        }

        protected void rptServices_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem)
            {
                return;
            }

            var dataRowView = e.Item.DataItem as DataRowView;
            if (dataRowView == null)
            {
                return;
            }

            var btnApply = e.Item.FindControl("btnApplyDiscount") as Button;
            if (btnApply != null)
            {
                var isApplied = dataRowView.Row.Field<bool>("IsDiscountApplied");
                btnApply.Enabled = !isApplied;
            }
        }

        protected void btnAddService_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(ddlAddService.SelectedValue))
            {
                return;
            }

            var serviceId = ddlAddService.SelectedValue;
            var serviceName = ddlAddService.SelectedItem.Text;
            var table = GetServicesFromViewState();

            var existingRow = table.AsEnumerable().FirstOrDefault(r =>
                string.Equals(r.Field<string>("Service_ID"), serviceId, StringComparison.OrdinalIgnoreCase));

            if (existingRow != null)
            {
                UpdateServiceRepeater(table, GetAdvanceAmount());
                ddlAddService.ClearSelection();
                return;
            }

            var price = 0m;
            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(
                       "SELECT Service_ID, Service_Name, Price FROM ServiceTbl WHERE Service_ID = @ServiceId", conn))
            {
                cmd.Parameters.AddWithValue("@ServiceId", serviceId);
                conn.Open();

                using (var reader = cmd.ExecuteReader(CommandBehavior.SingleRow))
                {
                    if (reader.Read())
                    {
                        price = reader["Price"] as decimal? ?? 0m;
                        serviceName = reader["Service_Name"]?.ToString() ?? serviceName;
                    }
                }
            }

            var row = table.NewRow();
            row["Service_ID"] = serviceId;
            row["Service_Name"] = serviceName;
            row["Price"] = price;
            row["Discount"] = 0m;
            row["DiscountedPrice"] = price;
            row["DisplayDiscountAmount"] = "Rs. 0.00";
            row["IsDiscountApplied"] = false;
            row["EmployeeName"] = ddlAddServiceEmployee.SelectedItem != null && !string.IsNullOrWhiteSpace(ddlAddServiceEmployee.SelectedValue)
                ? ddlAddServiceEmployee.SelectedItem.Text
                : "-";
            table.Rows.Add(row);

            SaveServicesToViewState(table);
            UpdateServiceRepeater(table, GetAdvanceAmount());

            ddlAddService.ClearSelection();
        }

        private DataTable GetServicesFromViewState()
        {
            var table = ViewState[ServicesViewStateKey] as DataTable;
            return table ?? CreateServiceTableSchema();
        }

        private void SaveServicesToViewState(DataTable table)
        {
            ViewState[ServicesViewStateKey] = table;
        }

        private void UpdateServiceRepeater(DataTable serviceTable, decimal advanceAmount)
        {
            rptServices.DataSource = serviceTable;
            rptServices.DataBind();

            var grossTotal = serviceTable.AsEnumerable().Sum(row => row.Field<decimal>("Price"));
            var netTotal = serviceTable.AsEnumerable().Sum(row => row.Field<decimal>("DiscountedPrice"));
            var totalDiscount = grossTotal - netTotal;

            txtTotalAmount.Text = grossTotal.ToString("N2");
            txtTotalDiscount.Text = totalDiscount.ToString("N2");
            txtNetAmount.Text = netTotal.ToString("N2");
            txtNetValue.Text = (netTotal - advanceAmount).ToString("N2");

            upServices.Update();
        }

        private decimal GetAdvanceAmount()
        {
            var text = (txtAdvancePayment.Text ?? string.Empty)
                .Replace("Rs.", string.Empty)
                .Trim();

            decimal amount;
            if (decimal.TryParse(text, NumberStyles.AllowDecimalPoint | NumberStyles.AllowThousands, CultureInfo.InvariantCulture, out amount))
            {
                return amount;
            }

            return 0m;
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnApplyDiscountTotal_Click(object sender, EventArgs e)
        {
            var table = GetServicesFromViewState();
            if (table.Rows.Count == 0)
            {
                return;
            }

            decimal discountPercent;
            if (!decimal.TryParse(txtDiscountTotal.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out discountPercent))
            {
                discountPercent = 0m;
            }

            if (discountPercent < 0m)
            {
                discountPercent = 0m;
            }

            if (discountPercent > 100m)
            {
                discountPercent = 100m;
            }

            var grossTotal = table.AsEnumerable().Sum(row => row.Field<decimal>("Price"));
            var netBeforeExtra = table.AsEnumerable().Sum(row => row.Field<decimal>("DiscountedPrice"));

            var extraDiscount = Math.Round(netBeforeExtra * discountPercent / 100m, 2, MidpointRounding.AwayFromZero);
            var netAfter = Math.Round(netBeforeExtra - extraDiscount, 2, MidpointRounding.AwayFromZero);

            var perServiceDiscountTotal = Math.Round(grossTotal - netBeforeExtra, 2, MidpointRounding.AwayFromZero);

            txtTotalAmount.Text = grossTotal.ToString("N2");
            txtTotalDiscount.Text = perServiceDiscountTotal.ToString("N2");
            txtNetAmount.Text = netAfter.ToString("N2");
            txtNetValue.Text = (netAfter - GetAdvanceAmount()).ToString("N2");

            btnApplyDiscountTotal.Enabled = false;
            upServices.Update();
        }

        protected void btnGetBalance_Click(object sender, EventArgs e)
        {
            if (TryCalculateAndSetBalance())
            {
                upServices.Update();
            }
        }

        protected void btnGenerateInvoice_Click(object sender, EventArgs e)
        {
            SaveInvoice();
        }

        private void SaveInvoice()
        {
            if (!Page.IsValid)
            {
                return;
            }

            var services = GetServicesFromViewState();
            if (services.Rows.Count == 0)
            {
                ShowClientMessage("Please add at least one service before generating an invoice.");
                return;
            }

            var customerName = ddlCustomer.SelectedItem != null ? ddlCustomer.SelectedItem.Text : string.Empty;
            if (string.IsNullOrWhiteSpace(customerName))
            {
                ShowClientMessage("Customer is required.");
                return;
            }

            var paymentMethod = ddlPaymentMethod.SelectedValue ?? string.Empty;
            if (string.IsNullOrWhiteSpace(paymentMethod))
            {
                ShowClientMessage("Please select a payment method and enter amount given, then click Get Balance.");
                return;
            }

            var amountGivenText = txtAmountGiven.Text ?? string.Empty;
            decimal amountGiven;
            if (!decimal.TryParse(amountGivenText, NumberStyles.Number, CultureInfo.InvariantCulture, out amountGiven))
            {
                ShowClientMessage("Please enter a valid amount given, then click Get Balance.");
                return;
            }

            if (string.IsNullOrWhiteSpace(txtBalance.Text))
            {
                if (!TryCalculateAndSetBalance())
                {
                    ShowClientMessage("Please click Get Balance before generating the invoice.");
                    return;
                }
            }

            var invoiceId = txtInvoiceNo.Text ?? string.Empty;

            DateTime invoiceDate;
            if (!DateTime.TryParseExact(txtInvoiceDate.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out invoiceDate))
            {
                invoiceDate = DateTime.Today;
            }

            var grossTotal = services.AsEnumerable().Sum(r => r.Field<decimal>("Price"));
            var netBeforeExtra = services.AsEnumerable().Sum(r => r.Field<decimal>("DiscountedPrice"));
            var perServiceDiscountTotal = grossTotal - netBeforeExtra;

            var additionalDiscountPercent = ClampPercent(ParseDecimal(txtDiscountTotal.Text));
            var additionalDiscountValue = Math.Round(netBeforeExtra * additionalDiscountPercent / 100m, 2, MidpointRounding.AwayFromZero);
            var netAmount = Math.Round(netBeforeExtra - additionalDiscountValue, 2, MidpointRounding.AwayFromZero);

            var advancePayment = GetAdvanceAmount();
            var netPayable = Math.Round(netAmount - advancePayment, 2, MidpointRounding.AwayFromZero);
            if (netPayable < 0m)
            {
                netPayable = 0m;
            }

            decimal cashPayment = 0m, cardPayment = 0m;
            if (string.Equals(paymentMethod, "Cash", StringComparison.OrdinalIgnoreCase))
            {
                cashPayment = amountGiven;
            }
            else if (string.Equals(paymentMethod, "Card", StringComparison.OrdinalIgnoreCase))
            {
                cardPayment = amountGiven;
            }

            if ((cashPayment + cardPayment) < netPayable)
            {
                ShowClientMessage($"Amount given must be at least the net payable (Rs. {netPayable:N2}).");
                return;
            }

            var balance = Math.Round((cashPayment + cardPayment) - netPayable, 2, MidpointRounding.AwayFromZero);
            if (balance < 0m)
            {
                balance = 0m;
            }

            var selectedAppId = ddlAppID.SelectedValue;

            using (var conn = new SqlConnection(_connectionString))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        const string insertInvoiceSql = @"
INSERT INTO InvoiceTbl
(InvoiceID, InvoiceDate, AppID, GrossTotal, DiscountTotal, NetAmount, AdditionalDiscountValue, AdvancePayment, NetPayable, PaymentMethod, CashPaymentValue, CardPaymentValue, Balance)
VALUES
(@InvoiceID, @InvoiceDate, @AppID, @GrossTotal, @DiscountTotal, @NetAmount, @AdditionalDiscountValue, @AdvancePayment, @NetPayable, @PaymentMethod, @CashPaymentValue, @CardPaymentValue, @Balance);";

                        using (var cmd = new SqlCommand(insertInvoiceSql, conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@InvoiceID", invoiceId);
                            cmd.Parameters.AddWithValue("@InvoiceDate", invoiceDate);
                            cmd.Parameters.AddWithValue("@AppID", string.IsNullOrWhiteSpace(selectedAppId) ? (object)DBNull.Value : selectedAppId);
                            cmd.Parameters.AddWithValue("@GrossTotal", grossTotal);
                            cmd.Parameters.AddWithValue("@DiscountTotal", perServiceDiscountTotal);
                            cmd.Parameters.AddWithValue("@NetAmount", netAmount);
                            cmd.Parameters.AddWithValue("@AdditionalDiscountValue", additionalDiscountValue);
                            cmd.Parameters.AddWithValue("@AdvancePayment", advancePayment);
                            cmd.Parameters.AddWithValue("@NetPayable", netPayable);
                            cmd.Parameters.AddWithValue("@PaymentMethod", paymentMethod);
                            cmd.Parameters.AddWithValue("@CashPaymentValue", cashPayment);
                            cmd.Parameters.AddWithValue("@CardPaymentValue", cardPayment);
                            cmd.Parameters.AddWithValue("@Balance", balance);

                            cmd.ExecuteNonQuery();
                        }

                        if (!string.IsNullOrWhiteSpace(selectedAppId))
                        {
                            const string updateAppointmentSql = "UPDATE AppointmentsTbl SET Status = 'Done' WHERE AppID = @AppID";
                            using (var cmdUpdate = new SqlCommand(updateAppointmentSql, conn, tx))
                            {
                                cmdUpdate.Parameters.AddWithValue("@AppID", selectedAppId);
                                cmdUpdate.ExecuteNonQuery();
                            }
                        }

                        const string insertServiceSql = @"
INSERT INTO InvoiceServicesTbl
(InvoiceID, Service_ID, ServiceName, Price, DiscountValue, DiscountType, Total)
VALUES
(@InvoiceID, @Service_ID, @ServiceName, @Price, @DiscountValue, @DiscountType, @Total);";

                        foreach (DataRow row in services.Rows)
                        {
                            var price = row.Field<decimal>("Price");
                            var discounted = row.Field<decimal>("DiscountedPrice");
                            var discountVal = price - discounted;
                            var discountPct = row.Field<decimal>("Discount");
                            var serviceId = row.Field<string>("Service_ID") ?? string.Empty;
                            var serviceName = row.Field<string>("Service_Name") ?? string.Empty;
                            var discountType = "Percent"; // since discount is percentage-based

                            using (var cmd = new SqlCommand(insertServiceSql, conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@InvoiceID", invoiceId);
                                cmd.Parameters.AddWithValue("@Service_ID", serviceId);
                                cmd.Parameters.AddWithValue("@ServiceName", serviceName);
                                cmd.Parameters.AddWithValue("@Price", price);
                                cmd.Parameters.AddWithValue("@DiscountValue", discountVal);
                                cmd.Parameters.AddWithValue("@DiscountType", discountType);
                                cmd.Parameters.AddWithValue("@Total", discounted);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tx.Commit();

                        Response.Redirect(
                            "BillPrint.aspx?invoiceId=" + HttpUtility.UrlEncode(invoiceId),
                            false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        protected void ResetInvoiceForm()
        {
            BindAppointmentIds();
            BindAdditionalServices();

            ddlAppID.ClearSelection();
            ddlCustomer.ClearSelection();
            ddlPaymentMethod.ClearSelection();
            ddlAddService.ClearSelection();
            ddlAddServiceEmployee.Items.Clear();
            ddlAddServiceEmployee.Items.Add(new ListItem("-- Select Employee --", string.Empty));

            txtAppDate.Text = string.Empty;
            txtDiscountTotal.Text = string.Empty;
            txtAmountGiven.Text = string.Empty;
            txtBalance.Text = "0.00";
            hfCusID.Value = string.Empty;
            txtAdvancePayment.Text = "Rs. 0.00";

            var emptyTable = CreateServiceTableSchema();
            SaveServicesToViewState(emptyTable);
            UpdateServiceRepeater(emptyTable, 0m);

            txtInvoiceNo.Text = GetNextInvoiceNumber();
            txtInvoiceDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            btnApplyDiscountTotal.Enabled = true;

            upAppointment.Update();
            upServices.Update();
        }

        private static decimal ClampPercent(decimal value)
        {
            if (value < 0m) return 0m;
            if (value > 100m) return 100m;
            return value;
        }

        private void ClearAppointmentDetails()
        {
            txtAppDate.Text = string.Empty;
            ddlCustomer.ClearSelection();
            hfCusID.Value = string.Empty;
            txtAdvancePayment.Text = "Rs. 0.00";
            txtTotalAmount.Text = "0.00";
            txtTotalDiscount.Text = "0.00";
            txtNetAmount.Text = "0.00";
            txtNetValue.Text = "0.00";
            var emptyTable = CreateServiceTableSchema();
            SaveServicesToViewState(emptyTable);
            UpdateServiceRepeater(emptyTable, 0m);
            upAppointment.Update();
            upServices.Update();
        }

        private int GetNextInvoiceServiceNumber(SqlConnection conn, SqlTransaction tx)
        {
            return GetNextSequentialId(conn, tx, "InvoiceServicesTbl", "InvoiceServID", InvoiceServicePrefix);
        }

        private static decimal ParseDecimal(string text)
        {
            decimal value;
            if (!decimal.TryParse(text, NumberStyles.Number, CultureInfo.InvariantCulture, out value))
            {
                return 0m;
            }
            return value;
        }

        private static void SetDropDownSelection(DropDownList ddl, string value, string text)
        {
            if (ddl == null)
            {
                return;
            }

            if (!string.IsNullOrEmpty(value))
            {
                var byValue = ddl.Items.FindByValue(value);
                if (byValue != null)
                {
                    ddl.ClearSelection();
                    byValue.Selected = true;
                    return;
                }
            }

            if (string.IsNullOrWhiteSpace(text))
            {
                return;
            }

            // Try exact text
            var exact = ddl.Items.Cast<ListItem>()
                .FirstOrDefault(i => string.Equals(i.Text, text, StringComparison.OrdinalIgnoreCase));
            if (exact != null)
            {
                ddl.ClearSelection();
                exact.Selected = true;
                return;
            }

            // Fallback: normalize names (strip titles, ignore case) and try match/contains
            var target = NormalizeName(text);
            var normalizedMatch = ddl.Items.Cast<ListItem>()
                .FirstOrDefault(i => string.Equals(NormalizeName(i.Text), target, StringComparison.OrdinalIgnoreCase))
                ?? ddl.Items.Cast<ListItem>()
                    .FirstOrDefault(i => NormalizeName(i.Text).Contains(target));

            if (normalizedMatch != null)
            {
                ddl.ClearSelection();
                normalizedMatch.Selected = true;
                return;
            }

            // Final fallback: add the name if it is missing in the list so it can render
            var injected = new ListItem(text.Trim(), value ?? text.Trim());
            ddl.Items.Add(injected);
            ddl.ClearSelection();
            injected.Selected = true;
        }

        private static string NormalizeName(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return string.Empty;
            }

            var prefixes = new[] { "mr", "ms", "mrs", "miss", "dr" };
            var parts = name.Trim()
                .Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(p => p.Trim())
                .ToList();

            if (parts.Count > 0 && prefixes.Any(p => string.Equals(parts[0], p, StringComparison.OrdinalIgnoreCase)))
            {
                parts.RemoveAt(0);
            }

            return string.Join(" ", parts).ToLowerInvariant();
        }

        // Add this method to your Invoice class
        private void ShowClientMessage(string message)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alertMessage", $"alert('{message.Replace("'", "\\'")}');", true);
        }

        // Add this method to your Invoice class
        private bool TryCalculateAndSetBalance()
        {
            decimal netAmount;
            if (!decimal.TryParse(txtNetAmount.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out netAmount))
            {
                netAmount = 0m;
            }

            decimal advance = GetAdvanceAmount();
            decimal netPayable = Math.Round(netAmount - advance, 2, MidpointRounding.AwayFromZero);
            if (netPayable < 0m)
            {
                netPayable = 0m;
            }

            decimal amountGiven;
            if (!decimal.TryParse(txtAmountGiven.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out amountGiven))
            {
                amountGiven = 0m;
            }

            decimal balance = Math.Round(amountGiven - netPayable, 2, MidpointRounding.AwayFromZero);
            if (balance < 0m)
            {
                balance = 0m;
            }

            txtBalance.Text = balance.ToString("N2");
            return true;
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ResetInvoiceForm();
        }
    }
}