using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Glamora
{
    public static class UserRepository
    {
        public static IEnumerable<AdminUser> GetUsers()
        {
            return InMemoryUserStore.GetAllUsers();
        }

        public static void UpsertUser(AdminUser user)
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

        public static void DeleteUser(Guid userId)
        {
            if (userId == Guid.Empty)
            {
                return;
            }

            var connString = ConfigurationManager.ConnectionStrings["GlamoraDBConnection"]?.ConnectionString;
            if (string.IsNullOrWhiteSpace(connString))
            {
                return;
            }

            const string sql = "DELETE FROM UsersTbl WHERE UserId = @UserId";

            using (var conn = new SqlConnection(connString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@UserId", SqlDbType.UniqueIdentifier).Value = userId;

                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}
