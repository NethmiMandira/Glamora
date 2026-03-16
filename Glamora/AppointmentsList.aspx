<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AppointmentsList.aspx.cs" Inherits="Glamora.AppointmentsList" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Appointment Calander</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <style>
        /* --- Sidebar and Layout CSS copied from AppointmentBooking.aspx --- */
        :root {
            --sidebar-bg: #1e293b;
            --sidebar-text: #94a3b8;
            --sidebar-active: #334155;
            --primary-color: #6366f1;
            --primary-hover: #4f46e5;
            --primary-light-bg: #e0e7ff;
            --accent-red: #ef4444;
            --accent-green: #10b981;
            --accent-orange: #f59e0b;
            --bg-body: #f1f5f9;
            --bg-white: #ffffff;
            --text-dark: #0f172a;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --radius: 8px;
        }
        * { box-sizing: border-box; }
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
        /* Sidebar toggle handle (shared) */
        .sidebar.collapsed { width: 100px; }
        /* hide header and collapse nav text when collapsed (match Dashboard) */
        .sidebar.collapsed h2 { display: none; }
        .sidebar.collapsed .nav-list li a span,
        .sidebar.collapsed .nav-list li .asp-link-button span { display: none; }
        .sidebar.collapsed .nav-list li a,
        .sidebar.collapsed .nav-list li .asp-link-button { justify-content: center; padding: 15px 0; }
        .content-area.collapsed { margin-left: 100px; }
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
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 10px;
        }
        /* --- Existing calendar and appointment styles remain unchanged --- */
        .cal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .view-switcher .btn { padding: 8px 16px; border: 1px solid var(--border-color); background: white; cursor: pointer; }
        .view-switcher .btn.active { background: var(--primary-color); color: white; border-color: var(--primary-color); }
        .calendar-grid { display: grid; background: white; border: 1px solid var(--border-color); border-radius: 8px; overflow: hidden; }
        .grid-month { grid-template-columns: repeat(7, 1fr); }
        .grid-header { background: #f8fafc; padding: 10px; text-align: center; font-weight: 600; border-bottom: 1px solid var(--border-color); }
        .day-cell {
            min-height: 120px;
            padding: 10px;
            border-right: 2px solid var(--border-color);
            border-bottom: 2px solid var(--border-color);
            position: relative;
        }
        .timeline-grid { display: grid; grid-template-columns: 80px 1fr; }
        .timeline-grid {
            display: grid;
            grid-template-columns: 80px 1fr;
            grid-auto-rows: minmax(60px, auto);
        }
        .time-slot {
            min-height: 60px;
            border-bottom: 2px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            color: #64748b;
        }
        .event-slot {
            border-bottom: 2px solid var(--border-color);
            position: relative;
            background: #fff;
        }
        .event-slot-day {
            min-height: 60px;
            height: auto;
            max-height: none;
            overflow: visible;
            margin-top: 8px;
            border-bottom: 2px solid var(--border-color);
        }
        .app-badge {
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.75rem;
            margin-bottom: 8px;
            display: block;
            text-decoration: none;
            font-weight: 700;
            min-width: 60px;
            text-align: left;
        }
        .app-badge.status-pending {
            background-color: #ede9fe;
            color: #5b21b6;
            border-left: 3px solid #7c3aed;
        }
        .app-badge.status-pending:hover {
            background-color: #7c3aed;
            color: #fff;
        }
        .app-badge.status-done {
            background-color: #ecfdf3;
            color: #065f46;
            border-left: 3px solid #10b981;
        }
        .app-badge.status-done:hover {
            background-color: #10b981;
            color: #fff;
        }
        .app-badge.status-expired {
            background-color: #fef9c3 !important;
            color: #eab308 !important;
            border-left: 3px solid #eab308 !important;
        }
        .app-badge.status-expired:hover {
            background-color: #eab308;
            color: #fff;
        }
        .app-badge.status-cancelled {
            background-color: #fee2e2;
            color: #991b1b;
            border-left: 3px solid #ef4444;
        }
        .app-badge.status-cancelled:hover {
            background-color: #ef4444;
            color: #fff;
        }
        /* Status badge styles */
        .status-badge {
            display: inline-block;
            padding: 2px 10px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 700;
            letter-spacing: 0.5px;
            min-width: 60px;
            text-align: center;
            margin-left: 6px;
        }
        .status-pending {
            background: #7c3aed;
            color: #fff;
        }
        .status-done {
            background: #10b981;
            color: #fff;
        }
        .status-expired {
            background: #f59e0b;
            color: #222;
        }
        .status-cancelled {
            background: #ef4444;
            color: #fff;
        }
        .show-more-btn, .show-less-btn {
            background: none;
            color: #6366f1;
            border: none;
            font-weight: 400;
            cursor: pointer;
            padding: 4px 8px;
            font-size: 0.85rem;
        }
        .show-more-btn:hover, .show-less-btn:hover {
            text-decoration: underline;
        }
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
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-wrapper">
            <div class="sidebar">
                <h2>Glamora</h2>
                <ul class="nav-list">
                    <li><a href="Dashboard.aspx"><i class="fas fa-chart-line"></i><span>Dashboard</span></a></li>
                    <li><a href="ReportGenerating.aspx"><i class="fas fa-file-alt"></i> <span>Reports</span></a></li>
                    <li><a href="Services.aspx"><i class="fas fa-magic"></i><span>Services</span></a></li>
                    <li><a href="AppointmentBooking.aspx"><i class="fas fa-calendar-check"></i><span>Appointment Booking</span></a></li>
                    <li class="active"><a href="AppointmentsList.aspx"><i class="fas fa-clipboard-list"></i><span>Appointment List</span></a></li>
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
                <h2 class="content-header">Appointment Calander</h2>
                <div class="cal-header">
                    <div>
                        <asp:LinkButton ID="btnPrev" runat="server" OnClick="ChangeDate_Click" CommandArgument="prev" CssClass="btn"><i class="fas fa-chevron-left"></i></asp:LinkButton>
                        <asp:Label ID="lblCurrentRange" runat="server" Font-Bold="true" Font-Size="Large" style="margin: 0 15px;"></asp:Label>
                        <asp:LinkButton ID="btnNext" runat="server" OnClick="ChangeDate_Click" CommandArgument="next" CssClass="btn"><i class="fas fa-chevron-right"></i></asp:LinkButton>
                    </div>
                    <div class="view-switcher">
                        <asp:Button ID="btnMonth" runat="server" Text="Month" OnClick="SwitchView_Click" CommandArgument="Month" CssClass="btn active" />
                        <asp:Button ID="btnWeek" runat="server" Text="Week" OnClick="SwitchView_Click" CommandArgument="Week" CssClass="btn" />
                        <asp:Button ID="btnDay" runat="server" Text="Day" OnClick="SwitchView_Click" CommandArgument="Day" CssClass="btn" />
                    </div>
                </div>
                <asp:MultiView ID="mvCalendar" runat="server" ActiveViewIndex="0">
                    <asp:View ID="vwGrid" runat="server">
                        <div class="calendar-grid grid-month">
                            <div class="grid-header">Sun</div><div class="grid-header">Mon</div><div class="grid-header">Tue</div>
                            <div class="grid-header">Wed</div><div class="grid-header">Thu</div><div class="grid-header">Fri</div><div class="grid-header">Sat</div>
                            <asp:Repeater ID="rptCalendar" runat="server" OnItemDataBound="rptCalendar_ItemDataBound">
                                <ItemTemplate>
                                    <div class='<%# Eval("CssClass") %>'>
                                        <span style="font-weight:bold;"><%# Eval("DayNumber") %></span>
                                        <asp:PlaceHolder ID="phAppointments" runat="server"></asp:PlaceHolder>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:View>
                    <asp:View ID="vwDay" runat="server">
                        <div class="calendar-grid timeline-grid">
                            <asp:Repeater ID="rptTimeline" runat="server" OnItemDataBound="rptTimeline_ItemDataBound">
                                <ItemTemplate>
                                    <div class="time-slot"><%# Container.DataItem %>:00</div>
                                    <div class="event-slot event-slot-day">
                                        <asp:PlaceHolder ID="phDayApps" runat="server"></asp:PlaceHolder>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:View>
                </asp:MultiView>
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
        </script>
    </form>
    <script type="text/javascript">
        function toggleApps(cellId, showMore) {
            var wrap = document.getElementById(cellId + '_wrap');
            var more = document.getElementById(cellId + '_more');
            var btnMore = wrap.querySelector('.show-more-btn');
            var btnLess = wrap.querySelector('.show-less-btn');
            if (showMore) {
                more.style.display = '';
                btnMore.style.display = 'none';
                btnLess.style.display = '';
            } else {
                more.style.display = 'none';
                btnMore.style.display = '';
                btnLess.style.display = 'none';
            }
        }
    </script>
</body>
</html>
