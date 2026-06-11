using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;

namespace Glamora
{
    public partial class BillPrint : Page
    {
        private readonly string _connectionString =
            ConfigurationManager.ConnectionStrings["GlamoraDBConnection"].ConnectionString;
        // computed gross total from service 'Total' column
        private decimal _computedGrossTotal = 0m;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            LoadShopDetails();

            var invoiceId = Request.QueryString["invoiceId"] ?? Request.QueryString["id"];
            var appId = Request.QueryString["appId"];

            if (string.IsNullOrWhiteSpace(invoiceId) && !string.IsNullOrWhiteSpace(appId))
            {
                invoiceId = ResolveInvoiceIdByAppointment(appId);
            }

            if (string.IsNullOrWhiteSpace(invoiceId))
            {
                ShowMessage("Missing invoice id.");
                return;
            }

            LoadInvoice(invoiceId);
        }

        private void LoadShopDetails()
        {
            const string sql = @"SELECT TOP 1 LogoURL, Address, Telephone, FooterText FROM SettingTbl ORDER BY SettingID DESC";

            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();

                using (var reader = cmd.ExecuteReader(CommandBehavior.SingleRow))
                {
                    if (!reader.Read())
                    {
                        return;
                    }

                    var logoUrl = reader["LogoURL"]?.ToString();
                    if (!string.IsNullOrWhiteSpace(logoUrl))
                    {
                        imgLogo.ImageUrl = logoUrl;
                        imgLogo.Visible = true;
                    }
                    else
                    {
                        imgLogo.Visible = false;
                    }

                    litAddress.Text = reader["Address"]?.ToString();
                    litTelephone.Text = reader["Telephone"]?.ToString();
                    litFooterText.Text = reader["FooterText"]?.ToString();
                }
            }
        }

        private string ResolveInvoiceIdByAppointment(string appId)
        {
            const string sql = @"
SELECT TOP 1 InvoiceID
FROM InvoiceTbl
WHERE AppID = @AppID
ORDER BY InvoiceDate DESC, InvoiceID DESC";

            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@AppID", appId);
                conn.Open();

                var result = cmd.ExecuteScalar() as string;
                return result;
            }
        }

        private void LoadInvoice(string invoiceId)
        {
            const string headerSql = @"
SELECT TOP 1 i.InvoiceID,
             i.InvoiceDate,
             i.AppID,
             a.AppDate,
             ISNULL(NULLIF(LTRIM(RTRIM(CONCAT(ISNULL(c.Title,''),' ',c.CusFirst_Name,' ',c.CusLast_Name))),''), '') AS CustomerName,
             i.GrossTotal,
             i.DiscountTotal,
             i.NetAmount,
             i.AdditionalDiscountValue,
             i.AdvancePayment,
             i.NetPayable,
             i.PaymentMethod,
             i.CashPaymentValue,
             i.CardPaymentValue,
             i.Balance
FROM InvoiceTbl i
LEFT JOIN AppointmentsTbl a ON i.AppID = a.AppID
LEFT JOIN CustomerTbl c ON a.Cus_ID = c.Cus_ID
WHERE i.InvoiceID = @InvoiceID";

            using (var conn = new SqlConnection(_connectionString))
            using (var cmd = new SqlCommand(headerSql, conn))
            {
                cmd.Parameters.AddWithValue("@InvoiceID", invoiceId);
                conn.Open();
                // capture header discount/advance to compute net after services are bound
                decimal headerAdditionalDiscount = 0m;
                decimal headerAdvancePayment = 0m;

                using (var reader = cmd.ExecuteReader(CommandBehavior.SingleRow))
                {
                    if (!reader.Read())
                    {
                        ShowMessage("Invoice not found.");
                        return;
                    }

                    litInvoiceNo.Text = reader["InvoiceID"]?.ToString();
                    var invoiceDate = reader["InvoiceDate"] as DateTime?;
                    litInvoiceDate.Text = invoiceDate.HasValue
                        ? invoiceDate.Value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)
                        : string.Empty;

                    var appId = reader["AppID"]?.ToString();
                    var appDate = reader["AppDate"] as DateTime?;
                    litAppId.Text = appId;
                    litAppDate.Text = appDate.HasValue
                        ? appDate.Value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)
                        : string.Empty;

                    var hasAppointment = !string.IsNullOrWhiteSpace(appId);
                    phAppointment.Visible = hasAppointment;
                    phAppointmentDate.Visible = hasAppointment;

                    litCustomer.Text = reader["CustomerName"]?.ToString();

                    // show header values for additional discount / advance; gross will be computed from service rows
                    litAdditionalDiscount.Text = FormatAmount(reader["AdditionalDiscountValue"]);
                    litAdvancePayment.Text = FormatAmount(reader["AdvancePayment"]);

                    // capture numeric values for later net calculation
                    try { headerAdditionalDiscount = reader["AdditionalDiscountValue"] != DBNull.Value ? Convert.ToDecimal(reader["AdditionalDiscountValue"]) : 0m; } catch { headerAdditionalDiscount = 0m; }
                    try { headerAdvancePayment = reader["AdvancePayment"] != DBNull.Value ? Convert.ToDecimal(reader["AdvancePayment"]) : 0m; } catch { headerAdvancePayment = 0m; }
                    litCashPaid.Text = FormatAmount(reader["CashPaymentValue"]);
                    litCardPaid.Text = FormatAmount(reader["CardPaymentValue"]);
                    litBalance.Text = FormatAmount(reader["Balance"]);
                }

                BindServices(invoiceId, conn);

                // compute Net Amount = GrossTotal (from service totals) - AdditionalDiscount - AdvancePayment
                decimal net = _computedGrossTotal - headerAdditionalDiscount - headerAdvancePayment;
                litNetAmount.Text = FormatAmount(net);

                pnlInvoice.Visible = true;
            }
        }

        private void BindServices(string invoiceId, SqlConnection openConnection)
        {
            const string servicesSql = @"
SELECT ServiceName,
       Price,
       DiscountValue,
       DiscountType,
       Total
FROM InvoiceServicesTbl
WHERE InvoiceID = @InvoiceID
ORDER BY InvoiceServID";

            using (var cmd = new SqlCommand(servicesSql, openConnection))
            {
                cmd.Parameters.AddWithValue("@InvoiceID", invoiceId);
                using (var adapter = new SqlDataAdapter(cmd))
                {
                    var table = new DataTable();
                    adapter.Fill(table);

                    // Add Discount column (percentage) to the DataTable
                    if (!table.Columns.Contains("Discount"))
                        table.Columns.Add("Discount", typeof(decimal));

                    foreach (DataRow row in table.Rows)
                    {
                        decimal price = row["Price"] != DBNull.Value ? Convert.ToDecimal(row["Price"]) : 0m;
                        decimal discountValue = row["DiscountValue"] != DBNull.Value ? Convert.ToDecimal(row["DiscountValue"]) : 0m;
                        decimal discountPercent = price > 0m ? discountValue / price : 0m;
                        row["Discount"] = discountPercent;
                    }

                    // Calculate gross total as the SUM of the 'Total' column (not Price)
                    decimal grossTotal = 0m;
                    foreach (DataRow r in table.Rows)
                    {
                        if (r["Total"] != DBNull.Value)
                        {
                            decimal val = 0m;
                            try { val = Convert.ToDecimal(r["Total"]); } catch { val = 0m; }
                            grossTotal += val;
                        }
                    }

                    rptServices.DataSource = table;
                    rptServices.DataBind();

                    // Override Gross Total display to use the computed sum of Total column
                    _computedGrossTotal = grossTotal;
                    litGrossTotal.Text = FormatAmount(grossTotal);
                }
            }
        }

        private static string FormatAmount(object value)
        {
            decimal amount;
            if (value == null || value == DBNull.Value || !decimal.TryParse(
                    Convert.ToString(value, CultureInfo.InvariantCulture),
                    NumberStyles.Number,
                    CultureInfo.InvariantCulture,
                    out amount))
            {
                amount = 0m;
            }

            return amount.ToString("N2");
        }

        private void ShowMessage(string message)
        {
            litMessage.Text = $"<div style='color:red;font-weight:600;'>{Server.HtmlEncode(message)}</div>";
            pnlInvoice.Visible = false;
        }
    }
}