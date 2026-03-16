using System;
using System.Web.UI;
// You'll need System.Data and System.Data.SqlClient for database access later

namespace Glamora
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Text = string.Empty;
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text;

            var result = InMemoryUserStore.ValidateLogin(username, password);
            if (result.Success)
            {
                Response.Redirect("Dashboard.aspx");
                return;
            }

            lblMessage.Text = result.Message;
        }
    }
}