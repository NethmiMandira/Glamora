using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class TodaysAppointments : Page
    {
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        private Dictionary<string, string> _employeeServiceMap = new Dictionary<string, string>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Optional: show today's date if you have a label on the page
                var lbl = FindControl("lblTodayDate") as Label;
                if (lbl != null) lbl.Text = DateTime.Now.ToString("MMMM dd, yyyy");

                LoadAppointments();
            }
        }

        private void LoadAppointments()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();

                    string sql = @"
                        SELECT a.AppID,
                               c.Title + ' ' + c.CusFirst_Name + ' ' + c.CusLast_Name AS Customer_name,
                               c.Contact AS Customer_contact,
                               a.AppDate,
                               a.StartTime AS Start_time,
                               NULL AS End_time,
                               (
                                   SELECT STRING_AGG(s.Service_Name, ', ')
                                   FROM AppointmentServiceTbl ast
                                   INNER JOIN ServiceTbl s ON ast.Service_ID = s.Service_ID
                                   WHERE ast.AppID = a.AppID
                               ) AS Services,
                               a.TotalAmount AS Total_amount,
                               ISNULL(a.AdvanceAmount, 0) AS Advance_amount,
                               '' AS Payment_method,
                               a.Status AS Status,
                               a.BookingDate AS Booking_date
                        FROM AppointmentsTbl a
                        INNER JOIN CustomerTbl c ON a.Cus_ID = c.Cus_ID
                        WHERE CAST(a.AppDate AS DATE) = @today
                        ORDER BY a.StartTime ASC, a.AppID ASC;";

                    using (var da = new SqlDataAdapter(sql, con))
                    {
                        da.SelectCommand.Parameters.Add("@today", SqlDbType.Date).Value = DateTime.Today;

                        var dt = new DataTable();
                        da.Fill(dt);

                        dt.Columns.Add("Balance_amount", typeof(decimal));
                        dt.Columns.Add("IsExpired", typeof(bool));
                        dt.Columns.Add("IsDone", typeof(bool));
                        dt.Columns.Add("IsInvoiceAllowed", typeof(bool));

                        foreach (DataRow row in dt.Rows)
                        {
                            decimal total = row.Field<decimal>("Total_amount");
                            decimal advance = row.Field<decimal>("Advance_amount");
                            row["Balance_amount"] = Math.Max(0m, total - advance);

                            // Lapsed after 24 hours from AppDate (midnight base + 24h)
                            DateTime appDate = row.Field<DateTime>("AppDate").Date;
                            DateTime lapseThreshold = appDate.AddDays(1);
                            bool isLapsed = DateTime.Now >= lapseThreshold;
                            row["IsExpired"] = isLapsed;

                            string status = Convert.ToString(row["Status"] ?? string.Empty).Trim().ToLowerInvariant();
                            bool isDone = status == "done";
                            bool isCancelled = status == "cancelled" || status == "canceled";
                            row["IsDone"] = isDone;
                            // Only allow invoicing when not lapsed, not done, and not cancelled
                            row["IsInvoiceAllowed"] = !(isLapsed || isDone || isCancelled);
                        }

                        var rpt = FindControl("rptAppointments") as Repeater;
                        if (rpt != null)
                        {
                            LoadEmployeeServiceMap();
                            rpt.DataSource = dt;
                            rpt.DataBind();
                        }

                        var empty = FindControl("pnlEmpty") as Panel;
                        if (empty != null)
                        {
                            empty.Visible = dt.Rows.Count == 0;
                        }
                    }
                }
            }
            catch (Exception)
            {
                var empty = FindControl("pnlEmpty") as Panel;
                if (empty != null) empty.Visible = true;
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
                INNER JOIN AppointmentsTbl a ON ast.AppID = a.AppID
                WHERE CAST(a.AppDate AS DATE) = @today
                ORDER BY ast.AppID, EmpName, s.Service_Name";
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.Add("@today", SqlDbType.Date).Value = DateTime.Today;
                    con.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        var data = new Dictionary<string, Dictionary<string, List<string>>>();
                        while (rdr.Read())
                        {
                            string appId = (rdr["AppID"] ?? "").ToString();
                            string emp = (rdr["EmpName"] ?? "Not Assigned").ToString().Trim();
                            string svc = (rdr["Service_Name"] ?? "").ToString();
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

        protected string GetStatusClass(object statusObj)
        {
            string status = Convert.ToString(statusObj ?? string.Empty).Trim().ToLowerInvariant();
            switch (status)
            {
                case "done":
                    return "done";
                case "cancelled":
                case "canceled":
                    return "cancelled";
                case "lapsed":
                    return "lapsed";
                case "pending":
                    return "pending";
                default:
                    return string.Empty;
            }
        }

        protected string FormatStatus(object statusObj)
        {
            string status = Convert.ToString(statusObj ?? string.Empty).Trim();
            return string.IsNullOrWhiteSpace(status) ? "-" : status;
        }

        protected void rptAppointments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string cmd = (e.CommandName ?? string.Empty).Trim();
            string appId = e.CommandArgument as string ?? string.Empty;
            if (string.IsNullOrWhiteSpace(appId)) return;

            if (string.Equals(cmd, "Invoice", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("Invoice.aspx?appId=" + Server.UrlEncode(appId));
                return;
            }

            if (string.Equals(cmd, "Details", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("ViewAppointmentDetails.aspx?AppID=" + Server.UrlEncode(appId));
                return;
            }

            if (string.Equals(cmd, "Edit", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("EditAppointmentDetails.aspx?AppID=" + Server.UrlEncode(appId), false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (string.Equals(cmd, "Cancel", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    using (var con = new SqlConnection(connectionString))
                    using (var cmdCheck = new SqlCommand("SELECT Status FROM AppointmentsTbl WHERE AppID = @AppID", con))
                    {
                        cmdCheck.Parameters.AddWithValue("@AppID", appId);
                        con.Open();
                        var statusObj = cmdCheck.ExecuteScalar();
                        var status = statusObj == null || statusObj == DBNull.Value ? string.Empty : statusObj.ToString();
                        if (!string.IsNullOrWhiteSpace(status) && status.Equals("Done", StringComparison.OrdinalIgnoreCase))
                        {
                            // Do not cancel completed appointments
                            return;
                        }
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
                LoadAppointments();
                return;
            }

            if (string.Equals(cmd, "Remove", StringComparison.OrdinalIgnoreCase))
            {
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
                LoadAppointments();
                return;
            }
        }
    }
}