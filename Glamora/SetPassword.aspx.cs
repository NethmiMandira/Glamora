using System;
using System.Web.UI;

namespace Glamora
{
    public partial class SetPassword : Page
    {
        private const string TokenViewStateKey = "SetPasswordToken";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            lblMessage.Text = string.Empty;
            Guid token;
            if (!Guid.TryParse(Request.QueryString["token"], out token))
            {
                lblMessage.Text = "Invalid or missing token.";
                lblMessage.CssClass = "message error";
                btnSetPassword.Enabled = false;
                return;
            }

            ViewState[TokenViewStateKey] = token;
        }

        protected void btnSetPassword_Click(object sender, EventArgs e)
        {
            lblMessage.Text = string.Empty;
            var tokenObj = ViewState[TokenViewStateKey];
            if (tokenObj == null)
            {
                lblMessage.Text = "Token not found.";
                lblMessage.CssClass = "message error";
                return;
            }

            var newPassword = txtPassword.Text;
            var confirm = txtConfirm.Text;
            if (!string.Equals(newPassword, confirm, StringComparison.Ordinal))
            {
                lblMessage.Text = "Passwords do not match.";
                lblMessage.CssClass = "message error";
                return;
            }

            if (newPassword.Length < 8)
            {
                lblMessage.Text = "Password must be at least 8 characters.";
                lblMessage.CssClass = "message error";
                return;
            }

            var token = (Guid)tokenObj;
            var result = InMemoryUserStore.SetPassword(token, newPassword);
            lblMessage.Text = result.Message;
            lblMessage.CssClass = result.Success ? "message success" : "message error";
            if (result.Success)
            {
                btnSetPassword.Enabled = false;
                Response.Redirect("~/Login.aspx", true);
            }
        }
    }
}
