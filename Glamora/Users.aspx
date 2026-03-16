<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Users.aspx.cs" Inherits="Glamora.Users" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Users</title>
    <meta charset="utf-8" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --sidebar-bg: #1e293b;
            --sidebar-text: #94a3b8;
            --sidebar-active: #334155;
            --primary-color: #6366f1;
            --primary-hover: #4f46e5;
            --accent-red: #ef4444;
            --accent-green: #10b981;
            --bg-body: #f1f5f9;
            --bg-white: #ffffff;
            --text-dark: #0f172a;
            --text-muted: #64748b;
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

        .dashboard-wrapper { display: flex; min-height: 100vh; }

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
                margin: 0;
                padding: 25px;
                font-size: 1.5rem;
                font-weight: 800;
                color: white;
                letter-spacing: -0.5px;
                border-bottom: 1px solid rgba(255,255,255,0.05);
                background: rgba(0,0,0,0.1);
            }

        .nav-list { list-style: none; padding: 20px 15px; margin: 0; flex-grow: 1; }
            .nav-list li { margin-bottom: 5px; }
            .nav-list li a, .nav-list li a:visited, .nav-list li a:focus, .nav-list li .asp-link-button {
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
                .nav-list li a i, .nav-list li .asp-link-button i { margin-right: 12px; width: 20px; text-align: center; font-size: 1.1rem; }
                .nav-list li a:hover, .nav-list li .asp-link-button:hover { color: white; background-color: rgba(255,255,255,0.05); }
            .nav-list li.active a { background-color: var(--primary-color); color: white; box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); }
            .nav-list li.logout { margin-top: auto; border-top: 1px solid rgba(255,255,255,0.05); padding-top: 20px; }
                .nav-list li.logout .asp-link-button:hover { color: var(--accent-red); background: rgba(239, 68, 68, 0.1); }

        .content-area { flex-grow: 1; padding: 40px; margin-left: 260px; background-color: var(--bg-body); }
        .content-header { font-size: 1.75rem; font-weight: 700; color: var(--text-dark); margin-bottom: 25px; letter-spacing: -0.5px; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px; }

        .status { font-weight:bold; margin-bottom:15px; display:block; }
        .success { color: var(--accent-green); }
        .error { color: var(--accent-red); }

        .settings-grid {
            width: 100%;
            border-collapse: collapse;
            margin-top: 25px;
            background: var(--bg-white);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow);
        }

            .settings-grid th {
                background: var(--bg-body);
                text-align: left;
                padding: 15px 20px;
                font-weight: 600;
                color: var(--text-muted);
                text-transform: uppercase;
                font-size: 0.85rem;
                border-bottom: 1px solid #e2e8f0;
            }

            .settings-grid td {
                padding: 15px 20px;
                border-bottom: 1px solid #f8fafc;
                color: var(--text-dark);
                font-size: 0.95em;
            }

            .settings-grid tr:nth-child(even) {
                background-color: #fcfcfc;
            }

            .settings-grid tr:hover {
                background-color: #f0f4ff;
            }

            .settings-grid tr:last-child td {
                border-bottom: none;
            }

        /* Action links: no underline */
        .settings-grid .action-link,
        .settings-grid .action-link:visited,
        .settings-grid .action-link:focus,
        .settings-grid .action-link:hover {
            text-decoration: none;
        }

        .action-link { margin-right:8px; padding:6px 10px; border-radius:4px; border:1px solid var(--primary-color); color: var(--primary-color); text-decoration:none; display:inline-block; }
        .action-link:hover { background: var(--primary-color); color:#fff; }

        @media (max-width: 1024px) {
            .sidebar { width: 70px; }
                .sidebar h2 { display: none; }
            .nav-list li a span { display: none; }
            .nav-list li a { justify-content: center; padding: 15px 0; }
                .nav-list li a i { margin: 0; font-size: 1.25rem; }
            .content-area { margin-left: 70px; padding: 25px; }
        }

        @media (max-width: 768px) {
            .dashboard-wrapper { flex-direction: column; }
            .sidebar { position: relative; width: 100%; height: auto; flex-direction: row; overflow-x: auto; padding: 0; }
            .nav-list { display: flex; padding: 10px; }
                .nav-list li { margin: 0 5px; }
            .content-area { margin-left: 0; padding: 20px; }
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
        .sidebar.collapsed + .sidebar-toggle { left: 118px; background: var(--bg-white); border: 1px solid rgba(99,102,241,0.12); }
        .sidebar.collapsed + .sidebar-toggle i { color: var(--primary-color); }
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
                    <li><a href="AppointmentsList.aspx"><i class="fas fa-clipboard-list"></i><span>Appointment List</span></a></li>
                    <li><a href="Invoice.aspx"><i class="fas fa-file-invoice"></i><span>Invoice</span></a></li>
                    <li><a href="Employees.aspx"><i class="fas fa-user-tie"></i><span>Employees</span></a></li>
                    <li><a href="Customers.aspx"><i class="fas fa-users"></i><span>Customers</span></a></li>
                    <li class="active"><a href="Users.aspx"><i class="fas fa-shield-alt"></i><span>Users</span></a></li>
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
                <h1 class="content-header">Admin Registration Requests</h1>
                <asp:Label ID="lblMessage" runat="server" CssClass="status"></asp:Label>
                <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" CssClass="settings-grid" DataKeyNames="UserId" OnRowCommand="gvUsers_RowCommand" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="DisplayId" HeaderText="UserID" />
                        <asp:BoundField DataField="Email" HeaderText="Email" />
                        <asp:BoundField DataField="FullName" HeaderText="Name" />
                        <asp:BoundField DataField="Role" HeaderText="Role" />
                        <asp:BoundField DataField="PasswordHash" HeaderText="Password Hash" />
                        <asp:BoundField DataField="Status" HeaderText="Status" />
                        <asp:CheckBoxField DataField="EmailVerified" HeaderText="Verified" />
                        <asp:BoundField DataField="CreatedAt" HeaderText="Created" DataFormatString="{0:d}" />
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:CheckBox ID="chkActive" runat="server" AutoPostBack="True" OnCheckedChanged="chkActive_CheckedChanged" Checked='<%# Eval("IsActive") %>' Enabled='<%# Eval("CanToggle") %>' Text="Active" />
                                <br />
                                <asp:LinkButton ID="btnRemove" runat="server" CssClass="action-link" CommandName="Remove" CommandArgument='<%# Eval("UserId") %>' Text="Remove" Visible='<%# Eval("CanDelete") %>' OnClientClick="return confirm('Are you sure you want to delete this user?');" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
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
</body>
</html>
