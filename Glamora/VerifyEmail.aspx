<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VerifyEmail.aspx.cs" Inherits="Glamora.VerifyEmail" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Verify Email</title>
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
            <h2>Email Verification</h2>
            <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
        </div>
    </form>
</body>
</html>
