<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Configuration" %>
<%
    // Set server-side session based on provided uid (development helper).
    string uid = Request.QueryString["uid"];
    if (string.IsNullOrEmpty(uid))
    {
        uid = ConfigurationManager.AppSettings["AuthTestUserId"] ?? "";
    }
    if (!string.IsNullOrEmpty(uid))
    {
        Session["UserId"] = uid;
        // Optionally store email or display name if provided
    }
    Response.Redirect("Dashboard.aspx", false);
    Context.ApplicationInstance.CompleteRequest();
%>
<!DOCTYPE html>
<html><head><meta http-equiv="refresh" content="0;url=Dashboard.aspx" /></head><body></body></html>