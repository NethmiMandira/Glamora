using System;
using System.Web.UI;
// For real application, you'll need System.Data and System.Data.SqlClient for database interaction

namespace Glamora
{
    public partial class Signup : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Text = string.Empty;
            }
        }

        protected void btnSignUp_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email))
            {
                lblMessage.Text = "Please provide your name and email.";
                lblMessage.CssClass = "message error";
                return;
            }

            try
            {
                var result = InMemoryUserStore.RequestRegistration(email, fullName);
                if (result.Success && result.Token.HasValue)
                {
                    string verifyLink = BuildAbsoluteUrl($"~/VerifyEmail.aspx?token={result.Token.Value}");
                    try
                    {
                        EmailService.SendEmail(email,
                            "Verify your Glamora admin request",
                            $"<p>Hi {fullName},</p><p>Thanks for requesting admin access. Please verify your email to continue:</p><p><a href='{verifyLink}'>Verify Email</a></p><p>If the button doesn't work, copy this link into your browser:<br/>{verifyLink}</p>");
                        lblMessage.Text = "Check your inbox for a verification link.";
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
                    lblMessage.Text = result.Message;
                    lblMessage.CssClass = "message error";
                }

                txtFullName.Text = string.Empty;
                txtEmail.Text = string.Empty;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.Message);
                lblMessage.Text = "An unexpected error occurred during registration. Please try again.";
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
            // Surface the root cause to help configure SMTP correctly
            var message = ex.GetBaseException().Message;
            return "Registration recorded, but sending the verification email failed: " + message + ". Please verify SMTP settings in Web.config.";
        }
    }
}