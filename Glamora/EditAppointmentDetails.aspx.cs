using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Globalization;

namespace Glamora
{
    public partial class EditAppointmentDetails : System.Web.UI.Page
    {
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        // Declare txtStartTime to fix missing variable errors
        protected TextBox txtStartTime;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            txtDate.Attributes["min"] = DateTime.Today.ToString("yyyy-MM-dd");

            BindCustomers();
            BindServices();
            BindServiceEmployeeDropdown();

            var appId = Request.QueryString["AppID"];
            if (string.IsNullOrWhiteSpace(appId))
            {
                Response.Redirect("AppointmentsList.aspx");
                return;
            }

            LoadAppointment(appId);
            UpdateTotalFromServices();
            UpdateSaveButtonState();
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            UpdateSaveButtonState();
        }

        private void LoadAppointment(string appId)
        {
            var sql = @"SELECT AppID, Cus_ID, AppDate, StartTime, TotalAmount, AdvanceAmount, Status
                         FROM AppointmentsTbl
                         WHERE AppID = @AppID";

            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@AppID", appId);

                con.Open();
                using (var rd = cmd.ExecuteReader(CommandBehavior.SingleRow))
                {
                    if (!rd.Read())
                    {
                        RedirectWithMessage("Appointment not found.");
                        return;
                    }

                    lblAppId.Text = rd["AppID"]?.ToString();

                    var cusId = rd["Cus_ID"]?.ToString();
                    SetDropDownValueById(ddlCustomer, cusId);

                    var appDate = rd["AppDate"] as DateTime?;
                    txtDate.Text = appDate.HasValue ? appDate.Value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) : string.Empty;

                    if (rd["StartTime"] != DBNull.Value && rd["StartTime"] != null)
                    {
                        var startTime = rd["StartTime"];
                        TimeSpan ts;
                        if (startTime is TimeSpan)
                            ts = (TimeSpan)startTime;
                        else
                            ts = TimeSpan.TryParse(startTime.ToString(), out var parsed) ? parsed : TimeSpan.Zero;
                        ViewState["AppStartTime"] = ts;
                        txtStartTime.Text = ts.ToString("hh\\:mm");
                    }
                    else
                    {
                        txtStartTime.Text = "09:00";
                        ViewState["AppStartTime"] = TimeSpan.FromHours(9);
                    }

                    txtTotal.Text = FormatMoney(rd["TotalAmount"]);
                    txtAdvance.Text = FormatMoney(rd["AdvanceAmount"]);

                    var status = rd["Status"]?.ToString();
                    // Apply expired logic: if date is in past and status is Pending, show Expired
                    string displayStatus = status;
                    if (appDate.HasValue && appDate.Value.Date < DateTime.Today && status != null && status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                    {
                        displayStatus = "Expired";
                    }
                    var item = ddlStatus.Items.Cast<ListItem>().FirstOrDefault(i => string.Equals(i.Text, displayStatus, StringComparison.OrdinalIgnoreCase));
                    if (item != null)
                    {
                        ddlStatus.ClearSelection();
                        item.Selected = true;
                    }
                    else if (!string.IsNullOrWhiteSpace(displayStatus))
                    {
                        // Inject status if not present (e.g. Expired)
                        var injected = new ListItem(displayStatus, displayStatus);
                        ddlStatus.Items.Add(injected);
                        ddlStatus.ClearSelection();
                        injected.Selected = true;
                    }
                }
            }

            LoadAppointmentServices(appId);
        }

        private void LoadAppointmentServices(string appId)
        {
            var sql = @"SELECT ast.Service_ID, s.Service_Name, ast.PriceAtTime,
                               ast.Emp_ID, CONCAT(e.Title, ' ', e.EmpFirst_Name, ' ', e.EmpLast_Name) AS EmpName
                         FROM AppointmentServiceTbl ast
                         INNER JOIN ServiceTbl s ON ast.Service_ID = s.Service_ID
                         LEFT JOIN EmpTbl e ON ast.Emp_ID = e.Emp_ID
                         WHERE ast.AppID = @AppID
                         ORDER BY ast.AppServiceID";

            var serviceEntries = new List<string>();
            var serviceDisplay = new List<string>();
            decimal total = 0m;

            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@AppID", appId);
                con.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        var sid = rd["Service_ID"]?.ToString();
                        var sname = rd["Service_Name"]?.ToString();
                        var empId = rd["Emp_ID"]?.ToString() ?? "";
                        var empName = rd["EmpName"]?.ToString() ?? "";
                        var price = rd["PriceAtTime"] != DBNull.Value ? Convert.ToDecimal(rd["PriceAtTime"]) : 0m;
                        if (!string.IsNullOrEmpty(sid))
                        {
                            serviceEntries.Add(sid + "|" + sname + "|" + empId + "|" + empName);
                            string display = string.IsNullOrEmpty(empName)
                                ? (sname ?? sid)
                                : (sname ?? sid) + " \u2192 " + empName;
                            serviceDisplay.Add(display);
                            total += price;
                        }
                    }
                }
            }

            hdnServices.Value = string.Join(",", serviceEntries);
            BindServiceRepeater(serviceDisplay);
            txtTotal.Text = total.ToString("N2");
        }

        private void SetDropDownValueById(DropDownList ddl, string value)
        {
            if (ddl == null || string.IsNullOrWhiteSpace(value)) { ddl?.ClearSelection(); return; }
            var item = ddl.Items.FindByValue(value);
            if (item != null) { ddl.ClearSelection(); item.Selected = true; }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!CanSave())
            {
                ShowMessage("Please select a date, customer and add at least one service.", false);
                UpdateSaveButtonState();
                return;
            }

            if (string.IsNullOrWhiteSpace(lblAppId.Text))
            {
                ShowMessage("Missing appointment id.", false);
                return;
            }

            if (string.IsNullOrWhiteSpace(ddlStatus.SelectedValue))
            {
                ShowMessage("Please select a status.", false);
                return;
            }

            DateTime appDate;
            if (!DateTime.TryParse(txtDate.Text, out appDate))
            {
                ShowMessage("Please select a valid date.", false);
                return;
            }

            // Block assigning a past date for any appointment
            if (appDate < DateTime.Today)
            {
                ShowMessage("Appointment date cannot be before today.", false);
                return;
            }

            var cusId = ddlCustomer.SelectedValue ?? string.Empty;
            var serviceEntries = ParseServiceEntries();
            var serviceIds = serviceEntries.Select(x => x.Id).Distinct(StringComparer.OrdinalIgnoreCase).ToList();
            var totalAmount = CalculateServicesTotal(serviceIds);
            txtTotal.Text = totalAmount.ToString("N2");

            decimal advanceAmount;
            if (!decimal.TryParse(txtAdvance.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out advanceAmount)) advanceAmount = 0m;

            TimeSpan startTime = TimeSpan.FromHours(9);
            if (!string.IsNullOrWhiteSpace(txtStartTime.Text))
            {
                TimeSpan parsed;
                if (TimeSpan.TryParse(txtStartTime.Text, out parsed))
                    startTime = parsed;
            }
            ViewState["AppStartTime"] = startTime;

            // --- Check employee time conflicts before saving ---
            int totalDuration = 0;
            using (var conCheck = new SqlConnection(connectionString))
            {
                conCheck.Open();
                foreach (var entry in serviceEntries)
                {
                    var (_, dur) = GetServicePriceAndDuration(conCheck, null, entry.Id);
                    totalDuration += dur;
                }
            }
            TimeSpan endTime = startTime.Add(TimeSpan.FromMinutes(totalDuration > 0 ? totalDuration : 60));
            string conflictMsg = CheckEmployeeConflicts(serviceEntries, appDate, startTime, endTime, lblAppId.Text);
            if (!string.IsNullOrEmpty(conflictMsg))
            {
                ShowMessage(conflictMsg, false);
                return;
            }

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();
                using (var tran = con.BeginTransaction())
                {
                    try
                    {
                        var updateSql = @"UPDATE AppointmentsTbl SET Status = @Status, AppDate = @AppDate, Cus_ID = @Cus_ID, StartTime = @StartTime, TotalAmount = @TotalAmount, AdvanceAmount = @AdvanceAmount WHERE AppID = @AppID";
                        using (var cmd = new SqlCommand(updateSql, con, tran))
                        {
                            cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                            cmd.Parameters.AddWithValue("@AppID", lblAppId.Text);
                            cmd.Parameters.AddWithValue("@AppDate", appDate);
                            cmd.Parameters.AddWithValue("@Cus_ID", cusId);
                            cmd.Parameters.AddWithValue("@StartTime", startTime);
                            cmd.Parameters.AddWithValue("@TotalAmount", totalAmount);
                            cmd.Parameters.AddWithValue("@AdvanceAmount", advanceAmount);
                            cmd.ExecuteNonQuery();
                        }

                        var deleteSql = "DELETE FROM AppointmentServiceTbl WHERE AppID = @AppID";
                        using (var cmd = new SqlCommand(deleteSql, con, tran))
                        {
                            cmd.Parameters.AddWithValue("@AppID", lblAppId.Text);
                            cmd.ExecuteNonQuery();
                        }

                        var nextId = GetNextAppServiceID(con, tran);
                        var insertSvc = @"INSERT INTO AppointmentServiceTbl (AppServiceID, AppID, Service_ID, PriceAtTime, DurationAtTime, Emp_ID) VALUES (@AppServiceID, @AppID, @Service_ID, @PriceAtTime, @DurationAtTime, @Emp_ID)";
                        foreach (var entry in serviceEntries)
                        {
                            var (price, duration) = GetServicePriceAndDuration(con, tran, entry.Id);
                            using (var cmd = new SqlCommand(insertSvc, con, tran))
                            {
                                cmd.Parameters.AddWithValue("@AppServiceID", nextId);
                                cmd.Parameters.AddWithValue("@AppID", lblAppId.Text);
                                cmd.Parameters.AddWithValue("@Service_ID", entry.Id);
                                cmd.Parameters.AddWithValue("@PriceAtTime", price);
                                cmd.Parameters.AddWithValue("@DurationAtTime", duration);
                                cmd.Parameters.AddWithValue("@Emp_ID", string.IsNullOrWhiteSpace(entry.EmpId) ? (object)DBNull.Value : entry.EmpId);
                                cmd.ExecuteNonQuery();
                            }
                            nextId = GetNextAppServiceID(con, tran);
                        }

                        tran.Commit();
                        ViewState["AppStartTime"] = startTime;
                        ShowMessage("Appointment updated.", true);
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        ShowMessage("Error saving: " + ex.Message, false);
                    }
                }
            }
        }

        private string GetNextAppServiceID(SqlConnection con, SqlTransaction tran)
        {
            var sql = @"SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(AppServiceID, 3, 10) AS INT)), 0) FROM AppointmentServiceTbl WHERE AppServiceID LIKE 'AS%'";
            using (var cmd = new SqlCommand(sql, con, tran))
            {
                var r = cmd.ExecuteScalar();
                var last = r != null && r != DBNull.Value ? Convert.ToInt32(r) : 0;
                return "AS" + (last + 1);
            }
        }

        private (decimal Price, int Duration) GetServicePriceAndDuration(SqlConnection con, SqlTransaction tran, string serviceId)
        {
            var sql = "SELECT Price, Duration FROM ServiceTbl WHERE Service_ID = @Service_ID";
            using (var cmd = new SqlCommand(sql, con, tran))
            {
                cmd.Parameters.AddWithValue("@Service_ID", serviceId);
                using (var rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        var price = rd["Price"] != DBNull.Value ? Convert.ToDecimal(rd["Price"]) : 0m;
                        var dur = rd["Duration"];
                        int mins = 0;
                        if (dur != null && dur != DBNull.Value)
                        {
                            if (dur is TimeSpan ts) mins = (int)ts.TotalMinutes;
                            else if (dur is int i) mins = i;
                            else int.TryParse(dur.ToString(), out mins);
                        }
                        return (price, mins);
                    }
                }
            }
            return (0m, 0);
        }

        protected void btnAddService_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(ddlServices.SelectedValue)) return;
            if (string.IsNullOrWhiteSpace(ddlServiceEmployee.SelectedValue))
            {
                ShowMessage("Please select an employee for this service.", false);
                return;
            }

            var toAddId = ddlServices.SelectedValue;
            var toAddName = ddlServices.SelectedItem?.Text ?? toAddId;
            var toAddEmpId = ddlServiceEmployee.SelectedValue;
            var toAddEmpName = ddlServiceEmployee.SelectedItem?.Text ?? toAddEmpId;

            var entries = ParseServiceEntries();
            if (entries.Any(x => x.Id.Equals(toAddId, StringComparison.OrdinalIgnoreCase) && x.EmpId == toAddEmpId)) return;

            entries.Add((toAddId, toAddName, toAddEmpId, toAddEmpName));
            hdnServices.Value = string.Join(",", entries.Select(x => x.Id + "|" + x.Name + "|" + x.EmpId + "|" + x.EmpName));
            var displayNames = entries.Select(x => string.IsNullOrEmpty(x.EmpName) ? x.Name : x.Name + " \u2192 " + x.EmpName).ToList();
            BindServiceRepeater(displayNames);
            UpdateTotalFromServices();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("AppointmentBooking.aspx");
        }

        protected void txtDate_TextChanged(object sender, EventArgs e)
        {
            // If current status is Expired and new date is in the future, set status to Pending
            DateTime newDate;
            var statusItem = ddlStatus.SelectedItem;
            if (statusItem != null && statusItem.Text.Equals("Expired", StringComparison.OrdinalIgnoreCase)
                && DateTime.TryParse(txtDate.Text, out newDate)
                && newDate > DateTime.Today)
            {
                var pendingItem = ddlStatus.Items.FindByText("Pending");
                if (pendingItem != null)
                {
                    ddlStatus.ClearSelection();
                    pendingItem.Selected = true;
                }
            }
            UpdateSaveButtonState();
        }

        protected void ddlCustomer_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateSaveButtonState();
        }

        protected void rptServiceList_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!string.Equals(e.CommandName, "RemoveService", StringComparison.OrdinalIgnoreCase)) return;

            var toRemove = e.CommandArgument != null ? e.CommandArgument.ToString() : string.Empty;
            var entries = ParseServiceEntries();

            // Find the display text and remove matching entry
            int removeIndex = -1;
            var displayNames = entries.Select(x =>
                string.IsNullOrEmpty(x.EmpName) ? x.Name : x.Name + " \u2192 " + x.EmpName
            ).ToList();
            for (int i = 0; i < displayNames.Count; i++)
            {
                if (displayNames[i] == toRemove)
                {
                    removeIndex = i;
                    break;
                }
            }

            if (removeIndex >= 0)
                entries.RemoveAt(removeIndex);

            hdnServices.Value = string.Join(",", entries.Select(x => x.Id + "|" + x.Name + "|" + x.EmpId + "|" + x.EmpName));
            var remainingDisplay = entries.Select(x =>
                string.IsNullOrEmpty(x.EmpName) ? x.Name : x.Name + " \u2192 " + x.EmpName
            ).ToList();
            BindServiceRepeater(remainingDisplay);
            UpdateTotalFromServices();
        }

        private List<(string Id, string Name, string EmpId, string EmpName)> ParseServiceEntries()
        {
            var list = new List<(string, string, string, string)>();
            foreach (var part in (hdnServices.Value ?? string.Empty).Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                var p = part.Trim();
                if (string.IsNullOrWhiteSpace(p)) continue;
                var segments = p.Split('|');
                if (segments.Length >= 4)
                    list.Add((segments[0].Trim(), segments[1].Trim(), segments[2].Trim(), segments[3].Trim()));
                else if (segments.Length >= 2)
                    list.Add((segments[0].Trim(), segments[1].Trim(), "", ""));
                else
                    list.Add((p, p, "", ""));
            }
            return list;
        }

        private List<string> GetServiceIds()
        {
            return ParseServiceEntries().Select(x => x.Id).ToList();
        }

        private List<string> GetServicesList()
        {
            return ParseServiceEntries().Select(x =>
                string.IsNullOrEmpty(x.EmpName) ? x.Name : x.Name + " \u2192 " + x.EmpName
            ).ToList();
        }

        private void SyncServicesListFromText()
        {
            var names = GetServicesList();
            BindServiceRepeater(names);
            UpdateTotalFromServices();
        }

        private void BindServiceRepeater(List<string> services)
        {
            rptServiceList.DataSource = services;
            rptServiceList.DataBind();
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
        }

        private void BindCustomers()
        {
            ddlCustomer.Items.Clear();
            ddlCustomer.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Customer --", ""));

            const string sql = "SELECT Cus_ID, Title, CusFirst_Name, CusLast_Name FROM CustomerTbl ORDER BY CusFirst_Name, CusLast_Name";
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        var name = string.Join(" ", new[] { rd["Title"]?.ToString(), rd["CusFirst_Name"]?.ToString(), rd["CusLast_Name"]?.ToString() }.Where(s => !string.IsNullOrWhiteSpace(s)).Select(s => s.Trim()));
                        var id = rd["Cus_ID"]?.ToString();
                        ddlCustomer.Items.Add(new System.Web.UI.WebControls.ListItem(name, id));
                    }
                }
            }
        }

        private void BindServiceEmployeeDropdown()
        {
            ddlServiceEmployee.Items.Clear();
            ddlServiceEmployee.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Employee --", ""));

            const string sql = "SELECT Emp_ID, Title, EmpFirst_Name, EmpLast_Name FROM EmpTbl ORDER BY EmpFirst_Name, EmpLast_Name";
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        var name = string.Join(" ", new[] { rd["Title"]?.ToString(), rd["EmpFirst_Name"]?.ToString(), rd["EmpLast_Name"]?.ToString() }.Where(s => !string.IsNullOrWhiteSpace(s)).Select(s => s.Trim()));
                        var id = rd["Emp_ID"]?.ToString();
                        ddlServiceEmployee.Items.Add(new System.Web.UI.WebControls.ListItem(name, id));
                    }
                }
            }
        }

        private void BindServices()
        {
            ddlServices.Items.Clear();
            ddlServices.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Service --", ""));

            const string sql = "SELECT Service_ID, Service_Name FROM ServiceTbl ORDER BY Service_Name";
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        ddlServices.Items.Add(new System.Web.UI.WebControls.ListItem(rd["Service_Name"].ToString(), rd["Service_ID"].ToString()));
                    }
                }
            }
        }

        private void SetDropDownValue(System.Web.UI.WebControls.DropDownList ddl, string text)
        {
            if (ddl == null) return;
            if (string.IsNullOrWhiteSpace(text))
            {
                ddl.ClearSelection();
                return;
            }

            var item = ddl.Items.Cast<System.Web.UI.WebControls.ListItem>().FirstOrDefault(i => string.Equals(i.Text, text, StringComparison.OrdinalIgnoreCase));
            if (item != null)
            {
                ddl.ClearSelection();
                item.Selected = true;
            }
            else
            {
                var injected = new System.Web.UI.WebControls.ListItem(text, text);
                ddl.Items.Add(injected);
                ddl.ClearSelection();
                injected.Selected = true;
            }
        }

        private string FormatMoney(object value)
        {
            decimal amount;
            if (value == null || value == DBNull.Value || !decimal.TryParse(value.ToString(), NumberStyles.Number, CultureInfo.InvariantCulture, out amount))
            {
                amount = 0m;
            }
            return amount.ToString("N2");
        }

        private bool ColumnExists(string table, string column)
        {
            const string sql = @"
SELECT COUNT(*)
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE c.name = @Column
  AND (t.name = @Table OR (s.name + '.' + t.name) = @Table)
";
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@Table", table);
                cmd.Parameters.AddWithValue("@Column", column);
                con.Open();
                var count = (int)cmd.ExecuteScalar();
                return count > 0;
            }
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Visible = true;
            lblMessage.Text = message;
            lblMessage.CssClass = success ? "msg success" : "msg error";
        }

        private void RedirectWithMessage(string message)
        {
            Session["EditAppMsg"] = message;
            Response.Redirect("AppointmentsList.aspx");
        }

        private decimal CalculateServicesTotal(List<string> serviceIds)
        {
            if (serviceIds == null || serviceIds.Count == 0) return 0m;

            decimal total = 0m;
            using (var con = new SqlConnection(connectionString))
            {
                con.Open();
                foreach (var serviceId in serviceIds)
                {
                    var sql = "SELECT Price FROM ServiceTbl WHERE Service_ID = @Service_ID";
                    using (var cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@Service_ID", serviceId);
                        var result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            total += Convert.ToDecimal(result);
                    }
                }
            }
            return total;
        }

        private void UpdateTotalFromServices()
        {
            var serviceIds = GetServiceIds();
            var totalAmount = CalculateServicesTotal(serviceIds);
            txtTotal.Text = totalAmount.ToString("N2");
            UpdateSaveButtonState();
        }

        private bool CanSave()
        {
            return !string.IsNullOrWhiteSpace(txtDate.Text)
                   && !string.IsNullOrWhiteSpace(ddlCustomer.SelectedValue)
                   && GetServiceIds().Any();
        }

        private void UpdateSaveButtonState()
        {
            btnSave.Enabled = CanSave();
        }

        protected string GetServiceDisplayText(object dataItem)
        {
            string text = dataItem?.ToString() ?? "";
            return System.Web.HttpUtility.HtmlEncode(text);
        }

        /// <summary>
        /// Checks if any of the selected employees have overlapping appointments on the given date/time.
        /// Returns a conflict message if overlap found, or null if no conflicts.
        /// </summary>
        private string CheckEmployeeConflicts(List<(string Id, string Name, string EmpId, string EmpName)> serviceEntries, DateTime appDate, TimeSpan newStart, TimeSpan newEnd, string excludeAppId)
        {
            var employeeIds = serviceEntries
                .Where(s => !string.IsNullOrWhiteSpace(s.EmpId))
                .Select(s => s.EmpId)
                .Distinct()
                .ToList();

            if (employeeIds.Count == 0) return null;

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();
                foreach (string empId in employeeIds)
                {
                    string query = @"
                        SELECT a.AppID, a.StartTime,
                               ISNULL(SUM(ast.DurationAtTime), 0) AS TotalDuration,
                               CONCAT(e.Title, ' ', e.EmpFirst_Name, ' ', e.EmpLast_Name) AS EmpName
                        FROM AppointmentsTbl a
                        INNER JOIN AppointmentServiceTbl ast ON a.AppID = ast.AppID
                        INNER JOIN EmpTbl e ON ast.Emp_ID = e.Emp_ID
                        WHERE ast.Emp_ID = @EmpID
                          AND a.AppDate = @AppDate
                          AND a.Status IN ('Pending', 'Booked')";

                    if (!string.IsNullOrEmpty(excludeAppId))
                        query += " AND a.AppID <> @ExcludeAppID";

                    query += " GROUP BY a.AppID, a.StartTime, e.Title, e.EmpFirst_Name, e.EmpLast_Name";

                    using (var cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@EmpID", empId);
                        cmd.Parameters.AddWithValue("@AppDate", appDate.Date);
                        if (!string.IsNullOrEmpty(excludeAppId))
                            cmd.Parameters.AddWithValue("@ExcludeAppID", excludeAppId);

                        using (var rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                TimeSpan existingStart;
                                var startVal = rdr["StartTime"];
                                if (startVal is TimeSpan ts)
                                    existingStart = ts;
                                else if (!TimeSpan.TryParse(startVal?.ToString(), out existingStart))
                                    continue;

                                int durationMins = Convert.ToInt32(rdr["TotalDuration"]);
                                if (durationMins <= 0) durationMins = 60;
                                TimeSpan existingEnd = existingStart.Add(TimeSpan.FromMinutes(durationMins));

                                string empName = rdr["EmpName"]?.ToString() ?? empId;
                                string existingAppId = rdr["AppID"]?.ToString() ?? "";

                                if (newStart < existingEnd && newEnd > existingStart)
                                {
                                    return $"Time conflict! {empName.Trim()} is already booked from " +
                                           $"{existingStart:hh\\:mm} to {existingEnd:hh\\:mm} " +
                                           $"(Appointment {existingAppId}). Please choose a different time or employee.";
                                }
                            }
                        }
                    }
                }
            }
            return null;
        }
    }
}