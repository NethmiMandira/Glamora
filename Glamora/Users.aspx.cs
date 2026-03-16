using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class Users : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Text = string.Empty;
                BindGrid();
            }
        }

        protected void chkActive_CheckedChanged(object sender, EventArgs e)
        {
            var checkbox = sender as CheckBox;
            if (checkbox == null)
            {
                return;
            }

            var row = checkbox.NamingContainer as GridViewRow;
            if (row == null)
            {
                return;
            }

            var dataKey = gvUsers.DataKeys[row.RowIndex];
            Guid userId;
            if (dataKey == null || !Guid.TryParse(Convert.ToString(dataKey.Value), out userId))
            {
                return;
            }

            var result = InMemoryUserStore.SetActive(userId, checkbox.Checked);
            if (result != null)
            {
                lblMessage.Text = result.Message;
                lblMessage.CssClass = result.Success ? "status success" : "status error";
            }

            BindGrid();
        }

        private void BindGrid()
        {
            // Order users by creation date first
            var usersOrdered = UserRepository.GetUsers()
                .OrderBy(u => u.CreatedAt)
                .ToList();

            // Ensure the primary admin (default admin email) is placed first so they get DisplayId "User1".
            var primary = usersOrdered.FirstOrDefault(u => u.Email != null && u.Email.Equals(EmailService.DefaultAdminEmail, StringComparison.OrdinalIgnoreCase));

            var reordered = primary != null
                ? new[] { primary }.Concat(usersOrdered.Where(u => u.UserId != primary.UserId)).ToList()
                : usersOrdered;

            var users = reordered
                .Select((u, index) =>
                {
                    var isPrimaryAdmin = u.Email != null && u.Email.Equals(EmailService.DefaultAdminEmail, StringComparison.OrdinalIgnoreCase);
                    return new
                    {
                        u.UserId,
                        DisplayId = "User" + (index + 1),
                        u.Email,
                        u.FullName,
                        u.Role,
                        u.PasswordHash,
                        Status = u.Status.ToString(),
                        u.EmailVerified,
                        IsActive = u.Status == UserStatus.Active,
                        CanToggle = !isPrimaryAdmin,
                        CanActivate = u.Status != UserStatus.Active,
                        CanDeactivate = u.Status == UserStatus.Active,
                        CanDelete = !isPrimaryAdmin,
                        u.CreatedAt,
                        PendingLink = InMemoryUserStore.GetPendingLink(u, token => BuildAbsoluteUrl("~/SetPassword.aspx?token=" + token))
                    };
                })
                .ToList();

            gvUsers.DataSource = users;
            gvUsers.DataBind();
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            Guid userId;
            if (!Guid.TryParse(Convert.ToString(e.CommandArgument), out userId))
            {
                return;
            }

            OperationResult result = null;
            switch (e.CommandName)
            {
                case "Approve":
                    result = InMemoryUserStore.ApproveUser(userId);
                    if (result != null && result.Success && result.Token.HasValue)
                    {
                        var user = InMemoryUserStore.GetUser(userId);
                        if (user != null)
                        {
                            try
                            {
                                var setPasswordLink = BuildAbsoluteUrl("~/SetPassword.aspx?token=" + result.Token.Value);
                                EmailService.SendEmail(user.Email,
                                    "Your admin request was accepted",
                                    $"<p>Hi {user.FullName},</p><p>Your admin access request has been approved. Please set your password to activate your account:</p><p><a href='{setPasswordLink}'>Set Password</a></p><p>If the button doesn't work, copy this link:<br/>{setPasswordLink}</p>");
                            }
                            catch (Exception ex)
                            {
                                System.Diagnostics.Debug.WriteLine(ex);
                            }
                        }
                    }
                    break;
                case "Reject":
                    result = InMemoryUserStore.RejectUser(userId);
                    break;
                case "Resend":
                    // Re-issuing approval regenerates the set password token
                    result = InMemoryUserStore.ApproveUser(userId);
                    break;
                case "Remove":
                    result = InMemoryUserStore.DeleteUser(userId);
                    break;
            }

            if (result != null)
            {
                lblMessage.Text = result.Message;
                lblMessage.CssClass = result.Success ? "status success" : "status error";
                if (result.Success)
                {
                    // Refresh persisted state after approval/rejection
                    var user = InMemoryUserStore.GetUser(userId);
                    UserRepository.UpsertUser(user);
                }
            }

            BindGrid();
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx", true);
        }

        private string BuildAbsoluteUrl(string relative)
        {
            var url = new Uri(Request.Url, ResolveUrl(relative));
            return url.AbsoluteUri;
        }
    }
}
