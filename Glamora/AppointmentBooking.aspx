<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AppointmentBooking.aspx.cs" Inherits="Glamora.AppointmentBooking" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ Import Namespace="System.Web" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Appointment Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        /* --- Animation & Effects --- */
        /* Page-load fade-in animation removed */
        .btn {
            box-shadow: 0 2px 8px rgba(99,102,241,0.08);
            transition: box-shadow 0.2s, transform 0.2s;
        }
        .btn:hover {
            box-shadow: 0 4px 16px rgba(99,102,241,0.18);
            transform: scale(1.03);
        }
        .form-container {
            border: 1px solid var(--primary-color);
            background: linear-gradient(135deg, var(--bg-white) 80%, var(--primary-light-bg) 100%);
        }
        .form-section-title {
            letter-spacing: 1px;
            background: none;
            color: var(--primary-color);
            padding: 12px 18px;
            border-radius: 6px;
            margin-bottom: 30px;
            font-size: 1.3rem;
            box-shadow: none;
        }
        .booking-date {
            background: linear-gradient(90deg, var(--primary-color) 60%, var(--primary-hover) 100%);
            color: #fff;
            font-size: 1.1rem;
            letter-spacing: 0.5px;
            padding: 10px 18px;
            border-radius: 6px;
            font-weight: 600;
            display: inline-block;
            box-shadow: var(--shadow);
        }
        .app-meta-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            margin-bottom: 25px;
        }
        .app-meta-row .form-group {
            margin-bottom: 0;
        }
        .app-id-display {
            background: var(--primary-color);
            color: #fff;
            border: none;
        }
        .form-group label {
            font-size: 1rem;
            font-weight: 700;
            color: var(--primary-color);
        }
        .form-group input, .form-group select {
            font-size: 1.05em;
        }
        .services-section {
            background: linear-gradient(135deg, var(--primary-light-bg) 80%, #fff 100%);
            border: 2px solid var(--primary-color);
        }
        .service-item {
            border-left: 8px solid var(--primary-hover);
            box-shadow: 0 2px 8px rgba(99,102,241,0.08);
        }
        .total-cost {
            background: linear-gradient(90deg, var(--accent-green) 0%, var(--primary-color) 100%);
            color: #fff;
            font-size: 1.4rem;
            font-weight: 800;
            letter-spacing: 1px;
        }
        .action-link.action-delete {
            color: var(--accent-red);
        }
        .action-link.action-cancel {
            color: var(--accent-orange);
        }
        /* Disabled action style for expired/cancelled appointments */
        .action-link.disabled-action,
        .action-link.action-cancel.disabled-action {
            color: #b0b3b8 !important; /* Ash/grey color */
            background: none !important;
            cursor: not-allowed !important;
            pointer-events: none;
            text-decoration: none;
            opacity: 0.7;
        }
        .validation-error {
            font-size: 1em;
            font-weight: 600;
        }

        /* Status badge styles */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 14px;
            border-radius: 999px;
            font-size: 0.82em;
            font-weight: 700;
            letter-spacing: 0.5px;
            min-width: 80px;
            text-align: center;
            text-transform: uppercase;
        }
        .status-pending { color: #7c3aed; background: #ede9fe; border: 1px solid #c4b5fd; }
        .status-done { color: #065f46; background: #ecfdf5; border: 1px solid #a7f3d0; }
        .status-expired { color: #92400e; background: #fef3c7; border: 1px solid #fcd34d; }
        .status-cancelled { color: #991b1b; background: #fee2e2; border: 1px solid #fecaca; }
        /* --- Responsive Enhancements --- */
        @media (max-width: 1024px) {
            .form-section-title {
                font-size: 1.1rem;
                padding: 10px 12px;
            }
            .total-cost {
                font-size: 1.1rem;
            }
        }
        @media (max-width: 768px) {
            .form-section-title {
                font-size: 1rem;
                padding: 8px 8px;
            }
        }
        /* --- Subtle Glow for Save/Cancel --- */
        .btn-save, .btn-main-cancel {
            box-shadow: 0 0 16px 2px rgba(99,102,241,0.15);
        }
        .btn-save {
            background: linear-gradient(90deg, var(--primary-color) 0%, var(--primary-hover) 100%);
        }
        .btn-main-cancel {
            background: linear-gradient(90deg, var(--accent-red) 0%, #dc2626 100%);
        }
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
            --accent-orange: #f59e0b; /* Orange for Warning/Edit */
            /* General UI */
            --bg-body: #f1f5f9; /* Very light cool grey */
            --bg-white: #ffffff;
            --text-dark: #0f172a; /* Almost Black */
            --text-muted: #64748b; /* Slate Grey */
            --border-color: #e2e8f0; /* Light border */

            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --radius: 8px;
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

                    .nav-list li a[href="AppointmentBooking.aspx"]::before,
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
                    box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); /* Glow effect */
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

        /* --- Content Area --- */
        .content-area {
            flex-grow: 1;
            padding: 40px;
            margin-left: 260px;
            background-color: var(--bg-body);
            transition: margin-left 0.18s ease;
        }

        .content-header {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 35px;
            letter-spacing: -0.5px;
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 10px;
            max-width: 950px;
            margin-left: auto;
            margin-right: auto;
        }

        /* --- Form Container (Reduced Width) --- */
        .form-container {
            background: var(--bg-white);
            padding: 30px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
            /* Reduced Width and Centering */
            max-width: 950px;
            margin-left: auto;
            margin-right: auto;
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
            gap: 25px;
            margin-bottom: 25px;
        }

        .form-group {
            flex: 1;
            display: flex;
            flex-direction: column;
            margin-bottom: 20px;
        }

            .form-group.full-width {
                flex: 1 1 100%;
            }

            .form-group label {
                display: block;
                margin-bottom: 10px;
                font-weight: 600;
                color: var(--text-muted);
                font-size: 0.85rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

        .required::after {
            content: " *";
            color: var(--accent-red);
        }

        input[type="text"], input[type="date"], select, .time-input, .form-control {
            padding: 10px 12px;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            font-size: 1em;
            transition: all .2s;
            background: var(--bg-white);
            box-sizing: border-box;
            width: 100%;

            
        }

            input[type="text"]:focus, input[type="date"]:focus, select:focus, .form-control:focus {
                outline: none;
                border-color: var(--primary-color);
                box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
            }

        .time-container {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .time-input {
            width: 80px;
            text-align: center;
        }

        /* --- App ID & Booking Date Display --- */
        .app-id-display {
            background: var(--primary-light-bg);
            padding: 10px 15px;
            border-radius: 4px;
            border: 1px solid var(--primary-color);
            font-weight: 600;
            color: var(--primary-color);
            display: inline-block;
        }

        .booking-date {
            background: var(--primary-color);
            padding: 10px 18px;
            border-radius: 6px;
            color: white;
            font-weight: 600;
            display: inline-block;
            box-shadow: var(--shadow);
        }

        /* --- Buttons --- */
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            transition: all .2s;
            text-transform: uppercase;
        }

        .btn-add {
            background: var(--accent-green);
            color: white;
            letter-spacing: 0.5px;
        }

            .btn-add:hover {
                background: #047857;
            }

        .btn-save {
            background-color: var(--primary-color);
            color: white;
            padding: 14px 40px;
            font-size: 1.15rem;
            box-shadow: 0 4px 10px rgba(99, 102, 241, 0.4);
        }

            .btn-save:hover {
                background-color: var(--primary-hover);
                transform: translateY(-1px);
            }

        .btn-main-cancel {
            background: var(--accent-red);
            color: white;
            padding: 14px 40px;
            font-size: 1.15rem;
            box-shadow: 0 4px 10px rgba(239, 68, 68, 0.4);
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: all .2s;
            text-transform: uppercase;
        }

            .btn-main-cancel:hover {
                background: #dc2626;
                transform: translateY(-1px);
            }

        /* --- Services Section --- */
        .services-section {
            background: var(--primary-light-bg);
            padding: 20px;
            border-radius: 6px;
            border: 1px solid var(--primary-color);
        }

        .service-row {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-bottom: 20px;
        }

        .service-input {
            width: 100%;
        }

        .selected-services {
            margin-top: 15px;
            padding-top: 10px;
            border-top: 1px solid var(--border-color);
        }

        .service-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--bg-white);
            padding: 12px 15px;
            border-radius: 4px;
            margin-bottom: 8px;
            border-left: 5px solid var(--primary-color);
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .service-info {
            display: flex;
            gap: 20px;
            align-items: center;
            font-size: 0.95rem;
        }

            .service-info strong {
                color: var(--primary-hover);
            }

        .total-cost {
            background: var(--text-dark);
            color: var(--accent-green);
            padding: 15px;
            border-radius: 6px;
            margin-top: 20px;
            text-align: right;
            font-size: 1.3rem;
            font-weight: 700;
        }

        .no-services-msg {
            text-align: center;
            color: var(--text-muted);
            padding: 20px;
            font-style: italic;
            display: block;
        }

        /* Action link styles */
        .action-link {
            background: none;
            border: none;
            padding: 5px 8px;
            cursor: pointer;
            color: var(--primary-color);
            font-weight: 600;
            text-decoration: none;
            border-radius: 4px;
            transition: background-color 0.2s;
            font-size: 0.9rem;
            display: inline-block;
            margin: 0 4px;
            vertical-align: middle;
        }

        .action-link:hover {
            text-decoration: underline;
            background-color: rgba(99, 102, 241, 0.1);
        }

        .action-link.action-delete,
        .action-link.delete {
            color: var(--accent-red);
        }

        .action-link.action-delete:hover,
        .action-link.delete:hover {
            background-color: rgba(239, 68, 68, 0.1);
        }

        .action-link.action-cancel {
            color: #f59e0b;
        }

        .action-link.action-cancel:hover {
            background-color: rgba(245, 158, 11, 0.12);
        }


        .validation-error {
            color: var(--accent-red);
            font-size: .9em;
            margin-top: 4px;
            display: block;
        }

        /* --- Appointment Cards --- */
        .search-bar {
            display: flex;
            gap: 12px;
            align-items: center;
            max-width: 1200px;
            margin: 0 auto 20px auto;
            background: var(--bg-white);
            padding: 14px 20px;
            border-radius: 10px;
            border: 1px solid var(--border-color);
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        }

        .search-bar .search-type {
            /* slightly increased dropdown width so the text input is still dominant */
            flex: 0 0 130px;
            width: 130px;
            padding: 9px 12px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--text-dark);
            background: #f8fafc;
            cursor: pointer;
        }

        .search-bar .search-type:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
            outline: none;
        }

        .search-input-wrapper {
            flex: 3; /* make search input wider relative to the dropdown */
            position: relative;
            display: flex;
            align-items: center;
        }

        .search-input-wrapper .search-icon {
            position: absolute;
            left: 12px;
            color: var(--text-muted);
            font-size: 0.9rem;
            pointer-events: none;
        }

        .search-bar .search-input {
            width: 100%;
            padding: 9px 14px 9px 36px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 0.9rem;
            background: var(--bg-white);
        }

        .search-bar .search-input:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
            outline: none;
        }

        .search-bar .btn-search {
            padding: 9px 20px;
            background: var(--primary-color);
            color: #fff;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.88rem;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: background 0.2s;
            white-space: nowrap;
        }

        .search-bar .btn-search:hover {
            background: var(--primary-hover);
        }

        .search-bar .btn-clear {
            padding: 9px 16px;
            background: #f1f5f9;
            color: var(--text-muted);
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.88rem;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s;
            white-space: nowrap;
        }

        .search-bar .btn-clear:hover {
            background: #e2e8f0;
            color: var(--text-dark);
        }

        .search-date-row {
            display: none;
            flex-basis: 100%;
            gap: 12px;
            align-items: center;
        }
        .search-date-row.visible {
            display: flex;
        }
        .search-date-row label {
            font-size: 0.82rem;
            font-weight: 600;
            color: var(--text-muted);
            white-space: nowrap;
        }
        .search-date-row input[type="date"] {
            padding: 8px 10px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 0.88rem;
            width: 160px;
        }

        @media (max-width: 768px) {
            .search-bar {
                flex-wrap: wrap;
            }
            .search-bar .search-type {
                min-width: 100%;
            }
            .search-input-wrapper {
                min-width: 100%;
            }
            .search-date-row {
                flex-wrap: wrap;
            }
            .search-date-row input[type="date"] {
                width: 100%;
            }
        }

        .appointment-cards-container {
            display: flex;
            flex-direction: column;
            gap: 20px;
            margin-top: 10px;
            max-width: 950px;
            margin-left: auto;
            margin-right: auto;
        }

        .appointment-card {
            background: var(--bg-white);
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 4px 12px rgba(0,0,0,0.04);
            border: 1px solid var(--border-color);
            border-left: 5px solid var(--primary-color);
            padding: 0;
            display: flex;
            flex-direction: column;
            transition: box-shadow 0.25s ease, transform 0.25s ease;
            overflow: hidden;
        }

        .appointment-card:hover {
            box-shadow: 0 8px 30px rgba(99,102,241,0.14), 0 2px 8px rgba(0,0,0,0.06);
            transform: translateY(-3px);
        }

        /* Status-based left border color */
        .appointment-card.card-status-done { border-left-color: var(--accent-green); }
        .appointment-card.card-status-expired { border-left-color: #f59e0b; }
        .appointment-card.card-status-cancelled { border-left-color: var(--accent-red); }
        .appointment-card.card-status-pending { border-left-color: var(--primary-color); }

        .card-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 20px 12px;
            background: linear-gradient(135deg, var(--primary-light-bg) 0%, #f8fafc 100%);
            border-bottom: 1px solid var(--border-color);
        }

        .card-app-id {
            font-size: 1rem;
            font-weight: 800;
            color: var(--primary-color);
            letter-spacing: 0.5px;
            background: var(--bg-white);
            border: 1px solid var(--primary-color);
            padding: 4px 12px;
            border-radius: 6px;
        }

        .card-body-row {
            display: grid;
            /* use responsive auto-fit columns to avoid empty grid cells/whitespace */
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 14px 20px;
            padding: 18px 20px;
        }

        .card-detail {
            display: flex;
            flex-direction: column;
            gap: 4px;
            padding: 8px 12px;
            background: #f8fafc;
            border-radius: 8px;
            border: 1px solid #f1f5f9;
            transition: background 0.15s;
        }
        .card-detail:hover {
            background: var(--primary-light-bg);
        }

        /* Make services box wider: remove fixed max-width and allow it to span columns on larger screens */
        .card-detail.services-detail {
            max-width: none;
        }

        .card-detail.services-detail .card-value {
            word-break: break-word;
            overflow: auto;
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 8px;
        }

        /* On wide viewports let the services box span the full width of the card body */
        @media (min-width: 900px) {
            .card-body-row .card-detail.services-detail {
                grid-column: 1 / -1; /* span from first to last column */
            }
        }

        /* Make each emp-service-group look good inside the grid */
        .card-detail.services-detail .emp-service-group {
            margin: 0;
            padding: 8px;
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-radius: 6px;
        }

        @media (max-width: 900px) {
            .card-detail.services-detail .card-value {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 480px) {
            .card-detail.services-detail .card-value {
                grid-template-columns: 1fr;
            }
        }

        /* removed forced spanning to prevent empty whitespace in card layout */

        .card-label {
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .card-label i {
            color: var(--primary-color);
            font-size: 0.8rem;
            width: 14px;
            text-align: center;
        }

        .card-value {
            font-size: 0.92rem;
            font-weight: 600;
            color: var(--text-dark);
            word-break: break-word;
            line-height: 1.4;
        }

        .card-total {
            font-weight: 800;
            color: var(--accent-green);
            font-size: 1.1rem;
        }

        /* Services & Employees inside card */
        .card-detail .emp-service-group {
            margin-bottom: 10px;
            padding: 8px 10px;
            background: var(--bg-white);
            border-radius: 6px;
            border: 1px solid var(--border-color);
        }
        .card-detail .emp-service-group:last-child {
            margin-bottom: 0;
        }
        .emp-service-name {
            font-weight: 700;
            color: var(--primary-hover);
            font-size: 0.85rem;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding-bottom: 4px;
            border-bottom: 1px dashed var(--border-color);
            margin-bottom: 4px;
        }
        .emp-service-name i {
            font-size: 0.78rem;
            opacity: 0.8;
        }
        .emp-service-list {
            list-style: none;
            margin: 6px 0 0 0;
            padding-left: 18px;
        }
        .emp-service-list li {
            position: relative;
            padding: 3px 0;
            font-size: 0.85rem;
            color: var(--text-dark);
        }
        .emp-service-list li::before {
            content: '';
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: var(--primary-color);
            position: absolute;
            left: -14px;
            top: 9px;
        }

        /* Card Action Buttons */
        .card-actions {
            display: flex;
            gap: 4px;
            padding: 12px 20px;
            background: #fafbfc;
            border-top: 1px solid var(--border-color);
            justify-content: flex-end;
        }

        .card-actions .action-link {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.2s ease;
            border: 1px solid transparent;
        }

        .card-actions .action-link:hover {
            text-decoration: none;
            transform: translateY(-1px);
        }

        .card-actions .action-link i {
            font-size: 0.82rem;
        }

        /* Invoice button */
        .card-actions a.action-link[title="Generate Invoice"] {
            background: #ecfdf5;
            border-color: #a7f3d0;
            color: #065f46;
        }
        .card-actions a.action-link[title="Generate Invoice"]:hover {
            background: #d1fae5;
        }

        /* Edit button */
        .card-actions .action-link[title="Edit Appointment"] {
            background: var(--primary-light-bg);
            border-color: #c7d2fe;
            color: var(--primary-hover);
        }
        .card-actions .action-link[title="Edit Appointment"]:hover {
            background: #c7d2fe;
        }

        /* Cancel button */
        .card-actions .action-link.action-cancel {
            background: #fff7ed;
            border-color: #fed7aa;
            color: #c2410c;
        }
        .card-actions .action-link.action-cancel:hover {
            background: #ffedd5;
        }

        /* Delete button */
        .card-actions .action-link.action-delete {
            background: #fef2f2;
            border-color: #fecaca;
            color: #b91c1c;
        }
        .card-actions .action-link.action-delete:hover {
            background: #fee2e2;
        }

        @media (max-width: 480px) {
            .appointment-cards-container {
                gap: 16px;
            }
            .card-body-row {
                grid-template-columns: 1fr 1fr;
            }
            .card-detail:nth-child(n+5) {
                grid-column: span 2;
            }
            .card-actions {
                flex-wrap: wrap;
                justify-content: center;
            }
        }

        @media (max-width: 768px) {
            .card-body-row {
                grid-template-columns: 1fr 1fr;
            }
        }

        /* --- Responsive --- */
        @media (max-width: 1024px) {
            .form-row {
                flex-direction: column;
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
                margin-left: auto;
                margin-right: auto;
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
        }
        /* Sidebar toggle handle (shared) */
        .sidebar.collapsed { width: 100px; }
        /* hide header and collapse nav text when collapsed (match Dashboard) */
        .sidebar.collapsed h2 { display: none; }
        .sidebar.collapsed .nav-list li a span,
        .sidebar.collapsed .nav-list li .asp-link-button span { display: none; }
        .sidebar.collapsed .nav-list li a,
        .sidebar.collapsed .nav-list li .asp-link-button { justify-content: center; padding: 15px 0; }
        .content-area.collapsed { margin-left: 100px; transition: margin-left 0.18s ease; }
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
        .sidebar-toggle i { color: #fff; }
        .sidebar.collapsed + .sidebar-toggle { left: 78px; background: var(--bg-white); border: 1px solid rgba(99,102,241,0.12); }
        .sidebar.collapsed + .sidebar-toggle i { color: var(--primary-color); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="false" />
        <div class="dashboard-wrapper">
            <div class="sidebar">
                <h2>Glamora</h2>
                <ul class="nav-list">
                    <li><a href="Dashboard.aspx"><i class="fas fa-chart-line"></i><span>Dashboard</span></a></li>
                    <li><a href="ReportGenerating.aspx"><i class="fas fa-file-alt"></i> <span>Reports</span></a></li>
                    <li><a href="Services.aspx"><i class="fas fa-magic"></i><span>Services</span></a></li>
                    <li class="active"><a href="AppointmentBooking.aspx"><i class="fas fa-calendar-check"></i><span>Appointment Booking</span></a></li>
                    <li><a href="AppointmentsList.aspx"><i class="fas fa-clipboard-list"></i><span>Appointment List</span></a></li>
                    <li><a href="Invoice.aspx"><i class="fas fa-file-invoice"></i><span>Invoice</span></a></li>
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
                <h1 class="content-header">Appointment Booking</h1>
                <asp:Label ID="lblMessage" runat="server" Visible="false" />
                <div class="form-container">

                    <div class="app-meta-row">
                        <div class="form-group">
                            <label>Appointment ID</label>
                            <asp:Label ID="lblAppID" runat="server" Text="APP1" Font-Bold="true" Style="color: var(--primary-color); font-size: 1.1em;" />
                        </div>
                        <div class="form-group" style="text-align: right;">
                            <label>Booking Date</label>
                            <asp:Label ID="lblBookingDate" runat="server" Font-Bold="true" Style="color: var(--primary-color); font-size: 1.1em;" />
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label class="required">Appointment Date</label>
                            <asp:TextBox ID="txtAppDate" runat="server" TextMode="Date" AutoPostBack="true" OnTextChanged="txtAppDate_TextChanged" />
                            <asp:RequiredFieldValidator ID="rfvAppDate" runat="server"
                                ControlToValidate="txtAppDate"
                                ErrorMessage="Appointment date is required"
                                CssClass="validation-error"
                                Display="Dynamic" />
                        </div>
                        <div class="form-group">
                            <label class="required">Start Time</label>
                            <div class="time-container">
                                <asp:DropDownList ID="ddlStartHour" runat="server" CssClass="time-input" AutoPostBack="true" OnSelectedIndexChanged="ddlStartHour_SelectedIndexChanged">
                                    <asp:ListItem Value="">HH</asp:ListItem>
                                    <asp:ListItem>08</asp:ListItem>
                                    <asp:ListItem>09</asp:ListItem>
                                    <asp:ListItem>10</asp:ListItem>
                                    <asp:ListItem>11</asp:ListItem>
                                    <asp:ListItem>12</asp:ListItem>
                                    <asp:ListItem>13</asp:ListItem>
                                    <asp:ListItem>14</asp:ListItem>
                                    <asp:ListItem>15</asp:ListItem>
                                    <asp:ListItem>16</asp:ListItem>
                                    <asp:ListItem>17</asp:ListItem>
                                    <asp:ListItem>18</asp:ListItem>
                                    <asp:ListItem>19</asp:ListItem>
                                    <asp:ListItem>20</asp:ListItem>
                                </asp:DropDownList>
                                <span>:</span>
                                <asp:DropDownList ID="ddlStartMinute" runat="server" CssClass="time-input" AutoPostBack="true" OnSelectedIndexChanged="ddlStartMinute_SelectedIndexChanged">
                                    <asp:ListItem Value="">MM</asp:ListItem>
                                    <asp:ListItem>00</asp:ListItem>
                                    <asp:ListItem>15</asp:ListItem>
                                    <asp:ListItem>30</asp:ListItem>
                                    <asp:ListItem>45</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <asp:RequiredFieldValidator ID="rfvStartHour" runat="server"
                                ControlToValidate="ddlStartHour"
                                ErrorMessage="Hour required"
                                CssClass="validation-error"
                                Display="Dynamic"
                                InitialValue="" />
                            <asp:RequiredFieldValidator ID="rfvStartMinute" runat="server"
                                ControlToValidate="ddlStartMinute"
                                ErrorMessage="Minute required"
                                CssClass="validation-error"
                                Display="Dynamic"
                                InitialValue="" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="required">Customer</label>
                        <asp:TextBox ID="txtCustomer" runat="server" CssClass="form-control"
                            placeholder="Type customer name..." />
                        <asp:Literal ID="litCustomerDatalist" runat="server"></asp:Literal>
                        <asp:RequiredFieldValidator ID="rfvCustomer" runat="server"
                            ControlToValidate="txtCustomer"
                            ErrorMessage="Customer is required"
                            CssClass="validation-error"
                            Display="Dynamic" />
                    </div>
                    <div class="form-row">
                        <div class="form-group full-width">
                            <label class="required">Services (enter service ID or name)</label>
                            <div class="services-section">
                                <asp:UpdatePanel ID="upServices" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                <div class="service-row">
                                    <div class="service-input">
                                        <label style="font-size:0.8rem; margin-bottom:4px;">Service</label>
                                        <asp:DropDownList ID="ddlService" runat="server" CssClass="form-control"
                                            AutoPostBack="true" OnSelectedIndexChanged="ddlService_SelectedIndexChanged">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="service-input">
                                        <label style="font-size:0.8rem; margin-bottom:4px;">Employee</label>
                                        <asp:DropDownList ID="ddlServiceEmployee" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                    <div>
                                        <asp:Button ID="btnAddService" runat="server" Text="Add Service"
                                            CssClass="btn btn-add" style="width:25%;margin-left:73%;" OnClick="btnAddService_Click" CausesValidation="false" />
                                    </div>
                                </div>
                                        <div class="selected-services">
                                            <asp:Repeater ID="rptServices" runat="server" OnItemCommand="rptServices_ItemCommand">
                                                <ItemTemplate>
                                                    <div class="service-item fade-in">
                                                        <div class="service-info">
                                                            <strong><%# Eval("Service_Name") %></strong>
                                                            <span>Rs. <%# Eval("Price", "{0:N2}") %></span>
                                                            <span>(<%# Eval("DurationHoursMinutes") %>)</span>
                                                            <span style="color:var(--primary-hover); font-weight:600;">👤 <%# Eval("EmployeeName") %></span>
                                                        </div>
                                                        <asp:Button ID="btnCancelService" runat="server" Text="✖ Remove"
                                                            CssClass="btn btn-cancel"
                                                            CommandName="RemoveService"
                                                            CommandArgument='<%# Eval("Service_ID") + "|" + Eval("Emp_ID") %>'
                                                            CausesValidation="false" />
                                                    </div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                            <asp:Label ID="lblNoServices" runat="server"
                                                Text="No services added yet. Enter a service and click Add Service."
                                                CssClass="no-services-msg"
                                                Visible="false" />
                                        </div>
                                        <div class="total-cost">
                                            Total Cost: Rs.
                                            <asp:Label ID="lblTotalAmount" runat="server" Text="0.00" />
                                            &nbsp;&nbsp;|&nbsp;&nbsp;
                                            <i class="fas fa-hourglass-half"></i> Total Duration:
                                            <asp:Label ID="lblTotalDuration" runat="server" Text="0m" />
                                        </div>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                    </div>
                    <div class="form-row" style="margin-top: 15px;">
                        <div class="form-group">
                            <label>Advance Amount (LKR)</label>
                            <asp:TextBox ID="txtAdvanceAmount" runat="server" TextMode="Number"  CssClass="form-control" placeholder="0.00" />
                            <asp:RegularExpressionValidator ID="revAdvanceAmount" runat="server" ControlToValidate="txtAdvanceAmount" ValidationExpression="^\d{0,9}(\.\d{1,2})?$" ErrorMessage="Invalid amount" CssClass="validation-error" Display="Dynamic" />
                        </div>
                    </div>
                    <div class="form-group" style="text-align: center; margin-top: 40px;">
                        <asp:Button ID="btnSaveAppointment" runat="server" Text="Save Appointment"
                            CssClass="btn btn-save" OnClick="btnSaveAppointment_Click" />
                    </div>
                </div>
                <h2 class="content-header" style="margin-top: 40px; max-width: 950px; margin-left: auto; margin-right: auto;">Appointments List</h2>
                <asp:UpdatePanel ID="upAppointments" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                <div class="search-bar" style="max-width: 950px;">
                    <asp:DropDownList ID="ddlSearchType" runat="server" CssClass="search-type" onchange="toggleDateRange(this)">
                        <asp:ListItem Value="Customer">Customer</asp:ListItem>
                        <asp:ListItem Value="Employee">Employee</asp:ListItem>
                        <asp:ListItem Value="Status">Status</asp:ListItem>
                        <asp:ListItem Value="DateRange">Date Range</asp:ListItem>
                    </asp:DropDownList>
                    <div class="search-input-wrapper">
                        <i class="fas fa-search search-icon"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Type to search..." />
                    </div>
                    <div class="search-date-row" id="dateRangeRow">
                        <label>From</label>
                        <asp:TextBox ID="txtDateFrom" runat="server" TextMode="Date" CssClass="search-input" />
                        <label>To</label>
                        <asp:TextBox ID="txtDateTo" runat="server" TextMode="Date" CssClass="search-input" />
                    </div>
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn-search" OnClick="btnSearch_Click" CausesValidation="false" />
                    <asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="btn-clear" OnClick="btnClearSearch_Click" CausesValidation="false" />
                </div>

                <div class="appointment-cards-container">
                    <asp:Repeater ID="rptAppointments" runat="server" OnItemCommand="rptAppointments_ItemCommand">
                        <ItemTemplate>
                            <div class='appointment-card card-status-<%# Eval("DisplayStatus").ToString().Trim().ToLower() %>'>
                                <div class="card-header-row">
                                    <span class="card-app-id"><%# Eval("AppID") %></span>
                                    <%# GetStatusBadge(Eval("DisplayStatus")) %>
                                </div>
                                <div class="card-body-row">
                                    <div class="card-detail">
                                        <span class="card-label"><i class="fas fa-calendar-alt"></i> Date</span>
                                        <span class="card-value"><%# Eval("AppDate", "{0:yyyy-MM-dd}") %></span>
                                    </div>
                                    <div class="card-detail">
                                        <span class="card-label"><i class="fas fa-clock"></i> Time</span>
                                        <span class="card-value"><%# FormatStartTime(Eval("StartTime")) %> — <%# GetEndTime(Eval("StartTime"), Eval("TotalDurationMins")) %></span>
                                    </div>
                                    <div class="card-detail">
                                        <span class="card-label"><i class="fas fa-user"></i> Customer</span>
                                        <span class="card-value"><%# Eval("CustomerName") %></span>
                                    </div>
                                    <div class="card-detail">
                                        <span class="card-label"><i class="fas fa-hourglass-half"></i> Duration</span>
                                        <span class="card-value"><%# GetDurationDisplay(Eval("TotalDurationMins")) %></span>
                                    </div>
                                    <div class="card-detail">
                                        <span class="card-label"><i class="fas fa-coins"></i> Total</span>
                                        <span class="card-value card-total">Rs. <%# Eval("TotalAmount", "{0:N2}") %></span>
                                    </div>
                                    <div class="card-detail">
                                        <span class="card-label"><i class="fas fa-hand-holding-dollar"></i> Advance</span>
                                        <span class="card-value">Rs. <%# Eval("AdvanceAmount", "{0:N2}") %></span>
                                    </div>
                                    <div class="card-detail services-detail">
                                        <span class="card-label"><i class="fas fa-magic"></i> Services & Employees</span>
                                        <div class="card-value"><%# GetEmployeeServicesHtml(Eval("AppID")) %></div>
                                    </div>
                                </div>
                                <div class="card-actions">
                                    <a href='<%# "Invoice.aspx?appId=" + Eval("AppID") %>'
                                        class='action-link'
                                        style='color: var(--accent-green); <%# Eval("DisplayStatus").ToString().Trim().ToLower() == "pending" ? "" : "display:none;" %>'
                                        title="Generate Invoice"><i class="fas fa-file-invoice"></i> Invoice</a>
                                    <asp:LinkButton ID="lnkEdit" runat="server"
                                        CommandName="EditAppointment"
                                        CommandArgument='<%# Eval("AppID") %>'
                                        CssClass="action-link"
                                        ToolTip="Edit Appointment"
                                        CausesValidation="false"
                                        style='<%# (Eval("DisplayStatus").ToString().Trim().ToLower() == "done" || Eval("DisplayStatus").ToString().Trim().ToLower() == "cancelled") ? "display:none;" : "" %>'>
                                        <i class="fas fa-edit"></i> Edit</asp:LinkButton>
                                    <asp:LinkButton ID="lnkCancel" runat="server"
                                        CommandName="CancelAppointment"
                                        CommandArgument='<%# Eval("AppID") %>'
                                        CssClass="action-link action-cancel"
                                        ToolTip="Cancel Appointment"
                                        OnClientClick="return confirm('Mark this appointment as cancelled?');"
                                        CausesValidation="false"
                                        style='<%# (Eval("DisplayStatus").ToString().Trim().ToLower() == "done" || Eval("DisplayStatus").ToString().Trim().ToLower() == "cancelled") ? "display:none;" : "" %>'>
                                        <i class="fas fa-ban"></i> Cancel</asp:LinkButton>
                                    <asp:LinkButton ID="lnkDelete" runat="server"
                                        CommandName="DeleteAppointment"
                                        CommandArgument='<%# Eval("AppID") %>'
                                        CssClass="action-link action-delete"
                                        ToolTip="Delete Appointment"
                                        OnClientClick="return confirm('Are you sure you want to PERMANENTLY delete this appointment?');"
                                        CausesValidation="false"><i class="fas fa-trash-alt"></i> Delete</asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoAppointments" runat="server"
                        Text="No appointments found."
                        CssClass="no-services-msg"
                        Visible="false" />
                </div>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                        <asp:AsyncPostBackTrigger ControlID="btnClearSearch" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
        </div>
        </div>
        <script>
            (function(){
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

                // initialize
                updateTogglePosition();
                updateIcon();

                btn.addEventListener('click', function(){
                    sidebar.classList.toggle('collapsed');
                    content.classList.toggle('collapsed');
                    updateIcon();
                    setTimeout(updateTogglePosition, 180);
                });

                window.addEventListener('resize', updateTogglePosition);
                window.addEventListener('scroll', updateTogglePosition);
            })();

            function toggleDateRange(ddl) {
                var row = document.getElementById('dateRangeRow');
                var txtWrapper = ddl.parentElement.querySelector('.search-input-wrapper');
                var txtSearch = document.getElementById('<%= txtSearch.ClientID %>');
                if (ddl.value === 'DateRange') {
                    // show date inputs and hide free-text search
                    row.classList.add('visible');
                    if (txtWrapper) txtWrapper.style.display = 'none';
                    // clear any stray free-text so it doesn't affect the query
                    try { if (txtSearch) txtSearch.value = ''; } catch (e) { }
                } else {
                    row.classList.remove('visible');
                    if (txtWrapper) txtWrapper.style.display = '';
                }
            }
            // initialize on page load and after async postbacks
            (function() {
                function initSearchToggle() {
                    var ddl = document.querySelector('.search-type');
                    if (ddl) toggleDateRange(ddl);
                }
                initSearchToggle();
                // Re-run after UpdatePanel async postbacks
                if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                    try {
                        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
                            initSearchToggle();
                        });
                    } catch (e) { }
                }
            })();

            // Submit search when Enter is pressed inside the search input
            (function(){
                try {
                    var txt = document.getElementById('<%= txtSearch.ClientID %>');
                    var btn = document.getElementById('<%= btnSearch.ClientID %>');
                    if (txt && btn) {
                        txt.addEventListener('keydown', function (e) {
                            var key = e.which || e.keyCode || e.key;
                            if (key === 13 || key === 'Enter') {
                                e.preventDefault();
                                btn.click();
                            }
                        });
                    }
                } catch (e) { /* ignore when controls not found */ }
            })();
        </script>
    </form>
</body>
</html>
