<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Customers.aspx.cs" Inherits="Glamora.Customers" %>

<%@ Import Namespace="System.Web" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Customers</title>
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

        /* --- Customer Form Styles --- */
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
        }

            .form-group label {
                display: block;
                margin-bottom: 5px;
                font-weight: 600;
                color: var(--text-muted);
                font-size: 0.85rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .form-group input[type="text"], .form-group select {
                width: 100%;
                padding: 10px;
                border: 1px solid #cbd5e1;
                border-radius: 6px;
                box-sizing: border-box;
                font-size: 1rem;
                color: var(--text-dark);
                transition: border-color 0.2s;
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

        /* Customer ID label styling */
        .form-group label + .asp-label {
            display: block;
            margin-top: 10px;
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--primary-color);
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

        /* Phone input group (prefix + textbox) */
        .phone-input {
            display: flex;
            align-items: center;
            gap: 0;
        }

        .phone-prefix {
            display: inline-block;
            background: #e2e8f0;
            color: var(--text-muted);
            padding: 10px 12px;
            border: 1px solid #cbd5e1;
            border-right: none;
            border-top-left-radius: 6px;
            border-bottom-left-radius: 6px;
            font-weight: 600;
        }

        .phone-textbox {
            flex: 1;
            border-left: none !important;
            border-top-left-radius: 0 !important;
            border-bottom-left-radius: 0 !important;
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

        
        /* Employee Grid styles (Using standard GridView structure) */
        .customers-grid {
            width: 100%;
            border-collapse: collapse;
            margin-top: 25px;
            background: var(--bg-white);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow);
        }

            .customers-grid th {
                background: var(--bg-body); /* Light grey header */
                text-align: left;
                padding: 15px 20px;
                font-weight: 600;
                color: var(--text-muted);
                text-transform: uppercase;
                font-size: 0.85rem;
                border-bottom: 1px solid #e2e8f0;
            }

            .customers-grid td {
                padding: 15px 20px;
                border-bottom: 1px solid #f8fafc; /* Very light separator */
                color: var(--text-dark);
                font-size: 0.95em;
            }

            .customers-grid tr:nth-child(even) {
                background-color: #fcfcfc;
            }

            .customers-grid tr:hover {
                background-color: #f0f4ff; /* Light hover effect */
            }

            .customers-grid tr:last-child td {
                border-bottom: none;
            }

        /* Action Links */
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
        }

        /* Spacing for pipe divider */
        .action-divider {
            color: white;
            margin: 0 8px;
            font-size: 0.9rem;
            vertical-align: middle;
            padding: 5px 0;
        }

        .action-link:hover {
            text-decoration: underline;
            background-color: rgba(99, 102, 241, 0.1);
        }

        .action-link.delete {
            color: var(--accent-red);
        }

            .action-link.delete:hover {
                background-color: rgba(239, 68, 68, 0.1);
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

            /* Hide the ID in mobile for better column spacing */
            .customers-grid th:first-child, .customers-grid td:first-child {
                display: none;
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
                    <li><a href="Employees.aspx"><i class="fas fa-user-tie"></i><span>Employees</span></a></li>
                    <li class="active"><a href="Customers.aspx"><i class="fas fa-users"></i><span>Customers</span></a></li>
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
                <h1 class="content-header">Manage Customers</h1>

                <div class="form-container">
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="success-message"></asp:Label>

                    <div class="form-group">
                        <label>Customer ID</label>
                        <asp:Label ID="lblCustomerID" runat="server" Text="[Auto Generated]" CssClass="asp-label"></asp:Label>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 0 0 20%;">
                            <asp:Label ID="lblTitle" runat="server" AssociatedControlID="ddlTitle" Text="Title"></asp:Label>
                            <asp:DropDownList ID="ddlTitle" runat="server">
                                <asp:ListItem Text="Mr." Value="Mr"></asp:ListItem>
                                <asp:ListItem Text="Mrs." Value="Mrs"></asp:ListItem>
                                <asp:ListItem Text="Miss" Value="Miss"></asp:ListItem>
                                <asp:ListItem Text="Ms." Value="Ms"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="form-group" style="flex: 1;">
                            <asp:Label ID="lblFirstName" runat="server" AssociatedControlID="txtFirstName" Text="First Name"></asp:Label>
                            <asp:TextBox ID="txtFirstName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName" ErrorMessage="First Name is required." CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>

                        <div class="form-group" style="flex: 1;">
                            <asp:Label ID="lblLastName" runat="server" AssociatedControlID="txtLastName" Text="Last Name"></asp:Label>
                            <asp:TextBox ID="txtLastName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName" ErrorMessage="Last Name is required." CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label>Contact (Phone No.)</label>
                            <div class="phone-input">
                                <span class="phone-prefix">+94</span>
                                <asp:TextBox ID="txtContactLocal" runat="server" CssClass="phone-textbox" Placeholder="XXXXXXXXX"></asp:TextBox>
                            </div>
                            <asp:RequiredFieldValidator ID="rfvContactLocal" runat="server" ControlToValidate="txtContactLocal" ErrorMessage="Contact is required." CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="revContactLocal" runat="server" ControlToValidate="txtContactLocal"
                                ValidationExpression="^(?:0\d{9}|\d{9})$"
                                ErrorMessage="Enter a valid local number (9 digits or leading 0 + 9 digits)." CssClass="error-message" Display="Dynamic"></asp:RegularExpressionValidator>
                        </div>

                        <div class="form-group" style="flex: 1;">
                            <asp:Label ID="lblCity" runat="server" AssociatedControlID="txtCity" Text="City"></asp:Label>
                            <asp:TextBox ID="txtCity" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvCity" runat="server" ControlToValidate="txtCity" ErrorMessage="City is required." CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="form-group" style="display: flex; gap: 10px;">
                        <asp:Button ID="btnSave" runat="server" Text="Save Customer" OnClick="btnSave_Click" CssClass="btn-submit" />
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" CssClass="btn-cancel" />
                    </div>
                </div>

                <h2 class="content-header">Registered Customers</h2>
                <div class="table-container">
                    <asp:GridView ID="gvCustomers" runat="server" AutoGenerateColumns="false" CssClass="customers-grid" EmptyDataText="No customers found." GridLines="None"
                        DataKeyNames="Cus_ID" OnRowCommand="gvCustomers_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="Cus_ID" HeaderText="Customer ID" />
                            <asp:BoundField DataField="Title" HeaderText="Title" />
                            <asp:BoundField DataField="CusFirst_Name" HeaderText="First Name" />
                            <asp:BoundField DataField="CusLast_Name" HeaderText="Last Name" />
                            <asp:BoundField DataField="Contact" HeaderText="Contact" />
                            <asp:BoundField DataField="City" HeaderText="City" />
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" CssClass="action-link" CommandName="EditCustomer"
                                        CommandArgument='<%# Eval("Cus_ID") %>' CausesValidation="false">Edit</asp:LinkButton>
                                    <span class="action-divider">|</span>
                                    <asp:LinkButton ID="lnkDelete" runat="server" CssClass="action-link delete" CommandName="DeleteCustomer"
                                        CommandArgument='<%# Eval("Cus_ID") %>' CausesValidation="false"
                                        OnClientClick="return confirm('Are you sure you want to delete this customer?');">Delete</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

            </div>
        </div>
    </form>

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
    </script>

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
