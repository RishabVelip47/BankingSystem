<%@ page import="bank.BankDAO, java.util.*" %>
<%
    String admin = (String) session.getAttribute("admin");
    if (admin == null) { response.sendRedirect("login.jsp"); return; }
    BankDAO dao = new BankDAO();
    Map<String,Object> stats = dao.getAdminStats();
    List<Map<String,Object>> accounts = dao.getAllAccounts();

    List<String> months   = (List<String>) stats.get("months");
    List<Double> deposits = (List<Double>) stats.get("deposits");
    StringBuilder lblSB = new StringBuilder();
    StringBuilder depSB = new StringBuilder();
    for (int i=0; i<months.size(); i++) {
        if(i>0){lblSB.append(",");depSB.append(",");}
        lblSB.append("'").append(months.get(i)).append("'");
        depSB.append(deposits.get(i));
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — Admin Dashboard</title>
  <link rel="stylesheet" href="../css/style.css"/>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
<div class="shell">
  <!-- Admin Sidebar -->
  <aside class="sidebar">
    <div class="sidebar-logo">Simple<span>Bank</span> <span style="font-size:.6rem;color:var(--warning);vertical-align:middle">ADMIN</span></div>
    <nav class="nav-links">
      <a href="dashboard.jsp" class="nav-link active">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
        Overview
      </a>
      <a href="accounts.jsp" class="nav-link">
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
    <h1 class="page-title animate">Admin Overview</h1>
    <p class="page-subtitle animate delay-1">Bank-wide statistics and insights</p>

    <!-- Stats -->
    <div class="stat-grid">
      <div class="stat-card blue animate delay-1">
        <div class="stat-label">Total Accounts</div>
        <div class="stat-value"><%= stats.get("totalAccounts") %></div>
        <div class="stat-sub">Registered customers</div>
      </div>
      <div class="stat-card green animate delay-2">
        <div class="stat-label">Total Funds</div>
        <div class="stat-value">Rs. <%= String.format("%.0f", (Double) stats.get("totalBalance")) %></div>
        <div class="stat-sub">Across all accounts</div>
      </div>
      <div class="stat-card yellow animate delay-3">
        <div class="stat-label">Today's Transactions</div>
        <div class="stat-value"><%= stats.get("todayTxns") %></div>
        <div class="stat-sub">Processed today</div>
      </div>
    </div>

    <!-- Deposit trend chart -->
    <div class="card mb-24 animate delay-2">
      <div class="card-title">Deposit Trend — Last 6 Months</div>
      <div class="chart-container">
        <canvas id="trendChart"></canvas>
      </div>
    </div>

    <!-- Account type pie chart + recent accounts side by side -->
    <div class="grid-2">
      <div class="card animate delay-3">
        <div class="card-title">Balance Distribution</div>
        <div class="chart-container" style="height:220px">
          <canvas id="pieChart"></canvas>
        </div>
      </div>
      <div class="card animate delay-4">
        <div class="card-title">Recent Accounts</div>
        <table>
          <thead><tr><th>Name</th><th>Username</th><th>Balance</th></tr></thead>
          <tbody>
          <% int i=0; for (Map<String,Object> acc : accounts) { if(i++>=5) break; %>
            <tr>
              <td><%= acc.get("name") %></td>
              <td class="text-muted"><%= acc.get("username") %></td>
              <td>Rs. <%= String.format("%.0f", acc.get("balance")) %></td>
            </tr>
          <% } %>
          </tbody>
        </table>
        <a href="accounts.jsp" style="display:block;text-align:right;margin-top:12px;font-size:.82rem">View all accounts</a>
      </div>
    </div>
  </main>
</div>

<script>
// Trend chart
new Chart(document.getElementById('trendChart'), {
  type: 'line',
  data: {
    labels: [<%= lblSB %>],
    datasets: [{
      label: 'Deposits (Rs.)',
      data: [<%= depSB %>],
      borderColor: '#3b82f6',
      backgroundColor: 'rgba(59,130,246,.15)',
      fill: true, tension: .4,
      pointBackgroundColor: '#3b82f6'
    }]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { labels: { color: '#7c8499' } } },
    scales: {
      x: { ticks:{color:'#7c8499'}, grid:{color:'#2a2f3d'} },
      y: { ticks:{color:'#7c8499'}, grid:{color:'#2a2f3d'} }
    }
  }
});

// Pie chart — bucket balances
<%
    int low=0, mid=0, high=0;
    for (Map<String,Object> acc : accounts) {
        double b = (Double) acc.get("balance");
        if (b < 1000) low++;
        else if (b < 10000) mid++;
        else high++;
    }
%>
new Chart(document.getElementById('pieChart'), {
  type: 'doughnut',
  data: {
    labels: ['< Rs.1k', 'Rs.1k-10k', '> Rs.10k'],
    datasets: [{
      data: [<%= low %>, <%= mid %>, <%= high %>],
      backgroundColor: ['#ef4444','#f59e0b','#10b981'],
      borderColor: '#1e222d', borderWidth: 3
    }]
  },
  options: {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { labels: { color: '#7c8499', font:{family:'DM Sans'} } } }
  }
});
</script>
</body>
</html>
