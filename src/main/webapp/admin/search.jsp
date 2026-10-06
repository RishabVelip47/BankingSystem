<%@ page import="bank.BankDAO, java.util.*" %>
<%
    String admin = (String) session.getAttribute("admin");
    if (admin == null) { response.sendRedirect("login.jsp"); return; }
    Map<String,Object> result = null;
    String query = "";
    String notFound = "";
    if (request.getMethod().equals("POST")) {
        query = request.getParameter("query").trim();
        try {
            result = new BankDAO().searchAccount(query);
            if (result == null) notFound = "No account found for: " + query;
        } catch (Exception e) { notFound = "Error: " + e.getMessage(); }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — Search Account</title>
  <link rel="stylesheet" href="../css/style.css"/>
</head>
<body>
<div class="shell">
  <aside class="sidebar">
    <div class="sidebar-logo">Simple<span>Bank</span> <span style="font-size:.6rem;color:var(--warning);vertical-align:middle">ADMIN</span></div>
    <nav class="nav-links">
      <a href="dashboard.jsp" class="nav-link">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
        Overview
      </a>
      <a href="accounts.jsp" class="nav-link">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        All Accounts
      </a>
      <a href="search.jsp" class="nav-link active">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
        Search Account
      </a>
    </nav>
    <div class="sidebar-footer">
      <div class="sidebar-user">Admin<strong><%= admin %></strong></div>
      <a href="logout.jsp" class="btn btn-outline" style="width:100%;font-size:.82rem;padding:9px">Sign Out</a>
    </div>
  </aside>

  <main class="main">
    <h1 class="page-title animate">Search Account</h1>
    <p class="page-subtitle animate delay-1">Find a customer by username, email, or name</p>

    <div class="card animate delay-1" style="margin-bottom:24px">
      <form method="post">
        <div class="search-bar">
          <input type="text" name="query" placeholder="Search by username, email, or name..."
                 value="<%= query %>" required/>
          <button type="submit" class="btn btn-primary">Search</button>
        </div>
      </form>
    </div>

    <% if (!notFound.isEmpty()) { %>
      <div class="alert alert-error animate"><%= notFound %></div>
    <% } %>

    <% if (result != null) { %>
    <div class="card animate delay-2">
      <div class="card-title">Account Found</div>
      <div class="grid-2" style="margin-top:16px">
        <div>
          <table style="width:100%;font-size:.9rem">
            <tr><td style="color:var(--muted);padding:8px 0;width:120px">Account ID</td><td><strong>#<%= String.format("%06d", result.get("id")) %></strong></td></tr>
            <tr><td style="color:var(--muted);padding:8px 0">Full Name</td>   <td><strong><%= result.get("name") %></strong></td></tr>
            <tr><td style="color:var(--muted);padding:8px 0">Username</td>    <td><strong><%= result.get("username") %></strong></td></tr>
            <tr><td style="color:var(--muted);padding:8px 0">Email</td>       <td><strong><%= result.get("email") %></strong></td></tr>
            <tr><td style="color:var(--muted);padding:8px 0">Phone</td>       <td><strong><%= result.get("phone") %></strong></td></tr>
            <tr><td style="color:var(--muted);padding:8px 0">Joined</td>      <td><strong><%= result.get("created_at") != null ? result.get("created_at").toString().substring(0,10) : "N/A" %></strong></td></tr>
          </table>
        </div>
        <div class="stat-card green" style="display:flex;flex-direction:column;justify-content:center;align-items:center;text-align:center">
          <div class="stat-label">Account Balance</div>
          <div class="balance-display">Rs. <%= String.format("%.2f", result.get("balance")) %></div>
        </div>
      </div>
    </div>
    <% } %>
  </main>
</div>
</body>
</html>
