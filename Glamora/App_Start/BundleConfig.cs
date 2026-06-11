using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.UI;
using System.Configuration;

namespace Glamora
{
    public class BundleConfig
    {
        // For more information on Bundling, visit https://go.microsoft.com/fwlink/?LinkID=303951
        public static void RegisterBundles(BundleCollection bundles)
        {
            RegisterJQueryScriptManager();

            bundles.Add(new ScriptBundle("~/bundles/WebFormsJs").Include(
                            "~/Scripts/WebForms/WebForms.js",
                            "~/Scripts/WebForms/WebUIValidation.js",
                            "~/Scripts/WebForms/MenuStandards.js",
                            "~/Scripts/WebForms/Focus.js",
                            "~/Scripts/WebForms/GridView.js",
                            "~/Scripts/WebForms/DetailsView.js",
                            "~/Scripts/WebForms/TreeView.js",
                            "~/Scripts/WebForms/WebParts.js"));

            // Order is very important for these files to work, they have explicit dependencies
            bundles.Add(new ScriptBundle("~/bundles/MsAjaxJs").Include(
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjax.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxApplicationServices.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxTimer.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxWebForms.js"));

            // Use the Development version of Modernizr to develop with and learn from. Then, when you’re
            // ready for production, use the build tool at https://modernizr.com to pick only the tests you need
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                            "~/Scripts/modernizr-*"));
        }

        public static void RegisterJQueryScriptManager()
        {
            ScriptManager.ScriptResourceMapping.AddDefinition("jquery",
                new ScriptResourceDefinition
                {
                    Path = "~/scripts/jquery-3.7.0.min.js",
                    DebugPath = "~/scripts/jquery-3.7.0.js",
                    CdnPath = "http://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.7.0.min.js",
                    CdnDebugPath = "http://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.7.0.js"
                });
        }
    }

    // Minimal stub types compiled as part of this file so they are available to the project.
    // These are for local/dev testing only. For production, implement real Firebase integration in a proper service class.
    public class AuthUser
    {
        public string UserId { get; set; }
        public string Email { get; set; }
        public string DisplayName { get; set; }
    }

    public class AuthResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public AuthUser User { get; set; }
        public string IdToken { get; set; }
    }

    public class FirebaseAuthService
    {
        public System.Threading.Tasks.Task<AuthResult> AuthenticateAsync(string emailOrUsername, string password)
        {
            if (string.IsNullOrWhiteSpace(emailOrUsername) || string.IsNullOrWhiteSpace(password))
            {
                return System.Threading.Tasks.Task.FromResult(new AuthResult { Success = false, Message = "Invalid credentials." });
            }

            string testUsername = ConfigurationManager.AppSettings["AuthTestUsername"] ?? "admin";
            string testPassword = ConfigurationManager.AppSettings["AuthTestPassword"] ?? "password";
            string testEmail = ConfigurationManager.AppSettings["AuthTestEmail"] ?? "admin@local";
            string testUserId = ConfigurationManager.AppSettings["AuthTestUserId"] ?? "1";
            string testDisplayName = ConfigurationManager.AppSettings["AuthTestDisplayName"] ?? "Administrator";
            string testIdToken = ConfigurationManager.AppSettings["AuthTestIdToken"] ?? "local-dev-token";

            if ((emailOrUsername.Equals(testUsername, StringComparison.OrdinalIgnoreCase) ||
                 emailOrUsername.Equals(testEmail, StringComparison.OrdinalIgnoreCase))
                && password == testPassword)
            {
                var user = new AuthUser
                {
                    UserId = testUserId,
                    Email = testEmail,
                    DisplayName = testDisplayName
                };

                return System.Threading.Tasks.Task.FromResult(new AuthResult
                {
                    Success = true,
                    Message = "Authenticated",
                    User = user,
                    IdToken = testIdToken
                });
            }

            return System.Threading.Tasks.Task.FromResult(new AuthResult { Success = false, Message = "Email/username or password is incorrect." });
        }
    }
}
