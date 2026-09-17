<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Sign-in page for EMS.

  Known issues (deliberately left in for the modernization spec to catch):
   - Credentials are hard-coded in this JSP and compared in plain text.
   - No lockout, no rate limiting, no CSRF token, session id not rotated
     after login (session fixation).
   - Sign-in is cosmetic: no other page checks the session, so every
     screen is reachable without logging in.
   - Username is echoed back into the page unescaped.
--%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String ctx = request.getContextPath();
    String error = null;
    String info = null;
    String username = request.getParameter("username");

    if ("logout".equals(request.getParameter("action"))) {
        session.invalidate();
        info = "You have been signed out.";
    } else if ("POST".equalsIgnoreCase(request.getMethod())) {
        String password = request.getParameter("password");
        // NOTE: hard-coded credentials.
        if ("officer".equals(username) && "ems2019".equals(password)) {
            session.setAttribute("emsUser", "Jasmine Tan");
            session.setAttribute("emsRole", "Estate Officer");
            response.sendRedirect("dashboard.jsp?msg=welcome");
            return;
        } else if ("admin".equals(username) && "admin123".equals(password)) {
            session.setAttribute("emsUser", "System Administrator");
            session.setAttribute("emsRole", "Administrator");
            response.sendRedirect("dashboard.jsp?msg=welcome");
            return;
        }
        error = "Invalid username or password for user " + username + ".";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sign in | EMS - Estate Maintenance System</title>
  <link rel="icon" type="image/svg+xml" href="<%= ctx %>/assets/favicon.svg">
  <link rel="stylesheet" href="<%= ctx %>/assets/ems.css">
</head>
<body>
<div class="login-page">
  <section class="login-hero">
    <div style="display:flex;align-items:center;gap:12px;position:relative">
      <span class="brand-mark" style="width:40px;height:40px">
        <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 20V9l4-2.5V20M9 20V4l6 3.5V20M15 20V10l4 2v8M3 20h18"/></svg>
      </span>
      <div><div class="brand-name" style="font-size:20px">EMS</div><div style="font-size:12px;opacity:.75">Estate Maintenance System</div></div>
    </div>
    <div style="position:relative">
      <h2>Every fault logged. Every estate cared for.</h2>
      <p>Raise, route and track resident maintenance requests across all managed estates, from lift faults to corridor lighting.</p>
    </div>
    <div style="position:relative;font-size:12px;opacity:.7">&copy; 2011&ndash;2026 Estate Maintenance System &middot; synthetic demonstration system</div>
    <svg class="skyline" viewBox="0 0 600 180" preserveAspectRatio="none" fill="#fff"><path d="M0 180V90h40V60h30v120h20V30h50v150h20V80h40v100h20V40h45v140h20V100h40v80h20V60h45v120h25V20h40v160h20V90h45v90z"/></svg>
  </section>

  <section class="login-form-wrap">
    <form class="login-form" method="post" action="login.jsp">
      <h1>Sign in</h1>
      <p class="muted" style="margin:0 0 24px">Use your EMS staff account.</p>
<% if (error != null) { %>
      <div class="alert alert-danger"><div><%= error %></div></div>
<% } %>
<% if (info != null) { %>
      <div class="alert alert-info"><div><%= info %></div></div>
<% } %>
      <label class="field"><span>Username</span>
        <input class="input" type="text" name="username" value="<%= username == null ? "" : username %>" autocomplete="username" autofocus>
      </label>
      <label class="field"><span>Password</span>
        <input class="input" type="password" name="password" autocomplete="current-password">
      </label>
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;font-size:13px">
        <label><input type="checkbox" name="remember"> Keep me signed in</label>
        <a href="<%= ctx %>/help.jsp#contact">Forgot password?</a>
      </div>
      <button class="btn btn-primary" type="submit" style="width:100%;justify-content:center;height:42px">Sign in</button>
      <div class="sidebar-card" style="margin:24px 0 0">
        <b>Demo accounts</b>
        officer / ems2019 &middot; admin / admin123
      </div>
      <p class="muted" style="font-size:12px;margin-top:18px">Authorised users only. Activity may be monitored. <a href="<%= ctx %>/dashboard.jsp">Continue to dashboard &rarr;</a></p>
    </form>
  </section>
</div>
</body>
</html>
