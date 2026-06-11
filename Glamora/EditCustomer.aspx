<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditCustomer.aspx.cs" Inherits="Glamora.EditCustomer" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Edit Customer</title>
    <meta charset="utf-8" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        /* --- Color Palette & Variables (Matching Dashboard Theme) --- */
        :root {
            /* OPTION: Modern Indigo & Slate Theme */
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
            --radius: 8px;
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
            justify-content: center;
            align-items: flex-start;
            padding: 50px 20px;
            box-sizing: border-box;
        }

        .content-area {
            flex-basis: 100%;
            max-width: 900px;
            padding: 0 10px;
            margin: 0 auto;
        }

        .content-header {
            color: var(--text-dark);
            margin-bottom: 25px;
            border-bottom: 3px solid var(--primary-color); /* Indigo underbar */
            padding-bottom: 15px;
            font-size: 2.2em;
            font-weight: 700; /* Bolder header for the new theme */
        }

        .form-container {
            background-color: var(--bg-white);
            padding: 30px;
            border-radius: var(--radius); 
            box-shadow: var(--shadow); 
            max-width: 750px;
            margin: 0 auto 20px auto;
        }

        .form-group {
            margin-bottom: 20px;
        }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                font-weight: 600;
                color: var(--text-muted); /* Muted slate color */
                font-size: 0.9rem;
            }

            .form-group input[type="text"], .form-group select, .form-group .form-input, .phone-textbox {
                width: 100%;
                padding: 12px; /* Increased padding */
                border: 1px solid #e2e8f0; /* Light border */
                border-radius: 6px;
                box-sizing: border-box;
                font-size: 1em;
                color: var(--text-dark);
                background-color: #ffffff;
                transition: border-color 0.2s, box-shadow 0.2s;
            }
            
            .form-group input:focus, .form-group select:focus, .form-group .form-input:focus, .phone-textbox:focus {
                border-color: var(--primary-color);
                box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2); /* Indigo focus ring */
                outline: none;
            }

        .form-row {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }

            .form-row > .form-group { flex: 1 1 250px; }

        /* Style overrides for the Title dropdown column */
        .form-row > .form-group[style*="flex:0 0 140px;"] {
            flex: 0 0 140px !important; 
        }
        
        .form-row > .form-group:not([style*="flex:0 0 140px;"]) {
             flex: 1 1 250px; 
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
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

            .btn-submit:hover { 
                background-color: var(--primary-hover); 
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
            }

        .error-message {
            color: var(--accent-red);
            font-size: 0.85em; 
            margin-top: 5px;
            display: block;
            font-weight: 500;
        }

        .success-message {
            background-color: #d1fae5; /* Light green */
            color: #065f46; /* Darker green */
            padding: 12px;
            border: 1px solid #a7f3d0;
            border-radius: 6px;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 600;
        }
        
        /* Style for the non-editable Customer ID label */
        .customer-id-value {
            font-weight: 500;
            color: var(--text-muted);
            background-color: #f8fafc; /* Lighter background */
            padding: 12px;
            border-radius: 6px;
            display: block; 
            width: 100%;
            border: 1px dashed #e2e8f0;
        }

        .secondary-link {
            color: var(--text-muted); /* Darker slate color */
            text-decoration: none;
            margin-left: 15px;
            font-weight: 500;
            transition: color 0.2s;
        }
        
        .secondary-link:hover {
            color: var(--primary-color);
            text-decoration: underline;
        }
        
        /* Phone input group (prefix + textbox) */
        .phone-input {
            display: flex;
            align-items: center;
            gap: 0;
        }

        .phone-prefix {
            display: inline-block;
            background: #e2e8f0; /* Light grey consistent with the new theme's borders/bg */
            color: var(--text-muted);
            padding: 12px 12px;
            border: 1px solid #e2e8f0;
            border-right: none;
            border-top-left-radius: 6px;
            border-bottom-left-radius: 6px;
            font-weight: 600;
            font-size: 1em;
            line-height: 1; /* Align text vertically */
        }

        .phone-textbox {
            flex: 1;
            /* Inherits most styles from form-group input */
            border-top-right-radius: 6px;
            border-bottom-right-radius: 6px;
            border-left: none; /* Removes the double border with prefix */
        }
        
        .phone-textbox:focus {
            border-left: 1px solid var(--primary-color); /* Re-add focus border for seamless look */
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-wrapper">
            <div class="content-area">
                <h1 class="content-header">Edit Customer</h1>

                <div class="form-container">
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="success-message"></asp:Label>

                    <%-- Customer ID (Non-editable display) --%>
                    <div class="form-group">
                        <label>Customer ID</label>
                        <asp:Label ID="lblCustomerID" runat="server" Text="" CssClass="customer-id-value"></asp:Label>
                    </div>

                    <div class="form-row">
                        <%-- Title --%>
                        <div class="form-group" style="flex:0 0 140px;">
                            <asp:Label ID="lblTitle" runat="server" AssociatedControlID="ddlTitle" Text="Title"></asp:Label>
                            <asp:DropDownList ID="ddlTitle" runat="server" CssClass="form-input">
                                <asp:ListItem Text="Mr." Value="Mr"></asp:ListItem>
                                <asp:ListItem Text="Mrs." Value="Mrs"></asp:ListItem>
                                <asp:ListItem Text="Miss" Value="Miss"></asp:ListItem>
                                <asp:ListItem Text="Ms." Value="Ms"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <%-- First Name --%>
                        <div class="form-group">
                            <asp:Label ID="lblFirstName" runat="server" AssociatedControlID="txtFirstName" Text="First Name"></asp:Label>
                            <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-input" MaxLength="50"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName" ErrorMessage="First Name is required." CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>

                        <%-- Last Name --%>
                        <div class="form-group">
                            <asp:Label ID="lblLastName" runat="server" AssociatedControlID="txtLastName" Text="Last Name"></asp:Label>
                            <asp:TextBox ID="txtLastName" runat="server" CssClass="form-input" MaxLength="50"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName" ErrorMessage="Last Name is required." CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="form-row" style="margin-top:10px;">
                        <%-- Contact --%>
                        <div class="form-group">
                            <label>Contact (Phone No.)</label>
                            <div class="phone-input">
                                <span class="phone-prefix">+94</span>
                                <asp:TextBox ID="txtContactLocal" runat="server" CssClass="phone-textbox" Placeholder="XXXXXXXXX" MaxLength="10"></asp:TextBox>
                            </div>
                            <asp:RequiredFieldValidator ID="rfvContactLocal" runat="server" ControlToValidate="txtContactLocal" ErrorMessage="Contact is required." CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="revContactLocal" runat="server" ControlToValidate="txtContactLocal"
                                ValidationExpression="^(?:0\d{9}|\d{9})$"
                                ErrorMessage="Enter a valid local number (9 digits or leading 0 + 9 digits)." CssClass="error-message" Display="Dynamic"></asp:RegularExpressionValidator>
                        </div>

                        <%-- City --%>
                        <div class="form-group">
                            <asp:Label ID="lblCity" runat="server" AssociatedControlID="txtCity" Text="City"></asp:Label>
                            <asp:TextBox ID="txtCity" runat="server" CssClass="form-input" MaxLength="50"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvCity" runat="server" ControlToValidate="txtCity" ErrorMessage="City is required." CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>
                    </div>

                    <div class="form-group" style="margin-top:10px;">
                        <asp:Button ID="btnSave" runat="server" Text="Update Customer" OnClick="btnSave_Click" CssClass="btn-submit" />
                        <asp:HyperLink ID="hlBack" runat="server" NavigateUrl="Customers.aspx" CssClass="secondary-link">
                            <i class="fas fa-arrow-left"></i> Back to Customers
                        </asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>