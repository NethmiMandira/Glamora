using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace Glamora
{
    public enum UserStatus
    {
        PendingVerification,
        PendingApproval,
        PendingPassword,
        Active,
            Inactive,
        Rejected
    }

    public class AdminUser
    {
        public Guid UserId { get; set; }
        public string Email { get; set; }
        public string FullName { get; set; }
        public string PasswordHash { get; set; }
        public string Role { get; set; }
        public UserStatus Status { get; set; }
        public bool EmailVerified { get; set; }
        public DateTime CreatedAt { get; set; }
        public Guid? VerificationToken { get; set; }
        public DateTime? VerificationExpiresAt { get; set; }
        public Guid? SetPasswordToken { get; set; }
        public DateTime? SetPasswordExpiresAt { get; set; }
        public Guid? PasswordResetToken { get; set; }
        public DateTime? PasswordResetExpiresAt { get; set; }
        public bool PasswordResetUsed { get; set; }
    }

    public class OperationResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public Guid? Token { get; set; }

        public static OperationResult Ok(string message, Guid? token = null)
        {
            return new OperationResult { Success = true, Message = message, Token = token };
        }

        public static OperationResult Fail(string message)
        {
            return new OperationResult { Success = false, Message = message };
        }
    }

    public static class InMemoryUserStore
    {
        private static readonly List<AdminUser> _users = new List<AdminUser>();
        private static readonly object _lock = new object();
        private const int VerificationHours = 24;
        private const int PasswordTokenMinutes = 30;

        static InMemoryUserStore()
        {
            LoadUsersFromDatabase();
            SeedAdmin();
        }

        public static OperationResult RequestRegistration(string email, string fullName)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(fullName))
            {
                return OperationResult.Fail("Email and name are required.");
            }

            email = email.Trim();
            fullName = fullName.Trim();

            if (email.Equals(EmailService.DefaultAdminEmail, StringComparison.OrdinalIgnoreCase))
            {
                return OperationResult.Fail("Primary admin already exists.");
            }

            lock (_lock)
            {
                var existing = _users.FirstOrDefault(u => u.Email.Equals(email, StringComparison.OrdinalIgnoreCase));
                if (existing != null)
                {
                    if (existing.Status == UserStatus.Active || existing.Status == UserStatus.Inactive)
                    {
                        return OperationResult.Fail("This email is already registered and active.");
                    }

                    if (!existing.EmailVerified)
                    {
                        existing.VerificationToken = Guid.NewGuid();
                        existing.VerificationExpiresAt = DateTime.UtcNow.AddHours(VerificationHours);
                        return OperationResult.Ok("Verification link regenerated.", existing.VerificationToken);
                    }

                    return OperationResult.Fail("This email is already pending approval or password setup.");
                }

                var user = new AdminUser
                {
                    UserId = Guid.NewGuid(),
                    Email = email,
                    FullName = fullName,
                    Role = "ADMIN",
                    Status = UserStatus.PendingVerification,
                    EmailVerified = false,
                    CreatedAt = DateTime.UtcNow,
                    VerificationToken = Guid.NewGuid(),
                    VerificationExpiresAt = DateTime.UtcNow.AddHours(VerificationHours)
                };

                _users.Add(user);
                return OperationResult.Ok("Registration request recorded.", user.VerificationToken);
            }
        }

        public static OperationResult VerifyEmail(Guid token)
        {
            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.VerificationToken.HasValue && u.VerificationToken.Value == token);
                if (user == null)
                {
                    return OperationResult.Fail("Invalid or expired verification link.");
                }

                if (user.VerificationExpiresAt.HasValue && user.VerificationExpiresAt.Value < DateTime.UtcNow)
                {
                    return OperationResult.Fail("Verification link has expired. Please register again.");
                }

                if (user.EmailVerified && user.Status == UserStatus.PendingPassword && user.SetPasswordToken.HasValue)
                {
                    return OperationResult.Ok("Email already verified. Set your password to continue.", user.SetPasswordToken);
                }

                if (user.EmailVerified && user.Status == UserStatus.Active)
                {
                    return OperationResult.Ok("Email already verified. You can sign in.");
                }

                user.EmailVerified = true;
                user.Status = UserStatus.PendingApproval;
                user.SetPasswordToken = null;
                user.SetPasswordExpiresAt = null;

                return OperationResult.Ok("Email verified. Awaiting admin approval.", user.UserId);
            }
        }

        public static IEnumerable<AdminUser> GetAllUsers()
        {
            lock (_lock)
            {
                var distinct = _users
                    .GroupBy(u => u.Email ?? string.Empty, StringComparer.OrdinalIgnoreCase)
                    .Select(g => g.First())
                    .ToList();

                return distinct.Select(Clone).ToList();
            }
        }

        public static OperationResult ApproveUser(Guid userId)
        {
            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.UserId == userId);
                if (user == null)
                {
                    return OperationResult.Fail("User not found.");
                }

                if (!user.EmailVerified)
                {
                    return OperationResult.Fail("User email is not verified.");
                }

                user.Status = UserStatus.PendingPassword;
                user.SetPasswordToken = Guid.NewGuid();
                user.SetPasswordExpiresAt = DateTime.UtcNow.AddMinutes(PasswordTokenMinutes);

                var clone = Clone(user);
                UserRepository.UpsertUser(clone);
                PersistUser(clone);

                return OperationResult.Ok("User approved. Set password link generated.", user.SetPasswordToken);
            }
        }

        public static OperationResult RejectUser(Guid userId)
        {
            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.UserId == userId);
                if (user == null)
                {
                    return OperationResult.Fail("User not found.");
                }

                user.Status = UserStatus.Rejected;
                user.SetPasswordToken = null;
                user.SetPasswordExpiresAt = null;
                var clone = Clone(user);
                UserRepository.UpsertUser(clone);
                PersistUser(clone);
                return OperationResult.Ok("User rejected.");
            }
        }

        public static OperationResult DeleteUser(Guid userId)
        {
            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.UserId == userId);
                if (user == null)
                {
                    return OperationResult.Fail("User not found.");
                }

                if (!string.IsNullOrEmpty(user.Email) && user.Email.Equals(EmailService.DefaultAdminEmail, StringComparison.OrdinalIgnoreCase))
                {
                    return OperationResult.Fail("Primary admin cannot be deleted.");
                }

                _users.Remove(user);
                UserRepository.DeleteUser(userId);
                return OperationResult.Ok("User removed.");
            }
        }

        public static OperationResult SetActive(Guid userId, bool active)
        {
            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.UserId == userId);
                if (user == null)
                {
                    return OperationResult.Fail("User not found.");
                }

                if (!user.EmailVerified)
                {
                    return OperationResult.Fail("User email is not verified.");
                }

                if (user.Status != UserStatus.Active && user.Status != UserStatus.Inactive)
                {
                    return OperationResult.Fail("User cannot be toggled until activated.");
                }

                user.Status = active ? UserStatus.Active : UserStatus.Inactive;
                if (!active)
                {
                    user.SetPasswordToken = null;
                    user.SetPasswordExpiresAt = null;
                }

                var clone = Clone(user);
                UserRepository.UpsertUser(clone);
                PersistUser(clone);

                return OperationResult.Ok(active ? "User activated." : "User deactivated.");
            }
        }

        public static OperationResult SetPassword(Guid token, string password)
        {
            if (string.IsNullOrWhiteSpace(password))
            {
                return OperationResult.Fail("Password is required.");
            }

            if (password.Length < 8)
            {
                return OperationResult.Fail("Password must be at least 8 characters long.");
            }

            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.SetPasswordToken.HasValue && u.SetPasswordToken.Value == token);
                if (user == null)
                {
                    return OperationResult.Fail("Invalid or expired token.");
                }

                if (!user.SetPasswordExpiresAt.HasValue || user.SetPasswordExpiresAt.Value < DateTime.UtcNow)
                {
                    return OperationResult.Fail("Set password link has expired.");
                }

                user.PasswordHash = HashPassword(password);
                user.EmailVerified = true;
                user.Status = UserStatus.Active;
                user.SetPasswordToken = null;
                user.SetPasswordExpiresAt = null;
                user.PasswordResetToken = null;
                user.PasswordResetExpiresAt = null;
                user.PasswordResetUsed = false;

                // Persist to database
                var clone = Clone(user);
                UserRepository.UpsertUser(clone);
                PersistUser(clone);

                return OperationResult.Ok("Password set successfully. Account is now active.");
            }
        }

        public static OperationResult CreateResetToken(string email)
        {
            email = email == null ? string.Empty : email.Trim();

            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.Email.Equals(email, StringComparison.OrdinalIgnoreCase));
                if (user == null || user.Status != UserStatus.Active)
                {
                    return OperationResult.Ok("If the email is registered, a reset link has been sent.");
                }

                user.PasswordResetToken = Guid.NewGuid();
                user.PasswordResetExpiresAt = DateTime.UtcNow.AddMinutes(PasswordTokenMinutes);
                user.PasswordResetUsed = false;

                return OperationResult.Ok("Reset link generated.", user.PasswordResetToken);
            }
        }

        public static OperationResult ResetPassword(Guid token, string password)
        {
            if (string.IsNullOrWhiteSpace(password))
            {
                return OperationResult.Fail("Password is required.");
            }

            if (password.Length < 8)
            {
                return OperationResult.Fail("Password must be at least 8 characters long.");
            }

            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.PasswordResetToken.HasValue && u.PasswordResetToken.Value == token);
                if (user == null)
                {
                    return OperationResult.Fail("Invalid or expired reset link.");
                }

                if (!user.PasswordResetExpiresAt.HasValue || user.PasswordResetExpiresAt.Value < DateTime.UtcNow || user.PasswordResetUsed)
                {
                    return OperationResult.Fail("Invalid or expired reset link.");
                }

                user.PasswordHash = HashPassword(password);
                user.PasswordResetUsed = true;
                user.PasswordResetExpiresAt = null;
                user.PasswordResetToken = null;
                user.SetPasswordToken = null;
                user.SetPasswordExpiresAt = null;
                PersistUser(Clone(user));
                return OperationResult.Ok("Password has been reset.");
            }
        }

        public static OperationResult ValidateLogin(string usernameOrEmail, string password)
        {
            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.Email.Equals(usernameOrEmail, StringComparison.OrdinalIgnoreCase));
                if (user == null)
                {
                    return OperationResult.Fail("Invalid username or password.");
                }

                if (user.Status == UserStatus.Inactive)
                {
                    return OperationResult.Fail("Account is deactivated.");
                }

                if (user.Status != UserStatus.Active)
                {
                    if (user.EmailVerified && !string.IsNullOrEmpty(user.PasswordHash))
                    {
                        user.Status = UserStatus.Active;
                    }
                    else
                    {
                        return OperationResult.Fail("Account is not active yet.");
                    }
                }

                if (!user.EmailVerified)
                {
                    return OperationResult.Fail("Email not verified.");
                }

                var hashed = HashPassword(password);
                if (!string.Equals(user.PasswordHash, hashed, StringComparison.Ordinal))
                {
                    return OperationResult.Fail("Invalid username or password.");
                }

                return OperationResult.Ok("Login successful.");
            }
        }

        public static string GetPendingLink(AdminUser user, Func<Guid, string> linkBuilder)
        {
            if (user == null)
            {
                return string.Empty;
            }

            if (user.Status == UserStatus.PendingPassword && user.SetPasswordToken.HasValue && user.SetPasswordExpiresAt.HasValue && user.SetPasswordExpiresAt.Value > DateTime.UtcNow)
            {
                return linkBuilder(user.SetPasswordToken.Value);
            }

            return string.Empty;
        }

        public static AdminUser GetUser(Guid userId)
        {
            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.UserId == userId);
                return user == null ? null : Clone(user);
            }
        }

        public static AdminUser GetUserByVerificationToken(Guid token)
        {
            lock (_lock)
            {
                var user = _users.FirstOrDefault(u => u.VerificationToken.HasValue && u.VerificationToken.Value == token);
                return user == null ? null : Clone(user);
            }
        }

        private static void SeedAdmin()
        {
            lock (_lock)
            {
                if (_users.Any(u => u.Email != null && u.Email.Equals(EmailService.DefaultAdminEmail, StringComparison.OrdinalIgnoreCase)))
                {
                    return;
                }

                var admin = new AdminUser
                {
                    UserId = Guid.NewGuid(),
                    Email = EmailService.DefaultAdminEmail,
                    FullName = "Primary Admin",
                    PasswordHash = HashPassword("Password123!"),
                    Role = "ADMIN",
                    Status = UserStatus.Active,
                    EmailVerified = true,
                    CreatedAt = DateTime.UtcNow
                };

                _users.Add(admin);
            }
        }

        private static AdminUser Clone(AdminUser user)
        {
            return new AdminUser
            {
                UserId = user.UserId,
                Email = user.Email,
                FullName = user.FullName,
                PasswordHash = user.PasswordHash,
                Role = user.Role,
                Status = user.Status,
                EmailVerified = user.EmailVerified,
                CreatedAt = user.CreatedAt,
                VerificationToken = user.VerificationToken,
                VerificationExpiresAt = user.VerificationExpiresAt,
                SetPasswordToken = user.SetPasswordToken,
                SetPasswordExpiresAt = user.SetPasswordExpiresAt,
                PasswordResetToken = user.PasswordResetToken,
                PasswordResetExpiresAt = user.PasswordResetExpiresAt,
                PasswordResetUsed = user.PasswordResetUsed
            };
        }

        private static UserStatus ParseStatus(object statusObj)
        {
            var statusText = Convert.ToString(statusObj);
            UserStatus status;
            return Enum.TryParse(statusText, true, out status) ? status : UserStatus.Active;
        }

        private static void LoadUsersFromDatabase()
        {
            var connString = ConfigurationManager.ConnectionStrings["GlamoraDBConnection"]?.ConnectionString;
            if (string.IsNullOrWhiteSpace(connString))
            {
                return;
            }

            const string sql = "SELECT UserId, Email, FullName, PasswordHash, Role, Status, EmailVerified, CreatedAt FROM UsersTbl";

            var dbUsers = new List<AdminUser>();
            using (var conn = new SqlConnection(connString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var idObj = reader.IsDBNull(0) ? null : reader.GetValue(0);
                        Guid userId;
                        if (idObj is Guid guid)
                        {
                            userId = guid;
                        }
                        else if (!Guid.TryParse(Convert.ToString(idObj), out userId))
                        {
                            // Skip rows with non-GUID IDs to avoid failing the entire initialization
                            continue;
                        }

                        var user = new AdminUser
                        {
                            UserId = userId,
                            Email = reader.IsDBNull(1) ? string.Empty : reader.GetString(1),
                            FullName = reader.IsDBNull(2) ? string.Empty : reader.GetString(2),
                            PasswordHash = reader.IsDBNull(3) ? string.Empty : reader.GetString(3),
                            Role = reader.IsDBNull(4) ? string.Empty : reader.GetString(4),
                            Status = ParseStatus(reader.IsDBNull(5) ? null : reader.GetValue(5)),
                            EmailVerified = !reader.IsDBNull(6) && reader.GetBoolean(6),
                            CreatedAt = reader.IsDBNull(7) ? DateTime.UtcNow : reader.GetDateTime(7)
                        };
                        dbUsers.Add(user);
                    }
                }
            }

            lock (_lock)
            {
                foreach (var dbUser in dbUsers)
                {
                    var existing = _users.FirstOrDefault(u => u.UserId == dbUser.UserId);
                    var existingByEmail = _users.FirstOrDefault(u => !string.IsNullOrEmpty(dbUser.Email) && u.Email.Equals(dbUser.Email, StringComparison.OrdinalIgnoreCase));

                    if (existing == null && existingByEmail == null)
                    {
                        _users.Add(dbUser);
                    }
                    else
                    {
                        var target = existing ?? existingByEmail;
                        if (target != null)
                        {
                            target.Email = dbUser.Email;
                            target.FullName = dbUser.FullName;
                            target.PasswordHash = dbUser.PasswordHash;
                            target.Role = dbUser.Role;
                            target.Status = dbUser.Status;
                            target.EmailVerified = dbUser.EmailVerified;
                            target.CreatedAt = dbUser.CreatedAt;
                        }
                    }
                }
            }
        }

        private static string HashPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                var bytes = Encoding.UTF8.GetBytes(password);
                var hash = sha.ComputeHash(bytes);
                var builder = new StringBuilder();
                foreach (var b in hash)
                {
                    builder.Append(b.ToString("x2"));
                }

                var fullHash = builder.ToString();
                return fullHash.Length <= 10 ? fullHash : fullHash.Substring(0, 10);
            }
        }

        private static void PersistUser(AdminUser user)
        {
            if (user == null)
            {
                return;
            }

            var connString = ConfigurationManager.ConnectionStrings["GlamoraDBConnection"]?.ConnectionString;
            if (string.IsNullOrWhiteSpace(connString))
            {
                return;
            }

            const string sql = @"
IF EXISTS (SELECT 1 FROM UsersTbl WHERE UserId = @UserId)
    UPDATE UsersTbl
    SET Email = @Email,
        FullName = @FullName,
        PasswordHash = @PasswordHash,
        Role = @Role,
        Status = @Status,
        EmailVerified = @EmailVerified,
        CreatedAt = @CreatedAt
    WHERE UserId = @UserId;
ELSE
    INSERT INTO UsersTbl (UserId, Email, FullName, PasswordHash, Role, Status, EmailVerified, CreatedAt)
    VALUES (@UserId, @Email, @FullName, @PasswordHash, @Role, @Status, @EmailVerified, @CreatedAt);";

            using (var conn = new SqlConnection(connString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@UserId", SqlDbType.UniqueIdentifier).Value = user.UserId;
                cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 256).Value = user.Email ?? string.Empty;
                cmd.Parameters.Add("@FullName", SqlDbType.NVarChar, 256).Value = user.FullName ?? string.Empty;
                cmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 64).Value = user.PasswordHash ?? string.Empty;
                cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 50).Value = user.Role ?? string.Empty;
                cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 50).Value = user.Status.ToString();
                cmd.Parameters.Add("@EmailVerified", SqlDbType.Bit).Value = user.EmailVerified;
                cmd.Parameters.Add("@CreatedAt", SqlDbType.DateTime).Value = user.CreatedAt;

                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

    }
}
