<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SetPassword.aspx.cs" Inherits="Glamora.SetPassword" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Set Password</title>
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

        body { font-family: 'Inter', sans-serif; background: var(--bg-body); display:flex; justify-content:center; align-items:center; height:100vh; margin:0; color: var(--text-dark); }
        .card { background: var(--bg-white); padding:34px; border-radius: var(--radius); box-shadow: var(--shadow); width:420px; text-align:center; border:1px solid #e2e8f0; }
        h2 { color: var(--primary-color); margin:0 0 8px 0; font-weight:800; letter-spacing:-0.4px; }
        .form-group { text-align:left; margin-top:18px; }
        label { font-weight:600; display:block; margin-bottom:8px; color: var(--text-dark); }
        .input-text { width:100%; padding:12px; border:1px solid #cbd5e1; border-radius: var(--radius); font-size:1rem; }
        .input-text:focus { border-color: var(--primary-color); outline:none; box-shadow:0 0 0 3px rgba(99,102,241,0.18); }
        .btn { margin-top:18px; width:100%; padding:12px; border:none; border-radius: var(--radius); background: var(--primary-color); color:#fff; cursor:pointer; font-weight:700; letter-spacing:0.2px; box-shadow:0 4px 12px rgba(99,102,241,0.25); transition: background 0.2s, transform 0.1s; }
        .btn:hover { background: var(--primary-hover); transform: translateY(-1px); }
        .message { margin-top:15px; font-weight:600; color: var(--text-muted); display:block; }
        .success { color:#10b981; }
        .error { color:#ef4444; }
        a { color: var(--primary-color); text-decoration:none; font-weight:600; }
        a:hover { color: var(--primary-hover); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="card">
            <h2>Set Your Password</h2>
            <div class="form-group">
                <label for="<%= txtPassword.ClientID %>">New Password</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="input-text"></asp:TextBox>
            </div>
            <div class="form-group">
                <label for="<%= txtConfirm.ClientID %>">Confirm Password</label>
                <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" CssClass="input-text"></asp:TextBox>
            </div>
            <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
            <asp:Button ID="btnSetPassword" runat="server" Text="Set Password" CssClass="btn" OnClick="btnSetPassword_Click" />
            <p style="margin-top:15px;"><a href="Login.aspx">Return to login</a></p>
        </div>
    </form>
</body>
</html>
