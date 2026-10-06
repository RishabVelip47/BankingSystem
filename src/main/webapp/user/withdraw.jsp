<%@ page import="bank.BankDAO" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("../index.jsp"); return; }
    String msg = ""; String msgType = "";
    double balance = new BankDAO().getBalance(username);
    if (request.getMethod().equals("POST")) {
        try {
            double amount = Double.parseDouble(request.getParameter("amount"));
            if (amount <= 0) { msg = "Amount must be greater than 0."; msgType = "error"; }
            else {
                String result = new BankDAO().withdraw(username, amount);
                balance = new BankDAO().getBalance(username);
                if (result.equals("Success")) {
                    msg = "Rs. " + String.format("%.2f", amount) + " withdrawn successfully!";
                    msgType = "success";
                } else { msg = result; msgType = "error"; }
            }
        } catch (Exception e) { msg = "Error: " + e.getMessage(); msgType = "error"; }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — Withdraw</title>
  <link rel="stylesheet" href="../css/style.css"/>
</head>
<body>
<div class="shell">
  <%@ include file="_nav.jsp" %>
  <main class="main">
    <h1 class="page-title animate">Withdraw Funds</h1>
    <p class="page-subtitle animate delay-1">Transfer money out of your account</p>

    <div class="grid-2">
      <div class="stat-card <%= balance > 0 ? "green" : "red" %> animate delay-1" style="padding:28px">
        <div class="balance-label">Available Balance</div>
        <div class="balance-display" style="font-size:2.2rem">Rs. <%= String.format("%.2f", balance) %></div>
      </div>
      <div class="card animate delay-2">
        <div class="card-title">Withdraw Amount</div>
        <% if (!msg.isEmpty()) { %>
          <div class="alert alert-<%= msgType %>"><%= msg %></div>
        <% } %>
        <form method="post">
          <div class="form-group">
            <label>Amount (Rs.)</label>
            <input type="number" name="amount" placeholder="0.00" min="1" step="0.01"
                   max="<%= balance %>" required/>
          </div>
          <div style="display:flex;gap:10px;margin-bottom:16px;flex-wrap:wrap">
            <% int[] quick = {500,1000,5000,10000}; for(int q:quick) { %>
              <button type="button" onclick="document.querySelector('[name=amount]').value=<%= q %>"
                class="btn btn-outline" style="padding:6px 14px;font-size:.82rem">Rs. <%= q %></button>
            <% } %>
            <button type="button" onclick="document.querySelector('[name=amount]').value=<%= (int)balance %>"
              class="btn btn-outline" style="padding:6px 14px;font-size:.82rem">All</button>
          </div>
          <button type="submit" class="btn btn-danger btn-full">Confirm Withdrawal</button>
        </form>
      </div>
    </div>
  </main>
</div>
</body>
</html>
