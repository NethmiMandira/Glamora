<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewAllInvoices.aspx.cs" Inherits="Glamora.ViewAllInvoices" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | All Invoices</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --sidebar-bg: #1e293b;
            --sidebar-text: #94a3b8;
            --primary-color: #6366f1;
            --primary-hover: #4f46e5;
            --primary-light-bg: #e0e7ff;
            --accent-red: #ef4444;
            --accent-green: #10b981;
            --bg-body: #f1f5f9;
            --bg-white: #ffffff;
            --text-dark: #0f172a;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --radius: 10px;
        }

        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            background: var(--bg-body);
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

        .nav-list .submenu li.active a {
            background-color: var(--primary-color);
            color: white;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }

        .submenu-icon {
            margin-left: auto;
            transition: transform 0.2s;
            font-size: 0.8rem;
        }

        .has-submenu.expanded .submenu-icon {
            transform: rotate(180deg);
        }

        .content-area {
            flex-grow: 1;
            padding: 40px;
            margin-left: 260px;
            background-color: var(--bg-body);
        }

        .page {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px 40px 20px;
        }

        .header {
            font-size: 1.75rem;
            font-weight: 800;
            margin: 10px 0 20px 0;
            letter-spacing: -0.5px;
            color: var(--text-dark);
        }

        .invoice-cards {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
        }

        .invoice-card {
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 20px;
            position: relative;
            display: flex;
            flex-direction: column;
        }

        .invoice-card h3 {
            margin-top: 0;
            color: var(--primary-color);
        }

        .invoice-card p {
            margin: 5px 0;
        }

        .delete-btn {
            position: absolute;
            top: 10px;
            right: 10px;
            background: var(--accent-red);
            color: white;
            border: none;
            border-radius: 4px;
            padding: 5px 10px;
            cursor: pointer;
            font-weight: 600;
        }

        .delete-btn:hover {
            background: #dc2626;
        }

        .services {
            margin-top: 15px;
            border-top: 1px solid var(--border-color);
            padding-top: 10px;
        }

        .services h4 {
            margin-bottom: 10px;
            color: var(--text-dark);
        }

        .service-item {
            background: var(--primary-light-bg);
            padding: 10px;
            margin-bottom: 5px;
            border-radius: 4px;
        }

        .service-item p {
            margin: 2px 0;
            font-size: 0.9em;
        }

        .no-invoices {
            background: #fff;
            border: 1px dashed var(--border-color);
            color: var(--text-muted);
            padding: 25px;
            text-align: center;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
        }

        .error {
            color: var(--accent-red);
            text-align: center;
            font-size: 1.1em;
            margin: 20px 0;
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
                    <li><a href="Services.aspx"><i class="fas fa-magic"></i><span>Services</span></a></li>
                    <li><a href="AppointmentBooking.aspx"><i class="fas fa-calendar-check"></i><span>Appointment Booking</span></a></li>
                    <li><a href="AppointmentsList.aspx"><i class="fas fa-clipboard-list"></i><span>Appointment List</span></a></li>
                    <li class="has-submenu expanded" id="liInvoices" runat="server">
                        <a href="Invoice.aspx"><i class="fas fa-file-invoice"></i><span>Invoice</span></a>
                        <ul class="submenu">
                            <li class="active"><a href="ViewAllInvoices.aspx"><span>View All Invoices</span></a></li>
                        </ul>
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

            <div class="content-area">
                <div class="page">
                    <h1 class="header">All Invoices</h1>
                    <asp:Label ID="lblError" runat="server" CssClass="error" Visible="false"></asp:Label>
                    <asp:Label ID="lblNoInvoices" runat="server" Text="No invoices found." Visible="false" CssClass="no-invoices"></asp:Label>
                    <div class="invoice-cards">
                        <asp:Repeater ID="rptInvoices" runat="server" OnItemCommand="rptInvoices_ItemCommand">
                            <ItemTemplate>
                                <div class="invoice-card">
                                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CommandName="Delete" CommandArgument='<%# Eval("InvoiceID") %>' CssClass="delete-btn" OnClientClick="return confirm('Are you sure you want to delete this invoice?');" />
                                    <h3>Invoice ID: <%# Eval("InvoiceID") %></h3>
                                    <p><strong>Date:</strong> <%# Eval("InvoiceDate", "{0:yyyy-MM-dd}") %></p>
                                    <p><strong>Customer:</strong> <%# Eval("CustomerName") %></p>
                                    <p><strong>Employee:</strong> <%# Eval("EmployeeName") %></p>
                                    <p><strong>Total Amount:</strong> Rs. <%# Eval("TotalAmount", "{0:N2}") %></p>
                                    <p><strong>Net Value:</strong> Rs. <%# Eval("NetValue", "{0:N2}") %></p>
                                    <p><strong>Payment Method:</strong> <%# Eval("PaymentMethod") %></p>
                                    <p><strong>Bill No:</strong> <%# Eval("BillNo") %></p>
                                    <p><strong>Appointment ID:</strong> <%# Eval("AppID") %></p>
                                    <p><strong>Advance Amount:</strong> Rs. <%# Eval("AdvanceAmount", "{0:N2}") %></p>
                                    <p><strong>Balance:</strong> Rs. <%# Eval("Balance", "{0:N2}") %></p>
                                    <div class="services">
                                        <h4>Services:</h4>
                                        <asp:Repeater ID="rptServices" runat="server" DataSource='<%# Eval("Services") %>'>
                                            <ItemTemplate>
                                                <div class="service-item">
                                                    <p><strong>Name:</strong> <%# Eval("Service_Name") %></p>
                                                    <p><strong>Price:</strong> Rs. <%# Eval("Price", "{0:N2}") %></p>
                                                    <p><strong>Discount:</strong> <%# Eval("Discount", "{0:N2}") %>% (Rs. <%# Eval("DiscountValue", "{0:N2}") %>)</p>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        function toggleSubmenu(element) {
            var li = element.parentElement;
            var submenu = li.querySelector('.submenu');
            if (submenu.style.display === 'none' || submenu.style.display === '') {
                submenu.style.display = 'block';
            } else {
                submenu.style.display = 'none';
            }
        }
    </script>

</body>
</html>
