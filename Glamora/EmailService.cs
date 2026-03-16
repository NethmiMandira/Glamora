using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;

namespace Glamora
{
    public static class EmailService
    {
        public const string DefaultAdminEmail = "salonmsglamora@gmail.com";

        public static void SendEmail(string toEmail, string subject, string body)
        {
            if (string.IsNullOrWhiteSpace(toEmail))
            {
                throw new ArgumentException("Recipient email is required.", nameof(toEmail));
            }

            // Prefer <system.net> mailSettings; fall back to appSettings
            var smtpSection = ConfigurationManager.GetSection("system.net/mailSettings/smtp") as System.Net.Configuration.SmtpSection;
            var network = smtpSection?.Network;

            var host = !string.IsNullOrWhiteSpace(network?.Host) ? network.Host : ConfigurationManager.AppSettings["SmtpHost"];
            var portSetting = network?.Port.ToString() ?? ConfigurationManager.AppSettings["SmtpPort"];
            var username = !string.IsNullOrWhiteSpace(network?.UserName) ? network.UserName : ConfigurationManager.AppSettings["SmtpUsername"];
            var password = !string.IsNullOrWhiteSpace(network?.Password) ? network.Password : ConfigurationManager.AppSettings["SmtpPassword"];
            var from = smtpSection != null && !string.IsNullOrWhiteSpace(smtpSection.From) ? smtpSection.From : ConfigurationManager.AppSettings["SmtpFrom"];
            var sslSetting = network != null ? network.EnableSsl.ToString() : ConfigurationManager.AppSettings["SmtpEnableSsl"];

            var missingCredentials = string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password);
            var usingPlaceholders = (!string.IsNullOrWhiteSpace(username) && username.IndexOf("yourmail@", StringComparison.OrdinalIgnoreCase) >= 0)
                                    || string.Equals(password, "APP_PASSWORD_HERE", StringComparison.OrdinalIgnoreCase);

            if (missingCredentials || usingPlaceholders)
            {
                throw new InvalidOperationException("SMTP configuration is missing or still using placeholders. Please set SmtpHost, SmtpPort, SmtpUsername, and SmtpPassword in Web.config (use an app password if using Gmail/2FA).");
            }

            int port;
            if (!int.TryParse(portSetting, out port))
            {
                port = 587;
            }

            bool enableSsl;
            if (!bool.TryParse(sslSetting, out enableSsl))
            {
                enableSsl = true;
            }

            var message = new MailMessage
            {
                From = new MailAddress(string.IsNullOrWhiteSpace(from) ? username : from),
                Subject = subject,
                Body = body,
                IsBodyHtml = true
            };

            message.To.Add(new MailAddress(toEmail.Trim()));

            using (var client = new SmtpClient(host, port))
            {
                client.DeliveryMethod = SmtpDeliveryMethod.Network;
                client.UseDefaultCredentials = false;
                client.EnableSsl = enableSsl;
                client.Credentials = new NetworkCredential(username, password);
                client.Send(message);
            }
        }
    }
}
