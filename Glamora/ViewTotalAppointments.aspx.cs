using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class ViewTotalAppointments : Page
    {
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAppointments();
            }
        }

        private void LoadAppointments()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var da = new SqlDataAdapter(@"
                        SELECT AppID,
                               Customer_name,
                               AppDate,
                               Start_time,
                               End_time,
                               Services,
                               Employees,
                               Total_amount,
                               ISNULL(Advance_amount, 0) AS Advance_amount,
                               Payment_method,
                               Booking_date
                        FROM AppointmentsTbl
                        ORDER BY AppDate DESC, Start_time DESC;", con))
                {
                    var dt = new DataTable();
                    da.Fill(dt);

                    dt.Columns.Add("Balance_amount", typeof(decimal));
                    dt.Columns.Add("IsExpired", typeof(bool));

                    foreach (DataRow row in dt.Rows)
                    {
                        decimal total = row.Field<decimal>("Total_amount");
                        decimal advance = row.Field<decimal>("Advance_amount");
                        row["Balance_amount"] = total - advance;

                        // Lapsed after 24 hours from AppDate (midnight base + 24h)
                        DateTime appDate = row.Field<DateTime>("AppDate").Date;
                        DateTime lapseThreshold = appDate.AddDays(1); // appDate + 24h
                        bool isLapsed = DateTime.Now >= lapseThreshold;

                        row["IsExpired"] = isLapsed;
                    }

                    rptAppointments.DataSource = dt;
                    rptAppointments.DataBind();

                    pnlEmpty.Visible = dt.Rows.Count == 0;
                }
            }
            catch (Exception)
            {
                pnlEmpty.Visible = true;
            }
        }

        protected void rptAppointments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Pay")
            {
                string appId = e.CommandArgument as string ?? string.Empty;
                if (!string.IsNullOrEmpty(appId))
                {
                    Response.Redirect("Payment.aspx?appId=" + Server.UrlEncode(appId));
                }
            }
        }
    }
}