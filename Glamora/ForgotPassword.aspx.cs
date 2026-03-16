using System;
using System.Web.UI;

namespace Glamora
{
    public partial class ForgotPassword : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Text = string.Empty;
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            var email = txtEmail.Text.Trim();
            try
            {
                var result = InMemoryUserStore.CreateResetToken(email);
                var token = result.Token;

                if (token.HasValue)
                {
                    var resetLink = BuildAbsoluteUrl(string.Format("~/ResetPassword.aspx?token={0}", token.Value));
                    try
                    {
                        EmailService.SendEmail(email,
                            "Reset your Glamora password",
                            string.Format("<p>We received a request to reset your password.</p><p><a href='{0}'>Reset Password</a></p><p>If the button doesn't work, copy this link:<br/>{0}</p>", resetLink));
                        lblMessage.Text = "If the email is registered, a reset link has been sent.";
                        lblMessage.CssClass = "message success";
                    }
                    catch (Exception mailEx)
                    {
                        System.Diagnostics.Debug.WriteLine(mailEx);
                        lblMessage.Text = GetFriendlyEmailError(mailEx);
                        lblMessage.CssClass = "message error";
                    }
                }
                else
                {
                    lblMessage.Text = "If the email is registered, a reset link has been sent.";
                    lblMessage.CssClass = "message success";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex);
                lblMessage.Text = "An unexpected error occurred. Please try again.";
                lblMessage.CssClass = "message error";
            }
        }

        private string BuildAbsoluteUrl(string relative)
        {
            var url = new Uri(Request.Url, ResolveUrl(relative));
            return url.AbsoluteUri;
        }

        private string GetFriendlyEmailError(Exception ex)
        {
            var message = ex.GetBaseException().Message;
            return "Reset link generated, but sending the email failed: " + message + ". Please verify SMTP settings in Web.config.";
        }
    }
}
