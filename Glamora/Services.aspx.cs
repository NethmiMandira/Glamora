using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls; // Added for GridViewCommandEventArgs

namespace Glamora
{
    public partial class Services : Page
    {
        // Use a consistent connection string setup
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["GlamoraDBConnection"]?.ConnectionString
                                                     ?? "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        // State variable to track if we are currently editing a service
        private bool IsEditing
        {
            get => ViewState["IsEditing"] != null && (bool)ViewState["IsEditing"];
            set => ViewState["IsEditing"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GenerateServiceID();
                LoadCategories();
                BindGrid();
                if (lblMessage != null)
                {
                    lblMessage.Visible = false;
                }
            }
        }

        // Generate sequential service ID using 'S' prefix with zero-padded number (S001, S002, ...)
        private void GenerateServiceID()
        {
            string newServiceID = "S001";
            IsEditing = false; // Reset editing state
            btnSave.Text = "Save New Service"; // Reset button text

            const string sql = @"
                SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(Service_ID, 2, 9) AS INT)), 0)
                FROM ServiceTbl
                WHERE Service_ID LIKE 'S%'";

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        if (int.TryParse(result.ToString(), out int lastNumber))
                        {
                            newServiceID = "S" + (lastNumber + 1).ToString("D3");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("GenerateServiceID error: {0}", ex);
                ShowMessage("Error generating Service ID: " + ex.Message, "error-message");
            }

            if (lblServiceID != null)
            {
                lblServiceID.Text = newServiceID;
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
                        ddlCategory.DataSource = dt;
                        ddlCategory.DataTextField = "Category_Name";
                        ddlCategory.DataValueField = "Category_ID";
                        ddlCategory.DataBind();
                        ddlCategory.Items.Insert(0, new System.Web.UI.WebControls.ListItem("-- Select Category --", ""));
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("LoadCategories error: {0}", ex);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string serviceID = lblServiceID.Text?.Trim() ?? string.Empty;
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

            // Explicitly reject AM/PM usage — server-side guard to enforce 24-hour format
            if (durationText.IndexOf("AM", StringComparison.OrdinalIgnoreCase) >= 0
                || durationText.IndexOf("PM", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                ShowMessage("Invalid duration format: do not use AM/PM. Use 24-hour format HH:mm:ss (e.g. 1:05:20).", "error-message");
                return;
            }

            // Server-side Duration Validation (should match client-side format)
            TimeSpan duration;
            // Trying multiple formats for robustness (h:m:s, hh:mm:ss, h:m, etc.)
            var durationFormats = new[] { "h\\:m\\:s", "hh\\:mm\\:ss", "h\\:m", "hh\\:mm", "m\\:ss", "mm\\:ss" };

            bool parsed = TimeSpan.TryParseExact(durationText, durationFormats, CultureInfo.InvariantCulture, out duration)
                          || TimeSpan.TryParse(durationText, CultureInfo.InvariantCulture, out duration);

            if (!parsed)
            {
                ShowMessage("Invalid duration value. Use 24-hour formats like H:mm:ss (e.g. 0:30:00).", "error-message");
                return;
            }

            // Determine if this is an INSERT or an UPDATE
            string sql;
            if (IsEditing)
            {
                sql = @"
                    UPDATE ServiceTbl
                    SET Service_Name = @Service_Name, Price = @Price, Duration = @Duration, Category_ID = @Category_ID
                    WHERE Service_ID = @Service_ID";
            }
            else
            {
                sql = @"
                    INSERT INTO ServiceTbl
                        (Service_ID, Service_Name, Price, Duration, Category_ID)
                    VALUES
                        (@Service_ID, @Service_Name, @Price, @Duration, @Category_ID)";
            }

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Service_ID", serviceID);
                    cmd.Parameters.AddWithValue("@Service_Name", serviceName);
                    cmd.Parameters.AddWithValue("@Price", price);
                    // Duration stored as SQL TIME; pass TimeSpan
                    cmd.Parameters.Add("@Duration", SqlDbType.Time).Value = duration;
                    cmd.Parameters.AddWithValue("@Category_ID", string.IsNullOrEmpty(ddlCategory.SelectedValue) ? (object)DBNull.Value : ddlCategory.SelectedValue);

                    con.Open();
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        string action = IsEditing ? "updated" : "saved";
                        ShowMessage($"Service {serviceID} successfully {action}.", "success-message");

                        // After save/update, reset form and reload data
                        ResetForm();
                        GenerateServiceID();
                        BindGrid();
                    }
                    else
                    {
                        ShowMessage($"Service save/update failed. No rows affected.", "error-message");
                    }
                }
            }
            catch (SqlException ex)
            {
                System.Diagnostics.Trace.TraceError("btnSave_Click SQL error: {0}", ex);
                ShowMessage("Database Error: " + ex.Message, "error-message");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("btnSave_Click error: {0}", ex);
                ShowMessage("Unexpected Error: " + ex.Message, "error-message");
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ResetForm();
            GenerateServiceID();
        }

        // New method to handle Edit and Delete commands from the GridView
        protected void gvServices_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditService")
            {
                string serviceID = e.CommandArgument.ToString();
                // Navigate to EditServices.aspx with the service id as query string
                Response.Redirect($"EditServices.aspx?id={Server.UrlEncode(serviceID)}", false);
                Context.ApplicationInstance.CompleteRequest(); // avoid ThreadAbortException
            }
            else if (e.CommandName == "DeleteService")
            {
                string serviceID = e.CommandArgument.ToString();
                DeleteService(serviceID);
            }
        }

        private void LoadServiceForEdit(string serviceID)
        {
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
                            // Populate form controls
                            lblServiceID.Text = serviceID;
                            txtServiceName.Text = reader["Service_Name"].ToString();
                            txtPrice.Text = Convert.ToDecimal(reader["Price"]).ToString("N2");

                            // Convert Duration (TimeSpan) to "hh:mm:ss" format for the TextBox (always two-digit hours)
                            if (reader["Duration"] != DBNull.Value && reader["Duration"] is TimeSpan duration)
                            {
                                txtDuration.Text = duration.ToString(@"hh\:mm\:ss", CultureInfo.InvariantCulture);
                            }
                            else
                            {
                                // default to two-digit hours format
                                txtDuration.Text = "00:00:00";
                            }

                            // Set category dropdown
                            LoadCategories();
                            string catId = reader["Category_ID"]?.ToString() ?? "";
                            if (ddlCategory.Items.FindByValue(catId) != null)
                            {
                                ddlCategory.ClearSelection();
                                ddlCategory.Items.FindByValue(catId).Selected = true;
                            }

                            // Update state and button text
                            IsEditing = true;
                            btnSave.Text = "Update Service";
                            lblMessage.Visible = false; // Clear messages

                            // Bring user to the form section
                            ScriptManager.RegisterStartupScript(this, GetType(), "ScrollToForm", "document.querySelector('.form-container').scrollIntoView();", true);
                        }
                        else
                        {
                            ShowMessage($"Service with ID {serviceID} not found.", "error-message");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("LoadServiceForEdit error: {0}", ex);
                ShowMessage("Error loading service details for editing: " + ex.Message, "error-message");
            }
        }

        private void DeleteService(string serviceID)
        {
            const string sql = "DELETE FROM ServiceTbl WHERE Service_ID = @Service_ID";

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Service_ID", serviceID);
                    con.Open();
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        ShowMessage($"Service {serviceID} successfully deleted.", "success-message");
                        ResetForm();
                        GenerateServiceID();
                        BindGrid();
                    }
                    else
                    {
                        ShowMessage($"Service {serviceID} not found or deletion failed.", "error-message");
                    }
                }
            }
            catch (SqlException ex)
            {
                // Check for foreign key constraint violation (Error 547)
                if (ex.Number == 547)
                {
                    ShowMessage("Cannot delete service. It is currently linked to one or more appointments.", "error-message");
                }
                else
                {
                    System.Diagnostics.Trace.TraceError("DeleteService SQL error: {0}", ex);
                    ShowMessage("Database Error during deletion: " + ex.Message, "error-message");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("DeleteService error: {0}", ex);
                ShowMessage("Unexpected Error during deletion: " + ex.Message, "error-message");
            }
        }

        private void ResetForm()
        {
            if (txtServiceName != null) txtServiceName.Text = string.Empty;
            if (txtPrice != null) txtPrice.Text = string.Empty;
            if (txtDuration != null) txtDuration.Text = string.Empty;
            if (ddlCategory != null) ddlCategory.SelectedIndex = 0;
            if (lblMessage != null) lblMessage.Visible = false;
        }

        private void BindGrid()
        {
            const string sql = @"SELECT s.Service_ID, s.Service_Name, s.Price, s.Duration,
                                        ISNULL(c.Category_Name, '') AS Category_Name
                                 FROM ServiceTbl s
                                 LEFT JOIN ServiceCategoryTbl c ON s.Category_ID = c.Category_ID
                                 ORDER BY s.Service_ID";

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, con))
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    var dt = new DataTable();
                    adapter.Fill(dt);

                    // Convert Duration column (TIME/TimeSpan) to formatted string "hh:mm:ss" for display (preserve leading zero)
                    if (dt.Columns.Contains("Duration"))
                    {
                        dt.Columns.Add("DurationTemp", typeof(string));
                        foreach (DataRow r in dt.Rows)
                        {
                            if (r["Duration"] != DBNull.Value)
                            {
                                TimeSpan ts = (TimeSpan)r["Duration"];
                                // Use "hh:mm:ss" format (always two-digit hours)
                                r["DurationTemp"] = ts.ToString(@"hh\:mm\:ss", CultureInfo.InvariantCulture);
                            }
                            else
                            {
                                r["DurationTemp"] = string.Empty;
                            }
                        }

                        dt.Columns.Remove("Duration");
                        dt.Columns["DurationTemp"].ColumnName = "Duration";
                    }

                    gvServices.DataSource = dt;
                    gvServices.DataBind();
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("BindGrid error: {0}", ex);
                ShowMessage("Error loading services: " + ex.Message, "error-message");
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            // Simple redirection for logout
            Response.Redirect("Login.aspx");
        }
    }
}