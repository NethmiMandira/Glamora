<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PendingToday.aspx.cs" Inherits="Glamora.PendingToday" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Today's Pending Appointments</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --sidebar-bg: #1e293b;
            --sidebar-text: #94a3b8;
            /* Theme color changed to cyan (#06b6d4) as requested */
            --primary-color: #06b6d4;
            --primary-hover: #0ea5a3;
            --primary-light-bg: #e6f9fb;
            --accent-red: #ef4444;
            --accent-green: #10b981;
            --accent-blue: #06b6d4;
            --accent-orange: #f97316;
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

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 10px 0 20px 0;
            flex-wrap: wrap;
            gap: 15px;
        }

        .header {
            font-size: 1.75rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            color: var(--text-dark);
            margin: 0;
        }

        .today-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: linear-gradient(135deg,#7dd3fc,#06b6d4);
            color: white;
            padding: 8px 16px;
            border-radius: 999px;
            font-weight: 700;
            font-size: 0.95rem;
            box-shadow: 0 4px 12px rgba(249, 115, 22, 0.35);
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

        .emp-service-group {
            margin-bottom: 8px;
        }
        .emp-service-group:last-child {
            margin-bottom: 0;
        }
        .emp-service-name {
            font-weight: 700;
            color: var(--primary-hover);
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        .emp-service-name i {
            font-size: 0.8rem;
            opacity: 0.8;
        }
        .emp-service-list {
            list-style: none;
            margin: 4px 0 0 0;
            padding-left: 22px;
        }
        .emp-service-list li {
            position: relative;
            padding: 2px 0;
            font-size: 0.9rem;
            color: var(--text-dark);
        }
        .emp-service-list li::before {
            content: '\2022';
            color: var(--primary-color);
            font-weight: 700;
            position: absolute;
            left: -14px;
        }

        .inline-row {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .inline-row .label {
            color: var(--text-muted);
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .inline-row .value {
            color: var(--text-dark);
            display: inline-block;
        }

        .card-footer {
            border-top: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding: 12px 14px;
        }

        .chips-row {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: nowrap;
        }

        .footer-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .left-actions {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .right-actions {
            display: flex;
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
            font-size: 0.9rem;
            border: 1px solid var(--border-color);
            background: #ffffff;
            color: var(--text-dark);
        }
        .chip.total    { background: var(--text-dark); color: #fff; }
        .chip.advance  { background: #fff7ed; color: #b45309; border-color: #fed7aa; }
        .chip.balance  { background: #ecfdf5; color: #065f46; border-color: #a7f3d0; }
        .chip.status   { background: #ede9fe; color: #5b21b6; border-color: #c4b5fd; }
        .chip.status.pending { background: #ede9fe; color: #5b21b6; border-color: #c4b5fd; }
        .chip.status.done { background: #ecfdf3; color: #065f46; border-color: #a7f3d0; }
        .chip.status.cancelled { background: #fee2e2; color: #b91c1c; border-color: #fecaca; }
        .chip.status.lapsed { background: #fef3c7; color: #b45309; border-color: #fcd34d; }
        .btn-pay {
            padding: 8px 14px;
            border: none;
            border-radius: 6px;
            font-weight: 700;
            cursor: pointer;
            color: #fff;
            box-shadow: 0 4px 10px rgba(2, 6, 23, 0.08);
        }

        /* Button variants - use same action colors as AppointmentBooking page */
        /* AppointmentBooking uses: primary-color: #6366f1, primary-hover: #4f46e5, accent-orange: #f59e0b, accent-red: #ef4444 */
        .btn-edit { background: linear-gradient(135deg,#8b5cf6,#7c3aed); box-shadow: 0 4px 10px rgba(139,92,246,0.14); color: #fff; }
        .btn-edit:hover { background: #7c3aed; }

        /* lighter, friendlier cancel button with white text */
        .btn-cancel { background: linear-gradient(135deg,#ffd27a,#f59e0b); color: #fff; box-shadow: 0 4px 10px rgba(245,158,11,0.10); }
        .btn-cancel:hover { background: #f59e0b; }

        .btn-remove { background: linear-gradient(135deg,#ff9b9b,#ef4444); color: #fff; box-shadow: 0 4px 10px rgba(239,68,68,0.12); }
        .btn-remove:hover { background: #ef4444; }

        .btn-invoice { background: linear-gradient(135deg,#7dd3fc,#06b6d4); color: #fff; box-shadow: 0 4px 10px rgba(6,182,212,0.10); }
        .btn-invoice:hover { background: #06b6d4; }

        .btn-pay[disabled], .btn-pay.disabled {
            background: #94a3b8 !important;
            color: #ffffff !important;
            cursor: not-allowed;
            box-shadow: none;
            opacity: 0.9;
        }

        .empty {
            background: #fff;
            border: 1px dashed var(--border-color);
            color: var(--text-muted);
            padding: 40px 25px;
            text-align: center;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
        }

        .empty i {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        .empty-title {
            font-size: 1.25rem;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            padding: 8px 16px;
            border-radius: 6px;
            transition: all 0.2s;
            margin-bottom: 20px;
        }

        .back-link:hover {
            background: var(--primary-light-bg);
            gap: 12px;
        }

        @media (max-width: 768px) {
            .header-section {
                flex-direction: column;
                align-items: flex-start;
            }
            .row {
                grid-template-columns: 1fr;
            }
            .date-time {
                flex-direction: column;
                align-items: flex-start;
                gap: 4px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page">
            <a href="Dashboard.aspx" class="back-link">
                <i class="fas fa-arrow-left"></i>
                Back to Dashboard
            </a>

            <div class="header-section">
                <h1 class="header">Today's Pending Appointments</h1>
                <div class="today-badge">
                    <i class="fa-solid fa-calendar-day"></i>
                    <asp:Label ID="lblTodayDate" runat="server"></asp:Label>
                </div>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty">
                <i class="fa-regular fa-calendar-xmark"></i>
                <div class="empty-title">No Pending Appointments Today</div>
                <div>There are no pending appointments scheduled for today.</div>
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
                                <%# Eval("Start_time") == DBNull.Value ? "" : ((TimeSpan)Eval("Start_time")).ToString(@"hh\:mm") %> - <%# Eval("End_time") == DBNull.Value ? "" : ((TimeSpan)Eval("End_time")).ToString(@"hh\:mm") %>
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
                                <div class="label"><i class="fa-solid fa-phone"></i> Contact</div>
                                <div class="value"><%# Eval("Customer_contact") %></div>
                            </div>
                            <div class="row">
                                <div class="label"><i class="fa-solid fa-magic"></i> Services</div>
                                <div class="value services"><%# GetEmployeeServicesHtml(Eval("AppID")) %></div>
                            </div>
                            <div class="row">
                                <div class="label"><i class="fa-regular fa-calendar-plus"></i> Booked On</div>
                                <div class="value"><%# Eval("Booking_date", "{0:yyyy-MM-dd}") %></div>
                            </div>
                            <div class="inline-row">
                                <span class="label"><i class="fa-regular fa-flag"></i>&nbsp;Status:</span>
                                <span class='chip status pending'><%# string.IsNullOrWhiteSpace(Eval("Status") as string) ? "Pending" : Eval("Status") %></span>
                            </div>
                        </div>

                        <div class="card-footer">
                            <div class="footer-row" style="display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;">
                                <div class="chips-row" style="display:flex;gap:8px;align-items:center;flex:1;min-width:0;">
                                    <span class="chip total"><i class="fa-solid fa-sack-dollar"></i> Total: Rs. <%# Eval("Total_amount", "{0:N2}") %></span>
                                    <span class="chip advance"><i class="fa-regular fa-hand-holding-dollar"></i> Advance: Rs. <%# Eval("Advance_amount", "{0:N2}") %></span>
                                    <span class="chip balance"><i class="fa-solid fa-scale-balanced"></i> Amount Due: Rs. <%# Eval("Balance_amount", "{0:N2}") %></span>
                                </div>
                                <div class="right-actions" style="flex:0 0 auto;">
                                    <asp:Button ID="btnDetails" runat="server"
                                        Text="Details"
                                        CssClass="btn-pay btn-invoice"
                                        CommandName="Details"
                                        CommandArgument='<%# Eval("AppID") %>' />
                                </div>
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
