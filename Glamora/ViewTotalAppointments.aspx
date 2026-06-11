<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewTotalAppointments.aspx.cs" Inherits="Glamora.ViewTotalAppointments" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Appointments</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --sidebar-bg: #1e293b;
            --sidebar-text: #94a3b8;
            --primary-color: #6366f1;
            --primary-hover: #4f46e5;
            --primary-light-bg: #e0e7ff;
            --accent-red: #ef4444;
            --accent-green: #10b981;
            --bg-body: #f1f5f9;
            --bg-white: #ffffff;
            --text-dark: #0f172a;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --radius: 10px;
        }

        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            background: var(--bg-body);
            color: var(--text-dark);
        }

        .page {
            max-width: 900px;
            margin: 30px auto;
            padding: 0 20px 40px 20px;
        }

        .header {
            font-size: 1.75rem;
            font-weight: 800;
            margin: 10px 0 20px 0;
            letter-spacing: -0.5px;
            color: var(--text-dark);
        }

        .cards-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 18px;
        }

        .card {
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }
        .card.expired {
            opacity: .9;
            border-color: #fecaca;
            position: relative;
        }
        .expired-banner {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fecaca;
            border-radius: 999px;
            font-weight: 700;
            font-size: .85rem;
            padding: 6px 10px;
            white-space: nowrap;
            margin-bottom: 8px;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            align-items: center;
            padding: 12px 14px;
            background: var(--primary-light-bg);
            border-bottom: 1px solid var(--border-color);
        }

        .app-id {
            font-weight: 800;
            color: var(--primary-hover);
            background: #fff;
            border: 1px solid var(--primary-color);
            border-radius: 6px;
            padding: 4px 10px;
            box-shadow: var(--shadow);
            white-space: nowrap;
        }

        .date-time {
            color: var(--text-dark);
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
        }

        .card-body {
            padding: 14px;
            display: grid;
            grid-template-columns: 1fr;
            gap: 8px;
        }

        .row {
            display: grid;
            grid-template-columns: 140px 1fr;
            gap: 10px;
            align-items: start;
            font-size: .95rem;
        }
        .row .label {
            color: var(--text-muted);
            font-weight: 600;
        }
        .row .value {
            color: var(--text-dark);
        }

        .services {
            background: #f8fafc;
            border: 1px dashed var(--border-color);
            padding: 10px;
            border-radius: 6px;
            color: var(--text-dark);
            line-height: 1.35rem;
        }

        .inline-row {
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
        }
        .inline-row .label {
            color: var(--text-muted);
            font-weight: 600;
            display: inline-flex;
            align-items: center;
        }
        .inline-row .value {
            color: var(--text-dark);
            display: inline-block;
        }

        .card-footer {
            position: relative;
            padding: 12px 14px 48px 14px; /* extra bottom space for the button */
            border-top: 1px solid var(--border-color);
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            align-items: center;
        }

        .chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 10px;
            border-radius: 999px;
            font-weight: 700;
            font-size: 0.92rem;
            border: 1px solid var(--border-color);
            background: #ffffff;
            color: var(--text-dark);
        }
        .chip.total    { background: var(--text-dark); color: #fff; }
        .chip.advance  { background: #fff7ed; color: #b45309; border-color: #fed7aa; }
        .chip.balance  { background: #ecfdf5; color: #065f46; border-color: #a7f3d0; }

        /* Bottom-right placement for Go to Payment button */
        .pay-btn-wrapper {
            position: absolute;
            right: 14px;
        }

        /* Red themed button */
        .btn-pay {
            padding: 8px 14px;
            border: none;
            border-radius: 6px;
            font-weight: 700;
            cursor: pointer;
            background: #ef4444; /* red-500 */
            color: #fff;
            box-shadow: 0 4px 10px rgba(239, 68, 68, 0.35);
        }
        .btn-pay:hover {
            background: #dc2626; /* red-600 */
        }
        .btn-pay[disabled], .btn-pay.disabled {
            background: #94a3b8;
            color: #ffffff;
            cursor: not-allowed;
            box-shadow: none;
        }

        .empty {
            background: #fff;
            border: 1px dashed var(--border-color);
            color: var(--text-muted);
            padding: 25px;
            text-align: center;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page">
            <h1 class="header">All Appointments</h1>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty">
                <i class="fa-regular fa-calendar-xmark"></i>
                &nbsp;No appointments found.
            </asp:Panel>

            <asp:Repeater ID="rptAppointments" runat="server" OnItemCommand="rptAppointments_ItemCommand">
                <HeaderTemplate>
                    <div class="cards-grid">
                </HeaderTemplate>
                <ItemTemplate>
                    <div class='<%# (bool)Eval("IsExpired") ? "card expired" : "card" %>'>
                        <div class="card-header">
                            <span class="app-id"><%# Eval("AppID") %></span>
                            <span class="date-time">
                                <i class="fa-solid fa-calendar-day"></i>
                                <%# Eval("AppDate", "{0:yyyy-MM-dd}") %>
                                &nbsp;&middot;&nbsp;
                                <i class="fa-regular fa-clock"></i>
                                <%# Eval("Start_time") %> - <%# Eval("End_time") %>
                            </span>
                        </div>

                        <div class="card-body">
                            <%# (bool)Eval("IsExpired")
                                ? "<div class=\"expired-banner\"><i class=\"fa-regular fa-hourglass\"></i> Lapsed</div>"
                                : "" %>

                            <div class="row">
                                <div class="label"><i class="fa-regular fa-user"></i> Customer</div>
                                <div class="value"><%# Eval("Customer_name") %></div>
                            </div>
                            <div class="row">
                                <div class="label"><i class="fa-solid fa-user-tie"></i> Employee</div>
                                <div class="value"><%# Eval("Employees") %></div>
                            </div>
                            <div class="row">
                                <div class="label"><i class="fa-solid fa-magic"></i> Services</div>
                                <div class="value services"><%# Eval("Services") %></div>
                            </div>
                            <div class="row">
                                <div class="label"><i class="fa-regular fa-calendar-plus"></i> Booked On</div>
                                <div class="value"><%# Eval("Booking_date", "{0:yyyy-MM-dd}") %></div>
                            </div>
                            <div class="inline-row">
                                <span class="label"><i class="fa-solid fa-money-check-dollar"></i>&nbsp;Payment Method:</span>
                                <span class="value"><%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("Payment_method"))) ? "-" : Eval("Payment_method") %></span>
                            </div>
                        </div>

                        <div class="card-footer">
                            <span class="chip total"><i class="fa-solid fa-sack-dollar"></i> Total: Rs. <%# Eval("Total_amount", "{0:N2}") %></span>
                            <span class="chip advance"><i class="fa-regular fa-hand-holding-dollar"></i> Advance: Rs. <%# Eval("Advance_amount", "{0:N2}") %></span>
                            <span class="chip balance"><i class="fa-solid fa-scale-balanced"></i> Balance: Rs. <%# Eval("Balance_amount", "{0:N2}") %></span>

                            <div class="pay-btn-wrapper">
                                <asp:Button ID="btnPay" runat="server"
                                    Text="Go to Payment"
                                    CssClass='<%# (bool)Eval("IsExpired") ? "btn-pay disabled" : "btn-pay" %>'
                                    Enabled='<%# !(bool)Eval("IsExpired") %>'
                                    CommandName="Pay"
                                    CommandArgument='<%# Eval("AppID") %>' />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate>
                    </div>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </form>
</body>
</html>