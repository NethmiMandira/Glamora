<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReportGenerating.aspx.cs" Inherits="Glamora.ReportGenerating" %>
<%@ Import Namespace="System.Web" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Reports</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        /* ... (all styles exactly as in your original) ... */
        :root {
            --sidebar-bg: #1e293b;
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
        body { font-family: 'Inter', sans-serif; margin: 0; padding: 0; background-color: var(--bg-body); color: var(--text-dark); }
        .dashboard-wrapper { display: flex; min-height: 100vh; }
        .sidebar { width: 260px; background-color: var(--sidebar-bg); color: var(--sidebar-text); padding: 0; box-shadow: 4px 0 10px rgba(0,0,0,0.05); position: fixed; top: 0; left: 0; height: 100vh; overflow-y: auto; z-index: 1000; display: flex; flex-direction: column; }
        .sidebar h2 { text-align: left; margin: 0; padding: 25px; font-size: 1.5rem; font-weight: 800; color: white; letter-spacing: -0.5px; border-bottom: 1px solid rgba(255,255,255,0.05); background: rgba(0,0,0,0.1); }
        .nav-list { list-style: none; padding: 20px 15px; margin: 0; flex-grow: 1; }
        .nav-list li { margin-bottom: 5px; }
        .nav-list li a, .nav-list li .asp-link-button { display: flex; align-items: center; padding: 12px 15px; text-decoration: none; color: var(--sidebar-text); font-size: 0.9rem; font-weight: 500; border-radius: var(--radius); transition: all 0.2s ease; cursor: pointer; border: none; background: none; width: 100%; text-align: left; font-family: 'Inter', sans-serif; }
        .nav-list li a i, .nav-item-icon { margin-right: 12px; width: 20px; text-align: center; font-size: 1.1rem; }
        .nav-list li a:hover, .nav-list li .asp-link-button:hover { color: white; background-color: rgba(255,255,255,0.05); }
        .nav-list li.active a { background-color: var(--primary-color); color: white; box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); }
        .nav-list li.logout { margin-top: auto; border-top: 1px solid rgba(255,255,255,0.05); padding-top: 20px; }

        .content-area { flex-grow: 1; padding: 40px; margin-left: 260px; background-color: var(--bg-body); }
        .content-header {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 35px;
            letter-spacing: -0.5px;
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 10px;
        }

        .card { background-color: var(--bg-white); border-radius: var(--radius); padding: 18px; box-shadow: var(--shadow); border: 1px solid var(--border-color); }
        .filters { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; margin-bottom: 14px; }
        .field { display:flex; flex-direction: column; gap:6px; }
        label { font-weight:700; color:var(--text-muted); font-size:0.85rem; }
        input[type="date"], select, .btn { padding:8px 10px; border-radius:6px; border:1px solid var(--border-color); background:#fff; }
        .btn { cursor:pointer; font-weight:700; }
        .btn.primary { background:var(--primary-color); color:#fff; border:1px solid var(--primary-color); }
        .btn.export { background:var(--accent-green); color:#fff; border:1px solid var(--accent-green); }
        .btn.pdf { background:#2563eb; color:#fff; border:1px solid #1e40af; }
        .btn.print { background:#475569; color:#fff; border:1px solid #334155; }
        .btn[disabled], .btn.disabled { opacity:0.6; cursor:not-allowed; box-shadow:none; filter:grayscale(10%); }
        .actions { display:flex; gap:8px; justify-content:flex-end; align-items:center; }
        .message { margin-top:10px; color:var(--text-muted); font-weight:700; }
        .table-wrap { margin-top:16px; overflow:auto; }
        .content-area { max-width: calc(100% - 260px); box-sizing: border-box; overflow-x: hidden; }
        .card.shrinkable { max-width: 760px; width: 100%; }
        .table-wrap { overflow-x: auto; }
        table.report { width:100%; border-collapse:collapse; }
        table.report th, table.report td { padding:10px; border-bottom:1px solid var(--border-color); text-align:left; }
        table.report th { background:#f8fafc; font-weight:700; }

        .report-grid { width:100%; border-collapse:collapse; font-size:0.95rem; }
        .report-grid th, .report-grid td { border:1px solid var(--border-color); padding:10px 12px; text-align:left; vertical-align:middle; }
        .report-grid th { background:#f3f4f6; color:var(--text-dark); font-weight:700; }
        .report-grid tr:nth-child(even) td { background:#fbfdff; }
        .report-grid tr:hover td { background:#f1f5f9; }
        .report-grid .empty { text-align:center; color:var(--text-muted); padding:20px; }

        .sidebar.collapsed { width: 100px; }
        .sidebar.collapsed h2 { display: none; }
        .sidebar.collapsed .nav-list li a span,
        .sidebar.collapsed .nav-list li .asp-link-button span { display: none; }
        .sidebar.collapsed .nav-list li a,
        .sidebar.collapsed .nav-list li .asp-link-button { justify-content: center; padding: 15px 0; }

        @media (max-width: 1024px) {
            /* keep behavior same for small screens */
        }

        .sidebar.collapsed { width: 100px; }
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <asp:HiddenField ID="hfLogoUrl" runat="server" />
        <asp:HiddenField ID="hfFooterText" runat="server" />

        <div class="dashboard-wrapper">
            <div class="sidebar">
                <h2>Glamora</h2>
                <ul class="nav-list">
                    <li><a href="Dashboard.aspx"><i class="fas fa-chart-line"></i> <span>Dashboard</span></a></li>
                    <li class="active"><a href="ReportGenerating.aspx"><i class="fas fa-file-alt"></i> <span>Reports</span></a></li>
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

            <div id="contentArea" runat="server" class="content-area">
                <h2 class="content-header">Reports</h2>

                <div class="card">
                    <div style="display:flex;gap:12px;align-items:center;margin-bottom:12px;">
                        <div style="flex:1" class="field">
                            <label for="ddlReportType">Report Type</label>
                            <asp:DropDownList ID="ddlReportType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlReportType_SelectedIndexChanged">
                                <asp:ListItem Value="">Select Report type</asp:ListItem>
                                <asp:ListItem Value="Appointment">Appointment Report</asp:ListItem>
                                <asp:ListItem Value="Revenue">Revenue Report</asp:ListItem>
                                <asp:ListItem Value="ServicePerformance">Service Performance</asp:ListItem>
                                <asp:ListItem Value="EmployeePerformance">Employee Performance</asp:ListItem>
                                <asp:ListItem Value="Customer">Customer Report</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="filters">
                        <div class="field">
                            <label for="txtFrom">From</label>
                            <asp:TextBox ID="txtFrom" runat="server" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="field">
                            <label for="txtTo">To</label>
                            <asp:TextBox ID="txtTo" runat="server" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="field">
                            <label for="ddlCustomer">Customer</label>
                            <asp:DropDownList ID="ddlCustomer" runat="server">
                                <asp:ListItem Value="">-- All Customers --</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="field">
                            <label for="ddlEmployee">Employee</label>
                            <asp:DropDownList ID="ddlEmployee" runat="server">
                                <asp:ListItem Value="">-- All Employees --</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="actions" style="align-items:center;">
                        <asp:Button ID="btnGenerate" runat="server" Text="Generate" CssClass="btn primary" OnClick="btnGenerate_Click" Enabled="true" />
                        <asp:Button ID="btnExport" runat="server" Text="Export CSV" CssClass="btn export" OnClick="btnExport_Click" Enabled="true" />
                        <asp:Button ID="btnExportPdfClient" runat="server" Text="Export PDF" CssClass="btn pdf" OnClientClick="exportPdfClient(); return false;" Enabled="true" />
                        <asp:Button ID="btnPrint" runat="server" Text="Print" CssClass="btn print" OnClientClick="printReport(); return false;" Enabled="true" />
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>

                <!-- Alternate report panels -->
                <asp:Panel ID="pnlServicePerf" runat="server" CssClass="card" Visible="false" Style="margin-top:16px;">
                    <h3 style="margin-top:0;">Service Performance</h3>
                    <asp:GridView ID="gvServicePerf" runat="server" AutoGenerateColumns="false" CssClass="report-grid" ShowHeaderWhenEmpty="true" EmptyDataText="">
                        <Columns>
                            <asp:BoundField DataField="ServiceName" HeaderText="Service" />
                            <asp:BoundField DataField="Bookings" HeaderText="Bookings" />
                            <asp:BoundField DataField="Revenue" HeaderText="Revenue" DataFormatString="{0:N2}" />
                        </Columns>
                    </asp:GridView>
                </asp:Panel>

                <asp:Panel ID="pnlCustomerReport" runat="server" CssClass="card" Visible="false" Style="margin-top:16px;">
                    <h3 style="margin-top:0;">Customer Report</h3>
                    <asp:GridView ID="gvCustomerReport" runat="server" AutoGenerateColumns="false" CssClass="report-grid" ShowHeaderWhenEmpty="true" EmptyDataText="">
                        <Columns>
                            <asp:BoundField DataField="CustomerName" HeaderText="Customer" />
                            <asp:BoundField DataField="TotalVisits" HeaderText="Total Visits" />
                            <asp:BoundField DataField="TotalRevenue" HeaderText="Total Revenue" DataFormatString="{0:N2}" />
                            <asp:BoundField DataField="TotalAdvance" HeaderText="Total Advance" DataFormatString="{0:N2}" />
                            <asp:BoundField DataField="LastVisit" HeaderText="Last Visit" DataFormatString="{0:yyyy-MM-dd}" />
                        </Columns>
                    </asp:GridView>
                </asp:Panel>

                <asp:Panel ID="pnlEmployeePerf" runat="server" CssClass="card" Visible="false" Style="margin-top:16px;">
                    <h3 style="margin-top:0;">Employee Performance</h3>
                    <asp:GridView ID="gvEmployeePerf" runat="server" AutoGenerateColumns="false" CssClass="report-grid" ShowHeaderWhenEmpty="true" EmptyDataText="">
                        <Columns>
                            <asp:BoundField DataField="EmployeeName" HeaderText="Employee" />
                            <asp:BoundField DataField="ServicesDone" HeaderText="Services Done" />
                            <asp:BoundField DataField="Revenue" HeaderText="Revenue" DataFormatString="{0:N2}" />
                        </Columns>
                    </asp:GridView>
                </asp:Panel>

                <asp:Panel ID="pnlRevenue" runat="server" CssClass="card" Visible="false" Style="margin-top:16px;">
                    <h3 style="margin-top:0;">Revenue Report</h3>
                    <asp:GridView ID="gvRevenue" runat="server" AutoGenerateColumns="false" CssClass="report-grid" ShowHeaderWhenEmpty="true" EmptyDataText="">
                        <Columns>
                            <asp:BoundField DataField="Date" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" />
                            <asp:BoundField DataField="Revenue" HeaderText="Revenue" DataFormatString="{0:N2}" />
                            <asp:BoundField DataField="Advance" HeaderText="Advance" DataFormatString="{0:N2}" />
                        </Columns>
                    </asp:GridView>
                </asp:Panel>

                <asp:Panel ID="pnlReportResults" runat="server" CssClass="card" Style="margin-top:16px;" Visible="false">
                    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;">
                        <h3 style="margin:0;font-size:1.05rem;color:var(--text-dark);">Report Results</h3>
                    </div>
                    <div style="margin-bottom:8px;color:var(--text-muted);font-weight:700;" id="criteriaSummary">
                        <asp:Label ID="lblCriteria" runat="server" />
                    </div>
                    <div class="table-wrap">
                        <asp:GridView ID="gvReport" runat="server" AutoGenerateColumns="false" GridLines="Both" CssClass="report-grid" ShowHeaderWhenEmpty="true" EmptyDataText="No records to display">
                            <Columns>
                                <asp:BoundField DataField="Date" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" />
                                <asp:BoundField DataField="TotalAppointments" HeaderText="Total Appointments" ItemStyle-HorizontalAlign="Right" />
                                <asp:BoundField DataField="AdvancePaid" HeaderText="Advance Paid" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" />
                                <asp:BoundField DataField="Total" HeaderText="Total" DataFormatString="{0:N0}" ItemStyle-HorizontalAlign="Right" />
                                <asp:BoundField DataField="Completed" HeaderText="Completed" ItemStyle-HorizontalAlign="Right" />
                                <asp:BoundField DataField="Pending" HeaderText="Pending" ItemStyle-HorizontalAlign="Right" />
                                <asp:BoundField DataField="Cancelled" HeaderText="Cancelled" ItemStyle-HorizontalAlign="Right" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </asp:Panel>
            </div>
        </div>

        <script runat="server">
            protected void Page_PreRender(object sender, EventArgs e)
            {
                try
                {
                    var contentDiv = this.FindControl("contentArea") as System.Web.UI.HtmlControls.HtmlGenericControl;
                    if (contentDiv != null)
                    {
                        contentDiv.Attributes["class"] = "content-area";
                    }
                }
                catch { }
            }
        </script>

        <script type="text/javascript">
            // Convert interactive controls to plain text for printing/export
            function convertControlsToText(html) {
                try {
                    var wrapper = document.createElement('div');
                    wrapper.innerHTML = html;

                    // Replace inputs and textareas with their values
                    var inputs = wrapper.querySelectorAll('input, textarea');
                    for (var i = 0; i < inputs.length; i++) {
                        var el = inputs[i];
                        var v = '';
                        try { v = el.value || el.getAttribute('value') || ''; } catch (e) { v = ''; }
                        var span = document.createElement('span');
                        span.textContent = v;
                        el.parentNode.replaceChild(span, el);
                    }

                    // Replace selects with selected option text
                    var selects = wrapper.querySelectorAll('select');
                    for (var j = 0; j < selects.length; j++) {
                        var s = selects[j];
                        var text = '';
                        try { if (s.options && s.selectedIndex >= 0) text = s.options[s.selectedIndex].text; } catch (e) { text = ''; }
                        var span2 = document.createElement('span');
                        span2.textContent = text;
                        s.parentNode.replaceChild(span2, s);
                    }

                    // Replace buttons and links with their label text
                    var actions = wrapper.querySelectorAll('button, a');
                    for (var k = 0; k < actions.length; k++) {
                        var a = actions[k];
                        var t = (a.textContent || a.innerText || '').trim();
                        var sp = document.createElement('span');
                        sp.textContent = t;
                        a.parentNode.replaceChild(sp, a);
                    }

                    return wrapper.innerHTML;
                } catch (e) {
                    return html;
                }
            }

            // Scroll to the visible report panel after Generate
            function scrollToReportPanel() {
                var rpt = document.querySelector('[id$="ddlReportType"]');
                var card = null;
                try {
                    if (rpt && rpt.value === 'Appointment') {
                        var ap = document.querySelector('[id$="pnlReportResults"]');
                        if (ap && ap.offsetParent !== null) card = ap;
                    } else if (rpt && rpt.value === 'Customer') {
                        var cust = document.querySelector('[id$="pnlCustomerReport"]');
                        if (cust && cust.offsetParent !== null) card = cust;
                    } else if (rpt && rpt.value === 'ServicePerformance') {
                        var serv = document.querySelector('[id$="pnlServicePerf"]');
                        if (serv && serv.offsetParent !== null) card = serv;
                    } else if (rpt && rpt.value === 'EmployeePerformance') {
                        var emp = document.querySelector('[id$="pnlEmployeePerf"]');
                        if (emp && emp.offsetParent !== null) card = emp;
                    } else if (rpt && rpt.value === 'Revenue') {
                        var rev = document.querySelector('[id$="pnlRevenue"]');
                        if (rev && rev.offsetParent !== null) card = rev;
                    }
                } catch (e) { card = null; }
                if (!card) return;
                card.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }

            // Sidebar toggle functionality
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

            // Helper: get the currently visible report card
            function getVisibleReportCard() {
                var content = document.querySelector('.content-area');
                if (!content) return null;
                var rpt = document.querySelector('[id$="ddlReportType"]');
                var isAppointment = rpt && rpt.value === 'Appointment';
                var grids = content.querySelectorAll('.report-grid');
                for (var i = 0; i < grids.length; i++) {
                    var g = grids[i];
                    var card = g.closest('.card');
                    if (card && card.offsetParent !== null) {
                        try {
                            if (!isAppointment && card.id && card.id.match(/pnlReportResults$/)) continue;
                        } catch (e) { }
                        return card;
                    }
                }
                var wraps = content.querySelectorAll('.table-wrap');
                for (var j = 0; j < wraps.length; j++) {
                    var w = wraps[j];
                    var cardw = w.closest('.card');
                    if (cardw && cardw.offsetParent !== null) return cardw;
                }
                var cards = content.querySelectorAll('.card');
                for (var k = 0; k < cards.length; k++) {
                    var c2 = cards[k];
                    if (c2.offsetParent === null) continue;
                    if (c2.querySelector('.filters')) continue;
                    return c2;
                }
                return content.querySelector('.card');
            }

            // Helper: build applied filters HTML table
            function getFiltersHtml() {
                var from = document.querySelector('[id$="txtFrom"]');
                var to = document.querySelector('[id$="txtTo"]');
                var cust = document.querySelector('[id$="ddlCustomer"]');
                var emp = document.querySelector('[id$="ddlEmployee"]');
                var rows = '';
                if (from && from.value) rows += '<tr><th>From</th><td>' + from.value + '</td></tr>';
                if (to && to.value) rows += '<tr><th>To</th><td>' + to.value + '</td></tr>';
                if (cust && cust.selectedIndex >= 0 && cust.value) rows += '<tr><th>Customer</th><td>' + cust.options[cust.selectedIndex].text + '</td></tr>';
                if (emp && emp.selectedIndex >= 0 && emp.value) rows += '<tr><th>Employee</th><td>' + emp.options[emp.selectedIndex].text + '</td></tr>';
                if (!rows) return '';
                return '<table class="filters-table" style="width:100%;">' + rows + '</table>';
            }

            // Open a new window with printable content
            function openPrintable(innerHtml, autoPrint) {
                var newWin = window.open('', '_blank');
                var cssLink = '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>';
                var styles = '<style>' +
                    '@page { size: A4 portrait; margin: 12mm; }' +
                    'body{font-family:Inter, Arial, sans-serif; padding:20px; color:#0f172a; background:#fff;}' +
                    '.print-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;gap:16px;}' +
                    '.print-brand{display:flex;align-items:center;gap:12px;}' +
                    '.print-brand img{max-height:64px;max-width:160px;object-fit:contain;}' +
                    '.print-title{font-size:20px;font-weight:800;margin:0;color:#111827;text-align:right;}' +
                    '.print-sub{font-size:13px;color:#6b7280;margin-top:4px;text-align:right;}' +
                    '.filters-table{border-collapse:collapse;margin:6px 0 12px 0;font-size:13px;color:#374151;width:100%;}' +
                    '.filters-table th{font-weight:700;text-align:left;padding:6px 8px;color:#374151;width:120px;}' +
                    '.filters-table td{padding:6px 8px;}' +
                    '.report-grid{width:100%;border-collapse:collapse;margin-top:8px;font-size:13px;}' +
                    '.report-grid th, .report-grid td{border:1px solid #e6eef6;padding:10px;text-align:left;vertical-align:middle;}' +
                    '.report-grid th{background:#f8fafc;font-weight:700;color:#0f172a;}' +
                    '.report-grid tr:nth-child(even){background:#fbfdff;}' +
                    '.report-grid tr:hover td{background:#f1f5f9;}' +
                    '.report-grid td:nth-child(n+2), .report-grid th:nth-child(n+2){text-align:right;}' +
                    '.print-footer{position:fixed;left:0;right:0;bottom:8px;text-align:center;font-size:12px;color:#6b7280;}' +
                    '.no-print{display:block;margin-top:12px;}' +
                    '@media print{ .no-print{display:none;} .print-footer{position:fixed;bottom:6mm;} }' +
                    '</style>';

                // Build the header with logo and title
                var headerHtml = '<div class="print-header">' +
                    '<div class="print-brand">';

                // Get logo URL from hidden field
                try {
                    var logoHf = document.querySelector('[id$="hfLogoUrl"]');
                    if (logoHf && logoHf.value) {
                        headerHtml += '<img src="' + logoHf.value + '" alt="Glamora Logo" />';
                    }
                } catch (e) { }

                headerHtml += '</div>' +
                    '<div style="text-align:right;">' +
                    '<div class="print-title">Glamora Report</div>' +
                    '<div class="print-sub">Generated: ' + new Date().toLocaleString() + '</div>' +
                    '</div>' +
                    '</div>';

                newWin.document.write('<html><head><title>Report</title>' + cssLink + styles + '</head><body>');
                newWin.document.write(headerHtml);
                newWin.document.write(innerHtml);

                // Footer with generation timestamp and footer text
                var footerText = '';
                try { var hf = document.querySelector('[id$="hfFooterText"]'); if (hf) footerText = hf.value || ''; } catch (e) { footerText = ''; }
                var footerHtml = 'Glamora — Generated: ' + new Date().toLocaleString();
                if (footerText) footerHtml = footerText + ' | ' + footerHtml;
                newWin.document.write('<div class="print-footer">' + footerHtml + '</div>');

                if (!autoPrint) {
                    newWin.document.write('<div class="no-print"><button onclick="window.print();" style="font-weight:700;padding:8px 12px;border-radius:6px;border:1px solid #ccc;background:#fff;cursor:pointer;">Print</button></div>');
                }
                newWin.document.write('</body></html>');
                newWin.document.close();
                newWin.focus();
                if (autoPrint) {
                    setTimeout(function () { newWin.print(); }, 350);
                }
            }

            // PDF export (auto-print)
            function exportPdfClient() {
                var rpt = document.querySelector('[id$="ddlReportType"]');
                var card = null;
                try {
                    if (rpt && rpt.value === 'Appointment') {
                        var ap = document.querySelector('[id$="pnlReportResults"]');
                        if (ap && ap.offsetParent !== null) card = ap;
                    }
                } catch (e) { card = null; }
                if (!card) card = getVisibleReportCard();
                if (!card) { alert('Nothing to export'); return; }

                var title = (rpt && rpt.value) ? rpt.options[rpt.selectedIndex].text : 'Report';

                // Build the content that will be placed under the global header
                var contentHtml = '';

                // Report type and generation info (these are now in the global header, but keep filter summary)
                var filtersHtml = '';
                try { filtersHtml = getFiltersHtml(); } catch (e) { filtersHtml = ''; }
                if (filtersHtml) {
                    contentHtml += '<div style="margin-top:8px;margin-bottom:6px;color:#374151;">';
                    contentHtml += '<strong>Applied filters</strong>';
                    contentHtml += filtersHtml;
                    contentHtml += '</div>';
                } else {
                    contentHtml += '<div style="margin-top:8px;margin-bottom:6px;color:#6b7280;font-style:italic;">No filters applied.</div>';
                }

                var reportHtml = card.outerHTML;
                reportHtml = convertControlsToText(reportHtml);
                contentHtml += reportHtml;

                openPrintable(contentHtml, true);
            }

            // Print (show with Print button)
            function printReport() {
                var rpt = document.querySelector('[id$="ddlReportType"]');
                var card = null;
                try {
                    if (rpt && rpt.value === 'Appointment') {
                        var ap = document.querySelector('[id$="pnlReportResults"]');
                        if (ap && ap.offsetParent !== null) card = ap;
                    } else if (rpt && rpt.value === 'Customer') {
                        var cust = document.querySelector('[id$="pnlCustomerReport"]');
                        if (cust && cust.offsetParent !== null) card = cust;
                    } else if (rpt && rpt.value === 'ServicePerformance') {
                        var serv = document.querySelector('[id$="pnlServicePerf"]');
                        if (serv && serv.offsetParent !== null) card = serv;
                    } else if (rpt && rpt.value === 'EmployeePerformance') {
                        var emp = document.querySelector('[id$="pnlEmployeePerf"]');
                        if (emp && emp.offsetParent !== null) card = emp;
                    } else if (rpt && rpt.value === 'Revenue') {
                        var rev = document.querySelector('[id$="pnlRevenue"]');
                        if (rev && rev.offsetParent !== null) card = rev;
                    }
                } catch (e) { card = null; }
                if (!card) card = getVisibleReportCard();
                if (!card) { alert('No report is available to print. Please select a report type, set your filters, and click Generate.'); return; }

                var contentHtml = '';

                var filtersHtml = '';
                try { filtersHtml = getFiltersHtml(); } catch (e) { filtersHtml = ''; }
                if (filtersHtml) {
                    contentHtml += '<div style="margin-top:8px;margin-bottom:6px;color:#374151;">';
                    contentHtml += '<strong>Applied filters</strong>';
                    contentHtml += filtersHtml;
                    contentHtml += '</div>';
                } else {
                    contentHtml += '<div style="margin-top:8px;margin-bottom:6px;color:#6b7280;font-style:italic;">No filters applied.</div>';
                }

                var reportHtml = card.outerHTML;
                reportHtml = convertControlsToText(reportHtml);
                contentHtml += reportHtml;

                openPrintable(contentHtml, false);
            }

            // Enable/disable buttons based on report type selection
            (function () {
                var ddl = document.querySelector('[id$="ddlReportType"]');
                var content = document.querySelector('.content-area');
                var btnGen = document.querySelector('[id$="btnGenerate"]');
                var btnCsv = document.querySelector('[id$="btnExport"]');
                var btnPdf = document.querySelector('[id$="btnExportPdfClient"]');
                var btnPrint = document.querySelector('[id$="btnPrint"]');
                var pnlReportEl = document.querySelector('[id$="pnlReportResults"]');
                if (!ddl || !content) return;

                function setButtonDisabled(btn, disabled) {
                    try {
                        if (!btn) return;
                        btn.disabled = disabled;
                        if (disabled) btn.classList.add('disabled'); else btn.classList.remove('disabled');
                    } catch (e) { }
                }

                function updateVisibility() {
                    var hasSelection = ddl.value && ddl.value !== '';

                    setButtonDisabled(btnGen, !hasSelection);
                    setButtonDisabled(btnCsv, !hasSelection);
                    setButtonDisabled(btnPdf, !hasSelection);
                    setButtonDisabled(btnPrint, !hasSelection);

                    try {
                        if (pnlReportEl) {
                            var serverVisible = pnlReportEl.getAttribute && pnlReportEl.getAttribute('data-server-visible');
                            if (serverVisible === '1') {
                                pnlReportEl.style.display = '';
                            } else {
                                pnlReportEl.style.display = 'none';
                            }
                        }
                    } catch (e) { }
                }

                updateVisibility();
                ddl.addEventListener('change', updateVisibility);

                if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                    var prm = Sys.WebForms.PageRequestManager.getInstance();
                    prm.add_endRequest(function () {
                        scrollToReportPanel();
                    });
                }
            })();
        </script>
    </form>
</body>
</html>