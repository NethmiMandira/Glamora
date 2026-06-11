using System;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;

namespace Glamora
{
    public partial class EditCustomer : Page
    {
        private readonly string ConnectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        // Add this field to your class, matching the type of your liCustomers control (likely HtmlGenericControl)
        protected System.Web.UI.HtmlControls.HtmlGenericControl liCustomers;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (liCustomers != null)
                {
                    liCustomers.Attributes["class"] = "active";
                }

                string cusId = Request.QueryString["Cus_ID"];
                if (!string.IsNullOrEmpty(cusId))
                {
                    LoadCustomer(cusId);
                    ViewState["CurrentCustomerID"] = cusId;
                    btnSave.Text = "Update Customer";
                }
                else
                {
                    ShowMessage("No customer selected to edit.", isSuccess: false);
                    btnSave.Enabled = false;
                }
            }
        }

        private void LoadCustomer(string cusId)
        {
            const string Query = "SELECT Cus_ID, Title, CusFirst_Name, CusLast_Name, Contact, City FROM CustomerTbl WHERE Cus_ID = @Cus_ID";
            try
            {
                using (SqlConnection con = new SqlConnection(ConnectionString))
                using (SqlCommand cmd = new SqlCommand(Query, con))
                {
                    cmd.Parameters.AddWithValue("@Cus_ID", cusId);
                    con.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            lblCustomerID.Text = rdr["Cus_ID"]?.ToString();
                            var title = rdr["Title"]?.ToString();
                            if (!string.IsNullOrEmpty(title) && ddlTitle.Items.FindByValue(title) != null)
                                ddlTitle.SelectedValue = title;

                            txtFirstName.Text = rdr["CusFirst_Name"]?.ToString();
                            txtLastName.Text = rdr["CusLast_Name"]?.ToString();

                            string contact = rdr["Contact"]?.ToString() ?? string.Empty;
                            txtContactLocal.Text = contact.StartsWith("+94") ? contact.Substring(3) : contact;

                            txtCity.Text = rdr["City"]?.ToString();
                        }
                        else
                        {
                            ShowMessage("Customer not found.", isSuccess: false);
                            btnSave.Enabled = false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading customer: " + ex.Message, isSuccess: false);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string currentCusId = ViewState["CurrentCustomerID"] as string;
            if (string.IsNullOrEmpty(currentCusId))
            {
                ShowMessage("No customer loaded for update.", isSuccess: false);
                return;
            }

            string contactNumber = "+94" + txtContactLocal.Text.Trim();
            string title = ddlTitle.SelectedValue;
            string firstName = txtFirstName.Text.Trim();
            string lastName = txtLastName.Text.Trim();
            string city = txtCity.Text.Trim();

            if (!ValidateCustomerInput(currentCusId, title, firstName, lastName, contactNumber, city))
            {
                return;
            }

            string updateQuery = "UPDATE CustomerTbl SET Title = @Title, CusFirst_Name = @FirstName, CusLast_Name = @LastName, Contact = @Contact, City = @City WHERE Cus_ID = @Cus_ID";

            try
            {
                using (SqlConnection con = new SqlConnection(ConnectionString))
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
                        Response.Redirect("Customers.aspx");
                    }
                    else
                    {
                        ShowMessage("Update failed. Customer may not exist.", isSuccess: false);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating customer: " + ex.Message, isSuccess: false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.Visible = true;
            lblMessage.CssClass = isSuccess ? "success-message" : "error-message";
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

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}