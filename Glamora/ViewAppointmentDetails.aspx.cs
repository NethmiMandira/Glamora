using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Management;
using System.Web.UI;

namespace Glamora
{
    public partial class ViewAppointmentDetails : Page
    {
        private readonly string connectionString =
            "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        // Controls declared in markup but not present in designer file for some workspaces.
        // Declare here so code-behind can access them directly and control visibility/enabled state.
        protected global::System.Web.UI.WebControls.LinkButton lnkEdit;
        protected global::System.Web.UI.WebControls.LinkButton lnkCancel;
        protected global::System.Web.UI.WebControls.LinkButton lnkDelete;
        protected global::System.Web.UI.WebControls.LinkButton lnkInvoice;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // ensure action links start hidden until we evaluate appointment state
                try
                {
                    if (lnkEdit != null) lnkEdit.Visible = false;
                    if (lnkCancel != null) lnkCancel.Visible = false;
                    if (lnkDelete != null) lnkDelete.Visible = false;
                    if (lnkInvoice != null) lnkInvoice.Visible = false;
                }
                catch { }
                // Accept both "AppID" and "id" for backward compatibility
                string appId = (Request.QueryString["AppID"] ?? Request.QueryString["id"] ?? string.Empty).Trim();
                if (!string.IsNullOrEmpty(appId))
                {
                    LoadAppointmentDetails(appId);
                }
                else
                {
                    Response.Redirect("AppointmentsList.aspx");
                }
            }
        }

        private void LoadAppointmentDetails(string appId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string sql = @"
                    SELECT a.AppID, a.AppDate, a.StartTime, a.BookingDate, a.TotalAmount, a.AdvanceAmount, a.Status,
                           c.Cus_ID, c.Title AS CusTitle, c.CusFirst_Name, c.CusLast_Name, c.Contact AS CusContact
                    FROM AppointmentsTbl a
                    INNER JOIN CustomerTbl c ON a.Cus_ID = c.Cus_ID
                    WHERE a.AppID = @AppID";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@AppID", SqlDbType.NVarChar, 50).Value = appId;
                    try
                    {
                        con.Open();
                        using (SqlDataReader rd = cmd.ExecuteReader())
                        {
                            if (rd.Read())
                            {
                                try
                                {
                                    // Appointment ID
                                    lblAppID.Text = ToSafeString(rd["AppID"]);

                                    // Customer Name
                                    string customerName = (ToSafeString(rd["CusTitle"]).Trim() + " " + ToSafeString(rd["CusFirst_Name"]).Trim() + " " + ToSafeString(rd["CusLast_Name"]).Trim()).Trim();
                                    lblCustomer.Text = customerName;
                                    // Customer Contact
                                    lblContact.Text = string.IsNullOrWhiteSpace(ToSafeString(rd["CusContact"])) ? "-" : HttpUtility.HtmlEncode(ToSafeString(rd["CusContact"]));

                                    // AppDate (hidden)
                                    lblAppDate.Text = "-";

                                    // Start Time
                                    var startValue = rd["StartTime"];
                                    string startTimeText = string.Empty;
                                    if (startValue is TimeSpan ts)
                                        startTimeText = ts.ToString(@"hh\:mm");
                                    else if (DateTime.TryParse(Convert.ToString(startValue), out var startDt))
                                        startTimeText = startDt.ToString("HH:mm");
                                    else
                                        startTimeText = GetTimeWithoutSeconds(ToSafeString(startValue));
                                    lblStartTime.Text = !string.IsNullOrEmpty(startTimeText) ? HttpUtility.HtmlEncode(startTimeText) : "-";

                                    // Services List
                                    litServices.Text = GetServicesList(appId);

                                    // Total & Advance
                                    lblTotal.Text = FormatMoney(rd["TotalAmount"]);
                                    lblAdvance.Text = FormatMoney(rd["AdvanceAmount"]);

                                    // Status
                                    var statusRaw = ToSafeString(rd["Status"]);
                                    lblStatus.Text = statusRaw;
                                ApplyStatusStyling(statusRaw);

                                    // Determine button visibility/enabled states
                                    try
                                    {
                                        var appDateObj = SafeGet(rd, "AppDate");
                                        DateTime? appDate = TryGetDate(appDateObj);
                                        bool isLapsed = appDate.HasValue && DateTime.Now >= appDate.Value.Date.AddDays(1);
                                        var normalized = (statusRaw ?? string.Empty).Trim().ToLowerInvariant();
                                        bool isDone = normalized == "done";
                                        bool isCancelled = normalized == "cancelled" || normalized == "canceled";

                                        // Update action LinkButtons declared as protected fields.
                                        if (lnkEdit != null)
                                        {
                                            lnkEdit.Visible = !(isLapsed || isDone || isCancelled);
                                            lnkEdit.Enabled = !(isLapsed || isDone || isCancelled);
                                        }

                                        if (lnkCancel != null)
                                        {
                                            lnkCancel.Visible = !(isLapsed || isDone || isCancelled);
                                            lnkCancel.Enabled = !(isLapsed || isDone || isCancelled);
                                        }

                                        if (lnkDelete != null)
                                        {
                                            // Delete remains available regardless of status
                                            lnkDelete.Visible = true;
                                            lnkDelete.Enabled = true;
                                        }

                                        if (lnkInvoice != null)
                                        {
                                            // Match AppointmentBooking behavior: only show invoice when status is Pending
                                            lnkInvoice.Visible = (normalized == "pending");
                                            lnkInvoice.Enabled = (normalized == "pending");
                                        }
                                    }
                                    catch { }

                                    // Booking Date
                                    lblBookingDate.Text = GetDateOnlyDisplay(rd["BookingDate"]);
                                }
                                catch (Exception ex)
                                {
                                    lblAppID.Text = ToSafeString(rd["AppID"]);
                                    lblCustomer.Text = "-";
                                    lblContact.Text = "-";
                                    lblAppDate.Text = "-";
                                    lblStartTime.Text = "-";
                                    litServices.Text = "-";
                                    lblTotal.Text = FormatMoney(rd["TotalAmount"]);
                                    lblAdvance.Text = FormatMoney(rd["AdvanceAmount"]);
                                    var statusRaw = ToSafeString(rd["Status"]);
                                    lblStatus.Text = statusRaw;
                                    ApplyStatusStyling(statusRaw);
                                    lblBookingDate.Text = GetDateOnlyDisplay(rd["BookingDate"]);
                                    System.Diagnostics.Debug.WriteLine("ViewAppointmentDetails formatting fallback: " + ex.Message);
                                }
                            }
                            else
                            {
                                // No matching appointment; redirect to list
                                Response.Redirect("AppointmentsList.aspx");
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine(ex.Message);
                    }
                }
            }
        }

        private string GetCustomerContact(string customerName)
        {
            if (string.IsNullOrWhiteSpace(customerName))
                return string.Empty;

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 1 ISNULL(Contact, '') AS Contact
                    FROM CustomerTbl
                    WHERE LTRIM(RTRIM(CONCAT(ISNULL(Title,''), ' ', ISNULL(CusFirst_Name,''), ' ', ISNULL(CusLast_Name,'')))) = @Name
                       OR LTRIM(RTRIM(CONCAT(ISNULL(CusFirst_Name,''), ' ', ISNULL(CusLast_Name,'')))) = @Name", con))
                {
                    cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = customerName.Trim();
                    con.Open();
                    var result = cmd.ExecuteScalar();
                    return result == null || result == DBNull.Value ? string.Empty : Convert.ToString(result);
                }
            }
            catch
            {
                return string.Empty;
            }
        }

        private void ApplyStatusStyling(string status)
        {
            var normalized = (status ?? string.Empty).Trim().ToLowerInvariant();

            // Default class
            string cssClass = "status-badge";

            switch (normalized)
            {
                case "done":
                    cssClass += " status-done";
                    break;
                case "cancelled":
                case "canceled":
                    cssClass += " status-cancelled";
                    break;
                case "lapsed":
                    cssClass += " status-lapsed";
                    break;
                case "pending":
                case "booked":
                    cssClass += " status-pending";
                    break;
                default:
                    cssClass += " status-default";
                    break;
            }

            lblStatus.CssClass = cssClass;
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        private static DateTime? TryGetDate(object value)
        {
            if (value == null || value == DBNull.Value)
                return null;

            if (value is DateTime dt)
                return dt;

            DateTime parsed;
            return DateTime.TryParse(Convert.ToString(value), out parsed) ? parsed : (DateTime?)null;
        }

        private static string FormatMoney(object value)
        {
            if (value == null || value == DBNull.Value)
                return "-";

            decimal amount;
            if (decimal.TryParse(Convert.ToString(value), out amount))
                return "LKR " + amount.ToString("N2");

            var raw = ToSafeString(value);
            return string.IsNullOrEmpty(raw) ? "-" : HttpUtility.HtmlEncode(raw);
        }

        private static string ToSafeString(object value)
        {
            return value == null || value == DBNull.Value ? string.Empty : Convert.ToString(value);
        }

        private static object SafeGet(IDataRecord record, string columnName)
        {
            try
            {
                int ordinal = record.GetOrdinal(columnName);
                return record.IsDBNull(ordinal) ? null : record.GetValue(ordinal);
            }
            catch (IndexOutOfRangeException)
            {
                return null;
            }
        }

        private static object FirstOf(IDataRecord record, params string[] columns)
        {
            foreach (var col in columns)
            {
                var val = SafeGet(record, col);
                if (val != null && val != DBNull.Value)
                    return val;
            }
            return null;
        }

        private static string GetDateOnlyDisplay(object value)
        {
            var dt = TryGetDate(value);
            if (dt.HasValue)
                return dt.Value.ToString("dd MMM yyyy");

            var raw = ToSafeString(value);
            if (string.IsNullOrWhiteSpace(raw))
                return "-";

            // Attempt to strip time portion if present
            var datePart = raw.Split('T', ' ')[0];
            return string.IsNullOrWhiteSpace(datePart) ? HttpUtility.HtmlEncode(raw) : HttpUtility.HtmlEncode(datePart);
        }

        private static string GetTimeWithoutSeconds(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return value;

            TimeSpan ts;
            if (TimeSpan.TryParse(value, out ts))
                return ts.ToString(@"hh\:mm");

            DateTime dt;
            if (DateTime.TryParse(value, out dt))
                return dt.ToString("HH:mm");

            var parts = value.Split(':');
            if (parts.Length >= 2)
            {
                var hours = parts[0].PadLeft(2, '0');
                var minutes = parts[1].PadLeft(2, '0');
                return string.Format("{0}:{1}", hours, minutes);
            }

            return value;
        }

        private string GetServicesList(string appId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT s.Service_Name, ast.PriceAtTime,
                           ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(ISNULL(e.Title, ''), ' ', e.EmpFirst_Name, ' ', e.EmpLast_Name))), ''), 'Not Assigned') AS EmpName
                    FROM AppointmentServiceTbl ast
                    INNER JOIN ServiceTbl s ON ast.Service_ID = s.Service_ID
                    LEFT JOIN EmpTbl e ON ast.Emp_ID = e.Emp_ID
                    WHERE ast.AppID = @AppID
                    ORDER BY EmpName, s.Service_Name
                ", conn))
                {
                    cmd.Parameters.Add("@AppID", SqlDbType.NVarChar, 50).Value = appId;
                    conn.Open();
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        var grouped = new System.Collections.Generic.Dictionary<string, System.Collections.Generic.List<string>>();
                        while (rd.Read())
                        {
                            string empName = ToSafeString(rd["EmpName"]).Trim();
                            string serviceName = ToSafeString(rd["Service_Name"]);
                            string price = FormatMoney(rd["PriceAtTime"]);
                            string display = HttpUtility.HtmlEncode(serviceName) + (price != "-" ? " <span class='svc-price'>(" + HttpUtility.HtmlEncode(price) + ")</span>" : "");

                            if (!grouped.ContainsKey(empName))
                                grouped[empName] = new System.Collections.Generic.List<string>();
                            grouped[empName].Add(display);
                        }

                        if (grouped.Count == 0)
                            return "-";

                        var sb = new System.Text.StringBuilder();
                        foreach (var kvp in grouped)
                        {
                            sb.Append("<div class='emp-service-group'>");
                            sb.Append("<span class='emp-service-name'><i class='fas fa-user-tie'></i> " + HttpUtility.HtmlEncode(kvp.Key) + "</span>");
                            sb.Append("<ul class='emp-service-list'>");
                            foreach (var svc in kvp.Value)
                            {
                                sb.Append("<li>" + svc + "</li>");
                            }
                            sb.Append("</ul></div>");
                        }
                        return sb.ToString();
                    }
                }
            }
            catch
            {
                return "-";
            }
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            var appId = (lblAppID != null) ? ToSafeString(lblAppID.Text) : string.Empty;
            if (string.IsNullOrWhiteSpace(appId)) return;

            // server-side guard: check current appointment state before allowing edit
            GetAppointmentStatusInfo(appId, out string statusNormalized, out DateTime? appDate);
            bool isLapsed = appDate.HasValue && DateTime.Now >= appDate.Value.Date.AddDays(1);
            bool isDone = statusNormalized == "done";
            bool isCancelled = statusNormalized == "cancelled" || statusNormalized == "canceled";
            if (isLapsed || isDone || isCancelled)
            {
                ShowAlert("This appointment cannot be edited due to its current status.");
                return;
            }

            Response.Redirect("EditAppointmentDetails.aspx?AppID=" + Server.UrlEncode(appId), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnInvoice_Click(object sender, EventArgs e)
        {
            var appId = (lblAppID != null) ? ToSafeString(lblAppID.Text) : string.Empty;
            if (string.IsNullOrWhiteSpace(appId)) return;

            // server-side guard: cannot invoice cancelled or done appointments
            GetAppointmentStatusInfo(appId, out string statusNormalized, out DateTime? appDate);
            bool isDone = statusNormalized == "done";
            bool isCancelled = statusNormalized == "cancelled" || statusNormalized == "canceled";
            if (isDone || isCancelled)
            {
                ShowAlert("Invoice cannot be generated for completed or cancelled appointments.");
                return;
            }

            Response.Redirect("Invoice.aspx?appId=" + Server.UrlEncode(appId));
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            var appId = (lblAppID != null) ? ToSafeString(lblAppID.Text) : string.Empty;
            if (string.IsNullOrWhiteSpace(appId)) return;
            try
            {
                // server-side guard: do not allow cancel if already Done or Cancelled or lapsed
                GetAppointmentStatusInfo(appId, out string statusNormalized, out DateTime? appDate);
                bool isLapsed = appDate.HasValue && DateTime.Now >= appDate.Value.Date.AddDays(1);
                bool isDone = statusNormalized == "done";
                bool isCancelled = statusNormalized == "cancelled" || statusNormalized == "canceled";
                if (isDone || isCancelled || isLapsed)
                {
                    ShowAlert("This appointment cannot be cancelled due to its current status.");
                    return;
                }

                using (var con2 = new SqlConnection(connectionString))
                using (var cmdUpdate = new SqlCommand("UPDATE AppointmentsTbl SET Status = 'Cancelled' WHERE AppID = @AppID", con2))
                {
                    cmdUpdate.Parameters.AddWithValue("@AppID", appId);
                    con2.Open();
                    cmdUpdate.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Cancel Exception: " + ex.Message);
            }
            // reload
            LoadAppointmentDetails(appId);
        }

        // Helper: read current status and app date for the appointment
        private void GetAppointmentStatusInfo(string appId, out string statusNormalized, out DateTime? appDate)
        {
            statusNormalized = string.Empty;
            appDate = null;
            if (string.IsNullOrWhiteSpace(appId)) return;
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand("SELECT Status, AppDate FROM AppointmentsTbl WHERE AppID = @AppID", con))
                {
                    cmd.Parameters.AddWithValue("@AppID", appId);
                    con.Open();
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (rd.Read())
                        {
                            statusNormalized = ToSafeString(SafeGet(rd, "Status")).Trim().ToLowerInvariant();
                            var dt = SafeGet(rd, "AppDate");
                            appDate = TryGetDate(dt);
                        }
                    }
                }
            }
            catch { }
        }

        private void ShowAlert(string message)
        {
            try
            {
                var script = "alert('" + HttpUtility.JavaScriptStringEncode(message) + "');";
                if (System.Web.UI.ScriptManager.GetCurrent(this.Page) != null)
                    System.Web.UI.ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "msg", script, true);
                else
                    this.ClientScript.RegisterStartupScript(this.GetType(), "msg", script, true);
            }
            catch { }
        }

        protected void btnRemove_Click(object sender, EventArgs e)
        {
            var appId = (lblAppID != null) ? ToSafeString(lblAppID.Text) : string.Empty;
            if (string.IsNullOrWhiteSpace(appId)) return;
            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (var cmdChild = new SqlCommand("DELETE FROM AppointmentServiceTbl WHERE AppID = @AppID", con))
                    {
                        cmdChild.Parameters.AddWithValue("@AppID", appId);
                        cmdChild.ExecuteNonQuery();
                    }
                    using (var cmdDel = new SqlCommand("DELETE FROM AppointmentsTbl WHERE AppID = @AppID", con))
                    {
                        cmdDel.Parameters.AddWithValue("@AppID", appId);
                        cmdDel.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Remove Exception: " + ex.Message);
            }
            Response.Redirect("AppointmentsList.aspx");
        }
    }
}