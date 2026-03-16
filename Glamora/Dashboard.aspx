<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Glamora.Dashboard" %>
<%@ Import Namespace="System.Web" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        :root {
            --sidebar-bg: #1e293b;
            /* slightly lighter accent for borders/buttons (avoids appearing pure black) */
            --sidebar-accent: #2b3e50;
            /* header gradient colors */
            --header-bg-start: #60a5fa;
            --header-bg-end: #7dd3fc;
            /* header primary color to use for accents (matches header left color) */
            --header-color: #60a5fa;
            /* employee card custom colours (soft violet gradient) */
            --employee-header-start: #a78bfa; /* soft violet */
            --employee-header-end: #fbcfe8; /* light pink */
            --sidebar-text: #94a3b8;
            --sidebar-active: #334155;
            --primary-color: #6366f1;
            --primary-hover: #4f46e5;
            --accent-red: #ef4444;
            --accent-green: #10b981;
            --accent-blue: #3b82f6;
            --accent-orange: #f97316;
            --bg-body: #f1f5f9;
            --bg-white: #ffffff;
            --text-dark: #0f172a;
            --text-muted: #64748b;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --radius: 8px;
            --border-color: #e2e8f0;
        }

        * { box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
            background-color: var(--bg-body);
            color: var(--text-dark);
        }

        .dashboard-wrapper { display: flex; min-height: 100vh; }

        /* Sidebar */
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

        .nav-list li { margin-bottom: 5px; }

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

        .nav-list li a:hover, .nav-list li .asp-link-button:hover {
            color: white;
            background-color: rgba(255,255,255,0.05);
        }

        .nav-list li.active a {
            background-color: var(--primary-color);
            color: white;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
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

        /* Content */
        .content-area {
            flex-grow: 1;
            padding: 40px;
            margin-left: 260px;
            background-color: var(--bg-body);
            transition: margin-left 0.2s ease;
        }

        /* Collapsed sidebar styles (toggle) */
        .sidebar.collapsed { width: 100px; }
        .sidebar.collapsed h2 { display: none; }
        .sidebar.collapsed .nav-list li a span,
        .sidebar.collapsed .nav-list li .asp-link-button span { display: none; }
        .sidebar.collapsed .nav-list li a,
        .sidebar.collapsed .nav-list li .asp-link-button { justify-content: center; padding: 15px 0; }
        .content-area.collapsed { margin-left: 100px; }

        /* Toggle handle that sits between sidebar and content */
        .sidebar-toggle {
            position: fixed;
            top: 22px;
            left: 268px; /* will be adjusted by JS */
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

        .content-header {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 35px;
            letter-spacing: -0.5px;
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 10px;
        }

        /* Stats Cards */
        .top-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }

        .stat-card {
            background-color: var(--bg-white);
            border-radius: var(--radius);
            padding: 25px;
            box-shadow: var(--shadow);
            border: 1px solid rgba(0,0,0,0.03);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 150px;
            transition: transform 0.2s, box-shadow 0.2s;
            position: relative;
            overflow: hidden;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }

        .stat-card::after {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            /* default stripe uses primary gradient */
            background: linear-gradient(135deg, var(--primary-color), var(--primary-hover));
        }
        /* Per-card stripe gradients (no card background change) */
        .stat-card.today::after { background: linear-gradient(135deg, var(--accent-blue), var(--primary-color)); }
        .stat-card.pending::after { background: linear-gradient(135deg, #7dd3fc, #06b6d4); }
        .stat-card.cancel::after { background: linear-gradient(135deg, #f87171, var(--accent-red)); }
        .stat-card.employee::after { background: linear-gradient(135deg, #bbf7d0, var(--accent-green)); }

        /* Gradient number styles (gradient text) */
        .stat-card.today .stat-card-value { background: linear-gradient(135deg, var(--accent-blue), var(--primary-color)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
        .stat-card.pending .stat-card-value { background: linear-gradient(135deg, #7dd3fc, #06b6d4); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
        .stat-card.cancel .stat-card-value { background: linear-gradient(135deg, #f87171, var(--accent-red)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
        .stat-card.employee .stat-card-value { background: linear-gradient(135deg, #bbf7d0, var(--accent-green)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }

        /* Use gradient for the button text and border only (no background fill) */
        .stat-card.today .view-button,
        .stat-card.pending .view-button,
        .stat-card.cancel .view-button,
        .stat-card.employee .view-button {
            background: transparent;
            border: 1px solid transparent; /* border-image will supply gradient */
            padding: 6px 16px;
            border-radius: 8px;
            font-weight: 600;
            display: inline-block;
            text-decoration: none;
            transition: all 0.12s ease;
        }

        /* Gradient border using border-image and gradient text using background-clip */
        .stat-card.today .view-button {
            border-image: linear-gradient(135deg, var(--accent-blue), var(--primary-color)) 1;
            background: linear-gradient(135deg, var(--accent-blue), var(--primary-color));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
        }
        .stat-card.today .view-button:hover {
            /* on hover fill with the same gradient and use white text for contrast */
            background: linear-gradient(135deg, var(--accent-blue), var(--primary-color));
            color: #ffffff !important;
            border-color: transparent;
            -webkit-background-clip: initial; -webkit-text-fill-color: #ffffff; background-clip: initial;
        }
        .stat-card.pending .view-button {
            border-image: linear-gradient(135deg, #7dd3fc, #06b6d4) 1;
            background: linear-gradient(135deg, #7dd3fc, #06b6d4);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
        }
        .stat-card.pending .view-button:hover {
            background: linear-gradient(135deg, #7dd3fc, #06b6d4);
            color: #ffffff !important;
            border-color: transparent;
            -webkit-background-clip: initial; -webkit-text-fill-color: #ffffff; background-clip: initial;
        }
        .stat-card.cancel .view-button {
            border-image: linear-gradient(135deg, #f87171, var(--accent-red)) 1;
            background: linear-gradient(135deg, #f87171, var(--accent-red));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
        }
        .stat-card.cancel .view-button:hover {
            background: linear-gradient(135deg, #f87171, var(--accent-red));
            color: #ffffff !important;
            border-color: transparent;
            -webkit-background-clip: initial; -webkit-text-fill-color: #ffffff; background-clip: initial;
        }
        .stat-card.employee .view-button {
            border-image: linear-gradient(135deg, #bbf7d0, var(--accent-green)) 1;
            background: linear-gradient(135deg, #bbf7d0, var(--accent-green));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
        }
        .stat-card.employee .view-button:hover {
            background: linear-gradient(135deg, #bbf7d0, var(--accent-green));
            color: #ffffff !important;
            border-color: transparent;
            -webkit-background-clip: initial; -webkit-text-fill-color: #ffffff; background-clip: initial;
        }
        .stat-card.employee .view-button {
            border-image: linear-gradient(135deg, #bbf7d0, var(--accent-green)) 1;
            background: linear-gradient(135deg, #bbf7d0, var(--accent-green));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
        }

        /* Hover: use previous style (fill with primary color and white text) */
        .stat-card .view-button:hover {
            background-color: var(--primary-color);
            color: #fff;
            border-color: var(--primary-color);
        }

        /* Remove corner radius when stat-card buttons are hovered */
        .stat-card .view-button:hover {
            border-radius: 0 !important;
        }

        .stat-card-title {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 10px;
        }

        .stat-card-value {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 10px;
        }

        .stat-card-footer { margin-top: 15px; text-align: right; }

        /* Base view-button styles (avoid overriding per-card gradient/colour rules) */
        .view-button {
            padding: 6px 16px;
           
            text-decoration: none;
            font-size: 0.85rem;
            font-weight: 600;
            transition: all 0.2s;
            display: inline-block;
            background: transparent; /* keep transparent by default */
        }

        /* Generic hover falls back to primary color only when a per-card hover doesn't exist */
        .view-button:hover { background-color: var(--primary-color); color: white; }

        /* removed forced top-stats radius rules to restore original button corners */

        .section-header {
            margin-bottom: 20px;
            margin-top: 40px;
            font-weight: 600;
            color: var(--text-muted);
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        /* Day view calendar - use multi-column (masonry-like) layout so next cards fill vertical gaps
           This avoids large empty spaces when cards have varying heights. Columns behave like table
           columns but are pure CSS (no colspan/rowspan required). */
        .day-calendar {
            column-count: 2;
            column-gap: 24px;
            /* ensure children don't break across columns */
        }

        /* when the sidebar is collapsed/hidden, use 3 columns with narrower cards */
        .sidebar.collapsed ~ .content-area .day-calendar {
            grid-template-columns: repeat(3, minmax(200px, 1fr));
        }
        .calendar-col {
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.08);
            overflow: hidden;
            /* allow columns layout to flow items top-to-bottom and fill gaps (masonry-like) */
            display: inline-block;
            vertical-align: top;
            width: 100%;
            box-sizing: border-box;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            margin-bottom: 24px; /* spacing between items in a column */
            break-inside: avoid;
        }
        .calendar-col:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 36px rgba(15, 23, 42, 0.12);
        }
        .calendar-col-header {
            padding: 14px 16px;
            background: linear-gradient(135deg, var(--employee-header-start), var(--employee-header-end));
            color: white;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .emp-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: rgba(255,255,255,0.18);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.25);
        }
        .emp-title {
            display: flex;
            flex-direction: column;
            line-height: 1.2;
        }
        .emp-name { font-weight: 700; letter-spacing: -0.2px; }
        .emp-label { font-size: 0.8rem; opacity: 0.85; }
        .calendar-col-body {
            padding: 12px;
            display: flex;
            flex-direction: column;
            gap: 16px;

        }
        .appt-block {
            border: 1px solid #e2e8f0;
            border-left: 4px solid var(--accent-blue);
            border-radius: 10px;
            padding: 14px 16px;
            background: linear-gradient(135deg, #f8fafc, #ffffff);
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.7);
            display: flex;
            flex-direction: column;
            gap: 18px;
        }
        .appt-actions {
            display: flex;
            justify-content: flex-end;
        }
        .btn-details {
            /* match styles used by .view-button (smaller variant) */
            background-color: transparent;
            color:#7dd3fc;
            border: 1px solid #7dd3fc;
            padding: 6px 12px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 0.75rem;
            font-weight: 700;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn-details:hover {
            background-color:#7dd3fc;
            color: #fff;
        }
        .appt-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            margin: 0;
        }
        .appt-time {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 700;
            margin: 0;
        }
        .appt-title {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--text-muted);
            margin: 0;
        }
        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 600;
            background: #e0e7ff;
            color: #312e81;
            border: 1px solid #c7d2fe;
        }
        .status-badge {
            background: #fff7ed;
            color: #9a3412;
            border-color: #fed7aa;
        }
        .appt-meta {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 700;
            margin: 0;
        }
        .appt-contact {
            font-size: 0.85rem;
            color: var(--text-muted);
            display: inline-block;
            font-weight: 700;
            margin: 0;
        }
        .service-pill {
            color: var(--text-muted);
            font-weight: 700;
        }
        .label-icon {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .empty-col {
            font-size: 0.9rem;
            color: var(--text-muted);
            padding: 12px;
            border: 1px dashed #cbd5e1;
            border-radius: 6px;
            background: #f8fafc;
            text-align: center;
        }

        /* Removed appointments list elements */
        .appointments-grid { display: none; }
        .appointment-card { display: none; }
        .empty-state { display: none; }

        @media (max-width: 1024px) {
            .sidebar { width: 70px; }
            .sidebar h2 { display: none; }
            .nav-list li a span, .nav-list li .asp-link-button span { display: none; }
            .nav-list li a, .nav-list li .asp-link-button { justify-content: center; padding: 15px 0; }
            .nav-list li a i { margin: 0; font-size: 1.25rem; }
            .content-area { margin-left: 70px; padding: 25px; }
        }

        @media (max-width: 768px) {
            .dashboard-wrapper { flex-direction: column; }
            .sidebar { position: relative; width: 100%; height: auto; flex-direction: row; overflow-x: auto; padding: 0; background: var(--sidebar-bg); }
            .nav-list { display: flex; padding: 10px; }
            .nav-list li { margin: 0 5px; }
            .content-area { margin-left: 0; padding: 20px; }
            .top-stats { display: grid; }
            .day-calendar { column-count: 1; column-gap: 16px; }
        }
        
        /* --- Modified Employee Card & Appointment Styles --- */
        .day-calendar {
            /* use multi-column layout for masonry-like stacking so next cards fill vertical gaps */
            column-count: 2;
            column-gap: 24px;
        }

        /* when the sidebar is collapsed/hidden, increase columns so narrower cards fit better */
        .sidebar.collapsed ~ .content-area .day-calendar {
            column-count: 3;
        }

        /* The Employee Container Card */
        .calendar-col {
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .calendar-col:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.08);
        }

        /* Card Header with Initials Circle */
        .calendar-col-header {
            padding: 18px;
            /* alternate: use employee-specific gradient */
            background: linear-gradient(135deg, var(--employee-header-start), var(--employee-header-end));
            color: #ffffff;
            border-bottom: 1px solid rgba(0,0,0,0.03);
            display: flex;
            align-items: center;
            gap: 12px;
            /* round the top corners to match card radius */
            border-top-left-radius: 10px;
            border-top-right-radius: 10px;
        }

        .calendar-col-header .emp-info .emp-name { color: #fff; }
        .calendar-col-header .emp-info .emp-role { color: rgba(255,255,255,0.9); }

        .emp-avatar-circle {
            width: 42px;
            height: 42px;
            background: var(--primary-color);
            color: #fff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1rem;
            text-transform: uppercase;
        }

        .emp-info .emp-name { font-weight: 700; color: var(--text-dark); font-size: 1rem; }
        .emp-info .emp-role { font-size: 0.8rem; color: var(--text-muted); }

        /* Individual Appointment Blocks */
        .calendar-col-body { padding: 16px; background: #fafafa; display: flex; flex-direction: column; gap: 12px; }

        /* Ensure Inter font is used for new card components */
        .calendar-col,
        .calendar-col-header,
        .calendar-col-body,
        .appt-block,
        .emp-info {
            font-family: 'Inter', sans-serif;
        }

        .appt-block {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-left: 4px solid var(--accent-blue);
            border-radius: 8px;
            padding: 14px;
            transition: border-color 0.2s;
        }
        .appt-detail-row {
            display: flex;
            gap: 8px;
            align-items: center;
            margin-bottom: 6px;
        }
        .appt-detail-row .detail-label {
            font-family: 'Inter', sans-serif;
            font-size: 0.85rem;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
            min-width: 96px;
            /* ensure the label and its pseudo-element (:) are vertically centered */
            display: inline-flex;
            align-items: center;
            line-height: 1;
        }
        .appt-detail-row .detail-label::after {
            content: ":";
            display: inline-block;
            margin-left: 6px;
            margin-right: 8px;
            vertical-align: middle;
            line-height: 1;
        }
        .appt-detail-row .detail-value {
            font-family: 'Inter', sans-serif;
            font-size: 0.95rem;
            color: var(--text-dark);
            font-weight: 700;
            letter-spacing: -0.2px;
        }

        .appt-time-row { display: flex; justify-content: space-between; margin-bottom: 8px; }
        .appt-time { font-size: 0.75rem; font-weight: 800; color: var(--accent-blue); text-transform: uppercase; }
        .service-tag { font-size: 0.7rem; font-weight: 600; background: #f1f5f9; padding: 2px 8px; border-radius: 4px; color: var(--text-muted); }

        .customer-name { font-size: 0.95rem; font-weight: 700; margin: 0 0 4px 0; color: var(--text-dark); }
        .customer-contact { font-size: 0.8rem; color: var(--text-muted); display: flex; align-items: center; gap: 6px; }

        .appt-footer { margin-top: 12px; display: flex; justify-content: flex-end; }
        .btn-details {
            /* reuse the same compact view-button styles for footer details */
            background-color: transparent;
            color: var(--primary-color);
            border: 1px solid var(--primary-color);
            padding: 6px 12px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 0.75rem;
            font-weight: 700;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn-details:hover {
            background-color: var(--primary-color);
            color: #fff;
        }
        /* Use header color for left border and Details button so they match the header */
        .appt-block {
            border-left: 4px solid var(--header-color) !important;
        }

        .btn-details {
            color: var(--header-color) !important;
            border-color: var(--header-color) !important;
        }
        .btn-details:hover {
            background-color: var(--header-color) !important;
            color: #fff !important;
        }

        /* Override appointment border and details button colours inside each employee card
           so the employee card uses its own accent instead of the global header color. */
        .calendar-col .appt-block {
            border-left-color: var(--employee-header-start) !important;
        }
        .calendar-col .btn-details {
            color: var(--employee-header-start) !important;
            border-color: var(--employee-header-start) !important;
        }
        .calendar-col .btn-details:hover {
            background-color: var(--employee-header-start) !important;
            color: #fff !important;
        }

        /* Done Today stat card */
        .stat-card.done::after { background: linear-gradient(135deg, #bbf7d0, var(--accent-green)); }
        .stat-card.done .stat-card-value { background: linear-gradient(135deg, #34d399, var(--accent-green)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
        .stat-card.done .view-button {
            border-image: linear-gradient(135deg, #34d399, var(--accent-green)) 1;
            background: linear-gradient(135deg, #34d399, var(--accent-green));
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
        }
        .stat-card.done .view-button:hover {
            background: linear-gradient(135deg, #34d399, var(--accent-green));
            -webkit-background-clip: initial; -webkit-text-fill-color: #ffffff; background-clip: initial;
            border-color: transparent;
        }

        /* Revenue stat cards — unified purple gradient */
        .stat-card.revenue {
            background: linear-gradient(135deg, #7c3aed, #a78bfa);
            border: none;
        }
        .stat-card.revenue::after { background: rgba(255,255,255,0.35); width: 4px; }
        .stat-card.revenue .stat-card-title { color: rgba(255,255,255,0.85); }
        .stat-card.revenue .stat-card-title i { color: rgba(255,255,255,0.9); }
        .stat-card.revenue .stat-card-value { color: #fff; font-size: 1.8rem; background: none; -webkit-background-clip: initial; -webkit-text-fill-color: #fff; background-clip: initial; }
        .stat-card.revenue:hover { transform: translateY(-3px); box-shadow: 0 12px 24px rgba(124,58,237,0.3); }

        /* Quick Actions */
        .quick-actions {
            display: flex;
            gap: 14px;
            margin-bottom: 10px;
            flex-wrap: wrap;
        }
        .qa-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 0.88rem;
            font-weight: 600;
            text-decoration: none;
            color: #fff;
            transition: transform 0.15s, box-shadow 0.15s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        .qa-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.12); }
        .qa-btn i { font-size: 1rem; }
        .qa-book { background: linear-gradient(135deg, var(--primary-color), var(--primary-hover)); }
        .qa-customer { background: linear-gradient(135deg, #34d399, var(--accent-green)); }
        .qa-invoice { background: linear-gradient(135deg, #fbbf24, #d97706); }
        .qa-list { background: linear-gradient(135deg, var(--accent-blue), #6366f1); }

        /* Upcoming Appointments */
        .upcoming-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-bottom: 30px;
        }
        .upcoming-item {
            display: flex;
            align-items: flex-start;
            gap: 18px;
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-left: 4px solid var(--accent-blue);
            border-radius: 10px;
            padding: 16px 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
            position: relative;
        }
        .upcoming-item:hover {
            transform: translateX(4px);
            box-shadow: 0 6px 16px rgba(99,102,241,0.08);
            border-left-color: var(--primary-color);
        }
        .upcoming-time {
            min-width: 88px;
            font-size: 0.82rem;
            font-weight: 800;
            color: #fff;
            white-space: nowrap;
            background: linear-gradient(135deg, var(--accent-blue), var(--primary-color));
            padding: 6px 14px;
            border-radius: 20px;
            text-align: center;
            letter-spacing: 0.3px;
            box-shadow: 0 2px 6px rgba(59,130,246,0.25);
            flex-shrink: 0;
            margin-top: 2px;
        }
        .upcoming-details { flex: 1; min-width: 0; }
        .upcoming-customer {
            font-weight: 700;
            font-size: 0.95rem;
            color: var(--text-dark);
            display: flex;
            align-items: center;
            gap: 6px;
            margin-bottom: 8px;
        }
        .upcoming-customer::before {
            content: '\f007';
            font-family: 'Font Awesome 6 Free';
            font-weight: 900;
            font-size: 0.75rem;
            color: var(--accent-blue);
            background: #eff6ff;
            width: 22px;
            height: 22px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .upcoming-emp-services {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .upcoming-emp-group {
            display: flex;
            flex-direction: column;
            gap: 4px;
            padding: 8px 10px;
            background: #faf5ff;
            border-radius: 8px;
            border: 1px solid #ede9fe;
        }
        .upcoming-emp-name {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--employee-header-start);
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .upcoming-emp-name i {
            font-size: 0.72rem;
            background: linear-gradient(135deg, var(--employee-header-start), var(--employee-header-end));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .upcoming-emp-svc {
            display: inline-block;
            font-size: 0.75rem;
            font-weight: 600;
            color: var(--text-muted);
            padding: 0;
            margin-left: 20px;
            margin-top: 1px;
        }
        .upcoming-item .btn-details {
            align-self: center;
            flex-shrink: 0;
            border-radius: 20px;
            padding: 6px 16px;
            font-size: 0.75rem;
            transition: all 0.2s;
        }
        .upcoming-item .btn-details:hover {
            transform: scale(1.05);
        }

        @media (max-width: 768px) {
            .quick-actions { flex-direction: column; }
            .qa-btn span { display: inline; }
            .upcoming-item { flex-direction: column; align-items: flex-start; gap: 10px; }
            .upcoming-time { min-width: auto; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-wrapper">
            <div class="sidebar">
                <h2>Glamora</h2>
                <ul class="nav-list">
                    <li class="active"><a href="Dashboard.aspx"><i class="fas fa-chart-line"></i> <span>Dashboard</span></a></li>
                    <li><a href="ReportGenerating.aspx"><i class="fas fa-file-alt"></i> <span>Reports</span></a></li>
                    <li><a href="Services.aspx"><i class="fas fa-magic"></i> <span>Services</span></a></li>
                    <li><a href="AppointmentBooking.aspx"><i class="fas fa-calendar-check"></i> <span>Appointment Booking</span></a></li>
                    <li><a href="AppointmentsList.aspx"><i class="fas fa-clipboard-list"></i> <span>Appointment List</span></a></li>
                    <li><a href="Invoice.aspx"><i class="fas fa-file-invoice"></i> <span>Invoice</span></a></li>
                    <li><a href="Employees.aspx"><i class="fas fa-user-tie"></i> <span>Employees</span></a></li>
                    <li><a href="Customers.aspx"><i class="fas fa-users"></i> <span>Customers</span></a></li>
                    <li><a href="Users.aspx"><i class="fas fa-shield-alt"></i> <span>Users</span></a></li>
                    <li><a href="Settings.aspx"><i class="fas fa-sliders-h"></i> <span>Settings</span></a></li>
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
                <h2 class="content-header">Dashboard Overview</h2>

                <div class="section-header" style="margin-top:0; margin-bottom:20px;">
                    <span><i class="fas fa-coins" style="margin-right:8px;"></i>Revenue Overview</span>
                </div>
                <div class="top-stats">
                    <div class="stat-card revenue">
                        <div>
                            <div class="stat-card-title"><i class="fas fa-coins" style="margin-right:6px;"></i>Today's Revenue</div>
                            <div class="stat-card-value">
                                LKR <asp:Label ID="lblTodaysRevenue" runat="server" Text="0.00"></asp:Label>
                            </div>
                        </div>
                    </div>

                    <div class="stat-card revenue">
                        <div>
                            <div class="stat-card-title"><i class="fas fa-chart-line" style="margin-right:6px;"></i>Last 7 Days Revenue</div>
                            <div class="stat-card-value">
                                LKR <asp:Label ID="lblLast7DaysRevenue" runat="server" Text="0.00"></asp:Label>
                            </div>
                        </div>
                    </div>

                    <div class="stat-card revenue">
                        <div>
                            <div class="stat-card-title"><i class="fas fa-wallet" style="margin-right:6px;"></i>Total Revenue</div>
                            <div class="stat-card-value">
                                LKR <asp:Label ID="lblTotalRevenue" runat="server" Text="0.00"></asp:Label>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="section-header" style="margin-top:10px; margin-bottom:20px;">
                    <span><i class="fas fa-calendar-check" style="margin-right:8px;"></i>Appointments Overview</span>
                </div>
                <div class="top-stats">
                    <div class="stat-card today">
                        <div>
                            <div class="stat-card-title">Today's Appointments</div>
                            <div class="stat-card-value" style="color: var(--accent-blue);">
                                <asp:Label ID="lblTodaysAppointments" runat="server" Text="0"></asp:Label>
                            </div>
                        </div>
                        <div class="stat-card-footer">
                            <a href="TodaysAppointments.aspx?date=today" class="view-button">View All</a>
                        </div>
                    </div>

                    <div class="stat-card pending">
                        <div>
                            <div class="stat-card-title">Pending Today</div>
                            <div class="stat-card-value" style="color: var(--accent-orange);">
                                <asp:Label ID="lblPendingToday" runat="server" Text="0"></asp:Label>
                            </div>
                        </div>
                        <div class="stat-card-footer">
                            <a href="PendingToday.aspx?date=today&status=pending" class="view-button">Review</a>
                        </div>
                    </div>

                    <div class="stat-card cancel">
                        <div>
                            <div class="stat-card-title">Cancellations</div>
                            <div class="stat-card-value" style="color: var(--accent-red);">
                                <asp:Label ID="lblCancelAppointments" runat="server" Text="0"></asp:Label>
                            </div>
                        </div>
                        <div class="stat-card-footer">
                            <a href="CancelledAppointments.aspx?status=cancelled" class="view-button">Review</a>
                        </div>
                    </div>
                </div>

                <div class="section-header" style="margin-top:10px; margin-bottom:20px;">
                    <span><i class="fas fa-bolt" style="margin-right:8px;"></i>Quick Access</span>
                </div>
                <!-- Quick Actions -->
                <div class="quick-actions">
                    <a href="AppointmentBooking.aspx" class="qa-btn qa-book"><i class="fas fa-calendar-plus"></i> <span>New Appointment</span></a>
                    <a href="Customers.aspx" class="qa-btn qa-customer"><i class="fas fa-user-plus"></i> <span>Add Customer</span></a>
                    <a href="Employees.aspx" class="qa-btn qa-invoice"><i class="fas fa-user-tie"></i> <span>Add New Employee</span></a>
                    <a href="AppointmentsList.aspx" class="qa-btn qa-list"><i class="fas fa-clipboard-list"></i> <span>All Appointments</span></a>
                </div>

                <!-- Upcoming Appointments -->
                <div class="section-header">
                    <span>Upcoming Today</span>
                </div>

                <asp:Panel ID="pnlNoUpcoming" runat="server" Visible="false" CssClass="empty-col" style="margin-bottom:24px;">
                    <i class="fas fa-check-circle" style="margin-right:6px;"></i> No more appointments remaining today.
                </asp:Panel>

                <div class="upcoming-list">
                    <asp:Repeater ID="rptUpcoming" runat="server">
                        <ItemTemplate>
                            <div class="upcoming-item">
                                <div class="upcoming-time"><%# FormatTimeShort(Eval("StartTime")) %></div>
                                <div class="upcoming-details">
                                    <div class="upcoming-customer"><%# Eval("CustomerName") %></div>
                                    <div class="upcoming-emp-services"><%# GetUpcomingEmpServicesHtml(Eval("AppID")) %></div>
                                </div>
                                <a class="btn-details" href='<%# "ViewAppointmentDetails.aspx?id=" + Eval("AppID") %>'>Details</a>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                    </div>

                </div>
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

                // initialize
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
    </form>
</body>
</html>