<%@ page import="bank.BankDAO, java.util.*" %>
<%
    String admin = (String) session.getAttribute("admin");
    if (admin == null) { response.sendRedirect("login.jsp"); return; }
    List<Map<String,Object>> accounts = new BankDAO().getAllAccounts();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — All Accounts</title>
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
      <a href="accounts.jsp" class="nav-link active">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
        All Accounts
      </a>
      <a href="search.jsp" class="nav-link">
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
    <h1 class="page-title animate">All Accounts</h1>
    <p class="page-subtitle animate delay-1"><%= accounts.size() %> registered customers</p>

    <div class="card animate delay-1">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px">
        <div class="card-title" style="margin:0">Customer List</div>
        <a href="search.jsp" class="btn btn-outline" style="font-size:.82rem;padding:8px 16px">Search</a>
      </div>
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>ID</th><th>Name</th><th>Username</th>
              <th>Email</th><th>Phone</th><th>Balance</th><th>Joined</th>
            </tr>
          </thead>
          <tbody>
          <% if (accounts.isEmpty()) { %>
            <tr><td colspan="7" style="text-align:center;color:var(--muted);padding:32px">No accounts found</td></tr>
          <% } else { for (Map<String,Object> acc : accounts) { %>
            <tr>
              <td style="color:var(--muted)">#<%= String.format("%06d", acc.get("id")) %></td>
              <td><strong><%= acc.get("name") %></strong></td>
              <td class="text-muted"><%= acc.get("username") %></td>
              <td class="text-muted"><%= acc.get("email") %></td>
              <td class="text-muted"><%= acc.get("phone") %></td>
              <td><strong>Rs. <%= String.format("%.2f", acc.get("balance")) %></strong></td>
              <td class="text-muted text-sm"><%= acc.get("created_at") != null ? acc.get("created_at").toString().substring(0,10) : "" %></td>
            </tr>
          <% } } %>
          </tbody>
        </table>
      </div>
    </div>
  </main>
</div>
</body>
</html>
