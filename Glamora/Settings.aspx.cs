using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace Glamora
{
    public partial class Settings : System.Web.UI.Page
    {
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        private SortDirection SortDirection
        {
            get
            {
                if (ViewState["SortDirection"] == null)
                    ViewState["SortDirection"] = SortDirection.Ascending;
                return (SortDirection)ViewState["SortDirection"];
            }
            set
            {
                ViewState["SortDirection"] = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindSettingsGrid();
            }
        }

        private void LoadSettings()
        {
            string query = "SELECT TOP 1 LogoURL, Address, Telephone, FooterText FROM SettingTbl";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string logoURL = reader["LogoURL"].ToString();
                            ViewState["CurrentLogoURL"] = logoURL;
                            if (!string.IsNullOrEmpty(logoURL))
                            {
                                imgCurrentLogo.ImageUrl = logoURL;
                                imgCurrentLogo.Visible = true;
                            }
                            txtAddress.Text = reader["Address"].ToString();
                            txtTelephone.Text = reader["Telephone"].ToString();
                            txtFooterText.Text = reader["FooterText"].ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading settings: " + ex.Message, isSuccess: false);
            }
        }

        private void BindSettingsGrid()
        {
            string query = "SELECT SettingID, SettingID AS DisplaySettingID, LogoURL, Address, Telephone, FooterText FROM SettingTbl";

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(query, con))
                    {
                        da.Fill(dt);
                    }
                }
                gvSettings.DataSource = dt;
                gvSettings.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading settings grid: " + ex.Message, isSuccess: false);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string logoURL = ViewState["CurrentLogoURL"] as string ?? "";
            if (fuLogo.HasFile)
            {
                string fileName = Path.GetFileName(fuLogo.FileName);
                string folderPath = Server.MapPath("~/Logos/");
                if (!Directory.Exists(folderPath))
                {
                    Directory.CreateDirectory(folderPath);
                }
                string filePath = Path.Combine(folderPath, fileName);
                fuLogo.SaveAs(filePath);
                logoURL = "~/Logos/" + fileName;
            }

            string address = txtAddress.Text.Trim();
            string telephone = txtTelephone.Text.Trim();
            string footerText = txtFooterText.Text.Trim();

            string query;
            bool isUpdate = ViewState["EditingSettingID"] != null;

            if (isUpdate)
            {
                query = "UPDATE SettingTbl SET LogoURL = @LogoURL, Address = @Address, Telephone = @Telephone, FooterText = @FooterText WHERE SettingID = @SettingID";
            }
            else
            {
                query = "INSERT INTO SettingTbl (SettingID, LogoURL, Address, Telephone, FooterText) VALUES (@SettingID, @LogoURL, @Address, @Telephone, @FooterText)";
            }

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    if (isUpdate)
                    {
                        cmd.Parameters.AddWithValue("@SettingID", ViewState["EditingSettingID"]);
                    }
                    else
                    {
                        // Generate new SettingID (e.g., SET001, SET002, ...)
                        cmd.Parameters.AddWithValue("@SettingID", GenerateNextSettingID(con));
                    }
                    cmd.Parameters.AddWithValue("@LogoURL", logoURL);
                    cmd.Parameters.AddWithValue("@Address", address);
                    cmd.Parameters.AddWithValue("@Telephone", telephone);
                    cmd.Parameters.AddWithValue("@FooterText", footerText);

                    int rowsAffected = cmd.ExecuteNonQuery();
                    if (rowsAffected > 0)
                    {
                        BindSettingsGrid();
                        ClearForm();
                    }
                    else
                    {
                        ShowMessage("No changes were made.", isSuccess: false);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving settings: " + ex.Message, isSuccess: false);
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearForm();
            lblMessage.Visible = false;
        }

        private void ClearForm()
        {
            txtAddress.Text = "";
            txtTelephone.Text = "";
            txtFooterText.Text = "";
            fuLogo.Attributes.Clear();
            imgCurrentLogo.Visible = false;
            ViewState["CurrentLogoURL"] = null;
            ViewState["EditingSettingID"] = null;
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = isSuccess ? "success-message" : "error-message";
            lblMessage.Visible = true;
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        protected void gvSettings_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditSetting")
            {
                string settingId = e.CommandArgument.ToString();
                LoadSettingForEdit(settingId);
            }
            else if (e.CommandName == "DeleteSetting")
            {
                string settingId = e.CommandArgument.ToString();
                DeleteSetting(settingId);
                BindSettingsGrid();
            }
        }

        protected void gvSettings_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            this.gvSettings.PageIndex = e.NewPageIndex;
            BindSettingsGrid();
        }

        protected void gvSettings_Sorting(object sender, GridViewSortEventArgs e)
        {
            string sortExpression = e.SortExpression;
            string direction = string.Empty;
            if (SortDirection == SortDirection.Ascending)
            {
                SortDirection = SortDirection.Descending;
                direction = " DESC";
            }
            else
            {
                SortDirection = SortDirection.Ascending;
                direction = " ASC";
            }
            BindSettingsGridWithSort(sortExpression + direction);
        }

        private void BindSettingsGridWithSort(string sortOrder)
        {
            string query = "SELECT SettingID, SettingID AS DisplaySettingID, LogoURL, Address, Telephone, FooterText FROM SettingTbl ORDER BY " + sortOrder;

            try
            {
                DataTable dt = new DataTable();
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
                gvSettings.DataSource = dt;
                gvSettings.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading settings grid: " + ex.Message, isSuccess: false);
            }
        }

        private void LoadSettingForEdit(string settingId)
        {
            string query = "SELECT LogoURL, Address, Telephone, FooterText FROM SettingTbl WHERE SettingID = @SettingID";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SettingID", settingId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string logoURL = reader["LogoURL"].ToString();
                            ViewState["CurrentLogoURL"] = logoURL;
                            if (!string.IsNullOrEmpty(logoURL))
                            {
                                imgCurrentLogo.ImageUrl = logoURL;
                                imgCurrentLogo.Visible = true;
                            }
                            else
                            {
                                imgCurrentLogo.Visible = false;
                            }
                            txtAddress.Text = reader["Address"].ToString();
                            txtTelephone.Text = reader["Telephone"].ToString();
                            txtFooterText.Text = reader["FooterText"].ToString();
                            ViewState["EditingSettingID"] = settingId;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading setting for edit: " + ex.Message, isSuccess: false);
            }
        }

        private void DeleteSetting(string settingId)
        {
            string query = "DELETE FROM SettingTbl WHERE SettingID = @SettingID";

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SettingID", settingId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting setting: " + ex.Message, isSuccess: false);
            }
        }

        // Generate next SettingID as SET001, SET002, ...
        private string GenerateNextSettingID(SqlConnection con)
        {
            string sql = "SELECT MAX(SettingID) FROM SettingTbl WHERE SettingID LIKE 'SET%'";
            string lastId = null;
            using (var cmd = new SqlCommand(sql, con))
            {
                // Do not open or close the connection here; let the caller handle it.
                var obj = cmd.ExecuteScalar();
                lastId = obj != null && obj != DBNull.Value ? obj.ToString() : null;
            }
            int nextNum = 1;
            if (!string.IsNullOrEmpty(lastId) && lastId.Length >= 6)
            {
                int.TryParse(lastId.Substring(3), out nextNum);
                nextNum++;
            }
            return $"SET{nextNum.ToString("D3")}";
        }
    }
}