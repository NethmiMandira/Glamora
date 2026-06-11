<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CancelledAppointments.aspx.cs" Inherits="Glamora.CancelledAppointments" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Cancelled Appointments</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --sidebar-bg: #1e293b;
            --sidebar-text: #94a3b8;
            --primary-color: #ef4444;
            --primary-hover: #dc2626;
            --primary-light-bg: #fee2e2;
            --accent-red: #ef4444;
            --accent-green: #10b981;
            --accent-blue: #3b82f6;
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

        .cancelled-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: linear-gradient(135deg, #f87171, var(--primary-color));
            color: white;
            padding: 8px 16px;
            border-radius: 999px;
            font-weight: 700;
            font-size: 0.95rem;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.35);
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
        .card.cancelled {
            border-color: #fecaca;
            /* use white background for content (match PendingToday cards) */
            background: var(--bg-white);
            box-shadow: var(--shadow);
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
            position: relative;
            padding: 12px 14px 16px 14px;
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
            font-size: 0.9rem;
            border: 1px solid var(--border-color);
            background: #ffffff;
            color: var(--text-dark);
        }
        .chip.total    { background: var(--text-dark); color: #fff; }
        .chip.advance  { background: #fff7ed; color: #b45309; border-color: #fed7aa; }
        .chip.balance  { background: #ecfdf5; color: #065f46; border-color: #a7f3d0; }
        .chip.status   { background: #fee2e2; color: #b91c1c; border-color: #fecaca; }
        .chip.status.cancelled { background: #fee2e2; color: #b91c1c; border-color: #fecaca; }

        .btn-pay {
            padding: 8px 14px;
            border: none;
            border-radius: 6px;
            font-weight: 700;
            cursor: pointer;
            color: #fff;
            box-shadow: 0 4px 10px rgba(2, 6, 23, 0.08);
        }

        .btn-invoice { background: linear-gradient(135deg,#7dd3fc,#06b6d4); color: #fff; box-shadow: 0 4px 10px rgba(6,182,212,0.10); }
        .btn-invoice:hover { background: #06b6d4; }

        /* Details button variant for cancelled page (red shade matching card) */
        .btn-details-cancelled { background: linear-gradient(135deg,#fb7185,#ef4444); color: #fff; box-shadow: 0 4px 10px rgba(239,68,68,0.12);margin-left:200%;

        }
        .btn-details-cancelled:hover { background: #ef4444; }

        .btn-delete {
            padding: 8px 14px;
            border: none;
            border-radius: 6px;
            font-weight: 700;
            cursor: pointer;
            background: #ef4444;
            color: #fff;
            box-shadow: 0 4px 10px rgba(239, 68, 68, 0.35);
        }
        .btn-delete:hover {
            background: #dc2626;
        }
        .btn-delete[disabled], .btn-delete.disabled {
            background: #94a3b8;
            color: #ffffff;
            cursor: not-allowed;
            box-shadow: none;
        }

        .delete-wrapper {
            margin-left: auto;
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
                <h1 class="header">Cancelled Appointments</h1>
                <div class="cancelled-badge">
                    <i class="fa-regular fa-calendar-xmark"></i>
                    All Cancellations
                </div>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty">
                <i class="fa-regular fa-calendar-xmark"></i>
                <div class="empty-title">No Cancelled Appointments</div>
                <div>There are no cancelled appointments to display.</div>
            </asp:Panel>

            <asp:Repeater ID="rptAppointments" runat="server" OnItemCommand="rptAppointments_ItemCommand">
                <HeaderTemplate>
                    <div class="cards-grid">
                </HeaderTemplate>
                <ItemTemplate>
                    <div class="card cancelled">
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
                                <span class="chip status cancelled"><%# FormatStatus(Eval("Status")) %></span>
                            </div>
                        </div>

                        <div class="card-footer">
                            <div class="footer-row" style="display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;">
                                <div class="chips-row" style="display:flex;gap:8px;align-items:center;flex:1;min-width:0;">
                                    <span class="chip total"><i class="fa-solid fa-sack-dollar"></i> Total: Rs. <%# Eval("Total_amount", "{0:N2}") %></span>
                                    <span class="chip advance"><i class="fa-regular fa-hand-holding-dollar"></i> Advance: Rs. <%# Eval("Advance_amount", "{0:N2}") %></span>
                                    <span class="chip balance"><i class="fa-solid fa-scale-balanced"></i> Amount Due: Rs. <%# Eval("Balance_amount", "{0:N2}") %></span>
                                </div>

                                <div class="delete-wrapper" style="flex:0 0 auto;">
                                    <asp:Button ID="btnDetails" runat="server" Text="Details" CommandName="Details" CommandArgument='<%# Eval("AppID") %>' CssClass="btn-pay btn-details-cancelled" />
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
