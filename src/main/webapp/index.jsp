<%@ page import="bank.BankDAO" %>
<%
    // If already logged in, skip to dashboard
    if (session.getAttribute("username") != null) {
        response.sendRedirect("user/dashboard.jsp");
        return;
    }
    String error = "";
    if (request.getMethod().equals("POST")) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        try {
            BankDAO dao = new BankDAO();
            if (dao.login(username, password)) {
                session.setAttribute("username", username);
                response.sendRedirect("user/dashboard.jsp");
                return;
            } else {
                error = "Invalid username or password.";
            }
        } catch (Exception e) {
            error = "Database error: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — Login</title>
  <link rel="stylesheet" href="css/style.css"/>
</head>
<body>
<div class="page-center">
  <div class="auth-card animate">
    <p style="font-size:.75rem;color:var(--accent);font-weight:600;letter-spacing:1.5px;text-transform:uppercase;margin-bottom:12px">Customer Portal</p>
    <h1 class="auth-title">Welcome back</h1>
    <p class="auth-sub">Sign in to your SimpleBank account</p>

    <% if (!error.isEmpty()) { %>
      <div class="alert alert-error"><%= error %></div>
    <% } %>

    <form method="post">
      <div class="form-group">
        <label>Username</label>
        <input type="text" name="username" placeholder="Enter your username" required/>
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" placeholder="Enter your password" required/>
      </div>
      <button type="submit" class="btn btn-primary btn-full" style="margin-top:8px">Sign In</button>
    </form>

    <div class="divider">or</div>
    <p style="text-align:center;font-size:.88rem;color:var(--muted)">
      New customer? <a href="register.jsp">Create an account</a>
    </p>
    <p style="text-align:center;font-size:.82rem;color:var(--muted);margin-top:24px">
      Admin? <a href="admin/login.jsp">Admin login</a>
    </p>
  </div>
</div>
</body>
</html>
