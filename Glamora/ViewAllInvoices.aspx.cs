using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Glamora
{
    public partial class ViewAllInvoices : System.Web.UI.Page
    {
        private readonly string connectionString = "Server=DESKTOP-I6MPR4D\\SQLEXPRESS02;Database=Glamora;Integrated Security=True;";

        protected Label lblNoInvoices;
        protected Label lblError;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadInvoices();
            }
        }

        private void LoadInvoices()
        {
            try
            {
                List<InvoiceViewModel> invoices = new List<InvoiceViewModel>();
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = @"SELECT i.InvoiceID, i.InvoiceDate, i.TotalAmount, i.NetValue, i.PaymentMethod, i.BillNo, i.Balance, i.AppID,
                                     c.CusFirst_Name + ' ' + c.CusLast_Name AS CustomerName,
                                     e.EmpFirst_Name + ' ' + e.EmpLast_Name AS EmployeeName,
                                     a.Advance_amount
                                     FROM InvoiceTbl i
                                     INNER JOIN CustomerTbl c ON i.Cus_ID = c.Cus_ID
                                     INNER JOIN EmpTbl e ON i.Emp_ID = e.Emp_ID
                                     LEFT JOIN AppointmentsTbl a ON i.AppID = a.AppID
                                     ORDER BY i.InvoiceDate DESC";
                    using (SqlDataAdapter da = new SqlDataAdapter(query, con))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        foreach (DataRow row in dt.Rows)
                        {
                            invoices.Add(new InvoiceViewModel
                            {
                                InvoiceID = row["InvoiceID"].ToString(),
                                InvoiceDate = Convert.ToDateTime(row["InvoiceDate"]),
                                CustomerName = row["CustomerName"].ToString(),
                                EmployeeName = row["EmployeeName"].ToString(),
                                TotalAmount = Convert.ToDecimal(row["TotalAmount"]),
                                NetValue = Convert.ToDecimal(row["NetValue"]),
                                PaymentMethod = row["PaymentMethod"].ToString(),
                                BillNo = row["BillNo"].ToString(),
                                Balance = row["Balance"] != DBNull.Value ? Convert.ToDecimal(row["Balance"]) : 0,
                                AppID = row["AppID"].ToString(),
                                AdvanceAmount = row["Advance_amount"] != DBNull.Value ? Convert.ToDecimal(row["Advance_amount"]) : 0,
                                Services = new List<ServiceViewModel>()
                            });
                        }
                    }

                    // Load all services
                    if (invoices.Any())
                    {
                        string serviceQuery = @"SELECT iserv.InvoiceID, s.Service_Name, iserv.Price, iserv.DiscountValue, iserv.Discount
                                                FROM InvoiceServicesTbl iserv
                                                INNER JOIN ServiceTbl s ON iserv.Service_ID = s.Service_ID
                                                WHERE iserv.InvoiceID IN (" + string.Join(",", invoices.Select(i => "'" + i.InvoiceID.Replace("'", "''") + "'")) + ")";
                        using (SqlDataAdapter da = new SqlDataAdapter(serviceQuery, con))
                        {
                            DataTable dtServices = new DataTable();
                            da.Fill(dtServices);
                            var servicesByInvoice = dtServices.AsEnumerable()
                                .GroupBy(r => r["InvoiceID"].ToString())
                                .ToDictionary(g => g.Key, g => g.Select(r => new ServiceViewModel
                                {
                                    Service_Name = r["Service_Name"].ToString(),
                                    Price = Convert.ToDecimal(r["Price"]),
                                    DiscountValue = Convert.ToDecimal(r["DiscountValue"]),
                                    Discount = Convert.ToDecimal(r["Discount"])
                                }).ToList());
                            foreach (var invoice in invoices)
                            {
                                if (servicesByInvoice.ContainsKey(invoice.InvoiceID))
                                {
                                    invoice.Services = servicesByInvoice[invoice.InvoiceID];
                                }
                            }
                        }
                    }
                }
                rptInvoices.DataSource = invoices;
                rptInvoices.DataBind();
                lblNoInvoices.Visible = invoices.Count == 0;
            }
            catch (Exception ex)
            {
                lblError.Text = "Error loading invoices: " + ex.Message;
                lblError.Visible = true;
            }
        }

        protected void rptInvoices_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Delete")
            {
                string invoiceID = e.CommandArgument.ToString();
                DeleteInvoice(invoiceID);
                LoadInvoices();
            }
        }

        private void DeleteInvoice(string invoiceID)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (SqlTransaction trans = con.BeginTransaction())
                    {
                        // Delete from InvoiceServicesTbl
                        string deleteServices = "DELETE FROM InvoiceServicesTbl WHERE InvoiceID = @InvoiceID";
                        using (SqlCommand cmd = new SqlCommand(deleteServices, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@InvoiceID", invoiceID);
                            cmd.ExecuteNonQuery();
                        }

                        // Delete from InvoiceTbl
                        string deleteInvoice = "DELETE FROM InvoiceTbl WHERE InvoiceID = @InvoiceID";
                        using (SqlCommand cmd = new SqlCommand(deleteInvoice, con, trans))
                        {
                            cmd.Parameters.AddWithValue("@InvoiceID", invoiceID);
                            cmd.ExecuteNonQuery();
                        }

                        trans.Commit();
                    }
                }
            }
            catch (Exception ex)
            {
                // Handle error
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            try
            {
                Session.Clear();
                Session.Abandon();
                Response.Redirect("Login.aspx");
            }
            catch (Exception ex)
            {
                // Handle error
            }
        }
    }

    public class InvoiceViewModel
    {
        public string InvoiceID { get; set; }
        public DateTime InvoiceDate { get; set; }
        public string CustomerName { get; set; }
        public string EmployeeName { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal NetValue { get; set; }
        public string PaymentMethod { get; set; }
        public string BillNo { get; set; }
        public string AppID { get; set; }
        public decimal AdvanceAmount { get; set; }
        public decimal Balance { get; set; }
        public List<ServiceViewModel> Services { get; set; }
    }

    public class ServiceViewModel
    {
        public string Service_Name { get; set; }
        public decimal Price { get; set; }
        public decimal DiscountValue { get; set; }
        public decimal Discount { get; set; }
    }
}