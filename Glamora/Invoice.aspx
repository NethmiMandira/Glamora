<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Invoice.aspx.cs" Inherits="Glamora.Invoice" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Import Namespace="System.Web" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Invoice</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        /* --- Color Palette & Variables (Indigo & Slate Theme) --- */
        :root {
            /* Sidebar Colors */
            --sidebar-bg: #1e293b; /* Dark Slate */
            --sidebar-text: #94a3b8; /* Muted Grey text */
            --sidebar-active: #334155; /* Lighter Slate for active state */
            /* Primary Brand Color */
            --primary-color: #6366f1; /* Indigo */
            --primary-hover: #4f46e5; /* Darker Indigo */
            --primary-light-bg: #e0e7ff; /* Very light blue for subtle backgrounds */
            /* Accent Colors */
            --accent-red: #ef4444; /* Modern Red (for cancel/error) */
            --accent-green: #10b981; /* Emerald Green (for save/add) */
            /* General UI */
            --bg-body: #f1f5f9; /* Very light cool grey */
            --bg-white: #ffffff;
            --text-dark: #0f172a; /* Almost Black */
            --text-muted: #64748b; /* Slate Grey */
            --border-color: #e2e8f0; /* Light border */

            --shadow-sm: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --radius: 8px;
            --radius-lg: 12px;
            --gap: 25px; /* Standardized gap for equal spacing */
        }

        /* --- Base & Layout --- */
        * {
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--bg-body);
            color: var(--text-dark);
        }

        .dashboard-wrapper {
            display: flex;
            min-height: 100vh;
        }

        /* --- Sidebar --- */
        .sidebar {
            width: 260px;
            background-color: var(--sidebar-bg);
            color: var(--sidebar-text);
            padding: 0;
            box-shadow: 4px 0 10px rgba(0,0,0,0.05);
            position: fixed;
            top: 0;
            left: 0;
            height: 100vh;
            overflow-y: auto;
            z-index: 1000;
            display: flex;
            flex-direction: column;
        }

            .sidebar h2 {
                text-align: left;
                margin: 0;
                padding: 25px;
                font-size: 1.5rem;
                font-weight: 800;
                color: white;
                letter-spacing: -0.5px;
                border-bottom: 1px solid rgba(255,255,255,0.05);
                background: rgba(0,0,0,0.1);
            }

        .nav-list {
            list-style: none;
            padding: 20px 15px;
            margin: 0;
            flex-grow: 1;
        }

            .nav-list li {
                margin-bottom: 5px;
            }

                .nav-list li a, .nav-list li .asp-link-button {
                    display: flex;
                    align-items: center;
                    padding: 12px 15px;
                    text-decoration: none;
                    color: var(--sidebar-text);
                    font-size: 0.9rem;
                    font-weight: 500;
                    border-radius: var(--radius);
                    transition: all 0.2s ease;
                    cursor: pointer;
                    border: none;
                    background: none;
                    width: 100%;
                    text-align: left;
                    font-family: 'Inter', sans-serif;
                }

                    .nav-list li a i, .nav-item-icon {
                        margin-right: 12px;
                        width: 20px;
                        text-align: center;
                        font-size: 1.1rem;
                    }

                    .nav-list li a[href="Invoice.aspx"]::before,
                    .nav-list li.active a::before {
                        content: none !important;
                    }

                    .nav-list li a:hover, .nav-list li .asp-link-button:hover {
                        color: white;
                        background-color: rgba(255,255,255,0.05);
                    }

                .nav-list li.active a {
                    background-color: var(--primary-color);
                    color: white;
                    box-shadow: 0 4px 12px rgba(99, 102,241, 0.3); /* Glow effect */
                }

                .nav-list li.logout {
                    margin-top: auto;
                    border-top: 1px solid rgba(255,255,255,0.05);
                    padding-top: 20px;
                }

                    .nav-list li.logout .asp-link-button:hover {
                        color: var(--accent-red);
                        background: rgba(239, 68, 68, 0.1);
                    }

            /* Submenu styles */
            .nav-list .has-submenu .submenu {
                display: none;
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .nav-list .has-submenu.expanded .submenu {
                display: block;
            }

            .nav-list .submenu li {
                margin-bottom: 0;
                margin-top: 15px;
            }

                .nav-list .submenu li a {
                    padding: 10px 15px 10px 35px;
                    font-size: 0.85rem;
                    color: white;
                }

                    .nav-list .submenu li a:hover {
                        color: white;
                        background-color: rgba(255,255,255,0.05);
                    }

        .submenu-icon {
            margin-left: auto;
            transition: transform 0.2s;
            font-size: 0.8rem;
        }

        .has-submenu.expanded .submenu-icon {
            transform: rotate(180deg);
        }

        /* --- Content Area --- */
        .content-area {
            flex-grow: 1;
            padding: 40px;
            margin-left: 260px;
            background-color: var(--bg-body);
        }

        .content-header {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 35px;
            letter-spacing: -0.5px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--border-color);
        }

        /* --- Form Container (Reduced Width) --- */
        .form-container {
            background: var(--bg-white);
            padding: 40px;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
            /* Reduced Width and Centering */
            max-width: 950px;
        }

        .form-section-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--primary-color);
            margin-bottom: 25px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-color);
        }

        .form-row {
            display: flex;
            gap: var(--gap);
            margin-bottom: var(--gap);
        }

        .mt-4 {
            margin-top: 30px !important;
        }

        .form-group {
            flex: 1;
            display: flex;
            flex-direction: column; /* Changed to column default for better responsiveness */
            justify-content: flex-start;
        }

            .form-group.full-width {
                flex: 1 1 100%;
            }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                font-weight: 600;
                color: var(--text-muted);
                font-size: 0.85rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

        .form-group-btn {
            display: flex;
            gap: 300px;
            margin: 20px;
            flex-wrap: wrap;
        }

        .required::after {
            content: " *";
            color: var(--accent-red);
        }

        input[type="text"], input[type="date"], input[type="number"], select, .time-input, .form-control {
            padding: 10px 14px;
            height: 42px; /* Fixed height for consistency */
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 0.95em;
            transition: all 0.2s;
            background: #f8fafc; /* Slight bg for inputs */
            box-sizing: border-box;
            width: 100%;
            color: var(--text-dark);
        }

            input[type="text"]:focus, input[type="date"]:focus, input[type="number"]:focus, select:focus, .form-control:focus {
                outline: none;
                border-color: var(--primary-color);
                box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15); /* Softer focus ring */
                background: #fff;
            }

        .readonly-field {
            background-color: #f1f5f9;
            border-color: #cbd5e1;
            color: var(--text-muted);
            cursor: default;
        }

        /* Input group with button */
        .input-group-append {
            display: flex;
            align-items: center;
        }

            .input-group-append .form-control {
                border-top-right-radius: 0;
                border-bottom-right-radius: 0;
                border-right: 0;
            }

            .input-group-append .btn-icon {
                border-top-left-radius: 0;
                border-bottom-left-radius: 0;
                height: 42px;
                padding: 0 15px;
                background: #fff;
                border: 1px solid var(--border-color);
                color: var(--primary-color);
            }

                .input-group-append .btn-icon:hover {
                    background: var(--bg-body);
                }

        /* --- Buttons --- */
        .btn {
            padding: 0 20px;
            height: 42px;
            border: none;
            border-radius: 6px;
            font-size: 0.95em;
            font-weight: 600;
            cursor: pointer;
            transition: all .2s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .btn-generate {
            background-color: var(--primary-color);
            color: white;
            padding: 0 40px;
            height: 50px; /* Slightly larger */
            font-size: 1.1rem;
            box-shadow: 0 4px 10px rgba(99, 102, 241, 0.4);
            width: 100%; /* Full width on mobile, max width handled by container */
            max-width: 300px;
        }

            .btn-generate:hover {
                background-color: var(--primary-hover);
                transform: translateY(-1px);
                box-shadow: 0 6px 15px rgba(99, 102, 241, 0.5);
            }

        .btn-remove {
            background-color: rgba(239, 68, 68, 0.1);
            color: var(--accent-red);
            padding-top: 7px;
            padding-bottom: 7px;
            height: 50px;
            font-size: 1.1rem;
            box-shadow: 0 4px 10px rgba(99, 102, 241, 0.4);
            width: 100%;
            max-width: 200px;
        }

            .btn-remove:hover {
                background-color: var(--accent-red);
                color: white;
            }

        .btn-remove-action {
            background-color: rgba(239, 68, 68, 0.1);
            color: var(--accent-red);
            height: 30px;
            font-size: 0.8rem;
            box-shadow: 0 4px 10px rgba(99, 102, 241, 0.4);
            width: 100%;
            max-width: 100px;
        }

            .btn-remove-action:hover {
                background-color: var(--accent-red);
                color: white;
            }

        .btn-add-discount {
            background-color: var(--accent-green);
            color: white;
            padding: 5px 12px;
            height: 32px;
            font-size: 0.8rem;
            margin-left: 5px;
        }

            .btn-add-discount:hover {
                background-color: #059669;
            }

            .btn-add-discount:disabled {
                background-color: #94a3b8;
                cursor: not-allowed;
                opacity: 0.7;
            }

        .btn-action {
            background-color: var(--primary-color);
            color: white;
        }

            .btn-action:hover {
                background-color: var(--primary-hover);
            }

        .btn-apply-discount-total {
            background-color: var(--accent-green);
            color: white;
            padding: 0 20px;
            font-size: 0.9rem;
            border-top-left-radius: 0;
            border-bottom-left-radius: 0;
        }

            .btn-apply-discount-total:hover {
                background-color: #059669;
            }

            .btn-apply-discount-total:disabled {
                background-color: #94a3b8;
                cursor: not-allowed;
                opacity: 0.7;
            }

        /* --- Card Lite Section (Reusable) --- */
        .card-lite {
            background: #fff;
            padding: 25px;
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
            margin-top: 25px;
            position: relative;
        }

            /* Optional: Left accent styling */
            .card-lite::before {
                content: '';
                position: absolute;
                left: 0;
                top: 20px;
                bottom: 20px;
                width: 3px;
                background: var(--primary-color);
                border-top-right-radius: 3px;
                border-bottom-right-radius: 3px;
            }

        /* --- Tables --- */
        .services-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin-bottom: 20px;
            border-radius: var(--radius);
            overflow: hidden;
            border: 1px solid var(--border-color);
        }

            .services-table th {
                background-color: #f8fafc;
                color: var(--text-dark);
                padding: 15px;
                text-align: left;
                font-weight: 700;
                font-size: 0.85rem;
                text-transform: uppercase;
                border-bottom: 2px solid var(--border-color);
            }

            .services-table td {
                padding: 15px;
                border-bottom: 1px solid var(--border-color);
                vertical-align: middle;
            }

            .services-table tr:last-child td {
                border-bottom: none;
            }

            .services-table tr:hover {
                background-color: #f8fafc;
            }

        .service-name {
            font-weight: 600;
            color: var(--text-dark);
        }

        .service-price {
            font-weight: 500;
            font-family: monospace;
            font-size: 1.05rem;
        }

        /* --- Total Summary Card --- */
        .total-summary-card {
            background: linear-gradient(135deg, #1e293b, #0f172a);
            color: white;
            padding: 20px 25px;
            border-radius: var(--radius-lg);
            margin-top: 25px;
            text-align: right;
            box-shadow: var(--shadow);
            border: 1px solid rgba(255,255,255,0.1);
            position: relative;
            overflow: hidden;
        }

            .total-summary-card::after {
                content: '';
                position: absolute;
                top: -50%;
                right: -10%;
                width: 200px;
                height: 200px;
                background: rgba(99, 102, 241, 0.1);
                border-radius: 50%;
                filter: blur(40px);
                z-index: 0;
            }

        .total-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
            z-index: 1;
            margin-bottom: 12px; /* Increased spacing */
        }

        .amount-value {
            font-size: 1.8rem;
            font-weight: 800;
            color: var(--accent-green);
            letter-spacing: -0.5px;
        }

        .amount-label {
            font-size: 0.95rem;
            color: #ccc;
            margin-right: 15px;
            white-space: nowrap;
        }

        /* Adjusted Payment rows for consistency */
        .payment-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
            position: relative;
            z-index: 1;
        }

        .payment-label {
            font-size: 0.9rem;
            color: #cbd5e1;
            margin-right: 15px;
            flex-shrink: 0;
        }

        .payment-input-container {
            flex-grow: 1;
            max-width: 250px; /* Constrain width of inputs inside summary card - increased for uniformity */
            text-align: right;
        }

        /* Override generic input styles for summary card context */
        .total-summary-card .form-control {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            text-align: right;
            height: 36px;
            padding: 5px 10px;
        }

            .total-summary-card .form-control:focus {
                background: rgba(255, 255, 255, 0.15);
                border-color: var(--accent-green);
            }

        .total-summary-card select.form-control {
            background-color: transparent;
            color: #fff;
        }

            .total-summary-card select.form-control option {
                background-color: #1e293b; /* dark slate */
                color: #fff;
            }

        .total-summary-card .btn-apply-discount-total {
            height: 36px;
            line-height: 36px;
            padding: 0 15px;
        }

        /* Summary value textbox styling: consistent width and visible on dark background */
        .summary-value {
            display: inline-block;
            width: 220px; /* unified width for summary inputs */
            min-width: 180px;
            text-align: right;
            background: transparent;
            border: 1px solid rgba(0,0,0,0.08);
            color: inherit; /* use surrounding context color */
            padding: 6px 8px;
            border-radius: 6px;
            font-weight: 700;
            box-sizing: border-box;
        }

        /* On the dark summary card make values visible with white color and subtle border */
        .total-summary-card .summary-value {
            color: #fff;
            border: 1px solid rgba(255,255,255,0.12);
            background: rgba(255,255,255,0.03);
        }

        /* Ensure all form controls inside the summary card share the same width */
        .total-summary-card .form-control,
        .total-summary-card select.form-control,
        .total-summary-card .summary-value {
            width: 250px;
            max-width: 100%;
            box-sizing: border-box;
        }


        /* --- Discount & Payment Sections --- */
        .discount-input-group {
            display: flex;
            align-items: center;
        }

            .discount-input-group .form-control {
                flex: 1;
                border-top-right-radius: 0;
                border-bottom-right-radius: 0;
                border-right: 0;
            }

        .net-value {
            background: #f1f5f9;
            padding: 10px 15px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 1.1em;
            color: var(--primary-color);
            font-weight: 700;
            height: 42px;
            display: flex;
            align-items: center;
        }

        .payment-input-group {
            display: flex;
        }

            .payment-input-group .form-control {
                border-top-right-radius: 0;
                border-bottom-right-radius: 0;
            }

        /* --- Responsive --- */
        @media (max-width: 1024px) {
            .form-row {
                flex-direction: column;
                gap: 15px;
            }

            .sidebar {
                width: 70px;
            }

                .sidebar h2 {
                    display: none;
                }

            .nav-list li a span, .nav-list li .asp-link-button span {
                display: none;
            }

            .nav-list li a, .nav-list li .asp-link-button {
                justify-content: center;
                padding: 15px 0;
            }

                .nav-list li a i {
                    margin: 0;
                    font-size: 1.25rem;
                }

            .content-area {
                margin-left: 70px;
                padding: 25px;
            }

            .form-container {
                max-width: 100%;
                margin: 0;
            }

            .services-table {
                font-size: 0.9rem;
            }
        }

        @media (max-width: 768px) {
            .dashboard-wrapper {
                flex-direction: column;
            }

            .sidebar {
                position: relative;
                width: 100%;
                height: auto;
                flex-direction: row;
                overflow-x: auto;
                padding: 0;
                background: var(--sidebar-bg);
            }

            .nav-list {
                display: flex;
                padding: 10px;
            }

                .nav-list li {
                    margin: 0 5px;
                }

            .content-area {
                margin-left: 0;
                padding: 20px;
            }

            .services-table {
                display: block;
                overflow-x: auto;
            }

            .card-lite {
                padding: 15px;
            }
        }
        /* Sidebar toggle handle (shared) */
        .sidebar.collapsed {
            width: 100px;
        }
            /* hide header and collapse nav text when collapsed (match Dashboard) */
            .sidebar.collapsed h2 {
                display: none;
            }

            .sidebar.collapsed .nav-list li a span,
            .sidebar.collapsed .nav-list li .asp-link-button span {
                display: none;
            }

            .sidebar.collapsed .nav-list li a,
            .sidebar.collapsed .nav-list li .asp-link-button {
                justify-content: center;
                padding: 15px 0;
            }

        .content-area.collapsed {
            margin-left: 100px;
        }

        .sidebar-toggle {
            position: fixed;
            top: 22px;
            left: 268px;
            width: 36px;
            height: 36px;
            border-radius: 8px;
            background: var(--sidebar-bg);
            border: 1px solid rgba(0,0,0,0.06);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 6px 18px rgba(15,23,42,0.08);
            z-index: 1101;
            cursor: pointer;
            transition: left 0.18s ease, transform 0.18s ease, background 0.18s;
        }

            .sidebar-toggle i {
                color: #fff;
            }

        .sidebar.collapsed + .sidebar-toggle {
            left: 118px;
            background: var(--bg-white);
            border: 1px solid rgba(99,102,241,0.12);
        }

            .sidebar.collapsed + .sidebar-toggle i {
                color: var(--primary-color);
            }
        /* when sidebar is collapsed adjust content padding so centered layout stays correct */
        .content-area.collapsed {
            padding-left: 100px;
        }

        /* invoice meta styling */
        /* label element for invoice number */
       
        .form-group.invoice label {
    color:  var(--primary-color);
    font-weight: 700;
    display: block;
  
}

        /* the printed invoice value (asp:Label) */
        .invoice-no {
            color: var(--text-dark);
            font-weight: 700;
            display: block;
        }



        .form-group.date label {
            color:  var(--accent-green);
            font-weight: 700;
            display: block;
            
        }

        

        .invoice-date {
            color: var(--text-dark);
            font-weight: 600;
            display: block;
            text-align: right;
        }

        /* top meta row: place date to the far right */
        .form-row.invoice-meta {
            align-items: center;
            justify-content: space-between;
        }

            /* avoid flex:1 growth for meta items so spacing works */
            .form-row.invoice-meta .form-group {
                flex: 0 1 auto;
            }

                .form-row.invoice-meta .form-group.date {
                    max-width: 300px;
                    margin-left: 16px;
                }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <div class="dashboard-wrapper">
            <div class="sidebar">
                <h2>Glamora</h2>
                <ul class="nav-list">
                    <li><a href="Dashboard.aspx"><i class="fas fa-chart-line"></i><span>Dashboard</span></a></li>
                    <li><a href="ReportGenerating.aspx"><i class="fas fa-file-alt"></i><span>Reports</span></a></li>
                    <li><a href="Services.aspx"><i class="fas fa-magic"></i><span>Services</span></a></li>
                    <li><a href="AppointmentBooking.aspx"><i class="fas fa-calendar-check"></i><span>Appointment Booking</span></a></li>
                    <li><a href="AppointmentsList.aspx"><i class="fas fa-clipboard-list"></i><span>Appointment List</span></a></li>
                    <li class="active">
                        <a href="Invoice.aspx"><i class="fas fa-file-invoice"></i><span>Invoice</span></a>
                    </li>
                    <li><a href="Employees.aspx"><i class="fas fa-user-tie"></i><span>Employees</span></a></li>
                    <li><a href="Customers.aspx"><i class="fas fa-users"></i><span>Customers</span></a></li>
                    <li><a href="Users.aspx"><i class="fas fa-shield-alt"></i><span>Users</span></a></li>
                    <li><a href="Settings.aspx"><i class="fas fa-sliders-h"></i><span>Settings</span></a></li>
                    <li class="logout">
                        <asp:LinkButton ID="lnkLogout" runat="server" OnClick="lnkLogout_Click" CssClass="asp-link-button">
                 <i class="fas fa-sign-out-alt"></i> <span>Log Out</span>
                        </asp:LinkButton>
                    </li>
                </ul>
            </div>

            <button id="btnToggleSidebar" type="button" class="sidebar-toggle" aria-expanded="true" title="Toggle sidebar">
                <i class="fas fa-angle-left" aria-hidden="true"></i>
            </button>

            <div class="content-area">
                <h1 class="content-header">Invoice Generation</h1>

                <div class="form-container">
                    <div class="form-row invoice-meta">
                        <div class="form-group invoice">
                            <label class="label-invoice-no">Invoice No</label>
                            <asp:Label ID="txtInvoiceNo" runat="server" CssClass="invoice-no" />
                        </div>

                        <div class="form-group date">
                            <label class="label-invoice-date">Date</label>
                            <asp:Label ID="txtInvoiceDate" runat="server" CssClass="invoice-date" />
                        </div>
                    </div>

                    <!-- New update panel around appointment-dependent fields -->
                    <asp:UpdatePanel ID="upAppointment" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="form-row">
                                <div class="form-group full-width">
                                    <label>Appointment ID</label>
                                    <asp:DropDownList ID="ddlAppID" runat="server"
                                        CssClass="form-control"
                                        AutoPostBack="true"
                                        CausesValidation="false"
                                        OnSelectedIndexChanged="ddlAppID_SelectedIndexChanged">
                                        <asp:ListItem Value="">-- Select Appointment ID --</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="form-row mt-4">
                                <div class="form-group">
                                    <label class="required">Customer</label>
                                    <div class="input-group-append">
                                        <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="form-control"
                                            AutoPostBack="true"
                                            OnSelectedIndexChanged="ddlCustomer_SelectedIndexChanged"
                                            Style="border-radius: 6px 0 0 6px;">
                                            <asp:ListItem Value="">-- Select Customer --</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:Button ID="btnAddCustomer" runat="server" Text="+"
                                            CssClass="btn btn-icon"
                                            OnClick="btnAddCustomer_Click" Style="border-radius: 0 6px 6px 0;" />
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvCustomer" runat="server"
                                        ControlToValidate="ddlCustomer"
                                        InitialValue=""
                                        ErrorMessage="Customer is required"
                                        CssClass="validation-error"
                                        Display="Dynamic" />
                                </div>
                                <div class="form-group">
                                    <label>Appointment Date</label>
                                    <asp:TextBox ID="txtAppDate" runat="server" CssClass="form-control readonly-field summary-value" ReadOnly="true" />
                                </div>
                            </div>

                            <asp:HiddenField ID="hfCusID" runat="server" />
                            </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="ddlAppID" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>

                    <asp:UpdatePanel ID="upServices" runat="server" class="mt-4" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="form-row">
                                <div class="form-group full-width">
                                    <div class="card-lite">
                                        <h3 class="form-section-title">Service Details</h3>
                                        <table class="services-table">
                                            <thead>
                                                <tr>
                                                    <th style="width: 20%;">Service Name</th>
                                                    <th style="width: 18%;">Employee</th>
                                                    <th style="width: 12%;">Price</th>
                                                    <th style="width: 12%;">Discount (%)</th>
                                                    <th style="width: 12%;">Discount Amt</th>
                                                    <th style="width: 14%;">Total</th>
                                                    <th style="width: 12%;">Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <asp:Repeater ID="rptServices" runat="server" OnItemCommand="rptServices_ItemCommand" OnItemDataBound="rptServices_ItemDataBound">
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td class="service-name">
                                                                <asp:HiddenField ID="hfServiceID" runat="server" Value='<%# Eval("Service_ID") %>' />
                                                                <%# Eval("Service_Name") %>
                                                            </td>
                                                            <td style="font-weight:600; color: var(--text-dark); font-size:0.88rem;"><%# Eval("EmployeeName") %></td>
                                                            <td class="service-price">Rs. <%# Eval("Price", "{0:N2}") %></td>
                                                            <td>
                                                                <div style="display: flex; align-items: center;">
                                                                    <asp:TextBox ID="txtDiscount" runat="server" Text='<%# Eval("Discount") %>' TextMode="Number" CssClass="form-control" Placeholder="0" Min="0" Style="width: 70px; padding: 5px;" oninput="enableDiscountBtn(this)" />
                                                                    <asp:Button ID="btnApplyDiscount" runat="server" Text="Apply" CommandName="ApplyDiscount" CommandArgument='<%# Eval("Service_ID") %>' CssClass="btn btn-add-discount" />
                                                                </div>
                                                            </td>
                                                            <td class="service-price" style="color: var(--accent-red); font-size: 0.9rem;"><%# Eval("DisplayDiscountAmount") %></td>
                                                            <td class="service-price">
                                                                <span style="margin-right: 4px;">Rs.</span>
                                                                <asp:TextBox ID="txtTotal" runat="server" Text='<%# Eval("DiscountedPrice", "{0:0.00}") %>' TextMode="Number" CssClass="form-control" Placeholder="0" Min="0" Step="0.01" Style="width: 85px; padding: 5px;" />
                                                            </td>
                                                            <td>
                                                                <asp:LinkButton ID="lnkRemove" runat="server" Text="Remove" CommandName="Remove" CommandArgument='<%# Eval("Service_ID") %>' CssClass="btn btn-remove-action" />
                                                            </td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </tbody>
                                        </table>

                                        <div class="form-row" style="align-items: flex-end;">
                                            <div class="form-group">
                                                <label>Add Additional Service</label>
                                                <asp:DropDownList ID="ddlAddService" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlAddService_SelectedIndexChanged" />
                                            </div>
                                            <div class="form-group">
                                                <label>Assign Employee</label>
                                                <asp:DropDownList ID="ddlAddServiceEmployee" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="form-group" style="flex: 0 0 auto;">
                                                <asp:Button ID="btnAddService" runat="server" Text="Add Service" CssClass="btn btn-action" OnClick="btnAddService_Click" />
                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </div>

                            <div class="total-summary-card">
                                <!-- Gross Total: label now includes Rs. -->
                                <div class="total-row">
                                    <span class="amount-label">Gross Total (Rs.)</span>
                                    <span style="font-size: 1.1rem; font-weight: 600;">
                                        <asp:TextBox ID="txtTotalAmount" runat="server" CssClass="form-control readonly-field summary-value" ReadOnly="true" Text="0.00" />
                                    </span>
                                </div>

                                <!-- Total Discount: label includes "- Rs." -->
                                <div class="total-row" style="color: #cbd5e1;">
                                    <span class="amount-label">Total Discount (- Rs.)</span>
                                    <span>
                                        <asp:TextBox ID="txtTotalDiscount" runat="server" CssClass="form-control readonly-field summary-value" ReadOnly="true" Text="0.00" />
                                    </span>
                                </div>

                                <!-- Net Amount: label includes Rs. -->
                                <div class="total-row" style="color: #fff; font-weight: 600; margin-top: 5px;">
                                    <span class="amount-label" style="color: #fff;">Net Amount (Rs.)</span>
                                    <span>
                                        <asp:TextBox ID="txtNetAmount" runat="server" CssClass="form-control readonly-field summary-value" ReadOnly="true" Text="0.00" />
                                    </span>
                                </div>

                                <!-- Payment / Settlement Section (Style Integrated) -->
                                <div style="margin: 15px 0; border-top: 1px dotted rgba(255,255,255,0.2);"></div>

                                <div class="payment-row">
                                    <span class="payment-label">Additional Discount (%)</span>
                                    <div class="payment-input-container">
                                        <div class="discount-input-group">
                                            <asp:TextBox ID="txtDiscountTotal" runat="server" CssClass="form-control summary-value" Placeholder="0" TextMode="Number" Min="0" oninput="enableDiscountBtn(this)" />
                                            <asp:Button ID="btnApplyDiscountTotal" runat="server" Text="GO" CssClass="btn btn-apply-discount-total" OnClick="btnApplyDiscountTotal_Click" />
                                        </div>
                                    </div>
                                </div>

                                <div class="payment-row">
                                    <span class="payment-label">Advance Payment (- Rs.)</span>
                                    <div class="payment-input-container">

                                        <asp:TextBox ID="txtAdvancePayment" runat="server" ReadOnly="true" CssClass="form-control readonly-field summary-value" Text="0.00" />

                                    </div>
                                </div>

                                <div style="margin: 10px 0; border-top: 1px solid rgba(255,255,255,0.1);"></div>
                                <div class="total-row">
                                    <span class="amount-label" style="color: white; font-weight: 600;">NET PAYABLE (Rs.)</span>

                                    <asp:TextBox ID="txtNetValue" runat="server" CssClass="form-control readonly-field summary-value" ReadOnly="true" Text="0.00" />

                                </div>
                                <div style="margin: 10px 0; border-top: 1px solid rgba(255,255,255,0.1);"></div>

                                <div class="payment-row">
                                    <span class="payment-label">Payment Method</span>
                                    <div class="payment-input-container" style="background: none; border: none; color: #fff;">
                                        <asp:DropDownList ID="ddlPaymentMethod" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="">-- Select --</asp:ListItem>
                                            <asp:ListItem Value="Cash">Cash</asp:ListItem>
                                            <asp:ListItem Value="Card">Card</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>

                                <div class="payment-row">
                                    <span class="payment-label">Paid Amount (Rs.)</span>
                                    <div class="payment-input-container">
                                        <div class="payment-input-group">

                                            <asp:TextBox ID="txtAmountGiven" runat="server" CssClass="form-control summary-value" TextMode="Number" Min="0" placeholder="0.00" />
                                            <asp:Button ID="btnGetBalance" runat="server" Text="Bal" CssClass="btn btn-apply-discount-total" OnClick="btnGetBalance_Click" ToolTip="Calculate Balance" />
                                        </div>
                                    </div>
                                </div>

                                <div class="payment-row">
                                    <span class="payment-label">Balance (Rs.)</span>
                                    <div class="payment-input-container">

                                        <asp:TextBox ID="txtBalance" runat="server" CssClass="form-control readonly-field summary-value" ReadOnly="true" Text="0.00" />

                                    </div>
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>

                    <div class="form-group-btn">
                        <asp:Button ID="btnGenerateInvoice" runat="server" Text="Generate Invoice"
                            CssClass="btn btn-generate" OnClick="btnGenerateInvoice_Click" />
                        <asp:Button ID="btnClear" runat="server" Text="Clear"
                            CssClass="btn btn-remove" OnClick="btnClear_Click"
                            Style="height: 42px;" />
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script>
        (function () {
            var sidebar = document.querySelector('.sidebar');
            var content = document.querySelector('.content-area');
            var btn = document.getElementById('btnToggleSidebar');
            if (!btn || !sidebar || !content) return;

            function updateTogglePosition() {
                var rect = sidebar.getBoundingClientRect();
                btn.style.left = (rect.right + 8) + 'px';
            }

            function updateIcon() {
                var icon = btn.querySelector('i');
                if (!icon) return;
                var collapsed = sidebar.classList.contains('collapsed');
                icon.classList.remove('fa-angle-left', 'fa-angle-right');
                icon.classList.add(collapsed ? 'fa-angle-right' : 'fa-angle-left');
                btn.setAttribute('aria-expanded', (!collapsed).toString());
            }

            updateTogglePosition();
            updateIcon();

            btn.addEventListener('click', function () {
                sidebar.classList.toggle('collapsed');
                content.classList.toggle('collapsed');
                updateIcon();
                setTimeout(updateTogglePosition, 180);
            });

            window.addEventListener('resize', updateTogglePosition);
            window.addEventListener('scroll', updateTogglePosition);
        })();
    </script>
</body>
</html>

<script>
    function toggleSubmenu(element) {
        var li = element.closest('li');
        var submenu = li.querySelector('.submenu');
        if (submenu.style.display === 'none' || submenu.style.display === '') {
            submenu.style.display = 'block';
            li.classList.add('expanded');
        } else {
            submenu.style.display = 'none';
            li.classList.remove('expanded');
        }
    }

    function enableDiscountBtn(txt) {
        var wrapper = txt.closest('.discount-input-group') || txt.closest('div');
        // Need to be generic to catch both repeater wrapper and main discount wrapper

        if (wrapper) {
            var btn = wrapper.querySelector('input[type=submit]');
            if (btn) {
                btn.removeAttribute('disabled');
            }
        }
    }
</script>
