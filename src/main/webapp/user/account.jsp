<%@ page import="bank.BankDAO, java.sql.ResultSet" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("../index.jsp"); return; }
    BankDAO dao = new BankDAO();
    ResultSet rs = dao.getAccountDetails(username);
    String name="", email="", phone="", created=""; double balance=0; int id=0;
    if (rs.next()) {
        id      = rs.getInt("id");
        name    = rs.getString("name");
        email   = rs.getString("email");
        phone   = rs.getString("phone");
        balance = rs.getDouble("balance");
        created = rs.getString("created_at");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — Account</title>
  <link rel="stylesheet" href="../css/style.css"/>
</head>
<body>
<div class="shell">
  <%@ include file="_nav.jsp" %>
  <main class="main">
    <h1 class="page-title animate">Account Details</h1>
    <p class="page-subtitle animate delay-1">Your profile and account information</p>

    <div class="grid-2">
      <!-- Balance card -->
      <div class="stat-card green animate delay-1" style="padding:28px">
        <div class="balance-label">Current Balance</div>
        <div class="balance-display">Rs. <%= String.format("%.2f", balance) %></div>
        <div class="stat-sub">Account #<%= String.format("%06d", id) %></div>
      </div>

      <!-- Info card -->
      <div class="card animate delay-2">
        <div class="card-title">Personal Info</div>
        <table style="width:100%;font-size:.9rem;">
          <tr><td style="color:var(--muted);padding:8px 0">Full Name</td>   <td><strong><%= name %></strong></td></tr>
          <tr><td style="color:var(--muted);padding:8px 0">Username</td>    <td><strong><%= username %></strong></td></tr>
          <tr><td style="color:var(--muted);padding:8px 0">Email</td>       <td><strong><%= email %></strong></td></tr>
          <tr><td style="color:var(--muted);padding:8px 0">Phone</td>       <td><strong><%= phone %></strong></td></tr>
          <tr><td style="color:var(--muted);padding:8px 0">Member Since</td><td><strong><%= created != null ? created.substring(0,10) : "N/A" %></strong></td></tr>
        </table>
      </div>
    </div>

    <div class="card animate delay-3" style="margin-top:24px">
      <div class="card-title">Quick Actions</div>
      <div style="display:flex;gap:12px;flex-wrap:wrap;margin-top:8px">
        <a href="deposit.jsp"      class="btn btn-success">Deposit</a>
        <a href="withdraw.jsp"     class="btn btn-danger">Withdraw</a>
        <a href="transfer.jsp"     class="btn btn-primary">Transfer</a>
        <a href="transactions.jsp" class="btn btn-outline">View History</a>
      </div>
    </div>
  </main>
</div>
</body>
</html>
