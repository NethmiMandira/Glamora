<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewAppointmentDetails.aspx.cs" Inherits="Glamora.ViewAppointmentDetails" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Appointment Details</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --primary-color: #6366f1;
            --primary-hover: #4f46e5;
            --primary-light: #eef2ff;
            --accent: #a855f7;
            --bg-body: #f8fafc;
            --bg-white: #ffffff;
            --text-dark: #1e293b;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
            --shadow: 0 14px 40px -18px rgba(99, 102, 241, 0.45), 0 10px 30px -22px rgba(0, 0, 0, 0.2);
            --radius-lg: 18px;
            --radius-md: 12px;
        }

        * { box-sizing: border-box; }
        body { 
            font-family: 'Inter', sans-serif; 
            margin: 0; 
            padding: 0; 
            background-color: var(--bg-body); 
            color: var(--text-dark);
            -webkit-font-smoothing: antialiased;
        }
        
        .dashboard-wrapper { 
            display: flex; 
            justify-content: center; 
            align-items: flex-start;
            min-height: 100vh; 
            padding: 70px 20px;
            background: radial-gradient(circle at 15% 20%, rgba(99, 102, 241, 0.08), transparent 25%),
                        radial-gradient(circle at 80% 10%, rgba(168, 85, 247, 0.08), transparent 22%),
                        linear-gradient(145deg, #f8fafc 0%, #eef2ff 100%);
        }

        .content-area { 
            width: 100%;
            max-width: 820px;
            animation: fadeIn 0.5s ease-out;
            position: relative;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .back-link { 
            text-decoration: none; 
            color: var(--primary-color); 
            font-weight: 600; 
            display: inline-flex; 
            align-items: center; 
            gap: 10px; 
            margin-bottom: 28px; 
            padding: 10px 14px;
            border-radius: 999px;
            background: rgba(99, 102, 241, 0.1);
            transition: all 0.2s;
            font-size: 0.94rem;
        }
        .back-link i { font-size: 0.8rem; }
        .back-link:hover { color: var(--primary-hover); transform: translateX(-4px); box-shadow: 0 6px 16px -12px var(--primary-hover); }
        
        .details-card { 
            background: linear-gradient(135deg, #ffffff 0%, #f9fbff 100%); 
            border-radius: var(--radius-lg); 
            box-shadow: var(--shadow); 
            border: 1px solid rgba(99, 102, 241, 0.08); 
            overflow: hidden; 
            position: relative;
            backdrop-filter: blur(6px);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .details-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 18px 36px -18px rgba(99, 102, 241, 0.45), 0 10px 30px -24px rgba(0, 0, 0, 0.2);
        }

        .card-header { 
            padding: 30px 40px; 
            border-bottom: 1px solid var(--border-color); 
            display: flex; 
            justify-content: space-between; 
            align-items: flex-start; 
            gap: 12px;
            background: linear-gradient(120deg, #ffffff, #f6f7ff);
            position: relative;
        }

        .card-header::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background: var(--primary-color);
        }

        .header-title-wrapper h3 { 
            margin: 0; 
            font-size: 1.6rem; 
            font-weight: 800; 
            color: var(--text-dark); 
            letter-spacing: -0.02em;
        }
        
        .header-title-wrapper p {
            margin: 5px 0 0 0;
            color: var(--text-muted);
            font-size: 0.875rem;
        }

        .details-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); 
            padding: 40px; 
            gap: 18px; 
            justify-items: stretch; 
        }

        .info-group { 
            display: flex; 
            flex-direction: column; 
            gap: 8px; 
            align-items: flex-start; 
            background: #f8fafc;
            border: 1px solid rgba(226, 232, 240, 0.8);
            border-radius: var(--radius-md);
            padding: 14px 16px;
            transition: border-color 0.15s ease, transform 0.15s ease;
        }

        .info-group:hover {
            border-color: rgba(99, 102, 241, 0.4);
            transform: translateY(-1px);
        }

        .info-group.customer { order: 1; }
        .info-group.contact { order: 2; }
        .info-group.start { order: 3; }
        .info-group.booked { order: 4; }
        .info-group.services { order: 5; }
        .info-group.total { order: 6; }
        .info-group.advance { order: 7; }

        .info-label { 
            font-size: 0.72rem; 
            font-weight: 700; 
            text-transform: uppercase; 
            color: var(--text-muted); 
            letter-spacing: 0.08em; 
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .info-label i { color: var(--primary-color); opacity: 0.7; font-size: 0.85rem; }

        .info-value { 
            font-size: 1.05rem; 
            font-weight: 700; 
            color: var(--text-dark); 
            letter-spacing: -0.01em;
        }

        .full-width { grid-column: 1 / -1; padding: 20px; background: var(--primary-light); border-radius: var(--radius-md); width: 100%; }
        .full-width .info-value { color: var(--primary-color); }

        .services-list {
            white-space: normal;
            line-height: 1.5;
            display: block;
        }

        .emp-service-group {
            margin-bottom: 12px;
        }
        .emp-service-group:last-child {
            margin-bottom: 0;
        }
        .emp-service-name {
            font-weight: 700;
            color: var(--primary-hover);
            font-size: 0.95rem;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .emp-service-name i {
            font-size: 0.85rem;
            opacity: 0.8;
        }
        .emp-service-list {
            list-style: none;
            margin: 6px 0 0 0;
            padding-left: 24px;
        }
        .emp-service-list li {
            position: relative;
            padding: 3px 0;
            font-size: 0.95rem;
            font-weight: 500;
            color: var(--text-dark);
        }
        .emp-service-list li::before {
            content: '\2022';
            color: var(--primary-color);
            font-weight: 700;
            position: absolute;
            left: -16px;
        }
        .svc-price {
            color: var(--text-muted);
            font-weight: 500;
            font-size: 0.88rem;
        }

        .status-badge { 
            padding: 9px 16px; 
            border-radius: 999px; 
            font-size: 0.78rem; 
            font-weight: 800; 
            text-transform: uppercase; 
            letter-spacing: 0.04em;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 6px 14px -10px rgba(0,0,0,0.25);
        }

        .status-badge:before {
            content: '';
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: currentColor;
            opacity: 0.65;
        }
        
        /* Status badges aligned with Appointment List */
        .status-booked, .status-pending { background: #e0e7ff; color: #4f46e5; border: 1px solid #c7d2fe; }
        .status-done { background: #ecfdf3; color: #065f46; border: 1px solid #bbf7d0; }
        .status-lapsed { background: #fef9c3; color: #854d0e; border: 1px solid #eab308; }
        .status-cancelled { background: #fee2e2; color: #991b1b; border: 1px solid #ef4444; }
        .status-default { background: #e5e7eb; color: #374151; border: 1px solid #d1d5db; }

        /* Card action styles adapted from AppointmentBooking.aspx */

        .card-actions {
            display: flex;
            gap: 8px;
            padding: 12px 20px;
            background: #fafbfc;
            border-top: 1px solid var(--border-color);
            justify-content: space-between;
            align-items: center;
        }

        .card-actions-left,
        .card-actions-right {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .card-actions .action-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.2s ease;
            border: 1px solid transparent;
            color: inherit;
            background: transparent;
        }

        .card-actions .action-link:hover { transform: translateY(-1px); }

        .card-actions .action-link i { font-size: 0.92rem; }

        .card-actions .action-link[title="Generate Invoice"] {
            background: #ecfdf5;
            border-color: #a7f3d0;
            color: #065f46;
        }

        .card-actions .action-link[title="Generate Invoice"]:hover { background: #d1fae5; }

        .card-actions .action-link[title="Edit Appointment"] {
            background: var(--primary-light-bg);
            border-color: #c7d2fe;
            color: var(--primary-hover);
        }

        .card-actions .action-link.action-cancel {
            background: #fff7ed;
            border-color: #fed7aa;
            color: #c2410c;
        }

        .card-actions .action-link.action-delete {
            background: #fef2f2;
            border-color: #fecaca;
            color: #b91c1c;
        }

        /* details card uses default .details-card styles; status variants removed */

        .price-tag {
            font-size: 1.5rem !important;
            font-weight: 800 !important;
            color: var(--primary-color) !important;
            background: linear-gradient(120deg, var(--primary-color), var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        @media (max-width: 640px) {
            .details-grid { grid-template-columns: 1fr; padding: 25px; }
            .full-width { grid-column: span 1; }
            .card-header { flex-direction: column; align-items: flex-start; gap: 15px; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-wrapper">
            <div class="content-area">
                <a href="AppointmentsList.aspx" class="back-link">
                    <i class="fas fa-chevron-left"></i> Back to Appointments
                </a>
                
                <div class="details-card">
                    <div class="card-header">
                        <div class="header-title-wrapper">
                            <h3>Appointment - <asp:Label ID="lblAppID" runat="server" /></h3>
                            <p>Overview of booking details and service summary</p>
                        </div>
                        <asp:Label ID="lblStatus" runat="server" CssClass="status-badge" />
                    </div>
                    
                    <div class="details-grid">
                        <div class="info-group customer">
                            <span class="info-label"><i class="fas fa-user"></i> Customer Name</span>
                            <asp:Label ID="lblCustomer" runat="server" CssClass="info-value" />
                        </div>

                        <div class="info-group contact">
                            <span class="info-label"><i class="fas fa-phone"></i> Contact</span>
                            <asp:Label ID="lblContact" runat="server" CssClass="info-value" />
                        </div>
                        
                        <div class="info-group" style="display:none;">
                            <span class="info-label"><i class="fas fa-calendar-alt"></i> Date</span>
                            <asp:Label ID="lblAppDate" runat="server" CssClass="info-value" />
                        </div>

                        <div class="info-group start">
                            <span class="info-label"><i class="fas fa-clock"></i> Start Time</span>
                            <asp:Label ID="lblStartTime" runat="server" CssClass="info-value" />
                        </div>
                        
                        <div class="info-group booked">
                            <span class="info-label"><i class="fas fa-calendar-alt"></i> Booked On</span>
                            <asp:Label ID="lblBookingDate" runat="server" CssClass="info-value" />
                        </div>
                        
                        <div class="info-group full-width services">
                            <span class="info-label"><i class="fas fa-concierge-bell"></i> Services & Employees</span>
                            <div class="info-value services-list"><asp:Literal ID="litServices" runat="server" Mode="PassThrough" /></div>
                        </div>
                        
                        <div class="info-group total">
                            <span class="info-label"><i class="fas fa-receipt"></i> Total Amount</span>
                            <asp:Label ID="lblTotal" runat="server" CssClass="info-value price-tag" />
                        </div>
                        
                        <div class="info-group advance">
                            <span class="info-label"><i class="fas fa-wallet"></i> Advance Payment</span>
                            <asp:Label ID="lblAdvance" runat="server" CssClass="info-value" />
                        </div>
                    </div>
                    <!-- Action buttons moved to bottom of card -->
                    <div class="card-actions">
                        <div class="card-actions-left">
                            <asp:LinkButton ID="lnkEdit" runat="server" OnClick="btnEdit_Click" CssClass="action-link" ToolTip="Edit Appointment"><i class="fas fa-edit"></i>&nbsp;Edit</asp:LinkButton>
                            <asp:LinkButton ID="lnkCancel" runat="server" OnClick="btnCancel_Click" CssClass="action-link action-cancel" ToolTip="Cancel Appointment" OnClientClick="return confirm('Are you sure you want to cancel this appointment?');"><i class="fas fa-ban"></i>&nbsp;Cancel</asp:LinkButton>
                            <asp:LinkButton ID="lnkDelete" runat="server" OnClick="btnRemove_Click" CssClass="action-link action-delete" ToolTip="Delete Appointment" OnClientClick="return confirm('Remove this appointment and its services? This cannot be undone.');"><i class="fas fa-trash-alt"></i>&nbsp;Remove</asp:LinkButton>
                        </div>
                        <div class="card-actions-right">
                            <asp:LinkButton ID="lnkInvoice" runat="server" OnClick="btnInvoice_Click" CssClass="action-link" ToolTip="Generate Invoice"><i class="fas fa-file-invoice"></i>&nbsp;Invoice</asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>