using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Data.SqlClient;

namespace Glamora
{
    public partial class EditUsers : System.Web.UI.Page
    {
        protected System.Web.UI.WebControls.Label lblMessage;
        protected System.Web.UI.WebControls.Label lblUserID;
        protected System.Web.UI.WebControls.TextBox txtUsername;
        protected System.Web.UI.WebControls.TextBox txtPassword;
        protected System.Web.UI.WebControls.Button btnSave;
        protected System.Web.UI.WebControls.RequiredFieldValidator rfvUsername;
        protected System.Web.UI.WebControls.RequiredFieldValidator rfvPassword;
        protected System.Web.UI.WebControls.HyperLink hlBack;

        private readonly string connectionString = ConfigurationManager.ConnectionStrings["GlamoraDBConnection"]?.ConnectionString
                                                     ?? "Server=.;Database=Glamora;Integrated Security=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string userID = Request.QueryString["UserID"];
                if (!string.IsNullOrEmpty(userID))
                {
                    LoadUser(userID);
                    ViewState["CurrentUserID"] = userID;
                    btnSave.Text = "Update User";
                }
                else
                {
                    ShowMessage("No user selected to edit.", isSuccess: false);
                    btnSave.Enabled = false;
                }
            }
        }

        private void LoadUser(string userID)
        {
            const string sql = "SELECT UserID, Username, Password FROM USersTbl WHERE UserID = @UserID";
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@UserID", userID);
                    con.Open();
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            lblUserID.Text = rdr["UserID"]?.ToString();
                            txtUsername.Text = rdr["Username"]?.ToString();
                            txtPassword.Text = rdr["Password"]?.ToString();
                        }
                        else
                        {
                            ShowMessage("User not found.", isSuccess: false);
                            btnSave.Enabled = false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading user: " + ex.Message, isSuccess: false);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string currentUserID = ViewState["CurrentUserID"] as string;
            if (string.IsNullOrEmpty(currentUserID))
            {
                ShowMessage("No user loaded for update.", isSuccess: false);
                return;
            }

            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                ShowMessage("Username and password are required.", isSuccess: false);
                return;
            }

            string updateQuery = "UPDATE USersTbl SET Username = @Username, Password = @Password WHERE UserID = @UserID";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Password", password);
                    cmd.Parameters.AddWithValue("@UserID", currentUserID);

                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();
                    if (rowsAffected > 0)
                    {
                        Response.Redirect("Users.aspx");
                    }
                    else
                    {
                        ShowMessage("Update failed. User may not exist.", isSuccess: false);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating user: " + ex.Message, isSuccess: false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.Visible = true;
            lblMessage.CssClass = isSuccess ? "success-message" : "error-message";
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}