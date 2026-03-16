<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Signup.aspx.cs" Inherits="Glamora.Signup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Sign Up</title>
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
            background-color: var(--bg-body);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            color: var(--text-dark);
        }

        .signup-container {
            width: 420px;
            padding: 34px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            background-color: var(--bg-white);
            text-align: center;
            border: 1px solid #e2e8f0;
        }

        h2 {
            color: var(--primary-color);
            margin-bottom: 20px;
            font-weight: 800;
            letter-spacing: -0.4px;
            font-size: 2em;
        }

        .subtitle {
            color: var(--text-muted);
            margin-bottom: 20px;
            font-size: 0.8em;
        }

        .form-group {
            margin-bottom: 15px;
            text-align: left;
        }

        label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: var(--text-dark);
        }

        .input-text {
            width: 100%;
            padding: 12px;
            border: 1px solid #cbd5e1;
            border-radius: var(--radius);
            font-size: 1rem;
        }

        .input-text:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 3px rgba(99,102,241,0.18);
        }

        .signup-button {
            width: 100%;
            background-color: var(--primary-color);
            color: white;
            padding: 12px;
            border: none;
            border-radius: var(--radius);
            cursor: pointer;
            font-size: 1.05em;
            margin-top: 15px;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(99,102,241,0.25);
            transition: background-color 0.2s, transform 0.1s;
        }

        .signup-button:hover {
            background-color: var(--primary-hover);
            transform: translateY(-1px);
        }

        .message {
            margin-top: 12px;
            font-weight: 600;
            color: var(--text-muted);
            display: block;
        }

        .success { color: #10b981; }
        .error { color: #ef4444; }

        a { color: var(--primary-color); text-decoration: none; font-weight: 600; }
        a:hover { color: var(--primary-hover); text-decoration: underline; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="signup-container">
            <h2>Sign Up</h2>
            <div class="subtitle">Sign up to request access and receive a verification link. Admin approval is required.</div>

            <div class="form-group">
                <label for="<%= txtFullName.ClientID %>">Full Name</label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="input-text"></asp:TextBox>
            </div>

            <div class="form-group">
                <label for="<%= txtEmail.ClientID %>">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="input-text"></asp:TextBox>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>

            <asp:Button ID="btnSignUp" runat="server" Text="Sign Up" CssClass="signup-button"
                        OnClick="btnSignUp_Click" />

            <p style="margin-top: 20px; font-size: 0.9em;">
                Already verified and approved? <a href="Login.aspx" style="color: var(--primary-color);">Log In</a>
            </p>
        </div>
    </form>
</body>
</html>
