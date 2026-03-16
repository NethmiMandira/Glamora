<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Splash.aspx.cs" Inherits="Glamora.Splash" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Glamora | Premium Salon Experience</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        :root {
            --primary-color: #6366f1;
            --primary-hover: #4f46e5;
            --bg-body: #f1f5f9;
            --bg-white: #ffffff;
            --text-dark: #0f172a;
            --text-muted: #94a3b8;
            --shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
            --radius: 24px;
        }

        * { box-sizing: border-box; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }

        body {
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
            background: var(--primary-color);
            /* Soft mesh gradient background */
            background-image: 
                radial-gradient(at 0% 0%, rgba(99, 102, 241, 0.15) 0px, transparent 50%),
                radial-gradient(at 100% 100%, rgba(99, 102, 241, 0.1) 0px, transparent 50%);
            color: var(--text-dark);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
        }

        .splash-shell {
            width: 100%;
            max-width: 480px;
            padding: 24px;
            perspective: 1000px;
        }

        .splash-container {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(12px); /* Modern glass effect */
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.7);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            text-align: center;
            padding: 60px 40px;
            animation: slideUp 0.8s ease-out forwards;
        }

        /* Animated Logo Section */
        .logo-icon {
            width: 200px;
            height: 200px;
            background: transparent;
            border-radius: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 12px;
            
            
            padding: 12px;
        }

        .logo-icon img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }

        .logo-text {
            font-size: 3.5rem;
            font-weight: 800;
            letter-spacing: -2px;
            margin-bottom: 8px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-hover));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .tagline {
            font-size: 1.1rem;
            font-weight: 400;
            color: var(--text-muted);
            margin-bottom: 40px;
            line-height: 1.5;
        }

        .login-button {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 16px 32px;
            background: var(--primary-color);
            color: var(--bg-white);
            text-decoration: none;
            font-size: 1.1rem;
            font-weight: 600;
            border-radius: 16px;
            box-shadow: 0 10px 25px -5px rgba(99, 102, 241, 0.4);
            cursor: pointer;
        }

        .login-button:hover {
            background: var(--primary-hover);
            transform: translateY(-3px);
            box-shadow: 0 20px 30px -10px rgba(99, 102, 241, 0.5);
        }

        .login-button i {
            margin-left: 12px; /* Move icon to the right for "forward" motion */
            font-size: 0.9rem;
        }

        /* Animations */
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        /* Subtle Background Decoration */
        .blob {
            position: absolute;
            width: 300px;
            height: 300px;
            background: var(--primary-color);
            filter: blur(80px);
            opacity: 0.1;
            z-index: -1;
            border-radius: 50%;
        }
    </style>
</head>
<body>
    <div class="blob" style="top: 10%; left: 10%;"></div>
    <div class="blob" style="bottom: 10%; right: 10%;"></div>

    <form id="form1" runat="server">
        <div class="splash-shell">
            <div class="splash-container">
                <div class="logo-icon">
                    <asp:Image ID="LogoImage" runat="server" ImageUrl="~/logo.png" AlternateText="Glamora logo" />
                </div>
               
                <div class="tagline">Streamline your beauty business with our <br/><strong>next-gen</strong> management suite.</div>
                
                <a href="Signup.aspx" class="login-button">
                    <span>Get Started</span>
                    <i class="fas fa-arrow-right"></i>
                </a>
            </div>
        </div>
    </form>
</body>
</html>