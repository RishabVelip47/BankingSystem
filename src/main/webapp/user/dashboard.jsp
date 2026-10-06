<%@ page import="bank.BankDAO, java.util.*, java.sql.ResultSet" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("../index.jsp"); return; }

    BankDAO dao = new BankDAO();
    double balance = dao.getBalance(username);
    List<Map<String,Object>> txns = dao.getTransactions(username);
    List<Map<String,Object>> monthly = dao.getMonthlySummary(username);

    // Build chart data
    Map<String, Double> depMap = new LinkedHashMap<>();
    Map<String, Double> wdMap  = new LinkedHashMap<>();
    for (Map<String,Object> r : monthly) {
        String mon  = (String) r.get("month");
        String type = (String) r.get("type");
        double tot  = (Double)  r.get("total");
        if (type.equals("DEPOSIT"))  depMap.put(mon, tot);
        if (type.equals("WITHDRAW")) wdMap.put(mon, tot);
    }
    Set<String> allMonths = new LinkedHashSet<>(depMap.keySet());
    allMonths.addAll(wdMap.keySet());
    StringBuilder labels = new StringBuilder();
    StringBuilder deps   = new StringBuilder();
    StringBuilder wds    = new StringBuilder();
    for (String m : allMonths) {
        if (labels.length() > 0) { labels.append(","); deps.append(","); wds.append(","); }
        labels.append("'").append(m).append("'");
        deps.append(depMap.getOrDefault(m, 0.0));
        wds.append(wdMap.getOrDefault(m, 0.0));
    }

    ResultSet rs = dao.getAccountDetails(username);
    String name = username;
    if (rs.next()) name = rs.getString("name");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — Dashboard</title>
  <link rel="stylesheet" href="../css/style.css"/>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
<div class="shell">
  <aside class="sidebar">
    <div class="sidebar-logo">Simple<span>Bank</span></div>
    <nav class="nav-links">
      <a href="dashboard.jsp"    class="nav-link active">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
        Dashboard
      </a>
      <a href="account.jsp"      class="nav-link">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/></svg>
        Account
      </a>
      <a href="deposit.jsp"      class="nav-link">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 5v14M5 12l7 7 7-7"/></svg>
        Deposit
      </a>
      <a href="withdraw.jsp"     class="nav-link">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 19V5M5 12l7-7 7 7"/></svg>
        Withdraw
      </a>
      <a href="transfer.jsp"     class="nav-link">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M7 16V4m0 0L3 8m4-4 4 4M17 8v12m0 0 4-4m-4 4-4-4"/></svg>
        Transfer
      </a>
      <a href="transactions.jsp" class="nav-link">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2M9 5a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2M9 5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2"/></svg>
        Transactions
      </a>
    </nav>
    <div class="sidebar-footer">
      <div class="sidebar-user">Logged in as<strong><%= username %></strong></div>
      <a href="../logout.jsp" class="btn btn-outline" style="width:100%;font-size:.82rem;padding:9px">Sign Out</a>
    </div>
  </aside>

  <main class="main">
    <h1 class="page-title animate">Good day, <%= name %>.</h1>
    <p class="page-subtitle animate delay-1">Here's your financial overview</p>

    <!-- Stat Cards -->
    <div class="stat-grid">
      <div class="stat-card green animate delay-1">
        <div class="stat-label">Current Balance</div>
        <div class="stat-value">Rs. <%= String.format("%.2f", balance) %></div>
        <div class="stat-sub">Available funds</div>
      </div>
      <%
        int depCount = 0; double depTotal = 0;
        int wdCount  = 0; double wdTotal  = 0;
        for (Map<String,Object> t : txns) {
            String tp = (String) t.get("type");
            double am = (Double)  t.get("amount");
            if (tp.equals("DEPOSIT"))  { depCount++; depTotal += am; }
            if (tp.equals("WITHDRAW")) { wdCount++;  wdTotal  += am; }
        }
      %>
      <div class="stat-card blue animate delay-2">
        <div class="stat-label">Total Deposited</div>
        <div class="stat-value">Rs. <%= String.format("%.0f", depTotal) %></div>
        <div class="stat-sub"><%= depCount %> deposits</div>
      </div>
      <div class="stat-card red animate delay-3">
        <div class="stat-label">Total Withdrawn</div>
        <div class="stat-value">Rs. <%= String.format("%.0f", wdTotal) %></div>
        <div class="stat-sub"><%= wdCount %> withdrawals</div>
      </div>
    </div>

    <!-- Chart -->
    <div class="card mb-24 animate delay-2">
      <div class="card-title">Activity — Last 6 Months</div>
      <div class="chart-container">
        <canvas id="activityChart"></canvas>
      </div>
    </div>

    <!-- Recent Transactions -->
    <div class="card animate delay-3">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px">
        <div class="card-title" style="margin:0">Recent Transactions</div>
        <a href="transactions.jsp" class="text-sm" style="color:var(--accent)">View all</a>
      </div>
      <div class="table-wrap">
        <table>
          <thead>
            <tr><th>#</th><th>Type</th><th>Amount</th><th>Date</th></tr>
          </thead>
          <tbody>
          <% if (txns.isEmpty()) { %>
            <tr><td colspan="4" style="color:var(--muted);text-align:center;padding:24px">No transactions yet</td></tr>
          <% } else { int i=0; for (Map<String,Object> t : txns) { if(i++>=5) break; %>
            <tr>
              <td style="color:var(--muted)">#<%= t.get("id") %></td>
              <td><span class="badge badge-<%= ((String)t.get("type")).toLowerCase() %>"><%= t.get("type") %></span></td>
              <td>Rs. <%= String.format("%.2f", t.get("amount")) %></td>
              <td class="text-muted text-sm"><%= t.get("txn_date") %></td>
            </tr>
          <% } } %>
          </tbody>
        </table>
      </div>
    </div>
  </main>
</div>

<script>
const ctx = document.getElementById('activityChart').getContext('2d');
new Chart(ctx, {
  type: 'bar',
  data: {
    labels: [<%= labels %>],
    datasets: [
      {
        label: 'Deposits',
        data: [<%= deps %>],
        backgroundColor: 'rgba(16,185,129,.7)',
        borderRadius: 6,
        borderSkipped: false
      },
      {
        label: 'Withdrawals',
        data: [<%= wds %>],
        backgroundColor: 'rgba(239,68,68,.7)',
        borderRadius: 6,
        borderSkipped: false
      }
    ]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { labels: { color: '#7c8499', font: { family: 'DM Sans' } } } },
    scales: {
      x: { ticks: { color: '#7c8499' }, grid: { color: '#2a2f3d' } },
      y: { ticks: { color: '#7c8499' }, grid: { color: '#2a2f3d' } }
    }
  }
});
</script>
</body>
</html>
