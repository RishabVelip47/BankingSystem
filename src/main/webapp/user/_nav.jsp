<%-- Shared sidebar nav - included in user pages (account, deposit, withdraw, transfer, transactions) --%>
  <aside class="sidebar">
    <div class="sidebar-logo">Simple<span>Bank</span></div>
    <nav class="nav-links">
      <a href="dashboard.jsp"    class="nav-link <%= request.getRequestURI().contains("dashboard")    ? "active" : "" %>">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
        Dashboard
      </a>
      <a href="account.jsp"      class="nav-link <%= request.getRequestURI().contains("account")      ? "active" : "" %>">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/></svg>
        Account
      </a>
      <a href="deposit.jsp"      class="nav-link <%= request.getRequestURI().contains("deposit")      ? "active" : "" %>">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 5v14M5 12l7 7 7-7"/></svg>
        Deposit
      </a>
      <a href="withdraw.jsp"     class="nav-link <%= request.getRequestURI().contains("withdraw")     ? "active" : "" %>">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 19V5M5 12l7-7 7 7"/></svg>
        Withdraw
      </a>
      <a href="transfer.jsp"     class="nav-link <%= request.getRequestURI().contains("transfer")     ? "active" : "" %>">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M7 16V4m0 0L3 8m4-4 4 4M17 8v12m0 0 4-4m-4 4-4-4"/></svg>
        Transfer
      </a>
      <a href="transactions.jsp" class="nav-link <%= request.getRequestURI().contains("transactions") ? "active" : "" %>">
        <svg fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2M9 5a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2M9 5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2"/></svg>
        Transactions
      </a>
    </nav>
    <div class="sidebar-footer">
      <div class="sidebar-user">Logged in as<strong><%= session.getAttribute("username") %></strong></div>
      <a href="../logout.jsp" class="btn btn-outline" style="width:100%;font-size:.82rem;padding:9px">Sign Out</a>
    </div>
  </aside>
