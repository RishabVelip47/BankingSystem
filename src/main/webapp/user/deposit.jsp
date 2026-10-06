<%@ page import="bank.BankDAO" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("../index.jsp"); return; }
    String msg = ""; String msgType = "";
    double newBalance = new BankDAO().getBalance(username);
    if (request.getMethod().equals("POST")) {
        try {
            double amount = Double.parseDouble(request.getParameter("amount"));
            if (amount <= 0) { msg = "Amount must be greater than 0."; msgType = "error"; }
            else {
                new BankDAO().deposit(username, amount);
                newBalance = new BankDAO().getBalance(username);
                msg = "Rs. " + String.format("%.2f", amount) + " deposited successfully!";
                msgType = "success";
            }
        } catch (Exception e) { msg = "Error: " + e.getMessage(); msgType = "error"; }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SimpleBank — Deposit</title>
  <link rel="stylesheet" href="../css/style.css"/>
</head>
<body>
<div class="shell">
  <%@ include file="_nav.jsp" %>
  <main class="main">
    <h1 class="page-title animate">Deposit Funds</h1>
    <p class="page-subtitle animate delay-1">Add money to your account</p>

    <div class="grid-2">
      <div class="card animate delay-1">
        <div class="card-title">Current Balance</div>
        <div class="balance-display" style="font-size:2.2rem">Rs. <%= String.format("%.2f", newBalance) %></div>
      </div>
      <div class="card animate delay-2">
        <div class="card-title">Make a Deposit</div>
        <% if (!msg.isEmpty()) { %>
          <div class="alert alert-<%= msgType %>"><%= msg %></div>
        <% } %>
        <form method="post">
          <div class="form-group">
            <label>Amount (Rs.)</label>
            <input type="number" name="amount" placeholder="0.00" min="1" step="0.01" required/>
          </div>
          <div style="display:flex;gap:10px;margin-bottom:16px;flex-wrap:wrap">
            <% int[] quick = {500,1000,5000,10000}; for(int q:quick) { %>
              <button type="button" onclick="document.querySelector('[name=amount]').value=<%= q %>"
                class="btn btn-outline" style="padding:6px 14px;font-size:.82rem">Rs. <%= q %></button>
            <% } %>
          </div>
          <button type="submit" class="btn btn-success btn-full">Confirm Deposit</button>
        </form>
      </div>
    </div>
  </main>
</div>
</body>
</html>
