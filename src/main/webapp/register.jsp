<%@ page import="bank.BankDAO" %>
<%
    if (session.getAttribute("username") != null) {
        response.sendRedirect("user/dashboard.jsp");
        return;
    }
    String msg = ""; String msgType = "";
    if (request.getMethod().equals("POST")) {
        String name     = request.getParameter("name");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email    = request.getParameter("email");
        String phone    = request.getParameter("phone");
        try {
            new BankDAO().register(name, username, password, email, phone);
            msg = "Account created successfully! Please sign in.";
            msgType = "success";
        } catch (Exception e) {
            msg = "Error: " + e.getMessage();
            msgType = "error";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — Register</title>
  <link rel="stylesheet" href="css/style.css"/>
</head>
<body>
<div class="page-center">
  <div class="auth-card animate" style="max-width:480px">
    <p style="font-size:.75rem;color:var(--accent);font-weight:600;letter-spacing:1.5px;text-transform:uppercase;margin-bottom:12px">New Account</p>
    <h1 class="auth-title">Create account</h1>
    <p class="auth-sub">Join SimpleBank in seconds</p>

    <% if (!msg.isEmpty()) { %>
      <div class="alert alert-<%= msgType %>"><%= msg %></div>
    <% } %>

    <form method="post">
      <div class="grid-2">
        <div class="form-group">
          <label>Full Name</label>
          <input type="text" name="name" placeholder="Enter name" required/>
        </div>
        <div class="form-group">
          <label>Username</label>
          <input type="text" name="username" placeholder="Enter username" required/>
        </div>
      </div>
      <div class="form-group">
        <label>Email</label>
        <input type="email" name="email" placeholder="john@email.com" required/>
      </div>
      <div class="form-group">
        <label>Phone</label>
        <input type="tel" name="phone" placeholder="Phone number" required/>
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" placeholder="Create a password" required/>
      </div>
      <button type="submit" class="btn btn-primary btn-full" style="margin-top:8px">Create Account</button>
    </form>

    <div class="divider">or</div>
    <p style="text-align:center;font-size:.88rem;color:var(--muted)">
      Already have an account? <a href="index.jsp">Sign in</a>
    </p>
  </div>
</div>
</body>
</html>
