using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;

namespace Glamora
{
    public partial class Payment : Page
    {
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";
        private string AppId => Request.QueryString["appId"];

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (string.IsNullOrWhiteSpace(AppId))
                {
                    ShowError("Missing appointment ID.");
                    ToggleForm(false);
                    return;
                }
                LoadAppointment(AppId);
            }
        }

        private void LoadAppointment(string appId)
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var da = new SqlDataAdapter(@"
                    SELECT TOP 1
                        AppID,
                        Customer_name,
                        AppDate,
                        Start_time,
                        End_time,
                        Services,
                        Employees,
                        Total_amount,
                        Booking_date,
                        ISNULL(Advance_amount, 0) AS Advance_amount,
                        Payment_status,
                        Payment_method
                    FROM AppointmentsTbl
                    WHERE AppID = @AppID;", con))
                {
                    da.SelectCommand.Parameters.AddWithValue("@AppID", appId);
                    var dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        ShowError("Appointment not found.");
                        ToggleForm(false);
                        return;
                    }

                    var row = dt.Rows[0];

                    // Identity and main fields
                    lblAppID.Text = Convert.ToString(row["AppID"]);
                    lblCustomer.Text = Convert.ToString(row["Customer_name"]);
                    lblEmployee.Text = Convert.ToString(row["Employees"]);
                    lblServices.Text = Convert.ToString(row["Services"]);

                    // Dates
                    DateTime appDate = Convert.ToDateTime(row["AppDate"]);
                    lblAppDate.Text = appDate.ToString("yyyy-MM-dd");
                    lblBookedOn.Text = row["Booking_date"] != DBNull.Value
                        ? Convert.ToDateTime(row["Booking_date"]).ToString("yyyy-MM-dd")
                        : "-";

                    // Payment summary — recompute balance to match ViewTotalAppointments
                    decimal total = Convert.ToDecimal(row["Total_amount"]);
                    decimal advance = Convert.ToDecimal(row["Advance_amount"]);
                    decimal balance = total - advance;
                    if (balance < 0m) balance = 0m;

                    lblTotal.Text = total.ToString("N2");
                    lblAdvance.Text = advance.ToString("N2");
                    lblBalance.Text = balance.ToString("N2");

                    // Mirror balance into Outstanding Balance highlight
                    lblBalanceHighlight.Text = lblBalance.Text;

                    string lastMethod = Convert.ToString(row["Payment_method"]);
                    lblLastMethod.Text = string.IsNullOrWhiteSpace(lastMethod) ? "-" : lastMethod;

                    // Lapsed logic: 24h past AppDate midnight
                    DateTime lapseThreshold = appDate.Date.AddDays(1);
                    bool isLapsed = DateTime.Now >= lapseThreshold;
                    pnlLapsed.Visible = isLapsed;
                    btnProcess.Enabled = !isLapsed;
                    lblDisabledInfo.Visible = isLapsed;
                    lblDisabledInfo.Text = isLapsed ? "This appointment is lapsed. Payments are disabled." : string.Empty;

                    // Default amount to full balance when not lapsed
                    txtAmount.Text = (!isLapsed && balance > 0)
                        ? balance.ToString("N2", CultureInfo.InvariantCulture)
                        : "0.00";
                }
            }
            catch (Exception ex)
            {
                ShowError("Error loading appointment: " + ex.Message);
                ToggleForm(false);
            }
        }

        protected void btnProcess_Click(object sender, EventArgs e)
        {
            ClearMessages();

            if (string.IsNullOrWhiteSpace(AppId))
            {
                ShowError("Missing appointment ID.");
                return;
            }

            if (!decimal.TryParse(txtAmount.Text.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out var amount) || amount <= 0)
            {
                ShowError("Enter a valid payment amount greater than 0.");
                return;
            }

            var method = ddlMethod.SelectedValue;
            if (string.IsNullOrEmpty(method))
            {
                ShowError("Select a payment method.");
                return;
            }

            try
            {
                decimal currentBalance = 0m;
                decimal currentAdvance = 0m;
                decimal totalAmount = 0m;

                // Fetch current totals (recompute balance)
                using (var con = new SqlConnection(connectionString))
                using (var check = new SqlCommand(@"
                    SELECT Total_amount,
                           ISNULL(Advance_amount,0) AS Advance_amount
                    FROM AppointmentsTbl
                    WHERE AppID = @AppID;", con))
                {
                    check.Parameters.AddWithValue("@AppID", AppId);
                    con.Open();
                    using (var rdr = check.ExecuteReader())
                    {
                        if (!rdr.Read())
                        {
                            ShowError("Appointment not found for payment.");
                            return;
                        }
                        totalAmount = rdr.GetDecimal(rdr.GetOrdinal("Total_amount"));
                        currentAdvance = rdr.GetDecimal(rdr.GetOrdinal("Advance_amount"));
                        currentBalance = totalAmount - currentAdvance;
                        if (currentBalance < 0m) currentBalance = 0m;
                    }
                }

                if (amount > currentBalance)
                {
                    ShowError("Amount exceeds remaining balance.");
                    return;
                }

                // Compute new amounts
                decimal newAdvance = currentAdvance + amount;
                decimal newBalance = totalAmount - newAdvance;
                if (newBalance < 0m) newBalance = 0m;
                string newStatus = newBalance <= 0m ? "Paid" : "Partial";

                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(@"
                    UPDATE AppointmentsTbl
                    SET Advance_amount = @NewAdvance,
                        Balance_amount = @NewBalance,
                        Payment_status = @Status,
                        Payment_method = @Method
                    WHERE AppID = @AppID;", con))
                {
                    cmd.Parameters.AddWithValue("@NewAdvance", newAdvance);
                    cmd.Parameters.AddWithValue("@NewBalance", newBalance);
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@Method", method);
                    cmd.Parameters.AddWithValue("@AppID", AppId);

                    con.Open();
                    int rows = cmd.ExecuteNonQuery();
                    if (rows <= 0)
                    {
                        ShowError("Payment not processed.");
                        return;
                    }
                }

                // Refresh UI
                LoadAppointment(AppId);
                ShowSuccess("Payment processed successfully ✅");
            }
            catch (Exception ex)
            {
                ShowError("Error processing payment: " + ex.Message);
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("ViewTotalAppointments.aspx");
        }

        private void ToggleForm(bool enabled)
        {
            txtAmount.Enabled = enabled;
            ddlMethod.Enabled = enabled;
            btnProcess.Enabled = enabled;
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            pnlError.Controls.Clear();
            pnlError.Controls.Add(new LiteralControl(HttpUtility.HtmlEncode(message)));
        }

        private void ShowSuccess(string message)
        {
            pnlSuccess.Visible = true;
            pnlSuccess.Controls.Clear();
            pnlSuccess.Controls.Add(new LiteralControl(HttpUtility.HtmlEncode(message)));
        }

        private void ClearMessages()
        {
            pnlError.Visible = false;
            pnlSuccess.Visible = false;
            pnlError.Controls.Clear();
            pnlSuccess.Controls.Clear();
        }
    }
}