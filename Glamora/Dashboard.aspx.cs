using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web.UI.HtmlControls;
using System.Web.UI;
using System.Web;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class Dashboard : Page
    {
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardStats();

                string currentFile = Path.GetFileName(Request.Url.AbsolutePath);
                string script = @"(function(){var current='" + currentFile + @"';var links=document.querySelectorAll('.nav-list a');for(var i=0;i<links.length;i++){var a=links[i];var href=a.getAttribute('href');if(!href) continue; if(href.indexOf(current)!==-1){ a.parentElement.classList.add('active'); break; }}})();";
                ClientScript.RegisterStartupScript(this.GetType(), "setActiveNav", script, true);
            }
        }

        private void LoadDashboardStats()
        {
            lblCancelAppointments.Text = GetCancelledAppointments().ToString();

            if (lblTodaysAppointments != null)
                lblTodaysAppointments.Text = GetTodaysAppointmentsCount().ToString();

            if (lblPendingToday != null)
                lblPendingToday.Text = GetTodaysPendingAppointmentsCount().ToString();

            var lblTodayDate = FindControlRecursive(this, "lblTodayDate") as Label;
            if (lblTodayDate != null)
                lblTodayDate.Text = DateTime.Now.ToString("MMMM dd, yyyy");

            var lblDone = FindControlRecursive(this, "lblDoneToday") as Label;
            if (lblDone != null)
                lblDone.Text = GetDoneTodayCount().ToString();

            var lblRevenue = FindControlRecursive(this, "lblTodaysRevenue") as Label;
            if (lblRevenue != null)
                lblRevenue.Text = GetTodaysRevenue().ToString("N2");

            var lblLast7 = FindControlRecursive(this, "lblLast7DaysRevenue") as Label;
            if (lblLast7 != null)
                lblLast7.Text = GetLast7DaysRevenue().ToString("N2");

            var lblTotal = FindControlRecursive(this, "lblTotalRevenue") as Label;
            if (lblTotal != null)
                lblTotal.Text = GetTotalRevenue().ToString("N2");

            var lblEmpCount = FindControlRecursive(this, "lblTotalEmployees") as Label;
            if (lblEmpCount != null)
                lblEmpCount.Text = GetTotalEmployeesCount().ToString();

            BindUpcomingAppointments();

        }

        // Recursive find control helper (searches all child controls)
        private Control FindControlRecursive(Control root, string id)
        {
            if (root == null) return null;
            var c = root.FindControl(id);
            if (c != null) return c;
            foreach (Control child in root.Controls)
            {
                var found = FindControlRecursive(child, id);
                if (found != null) return found;
            }
            return null;
        }

        private int GetCancelledAppointments()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // Detect status column name
                    var columns = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                    using (var cmdCols = new SqlCommand("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AppointmentsTbl';", con))
                    using (var rdr = cmdCols.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            columns.Add(rdr.GetString(0));
                        }
                    }

                    string statusCol = columns.Contains("Status") ? "Status" : null;
                    if (statusCol == null)
                        return 0;

                    string sql = $@"SELECT COUNT(*)
                                     FROM AppointmentsTbl
                                     WHERE UPPER(LTRIM(RTRIM({statusCol}))) IN ('CANCELLED','CANCELED')";

                    using (var cmd = new SqlCommand(sql, con))
                    {
                        object result = cmd.ExecuteScalar();
                        return result != null ? Convert.ToInt32(result) : 0;
                    }
                }
            }
            catch
            {
                return 0;
            }
        }

        private int GetTodaysAppointmentsCount()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT COUNT(*) 
                    FROM AppointmentsTbl 
                    WHERE TRY_CONVERT(date, AppDate) = CONVERT(date, GETDATE())", con))
                {
                    con.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch
            {
                return 0;
            }
        }

        private int GetTodaysPendingAppointmentsCount()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // detect status column
                    string statusCol = null;
                    using (var cmdCols = new SqlCommand("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AppointmentsTbl';", con))
                    using (var rdr = cmdCols.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            var col = rdr.GetString(0);
                            if (string.Equals(col, "Status", StringComparison.OrdinalIgnoreCase))
                            {
                                statusCol = col;
                                break;
                            }
                        }
                    }

                    string filter = statusCol != null
                        ? $"AND ({statusCol} IS NULL OR LTRIM(RTRIM({statusCol})) = '' OR UPPER(LTRIM(RTRIM({statusCol}))) IN ('PENDING','BOOKED'))"
                        : string.Empty;

                    string sql =
                        "SELECT COUNT(*) " +
                        "FROM AppointmentsTbl " +
                        "WHERE TRY_CONVERT(date, AppDate) = CONVERT(date, GETDATE()) " +
                        filter;

                    using (var cmd = new SqlCommand(sql, con))
                    {
                        var result = cmd.ExecuteScalar();
                        return result != null ? Convert.ToInt32(result) : 0;
                    }
                }
            }
            catch
            {
                return 0;
            }
        }

        private int GetTotalEmployeesCount()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM EmpTbl", con))
                {
                    con.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch { return 0; }
        }

        private int GetDoneTodayCount()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT COUNT(*)
                    FROM AppointmentsTbl
                    WHERE TRY_CONVERT(date, AppDate) = CONVERT(date, GETDATE())
                      AND UPPER(LTRIM(RTRIM(Status))) = 'DONE'", con))
                {
                    con.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            catch { return 0; }
        }

        private decimal GetTodaysRevenue()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(i.NetPayable), 0)
                    FROM InvoiceTbl i
                    INNER JOIN AppointmentsTbl a ON i.AppID = a.AppID
                    WHERE TRY_CONVERT(date, a.AppDate) = CONVERT(date, GETDATE())", con))
                {
                    con.Open();
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? Convert.ToDecimal(result) : 0m;
                }
            }
            catch { return 0m; }
        }

        private decimal GetLast7DaysRevenue()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(i.NetPayable), 0)
                    FROM InvoiceTbl i
                    INNER JOIN AppointmentsTbl a ON i.AppID = a.AppID
                    WHERE TRY_CONVERT(date, a.AppDate) >= DATEADD(DAY, -7, CONVERT(date, GETDATE()))
                      AND TRY_CONVERT(date, a.AppDate) <= CONVERT(date, GETDATE())", con))
                {
                    con.Open();
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? Convert.ToDecimal(result) : 0m;
                }
            }
            catch { return 0m; }
        }

        private decimal GetTotalRevenue()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(i.NetPayable), 0)
                    FROM InvoiceTbl i", con))
                {
                    con.Open();
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value ? Convert.ToDecimal(result) : 0m;
                }
            }
            catch { return 0m; }
        }

        private void BindUpcomingAppointments()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // Get upcoming appointment IDs
                    var sqlAppts = @"
                        SELECT TOP 5
                            a.AppID,
                            a.StartTime,
                            ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(ISNULL(c.Title,''),' ',c.CusFirst_Name,' ',c.CusLast_Name))),''), '') AS CustomerName
                        FROM AppointmentsTbl a
                        LEFT JOIN CustomerTbl c ON a.Cus_ID = c.Cus_ID
                        WHERE a.AppDate = CONVERT(date, GETDATE())
                          AND a.StartTime >= CONVERT(time, GETDATE())
                          AND UPPER(LTRIM(RTRIM(a.Status))) IN ('PENDING','BOOKED')
                        ORDER BY a.StartTime ASC";

                    var dtAppts = new DataTable();
                    using (var da = new SqlDataAdapter(sqlAppts, con))
                        da.Fill(dtAppts);

                    // For each appointment, get employee-service groupings
                    var appIds = new List<string>();
                    foreach (DataRow row in dtAppts.Rows)
                        appIds.Add(row["AppID"].ToString());

                    if (appIds.Count > 0)
                    {
                        var paramNames = new List<string>();
                        var cmd = new SqlCommand();
                        cmd.Connection = con;
                        for (int i = 0; i < appIds.Count; i++)
                        {
                            paramNames.Add("@a" + i);
                            cmd.Parameters.AddWithValue("@a" + i, appIds[i]);
                        }
                        cmd.CommandText = string.Format(@"
                            SELECT
                                ast.AppID,
                                ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(ISNULL(e.Title,''),' ',e.EmpFirst_Name,' ',e.EmpLast_Name))),''), 'Not Assigned') AS EmpName,
                                ISNULL(s.Service_Name, '') AS ServiceName
                            FROM AppointmentServiceTbl ast
                            LEFT JOIN EmpTbl e ON ast.Emp_ID = e.Emp_ID
                            LEFT JOIN ServiceTbl s ON ast.Service_ID = s.Service_ID
                            WHERE ast.AppID IN ({0})
                            ORDER BY ast.AppID, EmpName, ServiceName", string.Join(",", paramNames));

                        var dtDetails = new DataTable();
                        using (var da2 = new SqlDataAdapter(cmd))
                            da2.Fill(dtDetails);

                        // Build lookup: AppID -> List<{EmpName, ServiceName}>
                        _upcomingEmpServices = new Dictionary<string, List<EmpService>>(StringComparer.OrdinalIgnoreCase);
                        foreach (DataRow dr in dtDetails.Rows)
                        {
                            var appId = dr["AppID"].ToString();
                            if (!_upcomingEmpServices.ContainsKey(appId))
                                _upcomingEmpServices[appId] = new List<EmpService>();
                            _upcomingEmpServices[appId].Add(new EmpService
                            {
                                EmpName = dr["EmpName"].ToString(),
                                ServiceName = dr["ServiceName"].ToString()
                            });
                        }
                    }

                    var rpt = FindControlRecursive(this, "rptUpcoming") as Repeater;
                    var pnl = FindControlRecursive(this, "pnlNoUpcoming") as Panel;
                    if (rpt != null)
                    {
                        rpt.DataSource = dtAppts;
                        rpt.DataBind();
                    }
                    if (pnl != null)
                        pnl.Visible = dtAppts.Rows.Count == 0;
                }
            }
            catch
            {
                var pnl = FindControlRecursive(this, "pnlNoUpcoming") as Panel;
                if (pnl != null) pnl.Visible = true;
            }
        }

        private Dictionary<string, List<EmpService>> _upcomingEmpServices;

        protected string GetUpcomingEmpServicesHtml(object appIdObj)
        {
            if (appIdObj == null) return string.Empty;
            var appId = appIdObj.ToString();
            if (_upcomingEmpServices == null || !_upcomingEmpServices.ContainsKey(appId))
                return string.Empty;

            var items = _upcomingEmpServices[appId];
            // Group services by employee
            var grouped = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);
            foreach (var item in items)
            {
                if (!grouped.ContainsKey(item.EmpName))
                    grouped[item.EmpName] = new List<string>();
                if (!string.IsNullOrWhiteSpace(item.ServiceName))
                    grouped[item.EmpName].Add(item.ServiceName);
            }

            var sb = new System.Text.StringBuilder();
            foreach (var kvp in grouped)
            {
                sb.AppendFormat("<div class=\"upcoming-emp-group\"><div class=\"upcoming-emp-name\"><i class=\"fas fa-user-tie\"></i> {0}</div>",
                    HttpUtility.HtmlEncode(kvp.Key));
                foreach (var svc in kvp.Value)
                {
                    sb.AppendFormat("<div class=\"upcoming-emp-svc\">{0}</div>",
                        HttpUtility.HtmlEncode(svc));
                }
                sb.Append("</div>");
            }
            return sb.ToString();
        }

        private class EmpService
        {
            public string EmpName { get; set; }
            public string ServiceName { get; set; }
        }

        protected string FormatTimeShort(object value)
        {
            if (value == null || value == DBNull.Value) return "";
            try
            {
                if (value is TimeSpan ts)
                    return DateTime.Today.Add(ts).ToString("hh:mm tt");
                DateTime dt;
                if (DateTime.TryParse(value.ToString(), out dt))
                    return dt.ToString("hh:mm tt");
                return value.ToString();
            }
            catch { return ""; }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
