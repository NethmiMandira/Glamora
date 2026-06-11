using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Globalization;
using System.Web.UI;

namespace Glamora
{
    public partial class EditServices : Page
    {
        // Use same connection string approach as Services.aspx.cs
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["GlamoraDBConnection"]?.ConnectionString
                                                     ?? "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Accept either "id" or "Service_ID" query parameter for compatibility
                string serviceId = Request.QueryString["id"] ?? Request.QueryString["Service_ID"];
                if (string.IsNullOrWhiteSpace(serviceId))
                {
                    ShowMessage("No Service ID specified.", "error-message");
                    btnSave.Enabled = false;
                    return;
                }

                LoadServiceForEdit(serviceId);
            }
        }

        // Load the service record into the form for editing
        private void LoadServiceForEdit(string serviceID)
        {
            LoadCategories();

            const string sql = "SELECT Service_Name, Price, Duration, Category_ID FROM ServiceTbl WHERE Service_ID = @Service_ID";

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Service_ID", serviceID);
                    con.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblServiceID.Text = serviceID;
                            txtServiceName.Text = reader["Service_Name"]?.ToString() ?? string.Empty;

                            if (reader["Price"] != DBNull.Value)
                            {
                                txtPrice.Text = Convert.ToDecimal(reader["Price"]).ToString("N2", CultureInfo.InvariantCulture);
                            }
                            else
                            {
                                txtPrice.Text = string.Empty;
                            }

                            // Preserve two-digit hour format for duration (e.g. "01:30:00")
                            if (reader["Duration"] != DBNull.Value && reader["Duration"] is TimeSpan ts)
                            {
                                txtDuration.Text = ts.ToString(@"hh\:mm\:ss", CultureInfo.InvariantCulture);
                            }
                            else
                            {
                                // default to valid two-digit format
                                txtDuration.Text = "00:00:00";
                            }

                            // Set category dropdown
                            string catId = reader["Category_ID"]?.ToString() ?? "";
                            if (ddlCategory.Items.FindByValue(catId) != null)
                            {
                                ddlCategory.ClearSelection();
                                ddlCategory.Items.FindByValue(catId).Selected = true;
                            }

                            lblMessage.Visible = false;
                        }
                        else
                        {
                            ShowMessage($"Service {serviceID} not found.", "error-message");
                            btnSave.Enabled = false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadServiceForEdit error: {0}", ex);
                ShowMessage("Error loading service details: " + ex.Message, "error-message");
                btnSave.Enabled = false;
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string serviceID = lblServiceID.Text?.Trim();
            if (string.IsNullOrWhiteSpace(serviceID))
            {
                ShowMessage("Service ID is missing.", "error-message");
                return;
            }

            string serviceName = txtServiceName.Text.Trim();
            string priceText = txtPrice.Text.Replace(",", string.Empty).Trim();
            string durationText = txtDuration.Text.Trim();

            if (string.IsNullOrWhiteSpace(serviceName) || string.IsNullOrWhiteSpace(priceText) || string.IsNullOrWhiteSpace(durationText))
            {
                ShowMessage("Please fill all required fields.", "error-message");
                return;
            }

            if (!decimal.TryParse(priceText, NumberStyles.Number, CultureInfo.InvariantCulture, out decimal price))
            {
                ShowMessage("Invalid price value.", "error-message");
                return;
            }

            // Reject AM/PM
            if (durationText.IndexOf("AM", StringComparison.OrdinalIgnoreCase) >= 0
                || durationText.IndexOf("PM", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                ShowMessage("Invalid duration format: do not use AM/PM. Use 24-hour format HH:mm:ss.", "error-message");
                return;
            }

            TimeSpan duration;
            var durationFormats = new[] { "h\\:m\\:s", "hh\\:mm\\:ss", "h\\:m", "hh\\:mm", "m\\:ss", "mm\\:ss" };
            bool parsed = TimeSpan.TryParseExact(durationText, durationFormats, CultureInfo.InvariantCulture, out duration)
                          || TimeSpan.TryParse(durationText, CultureInfo.InvariantCulture, out duration);

            if (!parsed)
            {
                ShowMessage("Invalid duration value. Use formats like H:mm:ss (example: 0:30:00).", "error-message");
                return;
            }

            const string sqlUpdate = @"
                UPDATE ServiceTbl
                SET Service_Name = @Service_Name, Price = @Price, Duration = @Duration, Category_ID = @Category_ID
                WHERE Service_ID = @Service_ID";

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sqlUpdate, con))
                {
                    cmd.Parameters.AddWithValue("@Service_ID", serviceID);
                    cmd.Parameters.AddWithValue("@Service_Name", serviceName);
                    cmd.Parameters.AddWithValue("@Price", price);
                    cmd.Parameters.Add("@Duration", SqlDbType.Time).Value = duration;
                    cmd.Parameters.AddWithValue("@Category_ID", string.IsNullOrEmpty(ddlCategory.SelectedValue) ? (object)DBNull.Value : ddlCategory.SelectedValue);

                    con.Open();
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        // No messages shown; redirect back to Services list after update
                        Response.Redirect("Services.aspx");
                    }
                    else
                    {
                        ShowMessage("Update failed. No rows affected.", "error-message");
                    }
                }
            }
            catch (SqlException ex)
            {
                System.Diagnostics.Trace.TraceError("btnSave_Click SQL error: {0}", ex);
                ShowMessage("Database error: " + ex.Message, "error-message");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("btnSave_Click error: {0}", ex);
                ShowMessage("Unexpected error: " + ex.Message, "error-message");
            }
        }

        private void LoadCategories()
        {
            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    string query = "SELECT Category_ID, Category_Name FROM ServiceCategoryTbl ORDER BY Category_Name";
                    using (var da = new SqlDataAdapter(query, con))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);
                        ddlCategory.Items.Clear();
                        ddlCategory.Items.Add(new System.Web.UI.WebControls.ListItem("-- Select Category --", ""));
                        ddlCategory.DataSource = dt;
                        ddlCategory.DataTextField = "Category_Name";
                        ddlCategory.DataValueField = "Category_ID";
                        ddlCategory.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadCategories error: {0}", ex);
            }
        }

        private void ShowMessage(string message, string cssClass)
        {
            if (lblMessage != null)
            {
                lblMessage.Text = message;
                lblMessage.CssClass = cssClass;
                lblMessage.Visible = true;
            }
        }
    }
}