<%@ page import="bank.BankDAO" %>
<%
    if (session.getAttribute("admin") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    String error = "";
    if (request.getMethod().equals("POST")) {
        String u = request.getParameter("username");
        String p = request.getParameter("password");
        try {
            if (new BankDAO().adminLogin(u, p)) {
                session.setAttribute("admin", u);
                response.sendRedirect("dashboard.jsp");
                return;
            } else { error = "Invalid admin credentials."; }
        } catch (Exception e) { error = "DB Error: " + e.getMessage(); }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — Admin Login</title>
  <link rel="stylesheet" href="../css/style.css"/>
</head>
<body>
<div class="page-center">
  <div class="auth-card animate">
    <p style="font-size:.75rem;color:var(--warning);font-weight:600;letter-spacing:1.5px;text-transform:uppercase;margin-bottom:12px">Admin Access</p>
    <h1 class="auth-title">Admin Panel</h1>
    <p class="auth-sub">Restricted area authorized personnel only</p>

    <% if (!error.isEmpty()) { %>
      <div class="alert alert-error"><%= error %></div>
    <% } %>

    <form method="post">
      <div class="form-group">
        <label>Admin Username</label>
        <input type="text" name="username" placeholder="admin" required/>
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" placeholder="Enter password" required/>
      </div>
      <button type="submit" class="btn btn-full" style="background:var(--warning);color:#000;font-weight:700;margin-top:8px">Sign In as Admin</button>
    </form>

    <p style="text-align:center;font-size:.82rem;color:var(--muted);margin-top:20px">
      <a href="../index.jsp">Back to customer login</a>
    </p>
  </div>
</div>
</body>
</html>
