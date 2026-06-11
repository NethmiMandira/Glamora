using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class ServiceCategories : Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["GlamoraDBConnection"]?.ConnectionString
                                                     ?? "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        private bool IsEditing
        {
            get => ViewState["IsEditing"] != null && (bool)ViewState["IsEditing"];
            set => ViewState["IsEditing"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GenerateCategoryID();
                BindGrid();
            }
        }

        private void GenerateCategoryID()
        {
            string newID = "C001";
            IsEditing = false;
            btnSave.Text = "Save Category";

            const string sql = @"
                SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(Category_ID, 2, 9) AS INT)), 0)
                FROM ServiceCategoryTbl
                WHERE Category_ID LIKE 'C%'";

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        if (int.TryParse(result.ToString(), out int lastNumber))
                        {
                            newID = "C" + (lastNumber + 1).ToString("D3");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("GenerateCategoryID error: {0}", ex);
                ShowMessage("Error generating Category ID: " + ex.Message, "error-message");
            }

            lblCategoryID.Text = newID;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string categoryID = lblCategoryID.Text?.Trim();
            string categoryName = txtCategoryName.Text.Trim();

            if (string.IsNullOrWhiteSpace(categoryName))
            {
                ShowMessage("Category Name is required.", "error-message");
                return;
            }

            string sql;
            if (IsEditing)
            {
                sql = "UPDATE ServiceCategoryTbl SET Category_Name = @Category_Name WHERE Category_ID = @Category_ID";
            }
            else
            {
                sql = "INSERT INTO ServiceCategoryTbl (Category_ID, Category_Name) VALUES (@Category_ID, @Category_Name)";
            }

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Category_ID", categoryID);
                    cmd.Parameters.AddWithValue("@Category_Name", categoryName);

                    con.Open();
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        string action = IsEditing ? "updated" : "saved";
                        ShowMessage($"Category {categoryID} successfully {action}.", "success-message");
                        ResetForm();
                        GenerateCategoryID();
                        BindGrid();
                    }
                    else
                    {
                        ShowMessage("Save failed. No rows affected.", "error-message");
                    }
                }
            }
            catch (SqlException ex)
            {
                ShowMessage("Database Error: " + ex.Message, "error-message");
            }
            catch (Exception ex)
            {
                ShowMessage("Unexpected Error: " + ex.Message, "error-message");
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ResetForm();
            GenerateCategoryID();
        }

        protected void gvCategories_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string categoryID = e.CommandArgument.ToString();

            if (e.CommandName == "EditCategory")
            {
                LoadCategoryForEdit(categoryID);
            }
            else if (e.CommandName == "DeleteCategory")
            {
                DeleteCategory(categoryID);
            }
        }

        private void LoadCategoryForEdit(string categoryID)
        {
            const string sql = "SELECT Category_Name FROM ServiceCategoryTbl WHERE Category_ID = @Category_ID";

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@Category_ID", categoryID);
                    con.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblCategoryID.Text = categoryID;
                            txtCategoryName.Text = reader["Category_Name"].ToString();
                            IsEditing = true;
                            btnSave.Text = "Update Category";
                            lblMessage.Visible = false;
                        }
                        else
                        {
                            ShowMessage($"Category {categoryID} not found.", "error-message");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading category: " + ex.Message, "error-message");
            }
        }

        private void DeleteCategory(string categoryID)
        {
            // Check if any services use this category
            const string checkSql = "SELECT COUNT(*) FROM ServiceTbl WHERE Category_ID = @Category_ID";
            const string deleteSql = "DELETE FROM ServiceCategoryTbl WHERE Category_ID = @Category_ID";

            try
            {
                using (var con = new SqlConnection(connectionString))
                {
                    con.Open();

                    using (var chkCmd = new SqlCommand(checkSql, con))
                    {
                        chkCmd.Parameters.AddWithValue("@Category_ID", categoryID);
                        int count = (int)chkCmd.ExecuteScalar();
                        if (count > 0)
                        {
                            ShowMessage($"Cannot delete category {categoryID}. It is assigned to {count} service(s).", "error-message");
                            return;
                        }
                    }

                    using (var cmd = new SqlCommand(deleteSql, con))
                    {
                        cmd.Parameters.AddWithValue("@Category_ID", categoryID);
                        int rows = cmd.ExecuteNonQuery();

                        if (rows > 0)
                        {
                            ShowMessage($"Category {categoryID} deleted successfully.", "success-message");
                            ResetForm();
                            GenerateCategoryID();
                            BindGrid();
                        }
                        else
                        {
                            ShowMessage($"Category {categoryID} not found.", "error-message");
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547)
                    ShowMessage("Cannot delete category. It is linked to existing services.", "error-message");
                else
                    ShowMessage("Database Error: " + ex.Message, "error-message");
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting category: " + ex.Message, "error-message");
            }
        }

        private void ResetForm()
        {
            txtCategoryName.Text = string.Empty;
            lblMessage.Visible = false;
        }

        private void BindGrid()
        {
            const string sql = "SELECT Category_ID, Category_Name FROM ServiceCategoryTbl ORDER BY Category_ID";

            try
            {
                using (var con = new SqlConnection(connectionString))
                using (var cmd = new SqlCommand(sql, con))
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    gvCategories.DataSource = dt;
                    gvCategories.DataBind();
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine("BindGrid error: {0}", ex);
                ShowMessage("Error loading categories: " + ex.Message, "error-message");
            }
        }

        private void ShowMessage(string message, string cssClass)
        {
            if (lblMessage != null)
            {
                lblMessage.Text = message;
                lblMessage.CssClass = cssClass;
                lblMessage.Visible = true;
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Response.Redirect("Login.aspx");
        }
    }
}
