<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="Glamora.ForgotPassword" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Forgot Password</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary-color: #6366f1;
            --primary-hover: #4f46e5;
            --bg-body: #f1f5f9;
            --bg-white: #ffffff;
            --text-dark: #0f172a;
            --text-muted: #64748b;
            --shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --radius: 10px;
        }

        * { box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-body);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            color: var(--text-dark);
        }

        .card {
            background: var(--bg-white);
            padding: 36px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            width: 420px;
            text-align: center;
            border: 1px solid #e2e8f0;
        }

        h2 { color: var(--primary-color); margin: 0 0 6px 0; font-weight: 800; letter-spacing: -0.4px; }
        p { color: var(--text-muted); margin-top: 0; }

        .form-group { text-align:left; margin-top:18px; }
        label { font-weight:600; display:block; margin-bottom:8px; color: var(--text-dark); font-size: 0.95rem; }
        .input-text { width:100%; padding:12px; border:1px solid #cbd5e1; border-radius: var(--radius); font-size:1rem; }
        .input-text:focus { border-color: var(--primary-color); outline: none; box-shadow: 0 0 0 3px rgba(99,102,241,0.18); }

        .btn { margin-top:18px; width:100%; padding:12px; border:none; border-radius: var(--radius); background: var(--primary-color); color:#fff; cursor:pointer; font-weight:700; letter-spacing:0.2px; box-shadow: 0 4px 12px rgba(99,102,241,0.25); transition: background 0.2s, transform 0.1s; }
        .btn:hover { background: var(--primary-hover); transform: translateY(-1px); }

        .message { margin-top:15px; font-weight:600; color: var(--text-muted); display:block; }
        .success { color: #10b981; }
        .error { color: #ef4444; }

        a { color: var(--primary-color); text-decoration: none; font-weight: 600; }
        a:hover { color: var(--primary-hover); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="card">
            <h2>Forgot Password</h2>
            <p>Enter your registered email. If it exists, we'll send a reset link.</p>
            <div class="form-group">
                <label for="<%= txtEmail.ClientID %>">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="input-text"></asp:TextBox>
            </div>
            <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
            <asp:Button ID="btnSend" runat="server" Text="Send Reset Link" CssClass="btn" OnClick="btnSend_Click" />
            <p style="margin-top:15px;"><a href="Login.aspx">Return to login</a></p>
        </div>
    </form>
</body>
</html>
