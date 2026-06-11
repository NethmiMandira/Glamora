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

            <button id="btnLogin" type="button" class="login-button" onclick="clientSignIn()">Log In</button>
            
        </div>
    </form>
    <!-- Firebase SDK (compat) -->
    <script src="https://www.gstatic.com/firebasejs/9.22.2/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.22.2/firebase-auth-compat.js"></script>

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

        // Initialize Firebase using values from Web.config (rendered server-side)
        var firebaseConfig = {
            apiKey: '<%= System.Configuration.ConfigurationManager.AppSettings["Firebase_ApiKey"] %>',
            authDomain: '<%= System.Configuration.ConfigurationManager.AppSettings["Firebase_AuthDomain"] %>',
            projectId: '<%= System.Configuration.ConfigurationManager.AppSettings["Firebase_ProjectId"] %>',
            storageBucket: '<%= System.Configuration.ConfigurationManager.AppSettings["Firebase_StorageBucket"] %>',
            messagingSenderId: '<%= System.Configuration.ConfigurationManager.AppSettings["Firebase_MessagingSenderId"] %>',
            appId: '<%= System.Configuration.ConfigurationManager.AppSettings["Firebase_AppId"] %>',
            measurementId: '<%= System.Configuration.ConfigurationManager.AppSettings["Firebase_MeasurementId"] %>'
        };

        if (firebaseConfig.apiKey && firebaseConfig.apiKey.length > 0) {
            firebase.initializeApp(firebaseConfig);
        }

        // Dev/test fallback credentials and test user id (injected from server-side config). Avoid using in production.
        var __testAuthUsername = '<%= System.Configuration.ConfigurationManager.AppSettings["AuthTestUsername"] ?? string.Empty %>';
        var __testAuthPassword = '<%= System.Configuration.ConfigurationManager.AppSettings["AuthTestPassword"] ?? string.Empty %>';
        var __testAuthUserId = '<%= System.Configuration.ConfigurationManager.AppSettings["AuthTestUserId"] ?? string.Empty %>';

        function clientSignIn() {
            var email = document.getElementById('<%= txtUsername.ClientID %>').value.trim();
            var password = document.getElementById('<%= txtPassword.ClientID %>').value;

            if (!email || !password) {
                document.getElementById('<%= lblMessage.ClientID %>').innerText = 'Please enter your email and password.';
                return;
            }
            // If Firebase is available & configured, try Firebase auth first
            if (typeof firebase !== 'undefined' && firebase && firebase.auth && firebaseConfig.apiKey && firebaseConfig.apiKey.length > 0) {
                firebase.auth().signInWithEmailAndPassword(email, password)
                    .then(function(userCredential) {
                        // Signed in — set server session using SetSession.aspx then navigate to dashboard
                        var uid = (userCredential && userCredential.user && userCredential.user.uid) ? userCredential.user.uid : '';
                        if (!uid) uid = __testAuthUserId;
                        window.location.href = 'SetSession.aspx?uid=' + encodeURIComponent(uid);
                    })
                    .catch(function(error) {
                        // On Firebase failure, fall back to test credentials (development only)
                        if (__testAuthUsername && __testAuthPassword && email === __testAuthUsername && password === __testAuthPassword) {
                            window.location.href = 'SetSession.aspx?uid=' + encodeURIComponent(__testAuthUserId);
                        } else {
                            document.getElementById('<%= lblMessage.ClientID %>').innerText = error.message || 'Login failed.';
                        }
                    });
                return;
            }

            // If Firebase not configured, use server-provided test credentials (development only)
            if (__testAuthUsername && __testAuthPassword && email === __testAuthUsername && password === __testAuthPassword) {
                window.location.href = 'SetSession.aspx?uid=' + encodeURIComponent(__testAuthUserId);
                return;
            }

            document.getElementById('<%= lblMessage.ClientID %>').innerText = 'Firebase is not configured and credentials did not match test account.';
        }
    </script>
</body>
</html>