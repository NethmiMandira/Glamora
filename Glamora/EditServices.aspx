<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditServices.aspx.cs" Inherits="Glamora.EditServices" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Edit Service</title>
    <meta charset="utf-8" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        /* --- Color Palette & Variables (Matching Services.aspx Dashboard) --- */
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

            .form-group input[type="text"], .form-group select, .form-group .form-input {
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
            
            .form-group input:focus, .form-group select:focus, .form-group .form-input:focus {
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
        
        /* Style for the non-editable Service ID label */
        .service-id-value {
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
    </style>
    
    <script type="text/javascript">
        // --- JavaScript functions for Price and Duration validation (copied for completeness) ---

        function restrictPriceKey(e) {
            var key = e.key;
            var el = e.target || e.srcElement;
            var val = el.value || '';
            var code = e.which || e.keyCode;

            var allowedCodes = [8, 9, 13, 27, 46, 35, 36, 37, 38, 39, 40];
            if (e.ctrlKey || e.metaKey || allowedCodes.indexOf(code) !== -1) return true;

            if ((code >= 48 && code <= 57) || (code >= 96 && code <= 105)) return true;

            if (key === '.') {
                if (val.indexOf('.') === -1) {
                    return true;
                } else {
                    e.preventDefault();
                    return false;
                }
            }
            e.preventDefault();
            return false;
        }

        function handlePricePaste(e) {
            var pasted = (e.clipboardData || window.clipboardData).getData('text') || '';
            var sanitized = pasted.replace(/[^0-9.]/g, '');

            var parts = sanitized.split('.');
            if (parts.length > 1) {
                sanitized = parts[0] + '.' + parts.slice(1).join('');
            }

            if (sanitized.indexOf('.') !== -1) {
                var p = sanitized.split('.');
                p[1] = p[1].slice(0, 2);
                sanitized = p[0] + '.' + p[1];
            }

            e.preventDefault();
            var el = e.target || e.srcElement;
            if (typeof el.selectionStart === 'number') {
                var start = el.selectionStart, end = el.selectionEnd;
                var newVal = el.value.slice(0, start) + sanitized + el.value.slice(end);

                var dots = (newVal.match(/\./g) || []).length;
                if (dots > 1) {
                    var first = newVal.indexOf('.');
                    newVal = newVal.slice(0, first + 1) + newVal.slice(first + 1).replace(/\./g, '');
                }

                el.value = newVal;
                var pos = start + sanitized.length;
                el.setSelectionRange(pos, pos);
            } else {
                el.value = sanitized;
            }
        }

        function autoFormatDuration(el) {
            if (!el) return;
            var digits = (el.value || '').replace(/[^0-9]/g, '').slice(0, 6);
            var formatted = '';
            if (digits.length <= 2) formatted = digits;
            else if (digits.length <= 4) formatted = digits.slice(0, 2) + ':' + digits.slice(2);
            else formatted = digits.slice(0, 2) + ':' + digits.slice(2, 4) + ':' + digits.slice(4);
            el.value = formatted;
        }

        function handleDurationPaste(e) {
            var pasted = (e.clipboardData || window.clipboardData).getData('text') || '';
            if (/\b(?:am|pm)\b/i.test(pasted) || /[a-zA-Z]/.test(pasted.replace(/[:\s]/g, ''))) {
                e.preventDefault();
                alert('Only numbers are allowed for duration. Use 24-hour format HH:mm:ss (example: 01:30:00). Do not include AM/PM.');
                return false;
            }

            var digits = pasted.replace(/[^0-9]/g, '').slice(0, 6);
            var formatted = '';
            if (digits.length <= 2) formatted = digits;
            else if (digits.length <= 4) formatted = digits.slice(0, 2) + ':' + digits.slice(2);
            else formatted = digits.slice(0, 2) + ':' + digits.slice(2, 4) + ':' + digits.slice(4);

            e.preventDefault();
            var el = e.target || e.srcElement;
            if (typeof el.selectionStart === 'number') {
                var start = el.selectionStart, end = el.selectionEnd;
                el.value = el.value.slice(0, start) + formatted + el.value.slice(end);
                var pos = start + formatted.length;
                el.setSelectionRange(pos, pos);
            } else {
                el.value = formatted;
            }
            return false;
        }

        function restrictDurationKey(e) {
            var key = e.key;
            var code = e.which || e.keyCode;
            var allowedCodes = [8, 9, 13, 27, 46, 35, 36, 37, 38, 39, 40];
            if (e.ctrlKey || e.metaKey) return true;
            if (allowedCodes.indexOf(code) !== -1) return true;
            if ((code >= 48 && code <= 57) || (code >= 96 && code <= 105)) return true;
            if (key === ':' || code === 186 || code === 59 || code === 58) return true;
            e.preventDefault();
            return false;
        }

        function validateDuration() {
            var el = document.getElementById('<%= txtDuration.ClientID %>');
            if (!el) return true;
            var val = (el.value || '').trim();
            if (val.length === 0) return true;
            if (/\b(?:am|pm)\b/i.test(val)) { alert('Do not use AM/PM. Enter duration in 24-hour format HH:mm:ss.'); el.focus(); return false; }
            var re = /^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/;
            if (!re.test(val)) { alert('Invalid duration. Use HH:mm:ss.'); el.focus(); return false; }
            return true;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-wrapper">
            <div class="content-area">
                <h1 class="content-header">Edit Service</h1>

                <div class="form-container">
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="success-message"></asp:Label>

                    <%-- Service ID (Non-editable display) --%>
                    <div class="form-group">
                        <label>Service ID</label>
                        <asp:Label ID="lblServiceID" runat="server" Text="" CssClass="service-id-value"></asp:Label>
                    </div>

                    <div class="form-row">
                        <%-- Service Name --%>
                        <div class="form-group">
                            <label for="<%= txtServiceName.ClientID %>">Service Name</label>
                            <asp:TextBox ID="txtServiceName" runat="server" CssClass="form-input" MaxLength="50"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvServiceName" runat="server" ControlToValidate="txtServiceName"
                                ErrorMessage="Service Name is required." CssClass="error-message" Display="Dynamic" />
                        </div>

                        <%-- Price --%>
                        <div class="form-group">
                            <label for="<%= txtPrice.ClientID %>">Price (LKR)</label>
                            <asp:TextBox ID="txtPrice" runat="server" CssClass="form-input" TextMode="SingleLine"
                                placeholder="e.g. 1500.00" MaxLength="10" 
                                onkeypress="return restrictPriceKey(event)"
                                onpaste="handlePricePaste(event)"
                                inputmode="decimal" />
                            <asp:RequiredFieldValidator ID="rfvPrice" runat="server" ControlToValidate="txtPrice"
                                ErrorMessage="Price is required." CssClass="error-message" Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revPrice" runat="server" ControlToValidate="txtPrice"
                                ValidationExpression="^\s*(\d+|\d{1,3}(,\d{3})+)(\.\d{1,2})?\s*$"
                                ErrorMessage="Enter a valid price (digits only, optional 2 decimals)." CssClass="error-message" Display="Dynamic" />
                        </div>
                    </div>

                    <div class="form-row">
                        <%-- Duration --%>
                        <div class="form-group">
                            <label for="<%= txtDuration.ClientID %>">Duration (HH:mm:ss)</label>
                            <asp:TextBox ID="txtDuration" runat="server" TextMode="SingleLine" CssClass="form-input"
                                placeholder="HH:mm:ss (e.g., 01:30:00)" MaxLength="8" 
                                oninput="autoFormatDuration(this)"
                                onpaste="handleDurationPaste(event)"
                                onkeypress="return restrictDurationKey(event)" />
                            <asp:RequiredFieldValidator ID="rfvDuration" runat="server" ControlToValidate="txtDuration"
                                ErrorMessage="Duration is required." CssClass="error-message" Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revDuration" runat="server" ControlToValidate="txtDuration"
                                ValidationExpression="^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$"
                                ErrorMessage="Enter duration as HH:mm:ss (example: 01:30:00)." CssClass="error-message" Display="Dynamic" />
                        </div>

                        <%-- Category --%>
                        <div class="form-group">
                            <label for="<%= ddlCategory.ClientID %>">Category</label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-input">
                            </asp:DropDownList>
                        </div>
                    </div>

                    <%-- Action Buttons --%>
                    <div class="form-group">
                        <asp:Button ID="btnSave" runat="server" Text="Update Service" OnClick="btnSave_Click" OnClientClick="return validateDuration();" CssClass="btn-submit" />
                        <asp:HyperLink ID="hlBack" runat="server" NavigateUrl="Services.aspx" CssClass="secondary-link">
                            <i class="fas fa-arrow-left"></i> Back to Services
                        </asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>