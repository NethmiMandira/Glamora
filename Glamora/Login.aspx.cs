using System;
using System.Web.UI;
using System.Threading.Tasks;
// using Glamora.Services; // <-- Make sure to uncomment and update this line with your actual service namespace

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
    }
}