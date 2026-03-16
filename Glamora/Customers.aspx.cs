using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Web.UI.HtmlControls;

namespace Glamora
{
    public partial class Customers : Page
    {
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        // Sidebar list item (present in markup)
        protected HtmlGenericControl liCustomers;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Defensive: only set CSS class if control exists on this page
                if (liCustomers != null)
                {
                    liCustomers.Attributes["class"] = "active";
                }

                GenerateCustomerID();
                LoadCustomersGrid();
            }
        }

        // --- Generate next Cus_ID in format C001, C002, ... ---
        private void GenerateCustomerID()
        {
            try
            {
                const string sql = @"
                    SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(Cus_ID, 2, 9) AS INT)), 0) + 1
                    FROM CustomerTbl
                    WHERE Cus_ID LIKE 'C%'";
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    int nextNum = (result != null && result != DBNull.Value) ? Convert.ToInt32(result) : 1;
                    string nextId = "C" + nextNum.ToString("D3");
                    lblCustomerID.Text = nextId.Length <= 20 ? nextId : nextId.Substring(0, 20);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error generating next Customer ID: " + ex.Message, isSuccess: false);
                lblCustomerID.Text = "[Auto Generated]";
            }
        }

        // --- Data Loading (Read) ---
        private void LoadCustomersGrid()
        {
            DataTable dtCustomers = new DataTable();
            string query = "SELECT Cus_ID, Title, CusFirst_Name, CusLast_Name, Contact, City FROM CustomerTbl ORDER BY Cus_ID DESC";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dtCustomers);
                }

                gvCustomers.DataSource = dtCustomers;
                gvCustomers.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading customers: " + ex.Message, isSuccess: false);
            }
        }

        // --- Save/Update Logic (Create/Update) ---
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            string currentCusId = GetCurrentCustomerId();
            string contactNumber = "+94" + txtContactLocal.Text.Trim();
            string title = ddlTitle.SelectedValue;
            string firstName = txtFirstName.Text.Trim();
            string lastName = txtLastName.Text.Trim();
            string city = txtCity.Text.Trim();

            if (!ValidateCustomerInput(string.IsNullOrEmpty(currentCusId) ? lblCustomerID.Text : currentCusId,
                                       title, firstName, lastName, contactNumber, city))
            {
                return;
            }

            if (string.IsNullOrEmpty(currentCusId))
            {
                string insertQuery = "INSERT INTO CustomerTbl (Cus_ID, Title, CusFirst_Name, CusLast_Name, Contact, City) " +
                                     "VALUES (@Cus_ID, @Title, @FirstName, @LastName, @Contact, @City)";

                try
                {
                    using (SqlConnection con = new SqlConnection(connectionString))
                    using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@Cus_ID", lblCustomerID.Text);
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@FirstName", firstName);
                        cmd.Parameters.AddWithValue("@LastName", lastName);
                        cmd.Parameters.AddWithValue("@Contact", contactNumber);
                        cmd.Parameters.AddWithValue("@City", city);

                        con.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            // show alert then reload (consistent with Employees behavior)
                            RegisterAlertAndReload($"Customer {lblCustomerID.Text} - {firstName} {lastName} saved successfully!");
                            return;
                        }
                        else
                        {
                            ShowMessage("Customer saving failed.", isSuccess: false);
                        }
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage("Error saving customer: " + ex.Message, isSuccess: false);
                }
            }
            else
            {
                string updateQuery = "UPDATE CustomerTbl SET Title = @Title, CusFirst_Name = @FirstName, CusLast_Name = @LastName, Contact = @Contact, City = @City " +
                                     "WHERE Cus_ID = @Cus_ID";

                try
                {
                    using (SqlConnection con = new SqlConnection(connectionString))
                    using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@FirstName", firstName);
                        cmd.Parameters.AddWithValue("@LastName", lastName);
                        cmd.Parameters.AddWithValue("@Contact", contactNumber);
                        cmd.Parameters.AddWithValue("@City", city);
                        cmd.Parameters.AddWithValue("@Cus_ID", currentCusId);

                        con.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            RegisterAlertAndReload($"Customer {currentCusId} - {firstName} {lastName} updated successfully!");
                            return;
                        }
                        else
                        {
                            ShowMessage("Customer updating failed. Customer may not exist.", isSuccess: false);
                        }
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage("Error updating customer: " + ex.Message, isSuccess: false);
                }
            }

            ClearForm();
            LoadCustomersGrid();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        // --- GridView Actions (Edit/Delete) ---
        protected void gvCustomers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string cusId = (e.CommandArgument ?? string.Empty).ToString();

            if (e.CommandName == "EditCustomer")
            {
                Response.Redirect("EditCustomer.aspx?Cus_ID=" + Server.UrlEncode(cusId));
            }
            else if (e.CommandName == "DeleteCustomer")
            {
                DeleteCustomer(cusId);
            }
        }

        private void DeleteCustomer(string cusId)
        {
            string deleteQuery = "DELETE FROM CustomerTbl WHERE Cus_ID = @Cus_ID";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(deleteQuery, con))
                {
                    cmd.Parameters.AddWithValue("@Cus_ID", cusId);
                    con.Open();

                    int rowsAffected = cmd.ExecuteNonQuery();
                    if (rowsAffected > 0)
                    {
                        RegisterAlertAndReload($"Customer {cusId} deleted successfully.");
                        return;
                    }
                    else
                    {
                        ShowMessage("Customer deletion failed. Customer may not exist.", isSuccess: false);
                    }
                }
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547)
                    ShowMessage("Cannot delete customer ID " + cusId + ". Related records exist.", isSuccess: false);
                else
                    ShowMessage("Database error deleting customer: " + ex.Message, isSuccess: false);
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting customer: " + ex.Message, isSuccess: false);
            }
        }

        // --- Utility Methods ---
        private void ClearForm()
        {
            txtFirstName.Text = string.Empty;
            txtLastName.Text = string.Empty;
            txtContactLocal.Text = string.Empty;
            txtCity.Text = string.Empty;

            ddlTitle.SelectedIndex = 0;

            btnSave.Text = "Save Customer";
            ViewState["CurrentCustomerID"] = null;

            GenerateCustomerID();
        }

        private string GetCurrentCustomerId()
        {
            return ViewState["CurrentCustomerID"] as string ?? string.Empty;
        }

        private bool ValidateCustomerInput(string cusId, string title, string firstName, string lastName, string contact, string city)
        {
            if (!string.IsNullOrEmpty(cusId) && cusId.Length > 10)
            {
                ShowMessage("Customer ID cannot exceed 10 characters.", isSuccess: false);
                return false;
            }

            if (title.Length > 10)
            {
                ShowMessage("Title cannot exceed 10 characters.", isSuccess: false);
                return false;
            }

            if (firstName.Length > 50)
            {
                ShowMessage("First name cannot exceed 50 characters.", isSuccess: false);
                return false;
            }

            if (lastName.Length > 50)
            {
                ShowMessage("Last name cannot exceed 50 characters.", isSuccess: false);
                return false;
            }

            if (contact.Length > 15)
            {
                ShowMessage("Contact cannot exceed 15 characters.", isSuccess: false);
                return false;
            }

            if (city.Length > 50)
            {
                ShowMessage("City cannot exceed 50 characters.", isSuccess: false);
                return false;
            }

            return true;
        }

        // Replace label message usage with JS alert for all messages
        private void ShowMessage(string message, bool isSuccess)
        {
            // use JS alert for all messages (errors and successes)
            RegisterAlert(message);
        }

        // Register a JS alert on the client and then reload the current page.
        private void RegisterAlertAndReload(string message)
        {
            string encodedMsg = HttpUtility.JavaScriptStringEncode(message);
            string encodedUrl = HttpUtility.JavaScriptStringEncode(Request.RawUrl ?? "Customers.aspx");
            string script = $"alert('{encodedMsg}'); window.location = '{encodedUrl}';";

            if (ScriptManager.GetCurrent(Page) != null)
            {
                ScriptManager.RegisterStartupScript(Page, GetType(), Guid.NewGuid().ToString(), script, true);
            }
            else
            {
                Page.ClientScript.RegisterStartupScript(GetType(), Guid.NewGuid().ToString(), script, true);
            }
        }

        // Register a JS alert on the client without reloading
        private void RegisterAlert(string message)
        {
            string encoded = HttpUtility.JavaScriptStringEncode(message);
            string script = $"alert('{encoded}');";

            if (ScriptManager.GetCurrent(Page) != null)
            {
                ScriptManager.RegisterStartupScript(Page, GetType(), Guid.NewGuid().ToString(), script, true);
            }
            else
            {
                Page.ClientScript.RegisterStartupScript(GetType(), Guid.NewGuid().ToString(), script, true);
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        // C#
        protected DataTable GetAppointments()
        {
            if (string.IsNullOrWhiteSpace(connectionString))
                return new DataTable();

            const string sql = "SELECT * FROM dbo.Appointments"; // explicit schema
            var dt = new DataTable();

            try
            {
                using (var conn = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, conn))
                using (var da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
            catch (SqlException ex)
            {
                // log ex (Trace/ILog) and optionally set lblMessage.Text = friendly message
                // rethrow or return empty table depending on app behavior
                throw;
            }

            return dt;
        }
    }
}