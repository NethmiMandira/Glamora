using System;
using System.Web.UI;

namespace Glamora
{
    public partial class AdminApproval : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            lblMessage.Text = string.Empty;

            var userIdValue = Request.QueryString["userId"];
            var action = (Request.QueryString["action"] ?? "approve").ToLowerInvariant();
            Guid userId;
            if (!Guid.TryParse(userIdValue, out userId))
            {
                SetMessage("Invalid or missing user id.", false);
                return;
            }

            OperationResult result;
            if (action == "reject")
            {
                result = InMemoryUserStore.RejectUser(userId);
            }
            else
            {
                result = InMemoryUserStore.ApproveUser(userId);
            }

            SetMessage(result.Message, result.Success);

            if (result.Success && action != "reject" && result.Token.HasValue)
            {
                var user = InMemoryUserStore.GetUser(userId);
                if (user != null)
                {
                    try
                    {
                        var setPasswordLink = BuildAbsoluteUrl("~/SetPassword.aspx?token=" + result.Token.Value);
                        EmailService.SendEmail(user.Email,
                            "Set your Glamora admin password",
                            $"<p>Hi {user.FullName},</p><p>Your admin request has been approved. Set your password to activate your account:</p><p><a href='{setPasswordLink}'>Set Password</a></p><p>If the button doesn't work, copy this link:<br/>{setPasswordLink}</p>");
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine(ex);
                    }
                }
            }
        }

        private string BuildAbsoluteUrl(string relative)
        {
            var url = new Uri(Request.Url, ResolveUrl(relative));
            return url.AbsoluteUri;
        }

        private void SetMessage(string message, bool success)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = success ? "status success" : "status error";
        }
    }
}
