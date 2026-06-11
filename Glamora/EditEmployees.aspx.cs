using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class EditEmployees : Page
    {
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string empId = Request.QueryString["Emp_ID"];
                if (string.IsNullOrEmpty(empId))
                {
                    // No id present — go back to list
                    Response.Redirect("Employees.aspx");
                    return;
                }

                LoadEmployee(empId);
            }
        }

        private void LoadEmployee(string empId)
        {
            try
            {
                LoadServicesList();

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = "SELECT Emp_ID, Title, EmpFirst_Name, EmpLast_Name, Contact, Role FROM EmpTbl WHERE Emp_ID = @Emp_ID";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Emp_ID", empId);
                        con.Open();
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                lblEmpID.Text = rdr["Emp_ID"].ToString();
                                ddlTitle.SelectedValue = rdr["Title"].ToString();
                                txtFirstName.Text = rdr["EmpFirst_Name"].ToString();
                                txtLastName.Text = rdr["EmpLast_Name"].ToString();

                                string contactFromDb = rdr["Contact"] == DBNull.Value ? string.Empty : rdr["Contact"].ToString().Trim();
                                string localNumber = contactFromDb ?? string.Empty;

                                if (localNumber.StartsWith("+94", StringComparison.OrdinalIgnoreCase))
                                {
                                    localNumber = localNumber.Substring(3);
                                }
                                else if (localNumber.StartsWith("94", StringComparison.OrdinalIgnoreCase))
                                {
                                    localNumber = localNumber.Substring(2);
                                }

                                localNumber = localNumber.TrimStart('+').Trim();

                                txtContactLocal.Text = localNumber;
                                txtRole.Text = rdr["Role"].ToString();
                            }
                            else
                            {
                                lblMsg.Text = "Employee not found.";
                                lblMsg.CssClass = "error-message";
                                lblMsg.Visible = true;
                                Response.Redirect("Employees.aspx");
                            }
                        }
                    }

                    // Load assigned services and check them
                    string svcQuery = "SELECT Service_ID FROM EmployeeServiceTbl WHERE Emp_ID = @Emp_ID";
                    using (SqlCommand svcCmd = new SqlCommand(svcQuery, con))
                    {
                        svcCmd.Parameters.AddWithValue("@Emp_ID", empId);
                        using (SqlDataReader svcRdr = svcCmd.ExecuteReader())
                        {
                            while (svcRdr.Read())
                            {
                                string serviceId = svcRdr["Service_ID"].ToString();
                                ListItem item = cblServices.Items.FindByValue(serviceId);
                                if (item != null)
                                {
                                    item.Selected = true;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Error loading employee: " + ex.Message;
                lblMsg.CssClass = "error-message";
                lblMsg.Visible = true;
            }
        }

        private void LoadServicesList()
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT Service_ID, Service_Name FROM ServiceTbl ORDER BY Service_Name";
                using (SqlDataAdapter da = new SqlDataAdapter(query, con))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    cblServices.DataSource = dt;
                    cblServices.DataTextField = "Service_Name";
                    cblServices.DataValueField = "Service_ID";
                    cblServices.DataBind();
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string empId = lblEmpID.Text;
            string title = ddlTitle.SelectedValue;
            string firstName = txtFirstName.Text.Trim();
            string lastName = txtLastName.Text.Trim();

            // Save contact with +94 prefix to remain consistent with Customers/Employees insert behavior
            string contactLocal = txtContactLocal.Text.Trim();
            string contact = "+94" + contactLocal;

            string role = txtRole.Text.Trim();

            if (!ValidateEmployeeInput(title, firstName, lastName, contact, role))
            {
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (SqlTransaction tran = con.BeginTransaction())
                    {
                        try
                        {
                            string query = @"UPDATE EmpTbl
                                             SET Title = @Title,
                                                 EmpFirst_Name = @EmpFirst_Name,
                                                 EmpLast_Name = @EmpLast_Name,
                                                 Contact = @Contact,
                                                 Role = @Role
                                             WHERE Emp_ID = @Emp_ID";

                            using (SqlCommand cmd = new SqlCommand(query, con, tran))
                            {
                                cmd.Parameters.AddWithValue("@Title", title);
                                cmd.Parameters.AddWithValue("@EmpFirst_Name", firstName);
                                cmd.Parameters.AddWithValue("@EmpLast_Name", lastName);
                                cmd.Parameters.AddWithValue("@Contact", contact);
                                cmd.Parameters.AddWithValue("@Role", role);
                                cmd.Parameters.AddWithValue("@Emp_ID", empId);
                                cmd.ExecuteNonQuery();
                            }

                            // Update EmployeeServiceTbl: differential update
                            // 1. Get currently assigned services from DB
                            var existingServiceIds = new List<string>();
                            string selectSvc = "SELECT Service_ID FROM EmployeeServiceTbl WHERE Emp_ID = @Emp_ID";
                            using (SqlCommand selCmd = new SqlCommand(selectSvc, con, tran))
                            {
                                selCmd.Parameters.AddWithValue("@Emp_ID", empId);
                                using (SqlDataReader rdr = selCmd.ExecuteReader())
                                {
                                    while (rdr.Read())
                                        existingServiceIds.Add(rdr["Service_ID"].ToString());
                                }
                            }

                            // 2. Build selected set from CheckBoxList
                            var selectedServiceIds = new List<string>();
                            foreach (ListItem item in cblServices.Items)
                            {
                                if (item.Selected)
                                    selectedServiceIds.Add(item.Value);
                            }

                            // 3. Insert newly checked services
                            foreach (string svcId in selectedServiceIds)
                            {
                                if (!existingServiceIds.Contains(svcId))
                                {
                                    string insertSvc = "INSERT INTO EmployeeServiceTbl (Emp_ID, Service_ID) VALUES (@Emp_ID, @Service_ID)";
                                    using (SqlCommand svcCmd = new SqlCommand(insertSvc, con, tran))
                                    {
                                        svcCmd.Parameters.AddWithValue("@Emp_ID", empId);
                                        svcCmd.Parameters.AddWithValue("@Service_ID", svcId);
                                        svcCmd.ExecuteNonQuery();
                                    }
                                }
                            }

                            // 4. Remove unchecked services (skip if referenced by appointments)
                            var skippedServices = new List<string>();
                            foreach (string svcId in existingServiceIds)
                            {
                                if (!selectedServiceIds.Contains(svcId))
                                {
                                    // Check if any appointment references this employee+service
                                    string checkRef = "SELECT COUNT(*) FROM AppointmentServiceTbl WHERE Emp_ID = @Emp_ID AND Service_ID = @Service_ID";
                                    using (SqlCommand chkCmd = new SqlCommand(checkRef, con, tran))
                                    {
                                        chkCmd.Parameters.AddWithValue("@Emp_ID", empId);
                                        chkCmd.Parameters.AddWithValue("@Service_ID", svcId);
                                        int refCount = (int)chkCmd.ExecuteScalar();
                                        if (refCount > 0)
                                        {
                                            // Find the service name for a user-friendly message
                                            string nameSql = "SELECT Service_Name FROM ServiceTbl WHERE Service_ID = @Service_ID";
                                            using (SqlCommand nameCmd = new SqlCommand(nameSql, con, tran))
                                            {
                                                nameCmd.Parameters.AddWithValue("@Service_ID", svcId);
                                                object nameObj = nameCmd.ExecuteScalar();
                                                skippedServices.Add(nameObj?.ToString() ?? svcId);
                                            }
                                            continue;
                                        }
                                    }

                                    string deleteSvc = "DELETE FROM EmployeeServiceTbl WHERE Emp_ID = @Emp_ID AND Service_ID = @Service_ID";
                                    using (SqlCommand delCmd = new SqlCommand(deleteSvc, con, tran))
                                    {
                                        delCmd.Parameters.AddWithValue("@Emp_ID", empId);
                                        delCmd.Parameters.AddWithValue("@Service_ID", svcId);
                                        delCmd.ExecuteNonQuery();
                                    }
                                }
                            }

                            tran.Commit();

                            if (skippedServices.Count > 0)
                            {
                                lblMsg.Text = "Employee updated. However, the following services could not be unassigned because they are used in existing appointments: " + string.Join(", ", skippedServices);
                                lblMsg.CssClass = "error-message";
                                lblMsg.Visible = true;
                                // Reload the checkboxes to reflect actual state
                                LoadEmployee(empId);
                            }
                            else
                            {
                                Response.Redirect("Employees.aspx");
                            }
                        }
                        catch (Exception ex)
                        {
                            tran.Rollback();
                            lblMsg.Text = "Error updating employee: " + ex.Message;
                            lblMsg.CssClass = "error-message";
                            lblMsg.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Error updating employee: " + ex.Message;
                lblMsg.CssClass = "error-message";
                lblMsg.Visible = true;
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("Employees.aspx");
        }

        private bool ValidateEmployeeInput(string title, string firstName, string lastName, string contact, string role)
        {
            if (title.Length > 10)
            {
                lblMsg.Text = "Title cannot exceed 10 characters.";
                lblMsg.CssClass = "error-message";
                lblMsg.Visible = true;
                return false;
            }

            if (firstName.Length > 50)
            {
                lblMsg.Text = "First name cannot exceed 50 characters.";
                lblMsg.CssClass = "error-message";
                lblMsg.Visible = true;
                return false;
            }

            if (lastName.Length > 50)
            {
                lblMsg.Text = "Last name cannot exceed 50 characters.";
                lblMsg.CssClass = "error-message";
                lblMsg.Visible = true;
                return false;
            }

            if (contact.Length > 15)
            {
                lblMsg.Text = "Contact cannot exceed 15 characters.";
                lblMsg.CssClass = "error-message";
                lblMsg.Visible = true;
                return false;
            }

            if (role.Length > 30)
            {
                lblMsg.Text = "Role cannot exceed 30 characters.";
                lblMsg.CssClass = "error-message";
                lblMsg.Visible = true;
                return false;
            }

            return true;
        }
    }
}