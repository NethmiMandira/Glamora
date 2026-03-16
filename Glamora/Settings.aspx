<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="Glamora.Settings" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Settings</title>
    <meta charset="utf-8" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        /* --- Color Palette & Variables --- */
        :root {
            /* OPTION: Modern Indigo & Slate Theme */
            --sidebar-bg: #1e293b; /* Dark Slate */
            --sidebar-text: #94a3b8; /* Muted Grey text */
            --sidebar-active: #334155;
            --primary-color: #6366f1; /* Indigo */
            --primary-hover: #4f46e5; /* Darker Indigo */

            --accent-red: #ef4444; /* Modern Red */
            --accent-green: #10b981; /* Emerald Green */
            --accent-blue: #3b82f6; /* Bright Blue */

            --bg-body: #f1f5f9; /* Very light cool grey */
            --bg-white: #ffffff;
            --text-dark: #0f172a; /* Almost Black */
            --text-muted: #64748b; /* Slate Grey */

            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --radius: 8px; /* Slightly tighter corners */
        }

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

                    .nav-list li a i, .nav-list li .asp-link-button i {
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

                    .nav-list li.logout .asp-link-button {
                        margin-top: 0;
                    }

                        .nav-list li.logout .asp-link-button:hover {
                            color: var(--accent-red);
                            background: rgba(239, 68, 68, 0.1);
                        }

        /* --- Content --- */
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
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 10px;
        }

        /* --- Settings Form Styles --- */
        .form-container {
            background-color: var(--bg-white);
            padding: 25px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            max-width: 900px;
            margin: 0 auto 40px auto;
        }

        .form-group {
            margin-bottom: 15px;
            display: flex;
            align-items: center;
        }

            .form-group label {
                display: block;
                margin-bottom: 0;
                font-weight: 600;
                color: var(--text-muted);
                font-size: 0.85rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                width: 150px;
                flex-shrink: 0;
            }

            .form-group input[type="text"], .form-group textarea, .form-group input[type="file"] {
                flex: 1;
                padding: 10px;
                border: 1px solid #cbd5e1;
                border-radius: 6px;
                box-sizing: border-box;
                font-size: 1rem;
                color: var(--text-dark);
                transition: border-color 0.2s;
            }

                .form-group input[type="text"]:focus, .form-group textarea:focus, .form-group input[type="file"]:focus {
                    border-color: var(--primary-color);
                    outline: none;
                    box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.2);
                }

        .current-logo {
            max-width: 200px;
            max-height: 100px;
            margin-bottom: 10px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
        }

        /* Validation and Message Styles */
        .error-message {
            color: var(--accent-red);
            font-size: 0.85rem;
            margin-top: 5px;
            display: block;
            font-weight: 500;
        }

        .success-message {
            background-color: #d1fae5;
            color: var(--accent-green);
            padding: 12px;
            border: 1px solid #a7f3d0;
            border-radius: 6px;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 600;
        }

        .btn-submit {
            background-color: var(--primary-color);
            color: white;
            padding: 12px 25px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: background-color 0.3s, box-shadow 0.3s;
            box-shadow: 0 4px 8px rgba(99, 102, 241, 0.3);
        }

            .btn-submit:hover {
                background-color: var(--primary-hover);
                box-shadow: 0 6px 10px rgba(99, 102, 241, 0.4);
            }

        .btn-cancel {
            background-color: var(--accent-red);
            color: white;
            padding: 12px 25px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: background-color 0.3s, box-shadow 0.3s;
            box-shadow: 0 4px 8px rgba(239, 68, 68, 0.3);
        }

            .btn-cancel:hover {
                background-color: #dc2626;
                box-shadow: 0 6px 10px rgba(239, 68, 68, 0.4);
            }

        /* --- Responsive --- */
        @media (max-width: 1024px) {
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

            .form-row {
                flex-direction: column;
                gap: 0;
            }
        }

        .current-logo {
            max-width: 200px;
            max-height: 100px;
            margin-bottom: 10px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
        }

        /* Current Settings Horizontal Layout */
        .current-settings {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            margin-top: 25px;
            background: var(--bg-white);
            padding: 20px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            border: 1px solid #e2e8f0;
            overflow-x: auto;
            max-width: 900px;
            margin-left: auto;
            margin-right: auto;
        }



        /* Employee Grid styles (Using standard GridView structure) */
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
                background: var(--bg-body); /* Light grey header */
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
                border-bottom: 1px solid #f8fafc; /* Very light separator */
                color: var(--text-dark);
                font-size: 0.95em;
            }

            .settings-grid tr:nth-child(even) {
                background-color: #fcfcfc;
            }

            .settings-grid tr:hover {
                background-color: #f0f4ff; /* Light hover effect */
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
                    <li><a href="Users.aspx"><i class="fas fa-shield-alt"></i><span>Users</span></a></li>
                    <li class="active"><a href="Settings.aspx"><i class="fas fa-sliders-h"></i><span>Settings</span></a></li>
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
                <h1 class="content-header">Settings</h1>

                <div class="form-container">
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="success-message"></asp:Label>

                    <div class="form-group">
                        <asp:Label ID="lblLogoURL" runat="server" AssociatedControlID="fuLogo" Text="Logo"></asp:Label>
                        <asp:Image ID="imgCurrentLogo" runat="server" CssClass="current-logo" Visible="false" />
                        <asp:FileUpload ID="fuLogo" runat="server" />
                    </div>

                    <div class="form-group">
                        <asp:Label ID="lblAddress" runat="server" AssociatedControlID="txtAddress" Text="Address"></asp:Label>
                        <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <asp:Label ID="lblTelephone" runat="server" AssociatedControlID="txtTelephone" Text="Telephone"></asp:Label>
                            <asp:TextBox ID="txtTelephone" runat="server"></asp:TextBox>
                        </div>

                        <div class="form-group">
                            <asp:Label ID="lblFooterText" runat="server" AssociatedControlID="txtFooterText" Text="Footer Text"></asp:Label>
                            <asp:TextBox ID="txtFooterText" runat="server"></asp:TextBox>
                        </div>
                    </div>

                    <div class="form-group" style="display: flex; gap: 10px;">
                        <asp:Button ID="btnSave" runat="server" Text="Save Settings" OnClick="btnSave_Click" CssClass="btn-submit" />
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" CssClass="btn-cancel" />
                    </div>
                </div>

                <h2 class="content-header">Current Settings</h2>
                
                    <asp:GridView ID="gvSettings" runat="server" AutoGenerateColumns="false" CssClass="settings-grid" EmptyDataText="No settings found in the system." GridLines="None" OnRowCommand="gvSettings_RowCommand" AllowPaging="true" PageSize="5" OnPageIndexChanging="gvSettings_PageIndexChanging" AllowSorting="true" OnSorting="gvSettings_Sorting">
                        <Columns>
                            <asp:BoundField DataField="DisplaySettingID" HeaderText="Setting ID"  />
                            <asp:TemplateField HeaderText="Logo" >
                                <ItemTemplate>
                                    <asp:Image ID="imgLogo" runat="server" ImageUrl='<%# Eval("LogoURL") %>' Width="50px" Height="50px" AlternateText="No Logo" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Address" HeaderText="Address" />
                            <asp:BoundField DataField="Telephone" HeaderText="Telephone" />
                            <asp:BoundField DataField="FooterText" HeaderText="Footer Text" />
                            <asp:TemplateField HeaderText="Actions" HeaderStyle-Width="180px" ItemStyle-Width="180px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditSetting" CommandArgument='<%# Eval("SettingID") %>' CssClass="action-link" CausesValidation="false">Edit</asp:LinkButton>
                                    &nbsp;|&nbsp;
                                    <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteSetting" CommandArgument='<%# Eval("SettingID") %>' CssClass="action-link" CausesValidation="false" OnClientClick="return confirm('Are you sure you want to delete this settings?');" Style="color: var(--accent-red);">Delete</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                
            </div>
        </div>
    </form>
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
</body>
</html>
