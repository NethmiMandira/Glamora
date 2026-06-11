using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class ReportGenerating : Page
    {
        private readonly string connectionString =
            "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        // server controls added in markup
        protected global::System.Web.UI.WebControls.DropDownList ddlReportType;
        protected global::System.Web.UI.WebControls.Panel pnlServicePerf;
        protected global::System.Web.UI.WebControls.Panel pnlEmployeePerf;
        protected global::System.Web.UI.WebControls.Panel pnlRevenue;
        protected global::System.Web.UI.WebControls.GridView gvServicePerf;
        protected global::System.Web.UI.WebControls.GridView gvEmployeePerf;
        protected global::System.Web.UI.WebControls.GridView gvRevenue;
        protected global::System.Web.UI.WebControls.Panel pnlCustomerReport;
        protected global::System.Web.UI.WebControls.GridView gvCustomerReport;
        protected global::System.Web.UI.WebControls.Panel pnlReportResults;
        protected global::System.Web.UI.WebControls.Label lblCriteria;
        protected global::System.Web.UI.WebControls.HiddenField hfLogoUrl;
        protected global::System.Web.UI.WebControls.HiddenField hfFooterText;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCustomers();
                BindEmployees();
                // leave dropdown at its first item ("Select Report type") by default
                // do not force a specific report type here so the UI shows the placeholder
                if (ddlReportType != null && ddlReportType.Items.Count > 0)
                    ddlReportType.SelectedIndex = 0;
                UpdatePanelsForReportType();
                // load settings (logo/footer) from DB to expose to client-side printable view
                try
                {
                    using (var conn = new SqlConnection(connectionString))
                    using (var cmd = new SqlCommand("SELECT TOP 1 LogoURL, FooterText FROM SettingTbl", conn))
                    {
                        conn.Open();
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                if (hfLogoUrl != null)
                                {
                                    var raw = reader["LogoURL"] != DBNull.Value ? reader["LogoURL"].ToString() : string.Empty;
                                    if (!string.IsNullOrWhiteSpace(raw))
                                    {
                                        // if full URL provided, keep it; otherwise convert to app-relative URL
                                        if (raw.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || raw.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                                            hfLogoUrl.Value = raw;
                                        else
                                            hfLogoUrl.Value = ResolveUrl(raw);
                                    }
                                    else
                                    {
                                        hfLogoUrl.Value = string.Empty;
                                    }

            
                                }
                                if (hfFooterText != null)
                                    hfFooterText.Value = reader["FooterText"] != DBNull.Value ? reader["FooterText"].ToString() : string.Empty;
                            }
                        }
                    }
                }
                catch
                {
                    // ignore and leave hidden fields empty
                }
            }
        }

        protected void btnExportPdfServer_Click(object sender, EventArgs e)
        {
            // trigger client-side print (user can save as PDF)
            string script = "window.setTimeout(function(){ if(typeof(printReport) === 'function') printReport(); }, 200);";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "exportPdf", script, true);
        }

        protected void ddlReportType_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Do not auto-generate when the report type changes. User must click Generate.
            UpdatePanelsForReportType();
        }

        private void UpdatePanelsForReportType()
        {
            // Do not show any report panels just because the dropdown changed.
            // Panels will be shown only when the user clicks Generate.
            try
            {
                if (pnlServicePerf != null) pnlServicePerf.Visible = false;
                if (pnlEmployeePerf != null) pnlEmployeePerf.Visible = false;
                if (pnlRevenue != null) pnlRevenue.Visible = false;
                if (pnlCustomerReport != null) pnlCustomerReport.Visible = false;
                if (gvReport != null) gvReport.Visible = false;
                // clear any server-side marker used by client script
                try { if (pnlReportResults != null) pnlReportResults.Attributes.Remove("data-server-visible"); } catch { }
            }
            catch
            {
                // ignore layout errors
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        private void BindCustomers()
        {
            ddlCustomer.Items.Clear();
            ddlCustomer.Items.Add(new ListItem("-- All Customers --", ""));

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(
                "SELECT Cus_ID, CONCAT(Title, ' ', CusFirst_Name, ' ', CusLast_Name) AS FullName FROM CustomerTbl ORDER BY CusFirst_Name", conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ddlCustomer.Items.Add(new ListItem(
                            reader["FullName"].ToString(),
                            reader["Cus_ID"].ToString()));
                    }
                }
            }
        }

        private void BindEmployees()
        {
            ddlEmployee.Items.Clear();
            ddlEmployee.Items.Add(new ListItem("-- All Employees --", ""));

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(
                "SELECT Emp_ID, CONCAT(Title, ' ', EmpFirst_Name, ' ', EmpLast_Name) AS FullName FROM EmpTbl ORDER BY EmpFirst_Name", conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ddlEmployee.Items.Add(new ListItem(
                            reader["FullName"].ToString(),
                            reader["Emp_ID"].ToString()));
                    }
                }
            }
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            var type = ddlReportType != null ? ddlReportType.SelectedValue : "Appointment";
            lblMessage.Text = string.Empty;
            // hide all panels first; we'll show the requested one after generation
            try
            {
                if (pnlServicePerf != null) pnlServicePerf.Visible = false;
                if (pnlEmployeePerf != null) pnlEmployeePerf.Visible = false;
                if (pnlRevenue != null) pnlRevenue.Visible = false;
                if (pnlCustomerReport != null) pnlCustomerReport.Visible = false;
                if (gvReport != null) gvReport.Visible = false;
            }
            catch { }
            // show selected criteria summary on the page
            if (lblCriteria != null) lblCriteria.Text = BuildCriteriaString();
            if (type == "Appointment")
            {
                // bind appointment summary per-date
                BindAppointmentSummary();
                // show appointment panels (status summary removed for Appointment report)
                if (gvReport != null) gvReport.Visible = true;
                if (pnlReportResults != null)
                {
                    pnlReportResults.Visible = true;
                    try { pnlReportResults.Attributes["data-server-visible"] = "1"; } catch { }
                }
            }
            else if (type == "Customer")
            {
                BindCustomerReport();
                // show customer panel only
                if (pnlCustomerReport != null) pnlCustomerReport.Visible = true;
                if (gvReport != null) { gvReport.DataSource = null; gvReport.DataBind(); gvReport.Visible = false; }
            }
            else if (type == "ServicePerformance")
            {
                BindServicePerformance();
                if (pnlServicePerf != null) pnlServicePerf.Visible = true;
                if (gvReport != null) { gvReport.DataSource = null; gvReport.DataBind(); gvReport.Visible = false; }
            }
            else if (type == "EmployeePerformance")
            {
                BindEmployeePerformance();
                if (pnlEmployeePerf != null) pnlEmployeePerf.Visible = true;
                if (gvReport != null) { gvReport.DataSource = null; gvReport.DataBind(); gvReport.Visible = false; }
            }
            else if (type == "Revenue")
            {
                BindRevenueReport();
                if (pnlRevenue != null) pnlRevenue.Visible = true;
                if (gvReport != null) { gvReport.DataSource = null; gvReport.DataBind(); gvReport.Visible = false; }
                try { if (pnlReportResults != null) pnlReportResults.Attributes.Remove("data-server-visible"); } catch { }
            }
            // ensure criteria label is visible/updated after generation
            if (lblCriteria != null && string.IsNullOrWhiteSpace(lblCriteria.Text)) lblCriteria.Text = BuildCriteriaString();
        }

        private string BuildCriteriaString()
        {
            try
            {
                var parts = new System.Collections.Generic.List<string>();
                DateTime dtFrom, dtTo;
                if (DateTime.TryParse(txtFrom.Text, out dtFrom)) parts.Add("From: " + dtFrom.ToString("yyyy-MM-dd"));
                if (DateTime.TryParse(txtTo.Text, out dtTo)) parts.Add("To: " + dtTo.ToString("yyyy-MM-dd"));
                if (ddlCustomer != null && !string.IsNullOrWhiteSpace(ddlCustomer.SelectedValue)) parts.Add("Customer: " + ddlCustomer.SelectedItem.Text);
                if (ddlEmployee != null && !string.IsNullOrWhiteSpace(ddlEmployee.SelectedValue)) parts.Add("Employee: " + ddlEmployee.SelectedItem.Text);
                return parts.Count > 0 ? string.Join(" | ", parts) : string.Empty;
            }
            catch
            {
                return string.Empty;
            }
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            var type = ddlReportType != null ? ddlReportType.SelectedValue : "Appointment";
            if (type != "Appointment")
            {
                lblMessage.Text = "CSV export is only available for the Appointment report.";
                return;
            }

            DataTable dt = GetReportData();
            if (dt.Rows.Count == 0)
            {
                lblMessage.Text = "No records to export.";
                return;
            }

            var sb = new StringBuilder();

            // Header row
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                sb.Append(EscapeCsv(dt.Columns[i].ColumnName));
                if (i < dt.Columns.Count - 1) sb.Append(",");
            }
            sb.AppendLine();

            // Data rows
            foreach (DataRow row in dt.Rows)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    sb.Append(EscapeCsv(row[i] != null ? row[i].ToString() : ""));
                    if (i < dt.Columns.Count - 1) sb.Append(",");
                }
                sb.AppendLine();
            }

            Response.Clear();
            Response.ContentType = "text/csv";
            Response.AddHeader("Content-Disposition", "attachment; filename=GlamoraReport_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv");
            Response.Write(sb.ToString());
            Response.End();
        }

        private string EscapeCsv(string value)
        {
            if (string.IsNullOrEmpty(value)) return "";
            if (value.Contains(",") || value.Contains("\"") || value.Contains("\n"))
            {
                return "\"" + value.Replace("\"", "\"\"") + "\"";
            }
            return value;
        }

        private DataTable GetReportData()
        {
            string query = @"
                SELECT
                    a.AppID,
                    a.AppDate,
                    a.StartTime,
                    a.BookingDate,
                    inv.InvoiceID,
                    inv.InvoiceDate,
                    inv.GrossTotal,
                    inv.PaymentMethod,
                    inv.Balance AS InvoiceBalance,
                    CONCAT(c.Title, ' ', c.CusFirst_Name, ' ', c.CusLast_Name) AS CustomerName,
                    ISNULL(NULLIF(
                        (SELECT STUFF(COALESCE(
                            (SELECT DISTINCT ', ' + LTRIM(RTRIM(CONCAT(ISNULL(e2.Title, ''), ' ', e2.EmpFirst_Name, ' ', e2.EmpLast_Name)))
                             FROM AppointmentServiceTbl ast2
                             LEFT JOIN EmpTbl e2 ON ast2.Emp_ID = e2.Emp_ID
                             WHERE ast2.AppID = a.AppID AND e2.Emp_ID IS NOT NULL
                             FOR XML PATH(''), TYPE),
                            (SELECT CAST('' AS XML))).value('.', 'NVARCHAR(MAX)'), 1, 2, '')),
                    ''), 'Not Assigned') AS EmployeeName,
                    a.TotalAmount,
                    a.AdvanceAmount,
                    ISNULL(a.TotalAmount, 0) - ISNULL(a.AdvanceAmount, 0) AS Balance
                FROM AppointmentsTbl a
                LEFT JOIN CustomerTbl c ON a.Cus_ID = c.Cus_ID
                LEFT JOIN InvoiceTbl inv ON a.AppID = inv.AppID
                WHERE 1=1";

            DateTime dateFrom;
            DateTime dateTo;
            bool hasFrom = DateTime.TryParse(txtFrom.Text, out dateFrom);
            bool hasTo = DateTime.TryParse(txtTo.Text, out dateTo);

            if (hasFrom)
                query += " AND a.AppDate >= @DateFrom";
            if (hasTo)
                query += " AND a.AppDate <= @DateTo";
            if (!string.IsNullOrWhiteSpace(ddlCustomer.SelectedValue))
                query += " AND a.Cus_ID = @CusID";
            if (!string.IsNullOrWhiteSpace(ddlEmployee.SelectedValue))
                query += @" AND EXISTS (
                    SELECT 1 FROM AppointmentServiceTbl ast3
                    WHERE ast3.AppID = a.AppID AND ast3.Emp_ID = @EmpID
                )";

            query += " ORDER BY a.AppDate DESC, a.AppID DESC";

            using (var conn = new SqlConnection(connectionString))
            using (var da = new SqlDataAdapter(query, conn))
            {
                if (hasFrom)
                    da.SelectCommand.Parameters.AddWithValue("@DateFrom", dateFrom.Date);
                if (hasTo)
                    da.SelectCommand.Parameters.AddWithValue("@DateTo", dateTo.Date);
                if (!string.IsNullOrWhiteSpace(ddlCustomer.SelectedValue))
                    da.SelectCommand.Parameters.AddWithValue("@CusID", ddlCustomer.SelectedValue);
                if (!string.IsNullOrWhiteSpace(ddlEmployee.SelectedValue))
                    da.SelectCommand.Parameters.AddWithValue("@EmpID", ddlEmployee.SelectedValue);

                var dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        private void BindServicePerformance()
        {
            DateTime dateFrom, dateTo;
            bool hasFrom = DateTime.TryParse(txtFrom.Text, out dateFrom);
            bool hasTo = DateTime.TryParse(txtTo.Text, out dateTo);

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"SELECT isv.ServiceName AS ServiceName, COUNT(*) AS Bookings, ISNULL(SUM(isv.Total),0) AS Revenue
                                              FROM InvoiceServicesTbl isv
                                              LEFT JOIN InvoiceTbl i ON isv.InvoiceID = i.InvoiceID
                                              WHERE 1=1 " +
                                              (hasFrom ? " AND i.InvoiceDate >= @DateFrom" : "") +
                                              (hasTo ? " AND i.InvoiceDate <= @DateTo" : "") +
                                              " GROUP BY isv.ServiceName ORDER BY Revenue DESC", conn))
            {
                if (hasFrom) cmd.Parameters.AddWithValue("@DateFrom", dateFrom.Date);
                if (hasTo) cmd.Parameters.AddWithValue("@DateTo", dateTo.Date);
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                BindGridWithEmptyRow(gvServicePerf, dt);
            }
        }

        private void BindEmployeePerformance()
        {
            DateTime dateFrom, dateTo;
            bool hasFrom = DateTime.TryParse(txtFrom.Text, out dateFrom);
            bool hasTo = DateTime.TryParse(txtTo.Text, out dateTo);

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Detect which service identifier column exists in InvoiceServicesTbl and AppointmentServiceTbl
                string[] candidates = { "ServiceName", "Service", "Service_ID", "ServiceID", "Name" };
                string invoiceCol = null;
                string appointmentCol = null;

                // detect column in InvoiceServicesTbl
                using (var checkCmd = new SqlCommand(
                    "SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'InvoiceServicesTbl' AND COLUMN_NAME IN ('Service_ID','ServiceID','Service','ServiceName','Name') " +
                    "ORDER BY CASE WHEN COLUMN_NAME='Service_ID' THEN 1 WHEN COLUMN_NAME='ServiceID' THEN 2 WHEN COLUMN_NAME='Service' THEN 3 WHEN COLUMN_NAME='ServiceName' THEN 4 WHEN COLUMN_NAME='Name' THEN 5 ELSE 6 END", conn))
                {
                    var obj = checkCmd.ExecuteScalar();
                    if (obj != null && obj != DBNull.Value) invoiceCol = obj.ToString();
                }

                // detect column in AppointmentServiceTbl
                using (var checkCmd2 = new SqlCommand(
                    "SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'AppointmentServiceTbl' AND COLUMN_NAME IN ('Service_ID','ServiceID','Service','ServiceName','Name') " +
                    "ORDER BY CASE WHEN COLUMN_NAME='Service_ID' THEN 1 WHEN COLUMN_NAME='ServiceID' THEN 2 WHEN COLUMN_NAME='Service' THEN 3 WHEN COLUMN_NAME='ServiceName' THEN 4 WHEN COLUMN_NAME='Name' THEN 5 ELSE 6 END", conn))
                {
                    var obj2 = checkCmd2.ExecuteScalar();
                    if (obj2 != null && obj2 != DBNull.Value) appointmentCol = obj2.ToString();
                }

                // allow filtering by selected employee in UI
                bool hasEmployeeFilter = !string.IsNullOrWhiteSpace(ddlEmployee?.SelectedValue);

                // detect if InvoiceServicesTbl contains an employee identifier column (preferred for accurate revenue attribution)
                string invoiceEmpCol = null;
                using (var checkCmd3 = new SqlCommand(
                    "SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'InvoiceServicesTbl' AND COLUMN_NAME IN ('Emp_ID','EmpID','EmployeeID','Emp') " +
                    "ORDER BY CASE WHEN COLUMN_NAME='Emp_ID' THEN 1 WHEN COLUMN_NAME='EmpID' THEN 2 WHEN COLUMN_NAME='EmployeeID' THEN 3 WHEN COLUMN_NAME='Emp' THEN 4 ELSE 5 END", conn))
                {
                    var obj3 = checkCmd3.ExecuteScalar();
                    if (obj3 != null && obj3 != DBNull.Value) invoiceEmpCol = obj3.ToString();
                }

                // detect which column holds the monetary value in InvoiceServicesTbl (line total)
                string invoiceAmountCol = null;
                using (var checkCmd4 = new SqlCommand(
                    "SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'InvoiceServicesTbl' AND COLUMN_NAME IN ('Total','Amount','Price','ServiceTotal','ServicePrice','ServiceAmount','SubTotal','LineTotal') " +
                    "ORDER BY CASE WHEN COLUMN_NAME='Total' THEN 1 WHEN COLUMN_NAME='Amount' THEN 2 WHEN COLUMN_NAME='Price' THEN 3 WHEN COLUMN_NAME='ServiceTotal' THEN 4 WHEN COLUMN_NAME='ServicePrice' THEN 5 WHEN COLUMN_NAME='ServiceAmount' THEN 6 WHEN COLUMN_NAME='SubTotal' THEN 7 WHEN COLUMN_NAME='LineTotal' THEN 8 ELSE 9 END", conn))
                {
                    var obj4 = checkCmd4.ExecuteScalar();
                    if (obj4 != null && obj4 != DBNull.Value) invoiceAmountCol = obj4.ToString();
                }

                if (string.IsNullOrEmpty(invoiceCol) || string.IsNullOrEmpty(appointmentCol))
                {
                    // defensive: fail early with helpful message
                    throw new InvalidOperationException("Database schema mismatch: required service column not found in InvoiceServicesTbl and/or AppointmentServiceTbl.");
                }

                // escape/qualify the detected columns
                string isvCol = "isv.[" + invoiceCol.Replace("]", "]]") + "]";
                string astCol = "ast.[" + appointmentCol.Replace("]", "]]") + "]";

                // detect appointment-service monetary column (price at time)
                string appointmentAmountCol = null;
                using (var checkCmd5 = new SqlCommand(
                    "SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'AppointmentServiceTbl' AND COLUMN_NAME IN ('PriceAtTime','Price','Amount','ServicePrice','ServiceAmount','LineTotal') " +
                    "ORDER BY CASE WHEN COLUMN_NAME='PriceAtTime' THEN 1 WHEN COLUMN_NAME='Price' THEN 2 WHEN COLUMN_NAME='Amount' THEN 3 WHEN COLUMN_NAME='ServicePrice' THEN 4 WHEN COLUMN_NAME='ServiceAmount' THEN 5 WHEN COLUMN_NAME='LineTotal' THEN 6 ELSE 7 END", conn))
                {
                    var obj5 = checkCmd5.ExecuteScalar();
                    if (obj5 != null && obj5 != DBNull.Value) appointmentAmountCol = obj5.ToString();
                }

                // build a resilient join condition between invoice services and appointment services
                string invoiceToAstMatch = isvCol + " = " + astCol; // default: match on service id/name
                string isvAmt = null;
                string astAmt = null;
                if (!string.IsNullOrEmpty(invoiceAmountCol))
                    isvAmt = "ISNULL(isv.[" + invoiceAmountCol.Replace("]", "]]") + "],0)";
                if (!string.IsNullOrEmpty(appointmentAmountCol))
                    astAmt = "ISNULL(ast.[" + appointmentAmountCol.Replace("]", "]]") + "],0)";

                // prefer strict matching by service id; when price columns exist, require price match as well to avoid false positives
                if (!string.IsNullOrEmpty(isvAmt) && !string.IsNullOrEmpty(astAmt))
                {
                    invoiceToAstMatch = "(" + isvCol + " = " + astCol + " AND " + isvAmt + " = " + astAmt + ")";
                }

                // determine raw amount expressions for invoice-services and appointment-services
                string isvRaw = !string.IsNullOrEmpty(invoiceAmountCol)
                    ? "isv.[" + invoiceAmountCol.Replace("]", "]]") + "]"
                    : "isv.Total";
                string astRaw = !string.IsNullOrEmpty(appointmentAmountCol)
                    ? "ast.[" + appointmentAmountCol.Replace("]", "]]") + "]"
                    : "ast.PriceAtTime";

                // revenue expression: prefer invoice service amount when present, otherwise use appointment-service price
                string revenueExpr = "ISNULL(SUM(ISNULL(" + isvRaw + ", " + astRaw + ")),0)";

                // Deterministic mapping: for each appointment-service row (ast) attempt to find a single matching
                // invoice-service row (by InvoiceID and Service_ID) using OUTER APPLY. This avoids duplicate joins
                // where an invoice-service could match multiple ast rows. Revenue uses the invoice line Total when
                // present, otherwise falls back to the ast.PriceAtTime.
                string sql = @"
                    SELECT CONCAT(e.Title,' ',e.EmpFirst_Name,' ',e.EmpLast_Name) AS EmployeeName,
                           COUNT(DISTINCT ast.AppServiceID) AS ServicesDone,
                           ISNULL(SUM(ISNULL(isvMatch.Total, ast.PriceAtTime)),0) AS Revenue
                    FROM AppointmentServiceTbl ast
                    LEFT JOIN EmpTbl e ON ast.Emp_ID = e.Emp_ID
                    LEFT JOIN AppointmentsTbl a ON ast.AppID = a.AppID
                    LEFT JOIN InvoiceTbl inv ON a.AppID = inv.AppID
                    OUTER APPLY (
                        SELECT TOP 1 isv2.Total
                        FROM InvoiceServicesTbl isv2
                        WHERE isv2.InvoiceID = inv.InvoiceID AND isv2.Service_ID = ast.Service_ID
                        ORDER BY isv2.InvoiceServID
                    ) AS isvMatch
                    WHERE 1=1" +
                    (hasFrom ? " AND a.AppDate >= @DateFrom" : "") +
                    (hasTo ? " AND a.AppDate <= @DateTo" : "") +
                    (hasEmployeeFilter ? " AND ast.Emp_ID = @EmpID" : "") +
                    " GROUP BY CONCAT(e.Title,' ',e.EmpFirst_Name,' ',e.EmpLast_Name) ORDER BY Revenue DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (hasFrom) cmd.Parameters.AddWithValue("@DateFrom", dateFrom.Date);
                    if (hasTo) cmd.Parameters.AddWithValue("@DateTo", dateTo.Date);
                    if (hasEmployeeFilter) cmd.Parameters.AddWithValue("@EmpID", ddlEmployee.SelectedValue);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);
                    BindGridWithEmptyRow(gvEmployeePerf, dt);
                }
            }
        }

        private void BindRevenueReport()
        {
            DateTime dateFrom, dateTo;
            bool hasFrom = DateTime.TryParse(txtFrom.Text, out dateFrom);
            bool hasTo = DateTime.TryParse(txtTo.Text, out dateTo);

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"SELECT CAST(i.InvoiceDate AS DATE) AS [Date], ISNULL(SUM(i.GrossTotal),0) AS Revenue, ISNULL(SUM(i.AdvancePayment),0) AS Advance
                                              FROM InvoiceTbl i
                                              WHERE 1=1 " +
                                              (hasFrom ? " AND i.InvoiceDate >= @DateFrom" : "") +
                                              (hasTo ? " AND i.InvoiceDate <= @DateTo" : "") +
                                              " GROUP BY CAST(i.InvoiceDate AS DATE) ORDER BY [Date] DESC", conn))
            {
                if (hasFrom) cmd.Parameters.AddWithValue("@DateFrom", dateFrom.Date);
                if (hasTo) cmd.Parameters.AddWithValue("@DateTo", dateTo.Date);
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                BindGridWithEmptyRow(gvRevenue, dt);
            }
        }

        

        

        private void BindCustomerReport()
        {
            DateTime dateFrom, dateTo;
            bool hasFrom = DateTime.TryParse(txtFrom.Text, out dateFrom);
            bool hasTo = DateTime.TryParse(txtTo.Text, out dateTo);

            using (var conn = new SqlConnection(connectionString))
            {
                var sb = new StringBuilder();
                sb.AppendLine("SELECT c.Cus_ID AS CustomerID,");
                sb.AppendLine("       ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(ISNULL(c.Title,''),' ',c.CusFirst_Name,' ',c.CusLast_Name))),''),'Unknown') AS CustomerName,");
                sb.AppendLine("       COUNT(a.AppID) AS TotalVisits,");
                sb.AppendLine("       ISNULL(SUM(ISNULL(inv.GrossTotal, a.TotalAmount)),0) AS TotalRevenue,");
                sb.AppendLine("       ISNULL(SUM(ISNULL(a.AdvanceAmount,0)),0) AS TotalAdvance,");
                sb.AppendLine("       MAX(a.AppDate) AS LastVisit");
                sb.AppendLine("FROM CustomerTbl c");
                sb.AppendLine("LEFT JOIN AppointmentsTbl a ON a.Cus_ID = c.Cus_ID");
                sb.AppendLine("LEFT JOIN InvoiceTbl inv ON inv.AppID = a.AppID");
                sb.AppendLine("WHERE 1=1");

                if (hasFrom) sb.AppendLine(" AND a.AppDate >= @DateFrom");
                if (hasTo) sb.AppendLine(" AND a.AppDate <= @DateTo");
                if (!string.IsNullOrWhiteSpace(ddlCustomer.SelectedValue)) sb.AppendLine(" AND c.Cus_ID = @CusID");

                // include the customer id and the exact CustomerName expression used in SELECT
                sb.AppendLine("GROUP BY c.Cus_ID, ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(ISNULL(c.Title,''),' ',c.CusFirst_Name,' ',c.CusLast_Name))),''),'Unknown')");
                sb.AppendLine("ORDER BY TotalRevenue DESC");

                using (var cmd = new SqlCommand(sb.ToString(), conn))
                {
                    if (hasFrom) cmd.Parameters.AddWithValue("@DateFrom", dateFrom.Date);
                    if (hasTo) cmd.Parameters.AddWithValue("@DateTo", dateTo.Date);
                    if (!string.IsNullOrWhiteSpace(ddlCustomer.SelectedValue))
                        cmd.Parameters.AddWithValue("@CusID", ddlCustomer.SelectedValue);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);
                    BindGridWithEmptyRow(gvCustomerReport, dt);
                }
            }
        }

        // Helper: bind a DataTable to a GridView but ensure the grid renders header and empty cells when no data.
        private void BindGridWithEmptyRow(GridView gv, DataTable dt)
        {
            if (gv == null) return;
            bool wasEmpty = (dt == null) || (dt.Rows.Count == 0);
            // If there are no columns but the GridView has defined columns, create matching columns in the DataTable
            if ((dt == null || dt.Columns.Count == 0) && gv.Columns != null && gv.Columns.Count > 0)
            {
                if (dt == null) dt = new DataTable();
                foreach (DataControlField col in gv.Columns)
                {
                    var colName = !string.IsNullOrWhiteSpace(col.SortExpression) ? col.SortExpression : (col.HeaderText ?? "Col");
                    if (!dt.Columns.Contains(colName)) dt.Columns.Add(colName);
                }
            }

            if (wasEmpty)
            {
                // create an empty row so GridView will render a data row with cells
                if (dt == null) dt = new DataTable();
                var row = dt.NewRow();
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    var col = dt.Columns[i];
                    if (col.DataType == typeof(string))
                    {
                        row[i] = string.Empty;
                    }
                    else if (col.AllowDBNull)
                    {
                        row[i] = DBNull.Value;
                    }
                    else if (col.DataType.IsValueType)
                    {
                        // value-type default (0, false, DateTime.MinValue, etc.)
                        row[i] = Activator.CreateInstance(col.DataType);
                    }
                    else
                    {
                        row[i] = DBNull.Value;
                    }
                }
                dt.Rows.Add(row);
            }

            gv.DataSource = dt;
            gv.DataBind();

            if (wasEmpty && gv.Rows.Count > 0)
            {
                // ensure the empty cells render a non-empty placeholder to keep borders visible
                foreach (TableCell cell in gv.Rows[0].Cells)
                {
                    if (string.IsNullOrWhiteSpace(cell.Text) || cell.Text == "&nbsp;") cell.Text = "&nbsp;";
                }
            }
        }

        private void BindAppointmentSummary()
        {
            DateTime dateFrom, dateTo;
            bool hasFrom = DateTime.TryParse(txtFrom.Text, out dateFrom);
            bool hasTo = DateTime.TryParse(txtTo.Text, out dateTo);

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // detect a status-like column (prefer DisplayStatus)
                string detectedColumn = null;
                using (var checkCmd = new SqlCommand(
                    "SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'AppointmentsTbl' AND COLUMN_NAME IN ('DisplayStatus','Status','AppStatus','AppointmentStatus') " +
                    "ORDER BY CASE WHEN COLUMN_NAME='DisplayStatus' THEN 1 WHEN COLUMN_NAME='Status' THEN 2 WHEN COLUMN_NAME='AppStatus' THEN 3 WHEN COLUMN_NAME='AppointmentStatus' THEN 4 ELSE 5 END", conn))
                {
                    var colObj = checkCmd.ExecuteScalar();
                    if (colObj != null && colObj != DBNull.Value)
                    {
                        var col = colObj.ToString();
                        var allowed = new[] { "DisplayStatus", "Status", "AppStatus", "AppointmentStatus" };
                        if (Array.IndexOf(allowed, col) >= 0) detectedColumn = col;
                    }
                }

                var sb = new StringBuilder();
                if (!string.IsNullOrEmpty(detectedColumn))
                {
                    var colEsc = detectedColumn.Replace("]", "]]" );
                    sb.AppendLine("SELECT CAST(a.AppDate AS DATE) AS [Date],");
                    sb.AppendLine("       COUNT(a.AppID) AS TotalAppointments,");
                    sb.AppendLine("       ISNULL(SUM(ISNULL(a.AdvanceAmount,0)),0) AS AdvancePaid,");
                    sb.AppendLine("       ISNULL(SUM(ISNULL(inv.GrossTotal, a.TotalAmount)),0) AS Total,");
                    // Balance column removed; client requested to show Total and AdvancePaid only
                    sb.AppendLine("       ISNULL(SUM(CASE WHEN ISNULL(a.[" + colEsc + "],'')='Completed' THEN 1 ELSE 0 END),0) AS Completed,");
                    sb.AppendLine("       ISNULL(SUM(CASE WHEN ISNULL(a.[" + colEsc + "],'')='Pending' THEN 1 ELSE 0 END),0) AS Pending,");
                    sb.AppendLine("       ISNULL(SUM(CASE WHEN ISNULL(a.[" + colEsc + "],'')='Cancelled' THEN 1 ELSE 0 END),0) AS Cancelled");
                }
                else
                {
                    sb.AppendLine("SELECT CAST(a.AppDate AS DATE) AS [Date],");
                    sb.AppendLine("       COUNT(a.AppID) AS TotalAppointments,");
                    sb.AppendLine("       ISNULL(SUM(ISNULL(a.AdvanceAmount,0)),0) AS AdvancePaid,");
                    sb.AppendLine("       ISNULL(SUM(ISNULL(inv.GrossTotal, a.TotalAmount)),0) AS Total,");
                    // Balance column removed; client requested to show Total and AdvancePaid only
                    sb.AppendLine("       0 AS Completed, 0 AS Pending, 0 AS Cancelled");
                }

                sb.AppendLine("FROM AppointmentsTbl a");
                sb.AppendLine("LEFT JOIN InvoiceTbl inv ON a.AppID = inv.AppID");
                sb.AppendLine("WHERE 1=1");
                if (hasFrom) sb.AppendLine(" AND a.AppDate >= @DateFrom");
                if (hasTo) sb.AppendLine(" AND a.AppDate <= @DateTo");
                sb.AppendLine("GROUP BY CAST(a.AppDate AS DATE)");
                sb.AppendLine("ORDER BY [Date] DESC");

                using (var cmd = new SqlCommand(sb.ToString(), conn))
                {
                    if (hasFrom) cmd.Parameters.AddWithValue("@DateFrom", dateFrom.Date);
                    if (hasTo) cmd.Parameters.AddWithValue("@DateTo", dateTo.Date);

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
                    da.Fill(dt);
                    BindGridWithEmptyRow(gvReport, dt);
                    if (dt.Rows.Count == 0)
                        lblMessage.Text = "No records match your criteria. Try widening the date range or clearing filters.";
                    else
                        lblMessage.Text = dt.Rows.Count + " record(s) found.";
                }
            }
        }
    }
}
