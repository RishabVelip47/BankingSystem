package bank;

import java.sql.*;
import java.util.*;

public class BankDAO {

    // ── AUTH ────────────────────────────────────────────────────────────────

    public boolean register(String name, String username, String password, String email, String phone) throws Exception {
        Connection con = DBConnection.getConnection();
        String sql = "INSERT INTO accounts (name, username, password, email, phone, balance, created_at) VALUES (?, ?, ?, ?, ?, 0, NOW())";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, name);
        ps.setString(2, username);
        ps.setString(3, password);
        ps.setString(4, email);
        ps.setString(5, phone);
        int rows = ps.executeUpdate();
        con.close();
        return rows > 0;
    }

    public boolean login(String username, String password) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM accounts WHERE username=? AND password=?");
        ps.setString(1, username);
        ps.setString(2, password);
        ResultSet rs = ps.executeQuery();
        boolean found = rs.next();
        con.close();
        return found;
    }

    public boolean adminLogin(String username, String password) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM admins WHERE username=? AND password=?");
        ps.setString(1, username);
        ps.setString(2, password);
        ResultSet rs = ps.executeQuery();
        boolean found = rs.next();
        con.close();
        return found;
    }

    // ── ACCOUNT ─────────────────────────────────────────────────────────────

    public ResultSet getAccountDetails(String username) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM accounts WHERE username=?");
        ps.setString(1, username);
        return ps.executeQuery();
    }

    public double getBalance(String username) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT balance FROM accounts WHERE username=?");
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        double balance = 0;
        if (rs.next()) balance = rs.getDouble("balance");
        con.close();
        return balance;
    }

    // ── TRANSACTIONS ─────────────────────────────────────────────────────────

    public boolean deposit(String username, double amount) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "UPDATE accounts SET balance = balance + ? WHERE username=?");
        ps.setDouble(1, amount);
        ps.setString(2, username);
        int rows = ps.executeUpdate();
        if (rows > 0) logTransaction(con, username, "DEPOSIT", amount);
        con.close();
        return rows > 0;
    }

    public String withdraw(String username, double amount) throws Exception {
        double balance = getBalance(username);
        if (amount > balance) return "Insufficient funds!";
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "UPDATE accounts SET balance = balance - ? WHERE username=?");
        ps.setDouble(1, amount);
        ps.setString(2, username);
        ps.executeUpdate();
        logTransaction(con, username, "WITHDRAW", amount);
        con.close();
        return "Success";
    }

    public String transfer(String fromUser, String toUser, double amount) throws Exception {
        // check target exists
        Connection con = DBConnection.getConnection();
        PreparedStatement check = con.prepareStatement(
            "SELECT id FROM accounts WHERE username=?");
        check.setString(1, toUser);
        ResultSet rs = check.executeQuery();
        if (!rs.next()) { con.close(); return "Recipient not found!"; }
        con.close();

        double balance = getBalance(fromUser);
        if (amount > balance) return "Insufficient funds!";

        con = DBConnection.getConnection();
        con.setAutoCommit(false);
        try {
            PreparedStatement debit = con.prepareStatement(
                "UPDATE accounts SET balance = balance - ? WHERE username=?");
            debit.setDouble(1, amount); debit.setString(2, fromUser); debit.executeUpdate();

            PreparedStatement credit = con.prepareStatement(
                "UPDATE accounts SET balance = balance + ? WHERE username=?");
            credit.setDouble(1, amount); credit.setString(2, toUser); credit.executeUpdate();

            logTransaction(con, fromUser, "TRANSFER_OUT", amount);
            logTransaction(con, toUser,   "TRANSFER_IN",  amount);

            con.commit();
        } catch (Exception e) {
            con.rollback();
            con.close();
            return "Transfer failed!";
        }
        con.close();
        return "Success";
    }

    private void logTransaction(Connection con, String username, String type, double amount) throws Exception {
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO transactions (username, type, amount, txn_date) VALUES (?, ?, ?, NOW())");
        ps.setString(1, username);
        ps.setString(2, type);
        ps.setDouble(3, amount);
        ps.executeUpdate();
    }

    public List<Map<String, Object>> getTransactions(String username) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM transactions WHERE username=? ORDER BY txn_date DESC LIMIT 20");
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        List<Map<String, Object>> list = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id",       rs.getInt("id"));
            row.put("type",     rs.getString("type"));
            row.put("amount",   rs.getDouble("amount"));
            row.put("txn_date", rs.getString("txn_date"));
            list.add(row);
        }
        con.close();
        return list;
    }

    // monthly totals for chart (last 6 months)
    public List<Map<String, Object>> getMonthlySummary(String username) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT DATE_FORMAT(txn_date,'%b %Y') as month, type, SUM(amount) as total " +
            "FROM transactions WHERE username=? AND txn_date >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
            "GROUP BY month, type ORDER BY MIN(txn_date)");
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        List<Map<String, Object>> list = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("month",  rs.getString("month"));
            row.put("type",   rs.getString("type"));
            row.put("total",  rs.getDouble("total"));
            list.add(row);
        }
        con.close();
        return list;
    }

    // ── ADMIN ────────────────────────────────────────────────────────────────

    public List<Map<String, Object>> getAllAccounts() throws Exception {
        Connection con = DBConnection.getConnection();
        ResultSet rs = con.createStatement().executeQuery(
            "SELECT * FROM accounts ORDER BY created_at DESC");
        List<Map<String, Object>> list = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id",         rs.getInt("id"));
            row.put("name",       rs.getString("name"));
            row.put("username",   rs.getString("username"));
            row.put("email",      rs.getString("email"));
            row.put("phone",      rs.getString("phone"));
            row.put("balance",    rs.getDouble("balance"));
            row.put("created_at", rs.getString("created_at"));
            list.add(row);
        }
        con.close();
        return list;
    }

    public Map<String, Object> searchAccount(String query) throws Exception {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM accounts WHERE username=? OR email=? OR name LIKE ?");
        ps.setString(1, query);
        ps.setString(2, query);
        ps.setString(3, "%" + query + "%");
        ResultSet rs = ps.executeQuery();
        Map<String, Object> row = null;
        if (rs.next()) {
            row = new LinkedHashMap<>();
            row.put("id",         rs.getInt("id"));
            row.put("name",       rs.getString("name"));
            row.put("username",   rs.getString("username"));
            row.put("email",      rs.getString("email"));
            row.put("phone",      rs.getString("phone"));
            row.put("balance",    rs.getDouble("balance"));
            row.put("created_at", rs.getString("created_at"));
        }
        con.close();
        return row;
    }

    public Map<String, Object> getAdminStats() throws Exception {
        Connection con = DBConnection.getConnection();
        Map<String, Object> stats = new LinkedHashMap<>();

        ResultSet r1 = con.createStatement().executeQuery("SELECT COUNT(*) as cnt FROM accounts");
        if (r1.next()) stats.put("totalAccounts", r1.getInt("cnt"));

        ResultSet r2 = con.createStatement().executeQuery("SELECT SUM(balance) as total FROM accounts");
        if (r2.next()) stats.put("totalBalance", r2.getDouble("total"));

        ResultSet r3 = con.createStatement().executeQuery("SELECT COUNT(*) as cnt FROM transactions WHERE DATE(txn_date)=CURDATE()");
        if (r3.next()) stats.put("todayTxns", r3.getInt("cnt"));

        ResultSet r4 = con.createStatement().executeQuery(
            "SELECT DATE_FORMAT(txn_date,'%b') as month, SUM(amount) as total FROM transactions " +
            "WHERE type='DEPOSIT' AND txn_date >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
            "GROUP BY month, MONTH(txn_date) ORDER BY MIN(txn_date)");
        List<String> months = new ArrayList<>();
        List<Double> deposits = new ArrayList<>();
        while (r4.next()) { months.add(r4.getString("month")); deposits.add(r4.getDouble("total")); }
        stats.put("months",   months);
        stats.put("deposits", deposits);

        con.close();
        return stats;
    }
}
