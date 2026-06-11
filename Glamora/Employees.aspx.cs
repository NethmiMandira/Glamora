using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class Employees : Page
    {
        // CONFIRMED CONNECTION STRING - UPDATE THIS IF YOUR SERVER CHANGES
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GenerateEmployeeID();
                LoadCategories();
                LoadEmployees();
            }
        }

        // --- Employee ID Generation (E001, E002, etc.) ---
        private void GenerateEmployeeID()
        {
            string newEmployeeID = "E001";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(Emp_ID, 2, 9) AS INT)), 0)
                    FROM EmpTbl
                    WHERE Emp_ID LIKE 'E%'";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    try
                    {
                        con.Open();
                        object result = cmd.ExecuteScalar();

                        if (result != null && result != DBNull.Value)
                        {
                            int lastNumber = Convert.ToInt32(result);
                            int nextNumber = lastNumber + 1;
                            newEmployeeID = "E" + nextNumber.ToString("D3");
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowMessage("Error generating Employee ID: " + ex.Message, isSuccess: false);
                    }
                }
            }

            lblEmployeeID.Text = newEmployeeID;
        }

        // --- Load categories into dropdown ---
        private void LoadCategories()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = "SELECT Category_ID, Category_Name FROM ServiceCategoryTbl ORDER BY Category_Name";
                    using (SqlDataAdapter da = new SqlDataAdapter(query, con))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        ddlCategory.DataSource = dt;
                        ddlCategory.DataTextField = "Category_Name";
                        ddlCategory.DataValueField = "Category_ID";
                        ddlCategory.DataBind();
                        ddlCategory.Items.Insert(0, new ListItem("-- Select Category --", ""));
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading categories: " + ex.Message, isSuccess: false);
            }
        }

        // --- Category selection changed - filter services ---
        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Save currently selected services before rebinding
            var selectedServiceIds = new System.Collections.Generic.HashSet<string>();
            foreach (ListItem item in cblServices.Items)
            {
                if (item.Selected)
                    selectedServiceIds.Add(item.Value);
            }
            ViewState["SelectedServices"] = new System.Collections.Generic.List<string>(selectedServiceIds);

            LoadServicesList();

            // Restore selections for items that are still visible
            foreach (ListItem item in cblServices.Items)
            {
                if (selectedServiceIds.Contains(item.Value))
                    item.Selected = true;
            }
        }

        // --- Load services into the CheckBoxList (filtered by category) ---
        private void LoadServicesList()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string categoryId = ddlCategory.SelectedValue;
                    string query;

                    if (string.IsNullOrEmpty(categoryId))
                    {
                        cblServices.DataSource = null;
                        cblServices.DataBind();
                        lblServiceHint.Visible = true;
                        return;
                    }

                    query = "SELECT Service_ID, Service_Name FROM ServiceTbl WHERE Category_ID = @Category_ID ORDER BY Service_Name";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Category_ID", categoryId);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);
                            cblServices.DataSource = dt;
                            cblServices.DataTextField = "Service_Name";
                            cblServices.DataValueField = "Service_ID";
                            cblServices.DataBind();
                            lblServiceHint.Visible = false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading services: " + ex.Message, isSuccess: false);
            }
        }

        // --- Load employees into GridView ---
        private void LoadEmployees()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = @"SELECT e.Emp_ID, e.Title, e.EmpFirst_Name, e.EmpLast_Name, e.Contact, e.Role,
                                       ISNULL((SELECT STUFF((SELECT ', ' + s.Service_Name
                                                FROM EmployeeServiceTbl es
                                                INNER JOIN ServiceTbl s ON es.Service_ID = s.Service_ID
                                                WHERE es.Emp_ID = e.Emp_ID
                                                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '')), '') AS Services
                                     FROM EmpTbl e
                                     ORDER BY e.Emp_ID";

                    using (SqlDataAdapter da = new SqlDataAdapter(query, con))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvEmployees.DataSource = dt;
                        gvEmployees.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading employees: " + ex.Message, isSuccess: false);
            }
        }

        // --- Save Button Click Handler (Insert into EmpTbl) ---
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string employeeID = lblEmployeeID.Text;
            string title = ddlTitle.SelectedValue;
            string firstName = txtFirstName.Text.Trim();
            string lastName = txtLastName.Text.Trim();

            // Store contact consistently as +94 + local number, like Customers form
            string contact = "+94" + txtContactLocal.Text.Trim();
            string role = txtRole.Text.Trim();

            if (!ValidateEmployeeInput(title, firstName, lastName, contact, role))
            {
                return;
            }

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                using (SqlTransaction tran = con.BeginTransaction())
                {
                    try
                    {
                        string query = @"INSERT INTO EmpTbl
                                           (Emp_ID, Title, EmpFirst_Name, EmpLast_Name, Contact, Role) 
                                           VALUES 
                                           (@Emp_ID, @Title, @EmpFirst_Name, @EmpLast_Name, @Contact, @Role)";

                        using (SqlCommand cmd = new SqlCommand(query, con, tran))
                        {
                            cmd.Parameters.AddWithValue("@Emp_ID", employeeID);
                            cmd.Parameters.AddWithValue("@Title", title);
                            cmd.Parameters.AddWithValue("@EmpFirst_Name", firstName);
                            cmd.Parameters.AddWithValue("@EmpLast_Name", lastName);
                            cmd.Parameters.AddWithValue("@Contact", contact);
                            cmd.Parameters.AddWithValue("@Role", role);
                            cmd.ExecuteNonQuery();
                        }

                        // Collect all selected services: previously saved + currently visible
                        var allSelected = new System.Collections.Generic.HashSet<string>();
                        if (ViewState["SelectedServices"] is System.Collections.Generic.List<string> prev)
                        {
                            foreach (string id in prev) allSelected.Add(id);
                        }
                        foreach (ListItem item in cblServices.Items)
                        {
                            if (item.Selected)
                                allSelected.Add(item.Value);
                            else
                                allSelected.Remove(item.Value);
                        }

                        // Save assigned services to EmployeeServiceTbl
                        foreach (string serviceId in allSelected)
                        {
                            string insertSvc = "INSERT INTO EmployeeServiceTbl (Emp_ID, Service_ID) VALUES (@Emp_ID, @Service_ID)";
                            using (SqlCommand svcCmd = new SqlCommand(insertSvc, con, tran))
                            {
                                svcCmd.Parameters.AddWithValue("@Emp_ID", employeeID);
                                svcCmd.Parameters.AddWithValue("@Service_ID", serviceId);
                                svcCmd.ExecuteNonQuery();
                            }
                        }

                        tran.Commit();
                        RegisterAlertAndReload($"Employee {employeeID} - {firstName} {lastName} saved successfully! ✅");
                        return;
                    }
                    catch (SqlException ex)
                    {
                        tran.Rollback();
                        ShowMessage("Database Error: " + ex.Message, isSuccess: false);
                    }
                    catch (Exception ex)
                    {
                        tran.Rollback();
                        ShowMessage("Error saving employee: " + ex.Message, isSuccess: false);
                    }
                }
            }

            // If we reach here, ensure grid is up-to-date
            LoadEmployees();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ResetForm();
            GenerateEmployeeID();
        }

        // --- GridView RowCommand handler for Edit / Delete ---
        protected void gvEmployees_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string arg = (e.CommandArgument ?? string.Empty).ToString();
            if (string.IsNullOrEmpty(arg)) return;

            string empId = arg;

            if (e.CommandName == "EditEmployee")
            {
                // Navigate to Edit page with Emp_ID in query string
                Response.Redirect($"EditEmployees.aspx?Emp_ID={Server.UrlEncode(empId)}");
            }
            else if (e.CommandName == "DeleteEmployee")
            {
                // Delete from database
                try
                {
                    using (SqlConnection con = new SqlConnection(connectionString))
                    {
                        con.Open();
                        using (SqlTransaction tran = con.BeginTransaction())
                        {
                            try
                            {
                                // Check if employee has active (Pending) future appointments
                                string checkActive = @"SELECT COUNT(*)
                                    FROM AppointmentServiceTbl ast
                                    INNER JOIN AppointmentsTbl a ON ast.AppID = a.AppID
                                    WHERE ast.Emp_ID = @Emp_ID
                                      AND a.Status = 'Pending'
                                      AND a.AppDate >= CAST(GETDATE() AS DATE)";
                                using (SqlCommand chkCmd = new SqlCommand(checkActive, con, tran))
                                {
                                    chkCmd.Parameters.AddWithValue("@Emp_ID", empId);
                                    int activeCount = (int)chkCmd.ExecuteScalar();
                                    if (activeCount > 0)
                                    {
                                        tran.Rollback();
                                        ShowMessage($"Cannot delete employee {empId}. This employee has {activeCount} upcoming appointment(s).", isSuccess: false);
                                        LoadEmployees();
                                        return;
                                    }
                                }

                                // Ensure Emp_ID column allows NULL so we can clear old references
                                EnsureEmpIdNullable(con, tran);

                                // Clear Emp_ID from past/completed/cancelled appointment service rows
                                string clearRef = @"UPDATE AppointmentServiceTbl SET Emp_ID = NULL
                                    WHERE Emp_ID = @Emp_ID";
                                using (SqlCommand clearCmd = new SqlCommand(clearRef, con, tran))
                                {
                                    clearCmd.Parameters.AddWithValue("@Emp_ID", empId);
                                    clearCmd.ExecuteNonQuery();
                                }

                                // Delete assigned services
                                string deleteSvc = "DELETE FROM EmployeeServiceTbl WHERE Emp_ID = @Emp_ID";
                                using (SqlCommand svcCmd = new SqlCommand(deleteSvc, con, tran))
                                {
                                    svcCmd.Parameters.AddWithValue("@Emp_ID", empId);
                                    svcCmd.ExecuteNonQuery();
                                }

                                string query = "DELETE FROM EmpTbl WHERE Emp_ID = @Emp_ID";
                                using (SqlCommand cmd = new SqlCommand(query, con, tran))
                                {
                                    cmd.Parameters.AddWithValue("@Emp_ID", empId);
                                    int rows = cmd.ExecuteNonQuery();
                                    if (rows > 0)
                                    {
                                        tran.Commit();
                                        RegisterAlertAndReload($"Employee {empId} deleted successfully.");
                                        return;
                                    }
                                    else
                                    {
                                        tran.Rollback();
                                        ShowMessage("No employee record deleted. Employee may not exist.", isSuccess: false);
                                    }
                                }
                            }
                            catch (Exception ex)
                            {
                                tran.Rollback();
                                throw ex;
                            }
                        }
                    }
                }
                catch (SqlException ex)
                {
                    // common FK constraint handling similar to Customers
                    if (ex.Number == 547)
                        ShowMessage($"Cannot delete employee {empId}. Related records exist.", isSuccess: false);
                    else
                        ShowMessage("Database error deleting employee: " + ex.Message, isSuccess: false);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error deleting employee: " + ex.Message, isSuccess: false);
                }
                finally
                {
                    // Refresh grid if we didn't redirect/reload
                    LoadEmployees();
                }
            }
        }

        // --- Helper Methods ---

        /// <summary>
        /// Ensures AppointmentServiceTbl.Emp_ID allows NULL values by dropping
        /// any FK constraint that prevents it and altering the column.
        /// Safe to call multiple times — skips if already nullable.
        /// </summary>
        private void EnsureEmpIdNullable(SqlConnection con, SqlTransaction tran)
        {
            // Check if Emp_ID already allows NULL
            string checkSql = @"SELECT c.is_nullable
                FROM sys.columns c
                INNER JOIN sys.tables t ON c.object_id = t.object_id
                WHERE t.name = 'AppointmentServiceTbl' AND c.name = 'Emp_ID'";
            using (SqlCommand chk = new SqlCommand(checkSql, con, tran))
            {
                object result = chk.ExecuteScalar();
                if (result != null && (bool)result)
                    return; // already nullable
            }

            // Drop FK constraints on AppointmentServiceTbl.Emp_ID
            string dropFkSql = @"
                DECLARE @sql NVARCHAR(MAX) = '';
                SELECT @sql = @sql + 'ALTER TABLE [dbo].[AppointmentServiceTbl] DROP CONSTRAINT [' + fk.name + ']; '
                FROM sys.foreign_key_columns fkc
                INNER JOIN sys.foreign_keys fk ON fkc.constraint_object_id = fk.object_id
                INNER JOIN sys.tables t ON fkc.parent_object_id = t.object_id
                INNER JOIN sys.columns c ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
                WHERE t.name = 'AppointmentServiceTbl' AND c.name = 'Emp_ID';
                IF @sql <> '' EXEC sp_executesql @sql;";
            using (SqlCommand dropCmd = new SqlCommand(dropFkSql, con, tran))
            {
                dropCmd.ExecuteNonQuery();
            }

            // Alter column to allow NULL
            string alterSql = "ALTER TABLE [dbo].[AppointmentServiceTbl] ALTER COLUMN [Emp_ID] NVARCHAR(50) NULL";
            using (SqlCommand alterCmd = new SqlCommand(alterSql, con, tran))
            {
                alterCmd.ExecuteNonQuery();
            }
        }

        private void ResetForm()
        {
            txtFirstName.Text = string.Empty;
            txtLastName.Text = string.Empty;
            txtContactLocal.Text = string.Empty;
            txtRole.Text = string.Empty;
            ddlTitle.SelectedIndex = 0;
            ddlCategory.SelectedIndex = 0;
            LoadServicesList();
            foreach (ListItem item in cblServices.Items)
            {
                item.Selected = false;
            }
        }

        private bool ValidateEmployeeInput(string title, string firstName, string lastName, string contact, string role)
        {
            if (title.Length > 10)
            {
                ShowMessage("Title cannot exceed 10 characters.", isSuccess: false);
                return false;
            }

            if (firstName.Length > 50)
            {
                ShowMessage("First name cannot exceed 50 characters.", isSuccess: false);
                return false;
            }

            if (lastName.Length > 50)
            {
                ShowMessage("Last name cannot exceed 50 characters.", isSuccess: false);
                return false;
            }

            if (contact.Length > 15)
            {
                ShowMessage("Contact cannot exceed 15 characters.", isSuccess: false);
                return false;
            }

            if (role.Length > 30)
            {
                ShowMessage("Role cannot exceed 30 characters.", isSuccess: false);
                return false;
            }

            return true;
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.Visible = true;
            lblMessage.CssClass = isSuccess ? "success-message" : "error-message";
        }

        // Register a JS alert on the client and then reload the current page.
        private void RegisterAlertAndReload(string message)
        {
            string encodedMsg = HttpUtility.JavaScriptStringEncode(message);
            string encodedUrl = HttpUtility.JavaScriptStringEncode(Request.RawUrl ?? "Employees.aspx");
            string script = $"alert('{encodedMsg}'); window.location = '{encodedUrl}';";

            if (ScriptManager.GetCurrent(Page) != null)
            {
                ScriptManager.RegisterStartupScript(Page, GetType(), Guid.NewGuid().ToString(), script, true);
            }
            else
            {
                Page.ClientScript.RegisterStartupScript(GetType(), Guid.NewGuid().ToString(), script, true);
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Response.Redirect("Login.aspx");
        }
    }
}