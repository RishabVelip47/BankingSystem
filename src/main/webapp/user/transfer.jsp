<%@ page import="bank.BankDAO" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("../index.jsp"); return; }
    String msg = ""; String msgType = "";
    double balance = new BankDAO().getBalance(username);
    if (request.getMethod().equals("POST")) {
        try {
            String toUser = request.getParameter("toUser").trim();
            double amount = Double.parseDouble(request.getParameter("amount"));
            if (toUser.equalsIgnoreCase(username)) { msg = "Cannot transfer to yourself."; msgType = "error"; }
            else if (amount <= 0) { msg = "Amount must be greater than 0."; msgType = "error"; }
            else {
                String result = new BankDAO().transfer(username, toUser, amount);
                balance = new BankDAO().getBalance(username);
                if (result.equals("Success")) {
                    msg = "Rs. " + String.format("%.2f", amount) + " transferred to " + toUser + "!";
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
  <title>SimpleBank — Transfer</title>
  <link rel="stylesheet" href="../css/style.css"/>
</head>
<body>
<div class="shell">
  <%@ include file="_nav.jsp" %>
  <main class="main">
    <h1 class="page-title animate">Transfer Money</h1>
    <p class="page-subtitle animate delay-1">Send funds to another SimpleBank account</p>

    <div class="grid-2">
      <div class="stat-card blue animate delay-1" style="padding:28px">
        <div class="balance-label">Your Balance</div>
        <div class="balance-display" style="font-size:2.2rem">Rs. <%= String.format("%.2f", balance) %></div>
        <div class="stat-sub">After transfer, your balance will be deducted</div>
      </div>

      <div class="card animate delay-2">
        <div class="card-title">Transfer Details</div>
        <% if (!msg.isEmpty()) { %>
          <div class="alert alert-<%= msgType %>"><%= msg %></div>
        <% } %>
        <form method="post">
          <div class="form-group">
            <label>Recipient Username</label>
            <input type="text" name="toUser" placeholder="Enter recipient's username" required/>
          </div>
          <div class="form-group">
            <label>Amount (Rs.)</label>
            <input type="number" name="amount" placeholder="0.00" min="1" step="0.01" required/>
          </div>
          <button type="submit" class="btn btn-primary btn-full">Send Money</button>
        </form>
      </div>
    </div>
  </main>
</div>
</body>
</html>
