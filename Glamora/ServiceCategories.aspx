<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ServiceCategories.aspx.cs" Inherits="Glamora.ServiceCategories" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Service Categories</title>
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
            --accent-blue: #3b82f6;
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

        /* --- Sidebar --- */
        .sidebar {
            width: 260px;
            background-color: var(--sidebar-bg);
            color: var(--sidebar-text);
            padding: 0;
            box-shadow: 4px 0 10px rgba(0,0,0,0.05);
            position: fixed;
            top: 0; left: 0;
            height: 100vh;
            overflow-y: auto;
            z-index: 1000;
            display: flex;
            flex-direction: column;
        }

        .sidebar h2 {
            text-align: left; margin: 0; padding: 25px;
            font-size: 1.5rem; font-weight: 800; color: white;
            letter-spacing: -0.5px;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            background: rgba(0,0,0,0.1);
        }

        .nav-list { list-style: none; padding: 20px 15px; margin: 0; flex-grow: 1; }
        .nav-list li { margin-bottom: 5px; }

        .nav-list li a, .nav-list li .asp-link-button {
            display: flex; align-items: center; padding: 12px 15px;
            text-decoration: none; color: var(--sidebar-text);
            font-size: 0.9rem; font-weight: 500; border-radius: var(--radius);
            transition: all 0.2s ease; cursor: pointer; border: none;
            background: none; width: 100%; text-align: left;
            font-family: 'Inter', sans-serif;
        }

        .nav-list li a i, .nav-list li .asp-link-button i {
            margin-right: 12px; width: 20px; text-align: center; font-size: 1.1rem;
        }

        .nav-list li a:hover, .nav-list li .asp-link-button:hover {
            color: white; background-color: rgba(255,255,255,0.05);
        }

        .nav-list li.active > a {
            background-color: var(--primary-color); color: white;
            font-weight: 600; box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }

        .nav-list li.logout {
            margin-top: auto; border-top: 1px solid rgba(255,255,255,0.05); padding-top: 20px;
        }

        .nav-list li.logout .asp-link-button:hover {
            color: var(--accent-red); background: rgba(239, 68, 68, 0.1);
        }

        /* Sub-navigation */
        .sub-nav { list-style: none; padding: 0 0 0 20px; margin: 6px 0 0 0; }
        .sub-nav li a { padding: 8px 15px 8px 32px !important; font-size: 0.85rem !important; color: var(--sidebar-text); opacity: 0.85; }
        .sub-nav li a i { font-size: 0.7rem !important; margin-right: 10px !important; }
        .sub-nav li a:hover { opacity: 1; }
        .sub-nav li.active a {
            background-color: var(--primary-color); color: white; opacity: 1; font-weight: 600;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }

        /* --- Main Content --- */
        .content-area {
            flex-grow: 1; padding: 40px; background-color: var(--bg-body);
            margin-left: 260px; overflow-y: auto;
        }

        .content-header {
            font-size: 1.75rem; font-weight: 700; color: var(--text-dark);
            margin-bottom: 35px; letter-spacing: -0.5px;
            border-bottom: 2px solid #e2e8f0; padding-bottom: 10px;
        }

        .form-container {
            background-color: var(--bg-white); padding: 25px 30px;
            border-radius: var(--radius); box-shadow: var(--shadow);
            max-width: 600px; margin: 0 auto 30px auto;
        }

        .form-group { margin-bottom: 20px; }

        .form-group label {
            display: block; margin-bottom: 5px; font-weight: 600;
            color: var(--text-muted); font-size: 0.85rem;
            text-transform: uppercase; letter-spacing: 0.5px;
        }

        .form-group input[type="text"], .form-group select, .form-group .form-input {
            width: 100%; padding: 12px; border: 1px solid #e2e8f0;
            border-radius: 6px; box-sizing: border-box; font-size: 1em;
            color: var(--text-dark); background-color: #ffffff;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .form-group input[type="text"]:focus, .form-group .form-input:focus {
            border-color: var(--primary-color); outline: none;
            box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.2);
        }

        .btn-submit {
            background-color: var(--primary-color); color: white;
            padding: 12px 25px; border: none; border-radius: 6px;
            cursor: pointer; font-size: 1rem; font-weight: 600;
            transition: background-color 0.3s, box-shadow 0.3s;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .btn-submit:hover {
            background-color: var(--primary-hover);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
        }

        .btn-cancel {
            background: var(--accent-red); color: white;
            padding: 12px 25px; border: none; border-radius: 6px;
            cursor: pointer; font-size: 1rem; font-weight: 600;
            transition: background-color 0.3s, box-shadow 0.3s;
        }

        .btn-cancel:hover { background-color: #dc2626; }

        .error-message { color: var(--accent-red); font-size: 0.85em; margin-top: 5px; display: block; font-weight: 500; }

        .success-message {
            background-color: #d1fae5; color: #065f46; padding: 12px;
            border: 1px solid #a7f3d0; border-radius: 6px;
            margin-bottom: 20px; text-align: center; font-weight: 600;
        }

        .category-id-display {
            display: block; padding: 12px; font-weight: 500;
            color: var(--text-muted); background-color: #f8fafc;
            border: 1px dashed #e2e8f0; border-radius: 6px; font-style: italic;
        }

        /* Grid */
        .categories-grid {
            width: 100%; border-collapse: collapse; margin-top: 25px;
            background: var(--bg-white); border-radius: var(--radius);
            overflow: hidden; box-shadow: var(--shadow);
        }

        .categories-grid th {
            background: var(--bg-body); text-align: left; padding: 15px 20px;
            font-weight: 600; color: var(--text-muted);
            text-transform: uppercase; font-size: 0.85rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .categories-grid td {
            padding: 15px 20px; border-bottom: 1px solid #f8fafc;
            color: var(--text-dark); font-size: 0.95em;
        }

        .categories-grid tr:nth-child(even) { background-color: #fcfcfc; }
        .categories-grid tr:hover { background-color: #f0f4ff; }
        .categories-grid tr:last-child td { border-bottom: none; }

        .action-link {
            background: none; border: none; padding: 5px 8px;
            cursor: pointer; color: var(--primary-color); font-weight: 600;
            text-decoration: none; border-radius: 4px;
            transition: background-color 0.2s; font-size: 0.9rem; display: inline-block;
        }

        .action-divider { color: var(--text-muted); margin: 0 5px; font-size: 0.9rem; }

        .action-link:hover { text-decoration: underline; background-color: rgba(99, 102, 241, 0.1); }
        .action-link.delete { color: var(--accent-red); }
        .action-link.delete:hover { background-color: rgba(239, 68, 68, 0.1); }

        /* Responsive */
        @media (max-width: 1024px) {
            .sidebar { width: 70px; }
            .sidebar h2 { display: none; }
            .nav-list li a span, .nav-list li .asp-link-button span { display: none; }
            .nav-list li a, .nav-list li .asp-link-button { justify-content: center; padding: 15px 0; }
            .nav-list li a i, .nav-list li .asp-link-button i { margin: 0; font-size: 1.25rem; }
            .content-area { margin-left: 70px; padding: 25px; }
            .sub-nav { display: none; }
        }

        @media (max-width: 768px) {
            .dashboard-wrapper { flex-direction: column; }
            .sidebar { position: relative; width: 100%; height: auto; flex-direction: row; overflow-x: auto; padding: 0; }
            .nav-list { display: flex; padding: 10px; }
            .nav-list li { margin: 0 5px; }
            .content-area { margin-left: 0; padding: 20px; }
            .sub-nav { display: none; }
        }

        .sidebar.collapsed { width: 100px; }
        .sidebar.collapsed h2 { display: none; }
        .sidebar.collapsed .nav-list li a span, .sidebar.collapsed .nav-list li .asp-link-button span { display: none; }
        .sidebar.collapsed .nav-list li a, .sidebar.collapsed .nav-list li .asp-link-button { justify-content: center; padding: 15px 0; }
        .sidebar.collapsed .sub-nav { display: none; }
        .content-area.collapsed { margin-left: 100px; }
        .sidebar-toggle {
            position: fixed; top: 22px; left: 268px; width: 36px; height: 36px;
            border-radius: 8px; background: var(--sidebar-bg);
            border: 1px solid rgba(0,0,0,0.06); display: inline-flex;
            align-items: center; justify-content: center;
            box-shadow: 0 6px 18px rgba(15,23,42,0.08); z-index: 1101;
            cursor: pointer; transition: left 0.18s ease, transform 0.18s ease, background 0.18s;
        }
        .sidebar-toggle i { color: #fff; }
        .sidebar.collapsed + .sidebar-toggle { left: 78px; background: var(--bg-white); border: 1px solid rgba(99,102,241,0.12); }
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
                    <li><a href="Services.aspx"><i class="fas fa-magic"></i><span>Services</span></a>
                        <ul class="sub-nav">
                            <li class="active"><a href="ServiceCategories.aspx"><i class="fas fa-th-large"></i><span>Categories</span></a></li>
                        </ul>
                    </li>
                    <li><a href="AppointmentBooking.aspx"><i class="fas fa-calendar-check"></i><span>Appointment Booking</span></a></li>
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
                <h2 class="content-header">Service Categories</h2>

                <div class="form-container">
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="success-message"></asp:Label>

                    <div class="form-group">
                        <label>Category ID</label>
                        <asp:Label ID="lblCategoryID" runat="server" Text="[Auto Generated]" Font-Bold="true" Style="color: var(--primary-color); font-size: 1.1em;"></asp:Label>
                    </div>

                    <div class="form-group">
                        <label for="<%= txtCategoryName.ClientID %>">Category Name</label>
                        <asp:TextBox ID="txtCategoryName" runat="server" CssClass="form-input" MaxLength="100"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvCategoryName" runat="server" ControlToValidate="txtCategoryName"
                            ErrorMessage="Category Name is required." CssClass="error-message" Display="Dynamic" />
                    </div>

                    <div class="form-group" style="display: flex; gap: 10px;">
                        <asp:Button ID="btnSave" runat="server" Text="Save Category" OnClick="btnSave_Click" CssClass="btn-submit" />
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" CssClass="btn-cancel" CausesValidation="false" />
                    </div>
                </div>

                <h2 class="content-header">Category List</h2>

                <div class="table-container">
                    <asp:GridView ID="gvCategories" runat="server" AutoGenerateColumns="False" CssClass="categories-grid"
                        EmptyDataText="No categories found." GridLines="None" DataKeyNames="Category_ID"
                        OnRowCommand="gvCategories_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="Category_ID" HeaderText="Category ID" />
                            <asp:BoundField DataField="Category_Name" HeaderText="Category Name" />
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" CssClass="action-link" CommandName="EditCategory"
                                        CommandArgument='<%# Eval("Category_ID") %>' CausesValidation="false">Edit</asp:LinkButton>
                                    <span class="action-divider">|</span>
                                    <asp:LinkButton ID="lnkDelete" runat="server" CssClass="action-link delete" CommandName="DeleteCategory"
                                        CommandArgument='<%# Eval("Category_ID") %>' CausesValidation="false"
                                        OnClientClick="return confirm('Are you sure you want to delete this category?');">Delete</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
        <script>
            (function () {
                var sidebar = document.querySelector('.sidebar');
                var content = document.querySelector('.content-area');
                var btn = document.getElementById('btnToggleSidebar');
                if (!btn || !sidebar || !content) return;
                function updateTogglePosition() { var rect = sidebar.getBoundingClientRect(); btn.style.left = (rect.right + 8) + 'px'; }
                function updateIcon() { var icon = btn.querySelector('i'); if (!icon) return; var collapsed = sidebar.classList.contains('collapsed'); icon.classList.remove('fa-angle-left', 'fa-angle-right'); icon.classList.add(collapsed ? 'fa-angle-right' : 'fa-angle-left'); btn.setAttribute('aria-expanded', (!collapsed).toString()); }
                updateTogglePosition(); updateIcon();
                btn.addEventListener('click', function () { sidebar.classList.toggle('collapsed'); content.classList.toggle('collapsed'); updateIcon(); setTimeout(updateTogglePosition, 180); });
                window.addEventListener('resize', updateTogglePosition);
                window.addEventListener('scroll', updateTogglePosition);
            })();
        </script>
    </form>
</body>
</html>
