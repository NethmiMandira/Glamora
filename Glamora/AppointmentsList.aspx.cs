using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class AppointmentsList : Page
    {
        // Properties to keep track of state
        public DateTime SelectedDate { get { return (DateTime)(ViewState["SelectedDate"] ?? DateTime.Today); } set { ViewState["SelectedDate"] = value; } }
        public string CurrentView { get { return (string)(ViewState["CurrentView"] ?? "Month"); } set { ViewState["CurrentView"] = value; } }

        string connStr = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) { RenderCalendar(); }
        }

        protected void SwitchView_Click(object sender, EventArgs e)
        {
            CurrentView = ((Button)sender).CommandArgument;
            RenderCalendar();
        }

        protected void ChangeDate_Click(object sender, EventArgs e)
        {
            int direction = ((LinkButton)sender).CommandArgument == "next" ? 1 : -1;
            if (CurrentView == "Month") SelectedDate = SelectedDate.AddMonths(direction);
            else if (CurrentView == "Week") SelectedDate = SelectedDate.AddDays(direction * 7);
            else SelectedDate = SelectedDate.AddDays(direction);
            RenderCalendar();
        }

        private void RenderCalendar()
        {
            lblCurrentRange.Text = SelectedDate.ToString(CurrentView == "Month" ? "MMMM yyyy" : "MMM dd, yyyy");
            btnMonth.CssClass = "btn" + (CurrentView == "Month" ? " active" : "");
            btnWeek.CssClass = "btn" + (CurrentView == "Week" ? " active" : "");
            btnDay.CssClass = "btn" + (CurrentView == "Day" ? " active" : "");

            if (CurrentView == "Day")
            {
                mvCalendar.ActiveViewIndex = 1;
                var hours = Enumerable.Range(8, 13).ToList(); // 8 AM to 8 PM
                rptTimeline.DataSource = hours;
                rptTimeline.DataBind();
            }
            else
            {
                mvCalendar.ActiveViewIndex = 0;
                BindGrid();
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        private void BindGrid()
        {
            DateTime start, end;
            if (CurrentView == "Month")
            {
                DateTime firstOfMonth = new DateTime(SelectedDate.Year, SelectedDate.Month, 1);
                start = firstOfMonth.AddDays(-(int)firstOfMonth.DayOfWeek);
                end = start.AddDays(42); // 6 weeks
            }
            else // Week
            {
                start = SelectedDate.AddDays(-(int)SelectedDate.DayOfWeek);
                end = start.AddDays(7);
            }

            var days = new List<object>();
            for (DateTime date = start; date < end; date = date.AddDays(1))
            {
                days.Add(new
                {
                    Date = date,
                    DayNumber = date.Day,
                    CssClass = "day-cell" + (date.Month != SelectedDate.Month && CurrentView == "Month" ? " other-month" : "")
                });
            }
            rptCalendar.DataSource = days;
            rptCalendar.DataBind();
        }

        protected void rptCalendar_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DateTime cellDate = (DateTime)DataBinder.Eval(e.Item.DataItem, "Date");
                PlaceHolder ph = (PlaceHolder)e.Item.FindControl("phAppointments");
                DataTable dt = GetAppointments(cellDate);
                int total = dt.Rows.Count;
                string cellId = $"cellApps_{cellDate:yyyyMMdd}";
                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                sb.Append($"<div id='{cellId}_wrap'>");
                // Show first 3
                for (int i = 0; i < Math.Min(3, total); i++)
                {
                    string appId = dt.Rows[i]["AppID"].ToString();
                    string statusClass = GetStatusClass(dt.Rows[i]["Status"]);
                    string customerName = dt.Rows[i]["CustomerName"]?.ToString() ?? "";
                    sb.Append($"<a class='app-badge {statusClass}' href='ViewAppointmentDetails.aspx?AppID={appId}'>{System.Web.HttpUtility.HtmlEncode(customerName)}</a>");
                }
                // Hidden extra
                if (total > 3)
                {
                    sb.Append($"<div id='{cellId}_more' style='display:none;'>");
                    for (int i = 3; i < total; i++)
                    {
                        string appId = dt.Rows[i]["AppID"].ToString();
                        string statusClass = GetStatusClass(dt.Rows[i]["Status"]);
                        string customerName = dt.Rows[i]["CustomerName"]?.ToString() ?? "";
                        sb.Append($"<a class='app-badge {statusClass}' href='ViewAppointmentDetails.aspx?AppID={appId}'>{System.Web.HttpUtility.HtmlEncode(customerName)}</a>");
                    }
                    sb.Append("</div>");
                    sb.Append($"<button type='button' class='show-more-btn' onclick=\"toggleApps('{cellId}',true)\">Show More</button>");
                    sb.Append($"<button type='button' class='show-less-btn' style='display:none;' onclick=\"toggleApps('{cellId}',false)\">Show Less</button>");
                }
                sb.Append("</div>");
                ph.Controls.Add(new Literal { Text = sb.ToString() });
            }
        }

        protected void rptTimeline_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                int hour = (int)e.Item.DataItem;
                PlaceHolder ph = (PlaceHolder)e.Item.FindControl("phDayApps");

                DataTable dt = GetAppointments(SelectedDate, hour);
                foreach (DataRow row in dt.Rows)
                {
                    Literal lit = new Literal();
                    string appId = row["AppID"].ToString();
                    string statusClass = GetStatusClass(row["Status"]);
                    string customerName = row["CustomerName"]?.ToString() ?? "";
                    lit.Text = $"<a class='app-badge {statusClass}' href='ViewAppointmentDetails.aspx?AppID={appId}'>{System.Web.HttpUtility.HtmlEncode(customerName)}</a>";
                    ph.Controls.Add(lit);
                }
            }
        }

        private DataTable GetAppointments(DateTime date, int? hour = null)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Compute a display status the same way as AppointmentBooking so past pending
                // appointments are shown as "Expired" instead of still appearing as "Pending".
                string query = @"SELECT a.AppID,
                                       CASE WHEN a.AppDate < CAST(GETDATE() AS DATE) AND a.Status = 'Pending' THEN 'Expired' ELSE a.Status END AS Status,
                                       CONCAT(c.Title, ' ', c.CusFirst_Name, ' ', c.CusLast_Name) AS CustomerName
                                 FROM AppointmentsTbl a
                                 LEFT JOIN CustomerTbl c ON a.Cus_ID = c.Cus_ID
                                 WHERE a.AppDate = @Date";
                if (hour.HasValue) query += " AND DATEPART(HOUR, a.StartTime) = @Hour";

                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                da.SelectCommand.Parameters.AddWithValue("@Date", date.Date);
                if (hour.HasValue) da.SelectCommand.Parameters.AddWithValue("@Hour", hour.Value);

                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        // Returns the status class for the app badge
        public string GetStatusClass(object statusObj)
        {
            string status = (statusObj ?? "").ToString().Trim().ToLower();
            switch (status)
            {
                case "pending": return "status-pending";
                case "done": return "status-done";
                case "expired":
                case "exprired": return "status-expired";
                case "cancelled":
                case "canceled": return "status-cancelled";
                default: return "status-pending";
            }
        }
    }
}