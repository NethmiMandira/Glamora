using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;

namespace Glamora
{
    public partial class ViewAllCustomers : Page
    {
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        protected Repeater rptCustomers;
        protected Panel pnlEmpty;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["SearchTerm"] = string.Empty;
                LoadCustomers();
            }
        }

        private void LoadCustomers()
        {
            string searchTerm = ViewState["SearchTerm"] as string ?? string.Empty;
            DataTable dtCustomers = new DataTable();
            string query = "SELECT Cus_ID, Title, CusFirst_Name, CusLast_Name, Contact, City FROM CustomerTbl";

            if (!string.IsNullOrEmpty(searchTerm))
            {
                query += " WHERE CusFirst_Name LIKE @search OR CusLast_Name LIKE @search OR Title LIKE @search";
            }

            query += " ORDER BY Cus_ID DESC";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        cmd.Parameters.AddWithValue("@search", "%" + searchTerm + "%");
                    }

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dtCustomers);
                    }
                }

                rptCustomers.DataSource = dtCustomers;
                rptCustomers.DataBind();

                pnlEmpty.Visible = dtCustomers.Rows.Count == 0;
            }
            catch (Exception)
            {
                // Handle error
                pnlEmpty.Visible = true;
            }
        }

        protected void rptCustomers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string cusId = (e.CommandArgument ?? string.Empty).ToString();

            if (e.CommandName == "EditCustomer")
            {
                Response.Redirect("EditCustomer.aspx?Cus_ID=" + Server.UrlEncode(cusId));
            }
            else if (e.CommandName == "DeleteCustomer")
            {
                DeleteCustomer(cusId);
            }
        }

        private void DeleteCustomer(string cusId)
        {
            string deleteQuery = "DELETE FROM CustomerTbl WHERE Cus_ID = @Cus_ID";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(deleteQuery, con))
                {
                    cmd.Parameters.AddWithValue("@Cus_ID", cusId);
                    con.Open();

                    int rowsAffected = cmd.ExecuteNonQuery();
                    if (rowsAffected > 0)
                    {
                        LoadCustomers(); // Reload after delete
                    }
                }
            }
            catch (SqlException)
            {
                // Handle foreign key or other errors
            }
            catch (Exception)
            {
                // General error
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ViewState["SearchTerm"] = txtSearch.Text.Trim();
            LoadCustomers();
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}