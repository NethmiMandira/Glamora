<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Employees.aspx.cs" Inherits="Glamora.Employees" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Employees</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        /* --- Color Palette & Variables (Copied from Dashboard) --- */
        :root {
            /* OPTION: Modern Indigo & Slate Theme */
            --sidebar-bg: #1e293b; /* Dark Slate */
            --sidebar-text: #94a3b8; /* Muted Grey text */
            --sidebar-active: #334155; /* Lighter Slate for active state */

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

        /* --- Base Reset and Layout --- */
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

        /* --- Sidebar styles --- */
        .sidebar {
            width: 260px; /* Aligned with dashboard */
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

                    .nav-list li a i, .nav-item-icon { /* Added Font Awesome icons for better visual */
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

        /* --- Main Content Area --- */
        .content-area {
            flex-grow: 1;
            padding: 40px; /* Aligned with dashboard */
            background-color: var(--bg-body);
            margin-left: 260px; /* Aligned with dashboard sidebar width */
            overflow-y: auto;
        }

        .content-header {
            font-size: 1.75rem; /* Aligned with dashboard */
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 35px;
            letter-spacing: -0.5px;
            border-bottom: 2px solid #e2e8f0; /* Lighter separator */
            padding-bottom: 10px;
        }

        /* --- Employee Form Styles --- */
        .form-container {
            background-color: var(--bg-white);
            padding: 30px; /* Slightly more padding */
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            max-width: 900px; /* Adjusted max width */
            margin: 0 auto 40px auto;
            border: 1px solid rgba(0,0,0,0.05);
        }

        .form-group {
            margin-bottom: 20px;
        }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                font-weight: 600;
                color: var(--text-muted); /* Slate Grey for labels */
                font-size: 0.9rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .form-group input[type="text"], .form-group select {
                width: 100%;
                padding: 12px;
                border: 1px solid #cbd5e1; /* Light slate border */
                border-radius: 6px;
                box-sizing: border-box;
                font-size: 1em;
                color: var(--text-dark);
                background-color: #ffffff;
                transition: border-color 0.2s, box-shadow 0.2s;
            }

                .form-group input[type="text"]:focus, .form-group select:focus {
                    border-color: var(--primary-color);
                    outline: none;
                    box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.2);
                }

        .form-row {
            display: flex;
            gap: 20px;
        }

            .form-row > .form-group {
                flex: 1;
            }

        .btn-submit {
            background-color: var(--primary-color);
            color: white;
            padding: 12px 25px;
            border: none;
            border-radius: var(--radius);
            cursor: pointer;
            font-size: 1em;
            font-weight: 600;
            transition: background-color 0.3s, box-shadow 0.3s;
            box-shadow: var(--shadow);
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
            border-radius: var(--radius);
            cursor: pointer;
            font-size: 1em;
            font-weight: 600;
            transition: background-color 0.3s, box-shadow 0.3s;
            box-shadow: var(--shadow);
        }

            .btn-cancel:hover {
                background-color: #dc2626; /* Darker red */
                box-shadow: 0 6px 10px rgba(239, 68, 68, 0.4);
            }

        /* Phone input group (prefix + textbox) */
        .phone-input {
            display: flex;
            align-items: stretch; /* Stretch to fill group height */
            gap: 0;
            width: 100%;
        }

        .phone-prefix {
            display: flex;
            align-items: center;
            background: #e2e8f0; /* Lighter background */
            color: var(--text-muted);
            padding: 0 12px;
            border: 1px solid #cbd5e1;
            border-right: none;
            border-top-left-radius: 6px;
            border-bottom-left-radius: 6px;
            font-weight: 500;
        }

        .phone-textbox {
            flex: 1;
            padding: 12px;
            border: 1px solid #cbd5e1;
            border-top-right-radius: 6px;
            border-bottom-right-radius: 6px;
            border-left: none;
            font-size: 1em;
            box-sizing: border-box;
            color: var(--text-dark);
        }

        /* Validation and Message Styles */
        .error-message {
            color: var(--accent-red);
            font-size: 0.85em;
            margin-top: 5px;
            display: block;
        }

        .success-message {
            background-color: #ecfdf5; /* Light green/teal */
            color: var(--accent-green);
            padding: 15px;
            border: 1px solid #a7f3d0;
            border-radius: 6px;
            margin-bottom: 25px;
            text-align: center;
            font-weight: 500;
        }

        /* Employee Grid styles (Using standard GridView structure) */
        .employees-grid {
            width: 100%;
            border-collapse: collapse;
            margin-top: 25px;
            background: var(--bg-white);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow);
        }

            .employees-grid th {
                background: var(--bg-body); /* Light grey header */
                text-align: left;
                padding: 15px 20px;
                font-weight: 600;
                color: var(--text-muted);
                text-transform: uppercase;
                font-size: 0.85rem;
                border-bottom: 1px solid #e2e8f0;
            }

            .employees-grid td {
                padding: 15px 20px;
                border-bottom: 1px solid #f8fafc; /* Very light separator */
                color: var(--text-dark);
                font-size: 0.95em;
            }

            .employees-grid tr:nth-child(even) {
                background-color: #fcfcfc;
            }

            .employees-grid tr:hover {
                background-color: #f0f4ff; /* Light hover effect */
            }

            .employees-grid tr:last-child td {
                border-bottom: none;
            }

        .action-link {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
            transition: color 0.2s;
        }

            .action-link:hover {
                color: var(--primary-hover);
                text-decoration: underline;
            }

        /* Checkbox list for services */
        .services-checkbox-container {
            max-height: 220px;
            overflow-y: auto;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            padding: 10px 14px;
            background: #f8fafc;
        }

        .checkbox-list label {
            display: flex !important;
            align-items: center;
            padding: 6px 0;
            font-weight: 400 !important;
            font-size: 0.95rem !important;
            color: var(--text-dark) !important;
            text-transform: none !important;
            letter-spacing: 0 !important;
            cursor: pointer;
        }

        .checkbox-list input[type="checkbox"] {
            margin-right: 10px;
            accent-color: var(--primary-color);
            width: 16px;
            height: 16px;
        }

        /* Responsive adjustments for consistency */
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

            .form-row {
                flex-direction: column;
                gap: 0;
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
                    <li class="active"><a href="Employees.aspx"><i class="fas fa-user-tie"></i><span>Employees</span></a></li>
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
                <h1 class="content-header">Manage Employees</h1>

                <div class="form-container">
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="success-message"></asp:Label>

                    <div class="form-group">
                        <label>Employee ID</label>
                        <asp:Label ID="lblEmployeeID" runat="server" Text="[Auto Generated]" Font-Bold="true" Style="color: var(--primary-color); font-size: 1.1em;"></asp:Label>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 0 0 20%;">
                            <label for="<%= ddlTitle.ClientID %>">Title</label>
                            <asp:DropDownList ID="ddlTitle" runat="server">
                                <asp:ListItem Text="Mr." Value="Mr"></asp:ListItem>
                                <asp:ListItem Text="Mrs." Value="Mrs"></asp:ListItem>
                                <asp:ListItem Text="Miss" Value="Miss"></asp:ListItem>
                                <asp:ListItem Text="Ms." Value="Ms"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="form-group" style="flex: 1;">
                            <label for="<%= txtFirstName.ClientID %>">First Name</label>
                            <asp:TextBox ID="txtFirstName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName" ErrorMessage="First Name is required." CssClass="error-message" Display="Dynamic" ValidationGroup="SaveEmployee"></asp:RequiredFieldValidator>
                        </div>

                        <div class="form-group" style="flex: 1;">
                            <label for="<%= txtLastName.ClientID %>">Last Name</label>
                            <asp:TextBox ID="txtLastName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName" ErrorMessage="Last Name is required." CssClass="error-message" Display="Dynamic" ValidationGroup="SaveEmployee"></asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label>Contact (Phone No.)</label>
                            <div class="phone-input">
                                <span class="phone-prefix">+94</span>
                                <asp:TextBox ID="txtContactLocal" runat="server" CssClass="phone-textbox" Placeholder="XXXXXXXXX"></asp:TextBox>
                            </div>
                            <asp:RequiredFieldValidator ID="rfvContactLocal" runat="server" ControlToValidate="txtContactLocal" ErrorMessage="Contact is required." CssClass="error-message" Display="Dynamic" ValidationGroup="SaveEmployee"></asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="revContactLocal" runat="server" ControlToValidate="txtContactLocal"
                                ValidationExpression="^(?:0\d{9}|\d{9})$"
                                ErrorMessage="Enter a valid local number (9 digits or leading 0 + 9 digits)." CssClass="error-message" Display="Dynamic" ValidationGroup="SaveEmployee"></asp:RegularExpressionValidator>
                        </div>

                        <div class="form-group" style="flex: 1;">
                            <label for="<%= txtRole.ClientID %>">Role</label>
                            <asp:TextBox ID="txtRole" runat="server" Placeholder="e.g., Hair Stylist, Manager, etc."></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvRole" runat="server" ControlToValidate="txtRole" ErrorMessage="Role is required." CssClass="error-message" Display="Dynamic" ValidationGroup="SaveEmployee"></asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="<%= ddlCategory.ClientID %>">Select Category</label>
                        <asp:DropDownList ID="ddlCategory" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>

                    <div class="form-group">
                        <label>Assigned Services</label>
                        <div class="services-checkbox-container">
                            <asp:Label ID="lblServiceHint" runat="server" Text="Please select a category to view available services." 
                                Style="color: var(--text-muted); font-style: italic; font-size: 0.9rem; padding: 10px 0; display: block;"></asp:Label>
                            <asp:CheckBoxList ID="cblServices" runat="server" RepeatDirection="Vertical" RepeatLayout="Flow" CssClass="checkbox-list"></asp:CheckBoxList>
                        </div>
                    </div>

                    <div class="form-group" style="display: flex; gap: 10px;">
                        <asp:Button ID="btnSave" runat="server" Text="Save Employee" OnClick="btnSave_Click" CssClass="btn-submit" ValidationGroup="SaveEmployee" />
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" CssClass="btn-cancel" CausesValidation="false"/>
                    </div>
                </div>

                <h2 class="content-header">Registered Employees</h2>
                <div class="table-container">
                    <asp:GridView ID="gvEmployees" runat="server" AutoGenerateColumns="false" CssClass="employees-grid" EmptyDataText="No employees found in the system." GridLines="None"
                        DataKeyNames="Emp_ID" OnRowCommand="gvEmployees_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="Emp_ID" HeaderText="Employee ID" />
                            <asp:BoundField DataField="Title" HeaderText="Title" />
                            <asp:BoundField DataField="EmpFirst_Name" HeaderText="First Name" />
                            <asp:BoundField DataField="EmpLast_Name" HeaderText="Last Name" />
                            <asp:BoundField DataField="Contact" HeaderText="Contact" />
                            <asp:BoundField DataField="Role" HeaderText="Role" />
                            <asp:BoundField DataField="Services" HeaderText="Services" />
                            <asp:TemplateField HeaderText="Actions" ItemStyle-Width="150px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditEmployee" CommandArgument='<%# Eval("Emp_ID") %>' CssClass="action-link" CausesValidation="false">Edit</asp:LinkButton>
                                    &nbsp;|&nbsp;
                                    <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteEmployee" CommandArgument='<%# Eval("Emp_ID") %>' CssClass="action-link" CausesValidation="false" OnClientClick="return confirm('Are you sure you want to delete this employee?');" Style="color: var(--accent-red);">Delete</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

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
