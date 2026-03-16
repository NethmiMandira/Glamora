<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Glamora.Login" %>
<%@ Import Namespace="System.Web" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    
    <style>
        :root {
            --primary-color: #6366f1;       /* Indigo */
            --primary-hover: #4f46e5;       /* Darker Indigo */
            --bg-body: #f1f5f9;             /* Very light cool grey */
            --bg-white: #ffffff;
            --text-dark: #0f172a;           /* Almost Black */
            --text-muted: #64748b;          /* Slate Grey */
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

        .login-container {
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
            font-size: 2em;
            letter-spacing: -0.4px;
        }
        
        .login-subtitle {
            color: var(--text-muted);
            margin-bottom: 30px;
            font-size: 0.8rem;
        }

        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

        .password-wrap {
            position: relative;
            display: flex;
            align-items: center;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--text-dark);
            font-size: 0.9rem;
        }

        /* Styling for ASP.NET TextBoxes */
        .input-text {
            width: 100%;
            padding: 12px;
            border: 1px solid #cbd5e1; /* Slate border */
            border-radius: var(--radius);
            transition: border-color 0.3s, box-shadow 0.3s;
            font-size: 1rem;
        }
        
        .input-text:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.2); /* Indigo focus ring */
        }

        .toggle-eye {
            position: absolute;
            right: 12px;
            background: none;
            border: none;
            color: var(--text-muted);
            cursor: pointer;
            font-size: 1rem;
            padding: 4px;
        }

        .toggle-eye:hover { color: var(--primary-color); }

        /* Styling for ASP.NET Button */
        .login-button {
            width: 100%;
            background-color: var(--primary-color);
            color: var(--bg-white);
            padding: 12px;
            border: none;
            border-radius: var(--radius);
            cursor: pointer;
            font-size: 1.05em;
            font-weight: 700;
            margin-top: 20px;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); /* Button glow */
            transition: background-color 0.3s, transform 0.1s, box-shadow 0.3s;
        }

        .login-button:hover {
            background-color: var(--primary-hover);
            transform: translateY(-1px);
            box-shadow: 0 6px 15px rgba(99, 102, 241, 0.4);
        }

        .error-message {
            color: #ef4444; /* Modern red for errors */
            margin-top: 10px;
            font-weight: 500;
            display: block;
        }
        
        a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            transition: color 0.2s;
        }
        
        a:hover {
            color: var(--primary-hover);
            text-decoration: underline;
        }
        
        .signup-link {
            margin-top: 25px;
            font-size: 0.9rem;
            color: var(--text-muted);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-container">
            <h2>Login</h2>
            <p class="login-subtitle">Sign in to access the Dashboard</p>

            <div class="form-group">
                <label for="<%= txtUsername.ClientID %>">Username / Email</label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="input-text"></asp:TextBox>
            </div>

            <div class="form-group">
                <label for="<%= txtPassword.ClientID %>">Password</label>
                <div class="password-wrap">
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="input-text"></asp:TextBox>
                    <button type="button" class="toggle-eye" onclick="togglePassword('<%= txtPassword.ClientID %>', this)"><i class="fas fa-eye"></i></button>
                </div>
            </div>

            <asp:Label ID="lblMessage" runat="server" CssClass="error-message"></asp:Label>

            <asp:Button ID="btnLogin" runat="server" Text="Log In" CssClass="login-button" 
                        OnClick="btnLogin_Click" />

            <p class="signup-link">
                <a href="ForgotPassword.aspx">Forgot password?</a>
            </p>
            
            <p class="signup-link">
                Don't have an account? <a href="Signup.aspx">Sign Up here</a>
            </p>
            
        </div>
    </form>
    <script type="text/javascript">
        function togglePassword(inputId, btn) {
            var input = document.getElementById(inputId);
            if (!input) return;
            var isPwd = input.getAttribute('type') === 'password';
            input.setAttribute('type', isPwd ? 'text' : 'password');
            if (btn && btn.firstElementChild) {
                btn.firstElementChild.className = isPwd ? 'fas fa-eye-slash' : 'fas fa-eye';
            }
        }
    </script>
</body>
</html>