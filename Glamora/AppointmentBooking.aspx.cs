using AjaxControlToolkit;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Services; // <-- Add this using directive at the top

namespace Glamora
{
    public partial class AppointmentBooking : Page
    {
        // Returns a colored status badge HTML for the GridView
        public string GetStatusBadge(object statusObj)
        {
            string status = (statusObj ?? "").ToString().Trim().ToLower();
            string label;
            string css;
            string icon;
            switch (status)
            {
                case "pending":
                    label = "Pending";
                    css = "status-badge status-pending";
                    icon = "fa-clock";
                    break;
                case "done":
                    label = "Done";
                    css = "status-badge status-done";
                    icon = "fa-circle-check";
                    break;
                case "expired":
                case "exprired": // typo fallback
                    label = "Expired";
                    css = "status-badge status-expired";
                    icon = "fa-hourglass-end";
                    break;
                case "cancelled":
                case "canceled":
                    label = "Cancelled";
                    css = "status-badge status-cancelled";
                    icon = "fa-circle-xmark";
                    break;
                default:
                    label = statusObj?.ToString() ?? "";
                    css = "status-badge status-pending";
                    icon = "fa-circle-question";
                    break;
            }
            return $"<span class='{css}'><i class='fas {icon}'></i> {label}</span>";
        }

        // Formats end time from StartTime + TotalDurationMins for display on cards
        public string GetEndTime(object startTimeObj, object durationMinsObj)
        {
            if (startTimeObj == null || startTimeObj == DBNull.Value) return "-";
            TimeSpan start;
            if (startTimeObj is TimeSpan ts)
                start = ts;
            else if (!TimeSpan.TryParse(startTimeObj.ToString(), out start))
                return "-";

            int mins = 0;
            if (durationMinsObj != null && durationMinsObj != DBNull.Value)
                int.TryParse(durationMinsObj.ToString(), out mins);

            if (mins <= 0) return "-";
            TimeSpan end = start.Add(TimeSpan.FromMinutes(mins));
            return end.ToString(@"hh\:mm");
        }

        // Formats StartTime without seconds (e.g., "10:00" instead of "10:00:00")
        public string FormatStartTime(object startTimeObj)
        {
            if (startTimeObj == null || startTimeObj == DBNull.Value) return "-";
            if (startTimeObj is TimeSpan ts)
                return ts.ToString(@"hh\:mm");
            TimeSpan parsed;
            if (TimeSpan.TryParse(startTimeObj.ToString(), out parsed))
                return parsed.ToString(@"hh\:mm");
            return startTimeObj.ToString();
        }

        // Formats total duration in minutes to a readable string (e.g., "1h 30m")
        public string GetDurationDisplay(object durationMinsObj)
        {
            int mins = 0;
            if (durationMinsObj != null && durationMinsObj != DBNull.Value)
                int.TryParse(durationMinsObj.ToString(), out mins);

            if (mins <= 0) return "-";
            int hours = mins / 60;
            int remaining = mins % 60;
            if (hours > 0 && remaining > 0) return $"{hours}h {remaining}m";
            if (hours > 0) return $"{hours}h";
            return $"{remaining}m";
        }

        // Instance connection string (used by non-static members)
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";
        // Static connection string for PageMethods (WebMethods)
        private static readonly string staticConnectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        private const string SESSION_SERVICES = "SelectedServices";
        private const string DEFAULT_STATUS = "Pending";

        private Dictionary<string, string> _employeeServiceMap = new Dictionary<string, string>();

        protected Label lblTotalAmount;
        protected Label lblTotalDuration;
        protected Repeater rptServices;
        protected TextBox txtCustomer;
        protected TextBox txtAppDate;
        protected DropDownList ddlStartHour;
        protected DropDownList ddlStartMinute;
        protected Label lblAppID;
        protected Label lblBookingDate;
        protected Label lblNoServices;
        protected UpdatePanel upServices;
        protected Repeater rptAppointments;
        protected Label lblNoAppointments;
        protected Label lblMessage;
        protected TextBox txtAdvanceAmount;
        protected DropDownList ddlSearchType;
        protected TextBox txtSearch;
        protected TextBox txtDateFrom;
        protected TextBox txtDateTo;

        protected void Page_Load(object sender, EventArgs e)
        {
            BuildCustomerDatalist();

            txtCustomer.Attributes["list"] = "customers";

            if (!IsPostBack)
            {
                lblBookingDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                GenerateAppointmentID();
                Session[SESSION_SERVICES] = new List<ServiceItem>();
                LoadAppointments();
                txtAppDate.Attributes["min"] = DateTime.Now.ToString("yyyy-MM-dd");
                LoadAllServices();
                LoadEmployeesByService();
                BindSelectedServices();
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string searchType = ddlSearchType.SelectedValue;
            string searchText = txtSearch.Text.Trim();
            string dateFrom = txtDateFrom.Text.Trim();
            string dateTo = txtDateTo.Text.Trim();
            LoadAppointments(searchType, searchText, dateFrom, dateTo);
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            txtDateFrom.Text = "";
            txtDateTo.Text = "";
            ddlSearchType.SelectedIndex = 0;
            LoadAppointments();
        }

        private string GetNextAppServiceID(SqlConnection con, SqlTransaction tran)
        {
            string query = @"SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(AppServiceID, 3, 10) AS INT)), 0)
                             FROM AppointmentServiceTbl
                             WHERE AppServiceID LIKE 'AS%'";
            using (var cmd = new SqlCommand(query, con, tran))
            {
                object result = cmd.ExecuteScalar();
                int last = result != null && result != DBNull.Value ? Convert.ToInt32(result) : 0;
                return "AS" + (last + 1);
            }
        }

        private void GenerateAppointmentID()
        {
            string newAppID = "APP1";
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(AppID, 4, 10) AS INT)), 0)
                                     FROM AppointmentsTbl
                                     WHERE AppID LIKE 'APP%'";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    try
                    {
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            int lastNumber = Convert.ToInt32(result);
                            newAppID = "APP" + (lastNumber + 1);
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowMessage("Error generating Appointment ID: " + ex.Message, false);
                    }
                }
            }
            lblAppID.Text = newAppID;
        }

        private void LoadAppointments()
        {
            LoadAppointments(null, null, null, null);
        }

        private void LoadAppointments(string searchType, string searchText, string dateFrom = null, string dateTo = null)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT a.AppID, a.AppDate, a.StartTime,
                               CONCAT(c.Title, ' ', c.CusFirst_Name, ' ', c.CusLast_Name) AS CustomerName,
                               (SELECT STUFF(COALESCE((SELECT ', ' + s.Service_Name FROM AppointmentServiceTbl ast2 INNER JOIN ServiceTbl s ON ast2.Service_ID = s.Service_ID WHERE ast2.AppID = a.AppID FOR XML PATH(''), TYPE), (SELECT CAST('' AS XML))).value('.', 'NVARCHAR(MAX)'), 1, 2, '')) AS Services,
                               ISNULL(NULLIF(
                                   (SELECT STUFF(COALESCE(
                                       (SELECT DISTINCT ', ' + LTRIM(RTRIM(CONCAT(ISNULL(e2.Title, ''), ' ', e2.EmpFirst_Name, ' ', e2.EmpLast_Name)))
                                        FROM AppointmentServiceTbl ast3
                                        LEFT JOIN EmpTbl e2 ON ast3.Emp_ID = e2.Emp_ID
                                        WHERE ast3.AppID = a.AppID AND e2.Emp_ID IS NOT NULL
                                        FOR XML PATH(''), TYPE),
                                       (SELECT CAST('' AS XML))).value('.', 'NVARCHAR(MAX)'), 1, 2, '')),
                               ''), 'Not Assigned') AS EmployeeName,
                               a.TotalAmount, a.BookingDate, a.AdvanceAmount,
                               ISNULL((SELECT SUM(ast4.DurationAtTime) FROM AppointmentServiceTbl ast4 WHERE ast4.AppID = a.AppID), 0) AS TotalDurationMins,
                               CASE WHEN a.AppDate < CAST(GETDATE() AS DATE) AND a.Status = 'Pending' THEN 'Expired' ELSE a.Status END AS DisplayStatus
                        FROM AppointmentsTbl a
                        LEFT JOIN CustomerTbl c ON a.Cus_ID = c.Cus_ID";

                    // For DateRange searches we rely on dateFrom/dateTo instead of the free-text search box
                    bool hasSearch = !string.IsNullOrWhiteSpace(searchText) && !string.Equals(searchType, "DateRange", StringComparison.OrdinalIgnoreCase);
                    var conditions = new List<string>();

                    if (hasSearch && searchType == "Customer")
                    {
                        conditions.Add("CONCAT(c.Title, ' ', c.CusFirst_Name, ' ', c.CusLast_Name) LIKE @Search");
                    }
                    else if (hasSearch && searchType == "Employee")
                    {
                        conditions.Add(@"EXISTS (
                            SELECT 1 FROM AppointmentServiceTbl ast5
                            INNER JOIN EmpTbl e5 ON ast5.Emp_ID = e5.Emp_ID
                            WHERE ast5.AppID = a.AppID
                              AND CONCAT(e5.Title, ' ', e5.EmpFirst_Name, ' ', e5.EmpLast_Name) LIKE @Search
                        )");
                    }
                    else if (hasSearch && searchType == "Status")
                    {
                        conditions.Add(@"CASE WHEN a.AppDate < CAST(GETDATE() AS DATE) AND a.Status = 'Pending' THEN 'Expired' ELSE a.Status END LIKE @Search");
                    }

                    if (searchType == "DateRange")
                    {
                        if (DateTime.TryParse(dateFrom, out _))
                            conditions.Add("a.AppDate >= @DateFrom");
                        if (DateTime.TryParse(dateTo, out _))
                            conditions.Add("a.AppDate <= @DateTo");
                    }

                    if (conditions.Count > 0)
                        query += " WHERE " + string.Join(" AND ", conditions);

                    query += " ORDER BY a.AppID DESC";

                    using (SqlDataAdapter da = new SqlDataAdapter(query, con))
                    {
                        if (hasSearch && searchType != "DateRange")
                            da.SelectCommand.Parameters.AddWithValue("@Search", "%" + searchText.Trim() + "%");

                        if (searchType == "DateRange")
                        {
                            if (DateTime.TryParse(dateFrom, out DateTime dfParsed))
                                da.SelectCommand.Parameters.AddWithValue("@DateFrom", dfParsed);
                            if (DateTime.TryParse(dateTo, out DateTime dtParsed))
                                da.SelectCommand.Parameters.AddWithValue("@DateTo", dtParsed);
                        }

                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        if (dt.Rows.Count > 0)
                        {
                            LoadEmployeeServiceMap();
                            rptAppointments.DataSource = dt;
                            rptAppointments.DataBind();
                            rptAppointments.Visible = true;
                            lblNoAppointments.Visible = false;
                        }
                        else
                        {
                            rptAppointments.DataSource = null;
                            rptAppointments.DataBind();
                            rptAppointments.Visible = false;
                            lblNoAppointments.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading appointments: " + ex.Message, false);
            }
        }

        // Build HTML5 datalist for customer names (show name + contact, hide ID)
        private void BuildCustomerDatalist()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<datalist id='customers'>");

            string query = @"SELECT Cus_ID,
                                    CONCAT(Title, ' ', CusFirst_Name, ' ', CusLast_Name) AS FullName,
                                    Contact
                             FROM CustomerTbl
                             ORDER BY CusFirst_Name, CusLast_Name";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string fullName = rdr["FullName"]?.ToString() ?? "";
                            string contact = rdr["Contact"]?.ToString() ?? "";
                            string display = string.IsNullOrWhiteSpace(contact)
                                ? fullName
                                : $"{fullName} - {contact}";
                            string safeValue = HttpUtility.HtmlAttributeEncode(display);
                            sb.Append($"<option value=\"{safeValue}\"></option>");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load customer list: " + ex.Message, false);
            }

            sb.Append("</datalist>");
            if (litCustomerDatalist != null)
                    litCustomerDatalist.Text = sb.ToString();
        }

        // Service selection changed - load only assigned & available employees
        protected void ddlService_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadEmployeesByService();
        }

        // Date or time changed - refresh employee availability
        protected void txtAppDate_TextChanged(object sender, EventArgs e)
        {
            LoadEmployeesByService();
        }

        protected void ddlStartHour_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadEmployeesByService();
        }

        protected void ddlStartMinute_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadEmployeesByService();
        }

        // Load employees assigned to the selected service, excluding those already booked at the chosen date/time
        private void LoadEmployeesByService()
        {
            ddlServiceEmployee.Items.Clear();
            ddlServiceEmployee.Items.Add(new ListItem("-- Select Employee --", ""));

            string serviceId = ddlService.SelectedValue;
            if (string.IsNullOrEmpty(serviceId))
            {
                return;
            }

            // Get all employees assigned to this service
            string query = @"SELECT e.Emp_ID, CONCAT(e.Title, ' ', e.EmpFirst_Name, ' ', e.EmpLast_Name, ' (', e.Role, ')') AS FullName
                             FROM EmpTbl e
                             INNER JOIN EmployeeServiceTbl es ON e.Emp_ID = es.Emp_ID
                             WHERE es.Service_ID = @Service_ID
                             ORDER BY e.EmpFirst_Name, e.EmpLast_Name";

            // Determine the new appointment's time window
            DateTime? appDate = null;
            TimeSpan? newStart = null;
            TimeSpan? newEnd = null;

            if (DateTime.TryParse(txtAppDate.Text, out DateTime parsedDate))
                appDate = parsedDate;

            if (!string.IsNullOrEmpty(ddlStartHour.SelectedValue) && !string.IsNullOrEmpty(ddlStartMinute.SelectedValue))
            {
                newStart = TimeSpan.Parse(ddlStartHour.SelectedValue + ":" + ddlStartMinute.SelectedValue);

                // Calculate total duration from already-added services + the service being selected
                List<ServiceItem> currentServices = Session[SESSION_SERVICES] as List<ServiceItem> ?? new List<ServiceItem>();
                int currentDuration = currentServices.Sum(s => s.Duration);

                // Add the duration of the service being selected
                ServiceItem newService = FetchServiceById(serviceId);
                int newServiceDuration = newService != null ? newService.Duration : 0;

                int totalDuration = currentDuration + newServiceDuration;
                if (totalDuration <= 0) totalDuration = 60; // default 1 hour
                newEnd = newStart.Value.Add(TimeSpan.FromMinutes(totalDuration));
            }

            // Get booked time slots per employee for the selected date
            var employeeSlots = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);
            var busyEmployeeIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (appDate.HasValue)
            {
                employeeSlots = GetEmployeeBookedSlots(appDate.Value, null);
                if (newStart.HasValue && newEnd.HasValue)
                    busyEmployeeIds = GetBusyEmployeeIds(appDate.Value, newStart.Value, newEnd.Value, null);
            }

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Service_ID", serviceId);
                    con.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string empId = rdr["Emp_ID"]?.ToString() ?? "";
                            string fullName = rdr["FullName"]?.ToString() ?? "";

                            bool isBusy = busyEmployeeIds.Contains(empId);
                            bool hasSlots = employeeSlots.ContainsKey(empId);

                            string displayText;
                            if (isBusy && hasSlots)
                            {
                                // Show booked slots so user knows when the employee is busy
                                string slots = string.Join(", ", employeeSlots[empId]);
                                displayText = fullName + " ⛔ Booked: " + slots;
                            }
                            else if (hasSlots)
                            {
                                // Employee has bookings today but is free at the selected time
                                string slots = string.Join(", ", employeeSlots[empId]);
                                displayText = fullName + " ✅ (Busy: " + slots + ")";
                            }
                            else
                            {
                                displayText = fullName + " ✅";
                            }

                            var item = new ListItem(displayText, empId);
                            if (isBusy)
                            {
                                item.Attributes["disabled"] = "disabled";
                                item.Attributes["style"] = "color:#94a3b8;";
                            }
                            ddlServiceEmployee.Items.Add(item);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load employee list: " + ex.Message, false);
            }
        }

        /// <summary>
        /// Returns booked time slot strings (e.g., "09:00–10:30") per employee for the given date.
        /// </summary>
        private Dictionary<string, List<string>> GetEmployeeBookedSlots(DateTime appDate, string excludeAppId)
        {
            var result = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);

            string query = @"
                SELECT ast.Emp_ID, a.StartTime,
                       ISNULL((SELECT SUM(ast2.DurationAtTime) FROM AppointmentServiceTbl ast2 WHERE ast2.AppID = a.AppID), 60) AS TotalDuration
                FROM AppointmentsTbl a
                INNER JOIN AppointmentServiceTbl ast ON a.AppID = ast.AppID
                WHERE a.AppDate = @AppDate
                  AND a.Status IN ('Pending', 'Booked')
                  AND ast.Emp_ID IS NOT NULL";

            if (!string.IsNullOrEmpty(excludeAppId))
                query += " AND a.AppID <> @ExcludeAppID";

            query += " ORDER BY a.StartTime";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@AppDate", appDate.Date);
                    if (!string.IsNullOrEmpty(excludeAppId))
                        cmd.Parameters.AddWithValue("@ExcludeAppID", excludeAppId);

                    con.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        // Track already-added slots to avoid duplicates (same appointment with multiple services)
                        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                        while (rdr.Read())
                        {
                            string empId = rdr["Emp_ID"]?.ToString();
                            if (string.IsNullOrEmpty(empId)) continue;

                            TimeSpan start;
                            var startVal = rdr["StartTime"];
                            if (startVal is TimeSpan ts)
                                start = ts;
                            else if (!TimeSpan.TryParse(startVal?.ToString(), out start))
                                continue;

                            int durationMins = Convert.ToInt32(rdr["TotalDuration"]);
                            if (durationMins <= 0) durationMins = 60;
                            TimeSpan end = start.Add(TimeSpan.FromMinutes(durationMins));

                            string slot = start.ToString(@"hh\:mm") + "–" + end.ToString(@"hh\:mm");
                            string key = empId + "|" + slot;
                            if (seen.Contains(key)) continue;
                            seen.Add(key);

                            if (!result.ContainsKey(empId))
                                result[empId] = new List<string>();
                            result[empId].Add(slot);
                        }
                    }
                }
            }
            catch { }

            return result;
        }

        /// <summary>
        /// Returns a set of employee IDs that have conflicting appointments on the given date/time window.
        /// </summary>
        private HashSet<string> GetBusyEmployeeIds(DateTime appDate, TimeSpan newStart, TimeSpan newEnd, string excludeAppId)
        {
            var busy = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            string query = @"
                SELECT DISTINCT ast.Emp_ID
                FROM AppointmentsTbl a
                INNER JOIN AppointmentServiceTbl ast ON a.AppID = ast.AppID
                WHERE a.AppDate = @AppDate
                  AND a.Status IN ('Pending', 'Booked')
                  AND ast.Emp_ID IS NOT NULL
                  AND a.StartTime < @NewEnd
                  AND DATEADD(MINUTE,
                        ISNULL((SELECT SUM(ast2.DurationAtTime) FROM AppointmentServiceTbl ast2 WHERE ast2.AppID = a.AppID), 60),
                        CAST(a.StartTime AS DATETIME)) > CAST(@NewStart AS DATETIME)";

            if (!string.IsNullOrEmpty(excludeAppId))
                query += " AND a.AppID <> @ExcludeAppID";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@AppDate", appDate.Date);
                    cmd.Parameters.AddWithValue("@NewStart", newStart);
                    cmd.Parameters.AddWithValue("@NewEnd", newEnd);
                    if (!string.IsNullOrEmpty(excludeAppId))
                        cmd.Parameters.AddWithValue("@ExcludeAppID", excludeAppId);

                    con.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string empId = rdr["Emp_ID"]?.ToString();
                            if (!string.IsNullOrEmpty(empId))
                                busy.Add(empId);
                        }
                    }
                }
            }
            catch { }

            return busy;
        }

        // Load all services into dropdown
        private void LoadAllServices()
        {
            ddlService.Items.Clear();
            ddlService.Items.Add(new ListItem("-- Select Service --", ""));

            string query = @"SELECT s.Service_ID, s.Service_Name, s.Price, c.Category_Name
                             FROM ServiceTbl s
                             LEFT JOIN ServiceCategoryTbl c ON s.Category_ID = c.Category_ID
                             ORDER BY c.Category_Name, s.Service_Name";
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string serviceId = rdr["Service_ID"].ToString();
                            string name = rdr["Service_Name"].ToString();
                            decimal price = rdr.GetDecimal(rdr.GetOrdinal("Price"));
                            string category = rdr["Category_Name"]?.ToString() ?? "";
                            string displayText = string.IsNullOrEmpty(category)
                                ? $"{name} - Rs. {price:N2}"
                                : $"{name} - Rs. {price:N2} ({category})";
                            ddlService.Items.Add(new ListItem(displayText, serviceId));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load services: " + ex.Message, false);
            }
        }

        // --- Autocomplete WebMethods ---

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<string> GetCustomerSuggestions(string prefixText, int count)
        {
            var results = new List<string>();
            if (string.IsNullOrWhiteSpace(prefixText)) return results;

            using (SqlConnection con = new SqlConnection(staticConnectionString))
            {
                string query = @"
                        SELECT TOP (@Count)
                               Cus_ID,
                               CONCAT(Title, ' ', CusFirst_Name, ' ', CusLast_Name) AS FullName,
                               Contact
                        FROM CustomerTbl
                        WHERE CusFirst_Name LIKE @Search + '%'
                           OR CusLast_Name LIKE @Search + '%'
                           OR CONCAT(Title, ' ', CusFirst_Name, ' ', CusLast_Name) LIKE @Search + '%'
                        ORDER BY CusFirst_Name, CusLast_Name";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Count", count);
                    cmd.Parameters.AddWithValue("@Search", prefixText);
                    con.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string name = rdr["FullName"].ToString();
                            string contact = rdr["Contact"]?.ToString() ?? "";
                            string display = string.IsNullOrWhiteSpace(contact)
                                ? name
                                : $"{name} - {contact}";
                            results.Add(display);
                        }
                    }
                }
            }
            return results;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<string> GetEmployeeSuggestions(string prefixText, int count)
        {
            var results = new List<string>();
            if (string.IsNullOrWhiteSpace(prefixText)) return results;

            using (SqlConnection con = new SqlConnection(staticConnectionString))
            {
                string query = @"
                        SELECT TOP (@Count)
                               Emp_ID,
                               CONCAT(Title, ' ', EmpFirst_Name, ' ', EmpLast_Name, ' (', Role, ')') AS FullName
                        FROM EmpTbl
                        WHERE EmpFirst_Name LIKE @Search + '%'
                           OR EmpLast_Name LIKE @Search + '%'
                           OR CONCAT(Title, ' ', EmpFirst_Name, ' ', EmpLast_Name) LIKE @Search + '%'
                           OR Role LIKE @Search + '%'
                        ORDER BY EmpFirst_Name, EmpLast_Name";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Count", count);
                    cmd.Parameters.AddWithValue("@Search", prefixText);
                    con.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            results.Add(rdr["FullName"].ToString());
                        }
                    }
                }
            }
            return results;
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<string> GetServiceSuggestions(string prefixText, int count)
        {
            var results = new List<string>();
            if (string.IsNullOrWhiteSpace(prefixText)) return results;

            using (SqlConnection con = new SqlConnection(staticConnectionString))
            {
                string query = @"
                        SELECT TOP (@Count)
                               Service_ID, Service_Name, Price, Duration
                        FROM ServiceTbl
                        WHERE Service_ID LIKE @Search + '%'
                           OR Service_Name LIKE @Search + '%'
                        ORDER BY Service_Name";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Count", count);
                    cmd.Parameters.AddWithValue("@Search", prefixText);
                    con.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string id = rdr["Service_ID"].ToString();
                            string name = rdr["Service_Name"].ToString();
                            decimal price = rdr.GetDecimal(rdr.GetOrdinal("Price"));
                            int ordDuration = rdr.GetOrdinal("Duration");
                            TimeSpan durationTs =
                                rdr.GetFieldType(ordDuration) == typeof(TimeSpan)
                                    ? rdr.GetTimeSpan(ordDuration)
                                    : TimeSpan.FromMinutes(Convert.ToInt32(rdr["Duration"])); // Safe cast fixed

                            string hm = $"{(int)durationTs.TotalHours}.{durationTs.Minutes:D2}h";
                            results.Add($"{id} | {name} - Rs. {price:N2} ({hm})");
                        }
                    }
                }
            }
            return results;
        }

        // --- Add Service ---
        protected void btnAddService_Click(object sender, EventArgs e)
        {
            string selectedServiceId = ddlService.SelectedValue;
            if (string.IsNullOrEmpty(selectedServiceId))
            {
                ShowMessage("Please select a service.", false);
                return;
            }

            string selectedEmpId = ddlServiceEmployee.SelectedValue;
            if (string.IsNullOrEmpty(selectedEmpId))
            {
                ShowMessage("Please select an employee for this service.", false);
                return;
            }

            ServiceItem service = FetchServiceById(selectedServiceId);
            if (service == null)
            {
                ShowMessage("Service not found.", false);
                return;
            }

            // Validate employee can perform this service
            if (!CanEmployeePerformService(selectedEmpId, service.Service_ID))
            {
                ShowMessage("Selected employee is not assigned to this service.", false);
                return;
            }

            // Safety check: block unavailable employee even if disabled attribute was bypassed
            if (DateTime.TryParse(txtAppDate.Text, out DateTime checkDate)
                && !string.IsNullOrEmpty(ddlStartHour.SelectedValue)
                && !string.IsNullOrEmpty(ddlStartMinute.SelectedValue))
            {
                List<ServiceItem> existingServices = Session[SESSION_SERVICES] as List<ServiceItem> ?? new List<ServiceItem>();
                int totalDur = existingServices.Sum(s => s.Duration) + service.Duration;
                TimeSpan checkStart = TimeSpan.Parse(ddlStartHour.SelectedValue + ":" + ddlStartMinute.SelectedValue);
                TimeSpan checkEnd = checkStart.Add(TimeSpan.FromMinutes(totalDur > 0 ? totalDur : 60));
                var busy = GetBusyEmployeeIds(checkDate, checkStart, checkEnd, null);
                if (busy.Contains(selectedEmpId))
                {
                    ShowMessage("This employee is not available at the selected date/time. Please choose another employee.", false);
                    return;
                }
            }

            List<ServiceItem> selectedServices = Session[SESSION_SERVICES] as List<ServiceItem> ?? new List<ServiceItem>();

            // Check for duplicate service+employee combination
            if (selectedServices.Any(s => s.Service_ID == service.Service_ID && s.Emp_ID == selectedEmpId))
            {
                ShowMessage("This service with the same employee is already added.", false);
                return;
            }

            string empName = GetCleanEmployeeName(selectedEmpId);
            service.Emp_ID = selectedEmpId;
            service.EmployeeName = empName;

            selectedServices.Add(service);
            Session[SESSION_SERVICES] = selectedServices;

            ddlService.SelectedIndex = 0;
            ddlServiceEmployee.SelectedIndex = 0;
            BindSelectedServices();
        }

        private bool CanEmployeePerformService(string empId, string serviceId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT COUNT(*) FROM EmployeeServiceTbl WHERE Emp_ID = @Emp_ID AND Service_ID = @Service_ID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Emp_ID", empId);
                    cmd.Parameters.AddWithValue("@Service_ID", serviceId);
                    con.Open();
                    int count = (int)cmd.ExecuteScalar();
                    return count > 0;
                }
            }
        }

        private string GetCleanEmployeeName(string empId)
        {
            if (string.IsNullOrWhiteSpace(empId)) return empId;
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT CONCAT(Title, ' ', EmpFirst_Name, ' ', EmpLast_Name, ' (', Role, ')') AS FullName FROM EmpTbl WHERE Emp_ID = @Emp_ID", con))
                {
                    cmd.Parameters.AddWithValue("@Emp_ID", empId);
                    con.Open();
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? result.ToString() : empId;
                }
            }
            catch
            {
                return empId;
            }
        }

        private string ExtractLeadingId(string input)
        {
            int pipeIndex = input.IndexOf('|');
            if (pipeIndex > 0)
            {
                return input.Substring(0, pipeIndex).Trim();
            }
            var parts = input.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            return parts.Length > 0 ? parts[0].Trim() : input;
        }

        private string ResolveCustomerId(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return null;
            input = input.Trim();

            // Backward compatibility: formats with explicit ID prefix ("ID | Name")
            if (input.IndexOf('|') > 0)
            {
                var id = ExtractLeadingId(input);
                if (!string.IsNullOrEmpty(id)) return id;
            }

            // New format: "Full Name - Contact"
            string namePart = input;
            string contactPart = null;
            int dashIndex = input.LastIndexOf('-');
            if (dashIndex > 0)
            {
                namePart = input.Substring(0, dashIndex).Trim();
                contactPart = input.Substring(dashIndex + 1).Trim();
            }

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();

                // 1) Try to resolve by contact number if present
                if (!string.IsNullOrWhiteSpace(contactPart))
                {
                    var sqlByContact = @"SELECT TOP 1 Cus_ID FROM CustomerTbl WHERE Contact = @Contact";
                    using (var cmd = new SqlCommand(sqlByContact, con))
                    {
                        cmd.Parameters.AddWithValue("@Contact", contactPart);
                        var result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            return result.ToString();
                    }
                }

                // 2) Fallback: resolve by name only
                var sqlByName = @"SELECT TOP 1 Cus_ID FROM CustomerTbl
                                  WHERE LTRIM(CONCAT(ISNULL(Title,''), ' ', CusFirst_Name, ' ', CusLast_Name)) = @Name
                                     OR CONCAT(CusFirst_Name, ' ', CusLast_Name) = @Name";
                using (var cmd = new SqlCommand(sqlByName, con))
                {
                    cmd.Parameters.AddWithValue("@Name", namePart);
                    var result = cmd.ExecuteScalar();
                    return result?.ToString();
                }
            }
        }

        private string ResolveEmployeeId(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return null;
            input = input.Trim();

            // Backward compatibility: formats with explicit ID prefix ("ID | Name")
            if (input.IndexOf('|') > 0)
            {
                var id = ExtractLeadingId(input);
                if (!string.IsNullOrEmpty(id)) return id;
            }

            // New format: "Full Name (Role) - Contact"
            string namePart = input;
            string contactPart = null;
            int dashIndex = input.LastIndexOf('-');
            if (dashIndex > 0)
            {
                namePart = input.Substring(0, dashIndex).Trim();
                contactPart = input.Substring(dashIndex + 1).Trim();
            }

            using (var con = new SqlConnection(connectionString))
            {
                con.Open();

                // 1) Try to resolve by contact number if present
                if (!string.IsNullOrWhiteSpace(contactPart))
                {
                    var sqlByContact = @"SELECT TOP 1 Emp_ID FROM EmpTbl WHERE Contact = @Contact";
                    using (var cmd = new SqlCommand(sqlByContact, con))
                    {
                        cmd.Parameters.AddWithValue("@Contact", contactPart);
                        var result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            return result.ToString();
                    }
                }

                // 2) Fallback: resolve by name only
                var sqlByName = @"SELECT TOP 1 Emp_ID FROM EmpTbl
                                  WHERE LTRIM(CONCAT(ISNULL(Title,''), ' ', EmpFirst_Name, ' ', EmpLast_Name, ' (', ISNULL(Role,''), ')')) = @Name
                                     OR LTRIM(CONCAT(ISNULL(Title,''), ' ', EmpFirst_Name, ' ', EmpLast_Name)) = @Name
                                     OR CONCAT(EmpFirst_Name, ' ', EmpLast_Name) = @Name";
                using (var cmd = new SqlCommand(sqlByName, con))
                {
                    cmd.Parameters.AddWithValue("@Name", namePart);
                    var result = cmd.ExecuteScalar();
                    return result?.ToString();
                }
            }
        }

        private ServiceItem FetchServiceSmart(string input)
        {
            string id = ExtractLeadingId(input);
            ServiceItem byId = FetchServiceByField("Service_ID", id);
            if (byId != null) return byId;
            return FetchServiceByField("Service_Name", input);
        }

        private ServiceItem FetchServiceById(string serviceId)
        {
            return FetchServiceByField("Service_ID", serviceId);
        }

        private ServiceItem FetchServiceByField(string fieldName, string value)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = $@"SELECT TOP 1 Service_ID, Service_Name, Price, Duration
                                      FROM ServiceTbl
                                      WHERE {fieldName} = @Value";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Value", value);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int ordPrice = reader.GetOrdinal("Price");
                            int ordDuration = reader.GetOrdinal("Duration");
                            TimeSpan durationTs =
                                reader.GetFieldType(ordDuration) == typeof(TimeSpan)
                                    ? reader.GetTimeSpan(ordDuration)
                                    : TimeSpan.FromMinutes(Convert.ToInt32(reader[ordDuration])); // Safe cast fixed

                            return new ServiceItem
                            {
                                Service_ID = reader["Service_ID"].ToString(),
                                Service_Name = reader["Service_Name"].ToString(),
                                Price = reader.GetDecimal(ordPrice),
                                DurationTimeSpan = durationTs
                            };
                        }
                    }
                }
            }
            return null;
        }

        protected void rptServices_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "RemoveService")
            {
                string arg = e.CommandArgument.ToString();
                string[] parts = arg.Split('|');
                string serviceId = parts[0];
                string empId = parts.Length > 1 ? parts[1] : null;

                List<ServiceItem> selectedServices = Session[SESSION_SERVICES] as List<ServiceItem> ?? new List<ServiceItem>();
                if (empId != null)
                    selectedServices.RemoveAll(s => s.Service_ID == serviceId && s.Emp_ID == empId);
                else
                    selectedServices.RemoveAll(s => s.Service_ID == serviceId);
                Session[SESSION_SERVICES] = selectedServices;
                BindSelectedServices();
            }
        }

        private void BindSelectedServices()
        {
            List<ServiceItem> selectedServices = Session[SESSION_SERVICES] as List<ServiceItem> ?? new List<ServiceItem>();

            if (selectedServices.Count > 0)
            {
                rptServices.DataSource = selectedServices;
                rptServices.DataBind();
                lblNoServices.Visible = false;
                lblTotalAmount.Text = selectedServices.Sum(s => s.Price).ToString("N2");

                int totalMins = selectedServices.Sum(s => s.Duration);
                int hours = totalMins / 60;
                int mins = totalMins % 60;
                string durationText;
                if (hours > 0 && mins > 0) durationText = $"{hours}h {mins}m";
                else if (hours > 0) durationText = $"{hours}h";
                else durationText = $"{mins}m";
                lblTotalDuration.Text = durationText;
            }
            else
            {
                rptServices.DataSource = null;
                rptServices.DataBind();
                lblNoServices.Visible = true;
                lblTotalAmount.Text = "0.00";
                lblTotalDuration.Text = "0m";
            }

            upServices.Update();
        }

        protected void btnSaveAppointment_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string customerRaw = txtCustomer.Text.Trim();

            if (string.IsNullOrEmpty(customerRaw))
            {
                ShowMessage("Customer is required.", false);
                return;
            }

            // Extract ID (Cus_ID) - from "ID | Name" format or look up by name
            string customerId = ResolveCustomerId(customerRaw);
            string customerName = ExtractNamePortion(customerRaw);
            if (string.IsNullOrEmpty(customerId))
            {
                ShowMessage("Customer not found. Please select a customer from the list.", false);
                return;
            }

            List<ServiceItem> selectedServices = Session[SESSION_SERVICES] as List<ServiceItem> ?? new List<ServiceItem>();
            if (selectedServices.Count == 0)
            {
                ShowMessage("Please add at least one service.", false);
                return;
            }

            if (!DateTime.TryParse(txtAppDate.Text, out DateTime appDate))
            {
                ShowMessage("Invalid appointment date.", false);
                return;
            }

            if (appDate.Date < DateTime.Today)
            {
                ShowMessage("Appointment date cannot be before the booking date.", false);
                return;
            }

            if (string.IsNullOrEmpty(ddlStartHour.SelectedValue) || string.IsNullOrEmpty(ddlStartMinute.SelectedValue))
            {
                ShowMessage("Start time incomplete.", false);
                return;
            }

            string startTime = ddlStartHour.SelectedValue + ":" + ddlStartMinute.SelectedValue;
            int totalDuration = selectedServices.Sum(s => s.Duration);
            TimeSpan startTs = TimeSpan.Parse(startTime);
            if (appDate.Date == DateTime.Today && startTs < DateTime.Now.TimeOfDay)
            {
                ShowMessage("Start time must be later than the current time.", false);
                return;
            }
            TimeSpan endTs = startTs.Add(TimeSpan.FromMinutes(totalDuration));
            string endTime = endTs.ToString(@"hh\:mm");

            // --- Requirement 2 & 4: Check employee availability / prevent time conflicts ---
            string conflictMessage = CheckEmployeeConflicts(selectedServices, appDate, startTs, endTs, null);
            if (!string.IsNullOrEmpty(conflictMessage))
            {
                ShowMessage(conflictMessage, false);
                return;
            }

            decimal totalAmount = selectedServices.Sum(s => s.Price);
            DateTime bookingDate = DateTime.Now;
            string appID = lblAppID.Text;

            decimal advanceAmount = 0m;
            if (!string.IsNullOrWhiteSpace(txtAdvanceAmount?.Text))
            {
                if (decimal.TryParse(txtAdvanceAmount.Text.Trim(), out decimal adv))
                {
                    if (adv < 0) adv = 0;
                    if (adv > totalAmount) adv = totalAmount; // cap
                    advanceAmount = adv;
                }
                else
                {
                    ShowMessage("Invalid advance amount.", false);
                    return;
                }
            }
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                using (SqlTransaction tran = con.BeginTransaction())
                {
                    try
                    {
                        string insertApp = @"INSERT INTO AppointmentsTbl
                            (AppID, Cus_ID, AppDate, StartTime, BookingDate, TotalAmount, AdvanceAmount, Status)
                            VALUES
                            (@AppID, @Cus_ID, @AppDate, @StartTime, @BookingDate, @TotalAmount, @AdvanceAmount, @Status)";
                        using (SqlCommand cmd = new SqlCommand(insertApp, con, tran))
                        {
                            cmd.Parameters.AddWithValue("@AppID", appID);
                            cmd.Parameters.AddWithValue("@Cus_ID", customerId);
                            cmd.Parameters.AddWithValue("@AppDate", appDate);
                            cmd.Parameters.AddWithValue("@StartTime", startTs);
                            cmd.Parameters.AddWithValue("@BookingDate", bookingDate);
                            cmd.Parameters.AddWithValue("@TotalAmount", totalAmount);
                            cmd.Parameters.AddWithValue("@AdvanceAmount", advanceAmount);
                            cmd.Parameters.AddWithValue("@Status", DEFAULT_STATUS);
                            int rows = cmd.ExecuteNonQuery();
                            if (rows <= 0)
                            {
                                tran.Rollback();
                                ShowMessage("Appointment not saved.", false);
                                return;
                            }
                        }

                        string appServiceId = GetNextAppServiceID(con, tran);
                        string insertSvc = @"INSERT INTO AppointmentServiceTbl (AppServiceID, AppID, Service_ID, PriceAtTime, DurationAtTime, Emp_ID)
                            VALUES (@AppServiceID, @AppID, @Service_ID, @PriceAtTime, @DurationAtTime, @Emp_ID)";
                        foreach (var svc in selectedServices)
                        {
                            using (SqlCommand cmd = new SqlCommand(insertSvc, con, tran))
                            {
                                cmd.Parameters.AddWithValue("@AppServiceID", appServiceId);
                                cmd.Parameters.AddWithValue("@AppID", appID);
                                cmd.Parameters.AddWithValue("@Service_ID", svc.Service_ID);
                                cmd.Parameters.AddWithValue("@PriceAtTime", svc.Price);
                                cmd.Parameters.AddWithValue("@DurationAtTime", svc.Duration);
                                cmd.Parameters.AddWithValue("@Emp_ID", string.IsNullOrWhiteSpace(svc.Emp_ID) ? (object)DBNull.Value : svc.Emp_ID);
                                cmd.ExecuteNonQuery();
                            }
                            appServiceId = GetNextAppServiceID(con, tran);
                        }

                        tran.Commit();
                        RegisterAlertAndReload($"Appointment {appID} for {customerName} saved successfully! ✅");
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        ShowMessage("Error saving appointment: " + ex.Message, false);
                    }
                }
            }
        }

        /// <summary>
        /// Checks if any of the selected employees have overlapping appointments on the given date/time.
        /// Returns a conflict message if overlap found, or null if no conflicts.
        /// </summary>
        private string CheckEmployeeConflicts(List<ServiceItem> services, DateTime appDate, TimeSpan newStart, TimeSpan newEnd, string excludeAppId)
        {
            // Group by employee to check each one
            var employeeIds = services
                .Where(s => !string.IsNullOrWhiteSpace(s.Emp_ID))
                .Select(s => s.Emp_ID)
                .Distinct()
                .ToList();

            if (employeeIds.Count == 0) return null;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                foreach (string empId in employeeIds)
                {
                    // Get all active appointments for this employee on the same date
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

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@EmpID", empId);
                        cmd.Parameters.AddWithValue("@AppDate", appDate.Date);
                        if (!string.IsNullOrEmpty(excludeAppId))
                            cmd.Parameters.AddWithValue("@ExcludeAppID", excludeAppId);

                        using (SqlDataReader rdr = cmd.ExecuteReader())
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
                                if (durationMins <= 0) durationMins = 60; // default 1 hour if unknown
                                TimeSpan existingEnd = existingStart.Add(TimeSpan.FromMinutes(durationMins));

                                string empName = rdr["EmpName"]?.ToString() ?? empId;
                                string existingAppId = rdr["AppID"]?.ToString() ?? "";

                                // Check overlap: newStart < existingEnd AND newEnd > existingStart
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

        private string ExtractNamePortion(string raw)
        {
            int pipeIndex = raw.IndexOf('|');
            if (pipeIndex >= 0 && pipeIndex + 1 < raw.Length)
            {
                return raw.Substring(pipeIndex + 1).Trim();
            }
            return raw;
        }

        protected void rptAppointments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string appId = e.CommandArgument?.ToString();

            if (e.CommandName == "DeleteAppointment")
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(connectionString))
                    {
                        con.Open();
                        using (SqlTransaction tran = con.BeginTransaction())
                        {
                            try
                            {
                                // Attempt to remove related invoice records first (InvoiceServices -> Invoice)
                                // This prevents FK constraint violations when an appointment has generated invoices.
                                string deleteInvoiceServices = @"DELETE FROM InvoiceServicesTbl WHERE InvoiceID IN (SELECT InvoiceID FROM InvoiceTbl WHERE AppID = @AppID)";
                                using (SqlCommand invSvcCmd = new SqlCommand(deleteInvoiceServices, con, tran))
                                {
                                    invSvcCmd.Parameters.AddWithValue("@AppID", appId);
                                    invSvcCmd.ExecuteNonQuery();
                                }

                                string deleteInvoice = @"DELETE FROM InvoiceTbl WHERE AppID = @AppID";
                                using (SqlCommand invCmd = new SqlCommand(deleteInvoice, con, tran))
                                {
                                    invCmd.Parameters.AddWithValue("@AppID", appId);
                                    invCmd.ExecuteNonQuery();
                                }

                                // Delete appointment service child records
                                string deleteSvc = "DELETE FROM AppointmentServiceTbl WHERE AppID = @AppID";
                                using (SqlCommand svcCmd = new SqlCommand(deleteSvc, con, tran))
                                {
                                    svcCmd.Parameters.AddWithValue("@AppID", appId);
                                    svcCmd.ExecuteNonQuery();
                                }

                                // Delete the appointment
                                string deleteApp = "DELETE FROM AppointmentsTbl WHERE AppID = @AppID";
                                using (SqlCommand cmd = new SqlCommand(deleteApp, con, tran))
                                {
                                    cmd.Parameters.AddWithValue("@AppID", appId);
                                    int rows = cmd.ExecuteNonQuery();
                                    if (rows > 0)
                                    {
                                        tran.Commit();
                                        RegisterAlertAndReload($"Appointment {appId} deleted successfully.");
                                        return;
                                    }
                                    else
                                    {
                                        tran.Rollback();
                                        ShowMessage("No appointment deleted.", false);
                                    }
                                }
                            }
                            catch (Exception)
                            {
                                tran.Rollback();
                                throw;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    // If deletion fails due to FK constraints or other issues, show a friendly message.
                    ShowMessage("Error deleting appointment: " + ex.Message, false);
                }
                finally
                {
                    LoadAppointments();
                }
            }
            else if (e.CommandName == "EditAppointment")
            {
                if (!string.IsNullOrWhiteSpace(appId))
                {
                    // Check appointment status before allowing edit
                    string status = null;
                    using (SqlConnection con = new SqlConnection(connectionString))
                    {
                        string query = "SELECT Status, AppDate FROM AppointmentsTbl WHERE AppID = @AppID";
                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@AppID", appId);
                            con.Open();
                            using (var rdr = cmd.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    status = rdr["Status"]?.ToString();
                                    // Also check for expired (Pending + past date)
                                    if (status != null && status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                                    {
                                        var appDateObj = rdr["AppDate"];
                                        if (appDateObj != null && appDateObj != DBNull.Value)
                                        {
                                            DateTime appDate = Convert.ToDateTime(appDateObj);
                                            if (appDate.Date < DateTime.Today)
                                                status = "Expired";
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (status != null)
                    {
                        if (status.Equals("Expired", StringComparison.OrdinalIgnoreCase))
                        {
                            ShowMessage("Expired appointments cannot be edited.", false);
                            return;
                        }
                        else if (status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase) || status.Equals("Canceled", StringComparison.OrdinalIgnoreCase))
                        {
                            ShowMessage("Cancelled appointments cannot be edited.", false);
                            return;
                        }
                        else if (status.Equals("Done", StringComparison.OrdinalIgnoreCase))
                        {
                            ShowMessage("Completed appointments cannot be edited.", false);
                            return;
                        }
                    }
                    Response.Redirect("EditAppointmentDetails.aspx?AppID=" + HttpUtility.UrlEncode(appId), false);
                    Context.ApplicationInstance.CompleteRequest();
                }
            }
            else if (e.CommandName == "CancelAppointment")
            {
                // Prevent cancelling if status is Done
                string status = null;
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = "SELECT Status FROM AppointmentsTbl WHERE AppID = @AppID";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@AppID", appId);
                        con.Open();
                        status = cmd.ExecuteScalar()?.ToString();
                    }
                }
                if (status != null && status.Equals("Done", StringComparison.OrdinalIgnoreCase))
                {
                    ShowMessage("Completed appointments cannot be cancelled.", false);
                    return;
                }
                try
                {
                    using (SqlConnection con = new SqlConnection(connectionString))
                    {
                        string query = "UPDATE AppointmentsTbl SET Status = @Status WHERE AppID = @AppID";
                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@Status", "Cancelled");
                            cmd.Parameters.AddWithValue("@AppID", appId);
                            con.Open();
                            int rows = cmd.ExecuteNonQuery();
                            if (rows > 0)
                            {
                                RegisterAlertAndReload($"Appointment {appId} marked as cancelled.");
                                return;
                            }
                            ShowMessage("No appointment updated.", false);
                        }
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage("Error cancelling appointment: " + ex.Message, false);
                }
                finally
                {
                    LoadAppointments();
                }
            }
        }

        private void LoadEmployeeServiceMap()
        {
            _employeeServiceMap.Clear();
            string query = @"
                SELECT ast.AppID,
                       ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(ISNULL(e.Title, ''), ' ', e.EmpFirst_Name, ' ', e.EmpLast_Name))), ''), 'Not Assigned') AS EmpName,
                       s.Service_Name
                FROM AppointmentServiceTbl ast
                INNER JOIN ServiceTbl s ON ast.Service_ID = s.Service_ID
                LEFT JOIN EmpTbl e ON ast.Emp_ID = e.Emp_ID
                ORDER BY ast.AppID, EmpName, s.Service_Name";
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        var data = new Dictionary<string, Dictionary<string, List<string>>>();
                        while (rdr.Read())
                        {
                            string appId = rdr["AppID"]?.ToString() ?? "";
                            string emp = rdr["EmpName"]?.ToString()?.Trim() ?? "Not Assigned";
                            string svc = rdr["Service_Name"]?.ToString() ?? "";
                            if (!data.ContainsKey(appId))
                                data[appId] = new Dictionary<string, List<string>>();
                            if (!data[appId].ContainsKey(emp))
                                data[appId][emp] = new List<string>();
                            data[appId][emp].Add(svc);
                        }
                        foreach (var app in data)
                        {
                            var sb = new StringBuilder();
                            foreach (var kvp in app.Value)
                            {
                                sb.Append("<div class='emp-service-group'>");
                                sb.Append("<span class='emp-service-name'><i class='fas fa-user-tie'></i> " + HttpUtility.HtmlEncode(kvp.Key) + "</span>");
                                sb.Append("<ul class='emp-service-list'>");
                                foreach (var svc in kvp.Value)
                                {
                                    sb.Append("<li>" + HttpUtility.HtmlEncode(svc) + "</li>");
                                }
                                sb.Append("</ul></div>");
                            }
                            _employeeServiceMap[app.Key] = sb.ToString();
                        }
                    }
                }
            }
            catch { }
        }

        public string GetEmployeeServicesHtml(object appId)
        {
            if (appId == null) return "";
            string id = appId.ToString();
            return _employeeServiceMap.ContainsKey(id) ? _employeeServiceMap[id] : "\u2014";
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            // Optionally implement inline messaging or use simple JS alert
            string script = $"alert('{HttpUtility.JavaScriptStringEncode(message)}');";
            ScriptManager.RegisterStartupScript(Page, GetType(), Guid.NewGuid().ToString(), script, true);
        }

        private void RegisterAlertAndReload(string message)
        {
            string encodedMsg = HttpUtility.JavaScriptStringEncode(message);
            string encodedUrl = HttpUtility.JavaScriptStringEncode(Request.RawUrl ?? "AppointmentBooking.aspx");
            string script = $"alert('{encodedMsg}'); window.location = '{encodedUrl}';";
            ScriptManager.RegisterStartupScript(Page, GetType(), Guid.NewGuid().ToString(), script, true);
        }

        [Serializable]
        public class ServiceItem
        {
            public string Service_ID { get; set; }
            public string Service_Name { get; set; }
            public decimal Price { get; set; }
            public TimeSpan DurationTimeSpan { get; set; }
            public string Emp_ID { get; set; }
            public string EmployeeName { get; set; }
            public int Duration => (int)DurationTimeSpan.TotalMinutes;
            public string DurationHoursMinutes => $"{(int)DurationTimeSpan.TotalHours}.{DurationTimeSpan.Minutes:D2} hours";
            public string DurationDisplay
            {
                get
                {
                    int hours = (int)DurationTimeSpan.TotalHours;
                    int minutes = DurationTimeSpan.Minutes;
                    if (hours > 0 && minutes > 0) return $"{hours}h {minutes}m";
                    if (hours > 0) return $"{hours}h";
                    return $"{minutes}m";
                }
            }
        }
    }
}