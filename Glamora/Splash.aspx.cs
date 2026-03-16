using System;
using System.Web.UI;

namespace Glamora
{
    public partial class Splash : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Nothing needed on Page_Load for this simple redirection model
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Redirects to the Login page when the "Log In" button is clicked
            Response.Redirect("Login.aspx");
        }

        protected void btnSignUp_Click(object sender, EventArgs e)
        {
            // Redirects to the Sign Up page when the "Sign Up" button is clicked
            Response.Redirect("SignUp.aspx");
        }
    }
}