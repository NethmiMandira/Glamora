using System;
using System.Web.UI;

namespace Glamora
{
    public partial class VerifyEmail : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            lblMessage.Text = string.Empty;
            var tokenValue = Request.QueryString["token"];
            Guid token;
            if (!Guid.TryParse(tokenValue, out token))
            {
                lblMessage.Text = "Invalid verification link.";
                lblMessage.CssClass = "message error";
                return;
            }

            var initialUser = InMemoryUserStore.GetUserByVerificationToken(token);
            var result = InMemoryUserStore.VerifyEmail(token);
            lblMessage.Text = result.Message;
            lblMessage.CssClass = result.Success ? "message success" : "message error";

            if (!result.Success)
            {
                return;
            }

            var user = InMemoryUserStore.GetUserByVerificationToken(token);
            if (user == null)
            {
                return;
            }

            if (user.Status == UserStatus.PendingPassword && user.SetPasswordToken.HasValue)
            {
                var setPasswordUrl = ResolveUrl("~/SetPassword.aspx?token=" + user.SetPasswordToken.Value);
                Response.Redirect(setPasswordUrl, endResponse: true);
                return;
            }

            if (user.Status == UserStatus.PendingApproval)
            {
                try
                {
                    var approveLink = BuildAbsoluteUrl("~/AdminApproval.aspx?action=approve&userId=" + user.UserId);
                    var rejectLink = BuildAbsoluteUrl("~/AdminApproval.aspx?action=reject&userId=" + user.UserId);
                    EmailService.SendEmail(EmailService.DefaultAdminEmail,
                        "Admin approval required",
                        $"<p>User {user.FullName} ({user.Email}) verified their email.</p><p><a href='{approveLink}'>Approve Admin Access</a> | <a href='{rejectLink}'>Reject</a></p><p>If the buttons do not work, copy the links:<br/>Approve: {approveLink}<br/>Reject: {rejectLink}</p>");
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(ex);
                }
            }
        }

        private string BuildAbsoluteUrl(string relative)
        {
            var url = new Uri(Request.Url, ResolveUrl(relative));
            return url.AbsoluteUri;
        }

    }
}
