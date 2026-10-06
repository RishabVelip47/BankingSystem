<%@ page import="bank.BankDAO, java.util.*" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("../index.jsp"); return; }
    BankDAO dao = new BankDAO();
    List<Map<String,Object>> txns    = dao.getTransactions(username);
    List<Map<String,Object>> monthly = dao.getMonthlySummary(username);

    Map<String,Double> depMap = new LinkedHashMap<>();
    Map<String,Double> wdMap  = new LinkedHashMap<>();
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
        if (labels.length()>0) { labels.append(","); deps.append(","); wds.append(","); }
        labels.append("'").append(m).append("'");
        deps.append(depMap.getOrDefault(m,0.0));
        wds.append(wdMap.getOrDefault(m,0.0));
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — Transactions</title>
  <link rel="stylesheet" href="../css/style.css"/>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
<div class="shell">
  <%@ include file="_nav.jsp" %>
  <main class="main">
    <h1 class="page-title animate">Transaction History</h1>
    <p class="page-subtitle animate delay-1">Your last 20 transactions</p>

    <!-- Line chart -->
    <div class="card mb-24 animate delay-1">
      <div class="card-title">Monthly Activity</div>
      <div class="chart-container">
        <canvas id="lineChart"></canvas>
      </div>
    </div>

    <!-- Table -->
    <div class="card animate delay-2">
      <div class="table-wrap">
        <table>
          <thead>
            <tr><th>#</th><th>Type</th><th>Amount</th><th>Date &amp; Time</th></tr>
          </thead>
          <tbody>
          <% if (txns.isEmpty()) { %>
            <tr><td colspan="4" style="text-align:center;color:var(--muted);padding:32px">No transactions found</td></tr>
          <% } else { for (Map<String,Object> t : txns) { %>
            <tr>
              <td style="color:var(--muted)">#<%= t.get("id") %></td>
              <td><span class="badge badge-<%= ((String)t.get("type")).toLowerCase() %>"><%= t.get("type") %></span></td>
              <td><strong>Rs. <%= String.format("%.2f", t.get("amount")) %></strong></td>
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
const ctx = document.getElementById('lineChart').getContext('2d');
new Chart(ctx, {
  type: 'line',
  data: {
    labels: [<%= labels %>],
    datasets: [
      {
        label: 'Deposits',
        data: [<%= deps %>],
        borderColor: '#10b981',
        backgroundColor: 'rgba(16,185,129,.1)',
        fill: true,
        tension: .4,
        pointBackgroundColor: '#10b981'
      },
      {
        label: 'Withdrawals',
        data: [<%= wds %>],
        borderColor: '#ef4444',
        backgroundColor: 'rgba(239,68,68,.1)',
        fill: true,
        tension: .4,
        pointBackgroundColor: '#ef4444'
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
