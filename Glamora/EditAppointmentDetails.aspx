<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditAppointmentDetails.aspx.cs" Inherits="Glamora.EditAppointmentDetails" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Edit Appointment</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            /* Palette aligned with Edit Customer page */
            --primary-color: #6366f1; /* Indigo */
            --primary-hover: #4f46e5; /* Darker Indigo */
            --primary-light-bg: #e0e7ff;

            --accent-red: #ef4444;
            --accent-green: #10b981;
            --accent-blue: #3b82f6;

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

        .page-shell {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 40px 24px;
            min-height: 100vh;
        }

        .content-area {
            width: 100%;
            max-width: 1100px;
            background-color: var(--bg-body);
            display: flex;
            flex-direction: column;
        }

        .content-header {
            color: var(--text-dark);
            margin-bottom: 25px;
            border-bottom: 3px solid var(--primary-color); /* Indigo underbar */
            padding-bottom: 15px;
            font-size: 2.2em;
            font-weight: 700; /* Bolder header for the new theme */
            text-align: left;
        }

        .form-container {
            background: var(--bg-white);
            padding: 30px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
            width: 100%;
            max-width: 1100px;
        }

        .form-section-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--primary-color);
            margin-bottom: 25px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-color);
        }

        .form-row {
            display: flex;
            gap: 25px;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }

        .form-group {
            flex: 1;
            display: flex;
            flex-direction: column;
            margin-bottom: 20px;
            min-width: 220px;
        }

            .form-group.full-width {
                flex: 1 1 100%;
            }

            .form-group label {
                display: block;
                margin-bottom: 10px;
                font-weight: 600;
                color: var(--text-muted);
                font-size: 0.85rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

        input[type="text"], input[type="date"], select, .form-control {
            padding: 10px 12px;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            font-size: 1em;
            transition: all .2s;
            background: var(--bg-white);
            box-sizing: border-box;
            width: 100%;
        }

        .readonly-label {
            display: block;
            padding: 10px 12px;
            border: 1px solid var(--border-color);
            border-radius: 4px;
            background: #f8fafc;
            color: var(--text-muted);
            min-height: 42px;
        }

            input[type="text"]:focus, input[type="date"]:focus, select:focus, .form-control:focus {
                outline: none;
                border-color: var(--primary-color);
                box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2);
            }

        .actions {
            display: flex;
            gap: 12px;
            margin-top: 18px;
        }

        .btn {
            padding: 12px 18px;
            border: none;
            border-radius: 6px;
            font-size: 1em;
            font-weight: 600;
            cursor: pointer;
            transition: all .2s;
            text-transform: uppercase;
        }

        .btn-add {
            background: var(--accent-green);
            color: white;
            letter-spacing: 0.5px;
        }

            .btn-add:hover {
                background: #047857;
            }

        .btn-save {
            background-color: var(--primary-color);
            color: white;
            padding: 14px 28px;
            box-shadow: 0 4px 10px rgba(99, 102, 241, 0.4);
        }

            .btn-save:hover {
                background-color: var(--primary-hover);
                transform: translateY(-1px);
            }

        .btn-main-cancel {
            background: var(--accent-red);
            color: white;
            padding: 14px 28px;
            box-shadow: 0 4px 10px rgba(239, 68, 68, 0.4);
        }

            .btn-main-cancel:hover {
                background: #dc2626;
                transform: translateY(-1px);
            }

        .btn-save:disabled {
            background-color: #cbd5e1;
            color: #64748b;
            cursor: not-allowed;
            box-shadow: none;
        }

        .services-section {
            background: var(--primary-light-bg);
            padding: 20px;
            border-radius: 6px;
            border: 1px solid var(--primary-color);
        }

        .service-row {
            display: flex;
            gap: 15px;
            align-items: flex-end;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }

        .service-input { flex: 1; }

        .selected-services {
            margin-top: 15px;
            padding-top: 10px;
            border-top: 1px solid var(--border-color);
        }

        .service-list-actions {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-top: 10px;
            flex-wrap: wrap;
        }

        .total-line {
            margin-top: 12px;
            font-weight: 700;
            color: var(--primary-hover);
            display: inline-block;
        }

        .msg { margin-bottom: 12px; font-weight: 700; }
        .msg.success { color: #16a34a; }
        .msg.error { color: #dc2626; }
        .status-hint { font-size: 12px; color: #64748b; margin-top: -4px; }

        @media (max-width: 1024px) {
            .form-row { flex-direction: column; }

            .form-container {
                max-width: 100%;
                margin: 0;
            }
        }

        @media (max-width: 768px) {
            .page-shell { padding: 20px; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div class="page-shell">
            <div class="content-area">
                <h1 class="content-header">Edit Appointment</h1>

                <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="msg" />

                <div class="form-container">
                    <div class="form-section-title">Appointment Details</div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Appointment ID</label>
                            <asp:Label ID="lblAppId" runat="server" CssClass="readonly-label" />
                        </div>
                        <div class="form-group">
                            <label>Appointment Date</label>
                            <asp:TextBox ID="txtDate" runat="server" CssClass="form-control" TextMode="Date" AutoPostBack="true" OnTextChanged="txtDate_TextChanged" />
                        </div>
                        <div class="form-group">
                            <label>Start Time</label>
                            <asp:TextBox ID="txtStartTime" runat="server" CssClass="form-control" TextMode="Time" />
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Customer</label>
                            <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlCustomer_SelectedIndexChanged"></asp:DropDownList>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group full-width">
                            <label>Services</label>
                            <div class="services-section">
                                <div class="service-row">
                                    <div class="service-input">
                                        <label style="font-size:0.8rem; margin-bottom:4px;">Service</label>
                                        <asp:DropDownList ID="ddlServices" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                    <div class="service-input">
                                        <label style="font-size:0.8rem; margin-bottom:4px;">Employee</label>
                                        <asp:DropDownList ID="ddlServiceEmployee" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                    <asp:Button ID="btnAddService" runat="server" Text="Add Service" CssClass="btn btn-add" OnClick="btnAddService_Click" CausesValidation="false" />
                                </div>
                                <asp:HiddenField ID="hdnServices" runat="server" />

                                <div class="selected-services">
                                    <asp:Repeater ID="rptServiceList" runat="server" OnItemCommand="rptServiceList_ItemCommand">
                                        <ItemTemplate>
                                            <div class="service-list-actions" style="justify-content: space-between; width:100%;">
                                                <span><%# Container.ItemIndex + 1 %>. <%# GetServiceDisplayText(Container.DataItem) %></span>
                                                <asp:LinkButton ID="btnRemoveOne" runat="server" CommandName="RemoveService" CommandArgument='<%# Container.DataItem %>' CssClass="btn btn-main-cancel" CausesValidation="false">Remove</asp:LinkButton>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <div class="service-list-actions">
                                        <label style="margin:0; font-weight:700; color:var(--text-muted);">Total Amount (Rs.)</label>
                                        <asp:TextBox ID="txtTotal" runat="server" CssClass="form-control" ReadOnly="true" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Advance Amount</label>
                            <asp:TextBox ID="txtAdvance" runat="server" CssClass="form-control" TextMode="Number" step="0.01" />
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Status</label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                                <asp:ListItem Value="">-- Select --</asp:ListItem>
                                <asp:ListItem>Pending</asp:ListItem>
                                <asp:ListItem>Done</asp:ListItem>
                                <asp:ListItem>Lapsed</asp:ListItem>
                                <asp:ListItem>Cancelled</asp:ListItem>
                                <asp:ListItem>Expired</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvStatus" runat="server" ControlToValidate="ddlStatus" InitialValue="" ErrorMessage="Select a status." Display="Dynamic" CssClass="msg error" />
                           
                        </div>
                    </div>

                    <div class="actions">
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-save" OnClick="btnSave_Click" />
                        <asp:Button ID="btnCancel" runat="server" Text="Back" CssClass="btn btn-main-cancel" OnClick="btnCancel_Click" CausesValidation="false" />
                        <span id="saveReason" class="msg error" style="align-self:center; display:none;"></span>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script type="text/javascript">
        // @ts-nocheck
        (function () {
            var dateInput = /** @type {HTMLInputElement | null} */ (document.getElementById('<%= txtDate.ClientID %>'));
            var customerDdl = /** @type {HTMLSelectElement | null} */ (document.getElementById('<%= ddlCustomer.ClientID %>'));
            var servicesHidden = /** @type {HTMLInputElement | null} */ (document.getElementById('<%= hdnServices.ClientID %>'));
            var saveBtn = /** @type {HTMLButtonElement | null} */ (document.getElementById('<%= btnSave.ClientID %>'));
            var reasonEl = document.getElementById('saveReason');

            function refreshSaveState() {
                if (!saveBtn) return;
                var hasDate = !!(dateInput && dateInput.value.trim().length > 0);
                var hasCustomer = !!(customerDdl && customerDdl.value.trim().length > 0);
                var hasService = !!(servicesHidden && servicesHidden.value.trim().length > 0);
                var reasons = /** @type {string[]} */ ([]);
                if (!hasDate) reasons.push('Select a date');
                if (!hasCustomer) reasons.push('Select a customer');
                if (!hasService) reasons.push('Add at least one service');

                var canSave = hasDate && hasCustomer && hasService;
                saveBtn.disabled = !canSave;

                if (reasonEl) {
                    if (canSave) {
                        reasonEl.style.display = 'none';
                        reasonEl.textContent = '';
                    } else {
                        reasonEl.style.display = 'block';
                        reasonEl.textContent = reasons.join(', ');
                    }
                }
            }

            if (dateInput) dateInput.addEventListener('input', refreshSaveState);
            if (customerDdl) customerDdl.addEventListener('change', refreshSaveState);
            document.addEventListener('DOMContentLoaded', refreshSaveState);
            window.addEventListener('load', refreshSaveState);
        })();
    </script>
</body>
</html>
