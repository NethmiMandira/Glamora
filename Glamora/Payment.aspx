<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Payment.aspx.cs" Inherits="Glamora.Payment" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Payment</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --primary-color: #6366f1;
            --primary-hover: #4f46e5;
            --bg-body: #f1f5f9;
            --bg-white: #ffffff;
            --text-dark: #0f172a;
            --text-muted: #64748b;
            --border-color: #e2e8f0;
            --accent-red: #ef4444;
            --accent-green: #10b981;
            --shadow: 0 10px 25px rgba(0,0,0,0.08);
            --radius: 12px;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            background: linear-gradient(180deg, #f8fafc 0%, var(--bg-body) 100%);
            color: var(--text-dark);
        }

        .page {
            max-width: 960px;
            margin: 40px auto;
            padding: 0 24px 60px 24px;
        }

        .header {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 2.25rem;
            font-weight: 800;
            margin: 0 0 30px 0;
            letter-spacing: -0.8px;
            color: var(--text-dark);
        }

        /* Unified container layout */
        .card {
            background: var(--bg-white);
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 22px;
        }

        .section-title {
            font-size: 1.2rem;
            font-weight: 800;
            color: var(--primary-color);
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .summary-details { margin-top: 15px; }

        .row {
            display: grid;
            grid-template-columns: 180px 1fr;
            gap: 12px;
            margin-bottom: 8px;
            border-bottom: 1px dashed var(--border-color);
            padding-bottom: 8px;
        }
        .row:last-child { border-bottom: none; }

        .label { color: var(--text-muted); font-weight: 600; }
        .value { color: var(--text-dark); font-weight: 500; }

        .chips {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 10px;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-color);
            justify-content: center;
            text-align: center;
        }
        .chip {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px 14px;
            border-radius: 999px;
            font-weight: 700;
            border: 1px solid var(--border-color);
            background: #fff;
            text-align: center;
        }
        .chip.total { background: var(--text-dark); color: #fff; box-shadow: 0 4px 10px rgba(0,0,0,0.15); width:270px; }
        .chip.advance { background: #fff7ed; color: #b45309; border-color: #fed7aa; width:270px; }
        .chip.balance { background: #ecfdf5; color: #065f46; border-color: #a7f3d0; width:270px; }

        .lapsed {
            margin-top: 10px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fecaca;
            border-radius: 999px;
            padding: 6px 10px;
            font-weight: 700;
        }

        .payment-section {
            display: flex;
            flex-direction: column;
            gap: 14px;
            margin-top: 24px;
            padding-top: 16px;
            border-top: 1px solid var(--border-color);
        }

        .balance-highlight {
            text-align: center;
            margin: 0 0 15px 0;
            padding: 12px;
            border-radius: var(--radius);
            background: var(--bg-body);
            border: 1px solid var(--border-color);
        }
        .balance-highlight .label {
            font-size: 0.9rem;
            color: var(--text-muted);
            font-weight: 700;
            margin-bottom: 3px;
        }
        .balance-highlight .value {
            font-size: 1.75rem;
            font-weight: 800;
            color: var(--text-dark);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
            margin-bottom: 15px;
        }
        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-weight: 600; margin-bottom: 6px; }
        .form-control, select {
            padding: 12px 12px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 1rem;
            background: var(--bg-white);
        }

        .actions-container { margin-top: auto; padding-top: 10px; }
        .actions {
            display: flex;
            gap: 12px;
            align-items: center;
            margin-top: 10px;
        }

        .btn {
            padding: 12px 18px;
            border: none;
            border-radius: 8px;
            font-weight: 700;
            cursor: pointer;
            transition: transform .08s ease, box-shadow .12s ease;
        }
        .btn:hover { transform: translateY(-1px); }
        .btn-pay { background: var(--primary-color); color: #fff; box-shadow: 0 8px 18px rgba(99,102,241,.35); }
        .btn-pay:hover { background: var(--primary-hover); }
        .btn-cancel { background: #e5e7eb; color: #111827; }

        .error { color: var(--accent-red); font-size: .95rem; }
        .success { color: var(--accent-green); font-size: .95rem; }
        .disabled-banner { margin-top: 6px; font-size: .95rem; color: var(--accent-red); }

        @media (max-width: 900px) {
            .row { grid-template-columns: 140px 1fr; }
        }
        @media (max-width: 600px) {
            .page { padding: 0 16px 40px 16px; margin-top: 20px; }
            .header { font-size: 1.75rem; margin-bottom: 16px; }
            .balance-highlight .value { font-size: 1.5rem; }
            .row { grid-template-columns: 1fr; gap: 2px; margin-bottom: 12px; padding-bottom: 10px; }
            .label { font-size: 0.9rem; margin-bottom: 0; }
            .form-row { grid-template-columns: 1fr; gap: 14px; }
            .actions { flex-direction: column; align-items: stretch; }
            .btn { width: 100%; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page">
            <h1 class="header">
                <i class="fa-solid fa-receipt"></i>Payment
            </h1>

            <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="error"></asp:Panel>
            <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="success"></asp:Panel>

            <div class="card">
                <div class="section-title"><i class="fa-solid fa-circle-info"></i>Appointment Details</div>
                <div class="summary-details">
                    <div class="row"><div class="label">Appointment ID</div><div class="value"><asp:Label ID="lblAppID" runat="server" /></div></div>
                    <div class="row"><div class="label">Customer</div><div class="value"><asp:Label ID="lblCustomer" runat="server" /></div></div>
                    <div class="row"><div class="label">Employee</div><div class="value"><asp:Label ID="lblEmployee" runat="server" /></div></div>
                    <div class="row"><div class="label">Date</div><div class="value"><asp:Label ID="lblAppDate" runat="server" /></div></div>
                    <div class="row"><div class="label">Booked Date</div><div class="value"><asp:Label ID="lblBookedOn" runat="server" /></div></div>
                    <div class="row"><div class="label">Services</div><div class="value"><asp:Label ID="lblServices" runat="server" /></div></div>
                    <div class="row"><div class="label">Last Payment Method</div><div class="value"><asp:Label ID="lblLastMethod" runat="server" /></div></div>
                </div>

                <div class="chips">
                    <span class="chip total"><i class="fa-solid fa-sack-dollar"></i>Total: Rs. <asp:Label ID="lblTotal" runat="server" /></span>
                    <span class="chip advance"><i class="fa-regular fa-hand-holding-dollar"></i>Advance: Rs. <asp:Label ID="lblAdvance" runat="server" /></span>
                    <span class="chip balance"><i class="fa-solid fa-scale-balanced"></i>Balance: Rs. <asp:Label ID="lblBalance" runat="server" /></span>
                </div>

                <asp:Panel ID="pnlLapsed" runat="server" Visible="false" CssClass="lapsed">
                    <i class="fa-regular fa-hourglass"></i> Lapsed — payment disabled (24h past appointment date)
                </asp:Panel>

                <div class="payment-section">
                    <div class="section-title"><i class="fa-solid fa-credit-card"></i>Process Payment</div>

                    <div class="balance-highlight">
                        <div class="label">Outstanding Balance</div>
                        <div class="value">Rs. <asp:Label ID="lblBalanceHighlight" runat="server" Text="" /></div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Payment Amount (LKR)</label>
                            <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control" placeholder="0.00" />
                            <asp:RegularExpressionValidator ID="revAmount" runat="server" ControlToValidate="txtAmount" ValidationExpression="^\d{0,9}(\.\d{1,2})?$" ErrorMessage="Enter a valid amount (max 2 decimals)" Display="Dynamic" CssClass="error" />
                        </div>
                        <div class="form-group">
                            <label>Payment Method</label>
                            <asp:DropDownList ID="ddlMethod" runat="server" CssClass="form-control">
                                <asp:ListItem Value="">-- Select --</asp:ListItem>
                                <asp:ListItem>Cash</asp:ListItem>
                                <asp:ListItem>Card</asp:ListItem>
                                <asp:ListItem>Online</asp:ListItem>
                                <asp:ListItem>Other</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvMethod" runat="server" ControlToValidate="ddlMethod" InitialValue="" ErrorMessage="Select a payment method" Display="Dynamic" CssClass="error" />
                        </div>
                    </div>

                    <div class="actions-container">
                        <div class="actions">
                            <asp:Button ID="btnProcess" runat="server" Text="Process Payment" CssClass="btn btn-pay" OnClick="btnProcess_Click" />
                            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-cancel" CausesValidation="false" OnClick="btnCancel_Click" />
                        </div>
                        <asp:Label ID="lblDisabledInfo" runat="server" Visible="false" CssClass="disabled-banner" />
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>