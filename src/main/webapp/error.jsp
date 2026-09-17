<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Error page for 404 / 500 (wired up in web.xml).

  Known issues (deliberately left in for the modernization spec to catch):
   - Shows the raw exception message (including the failing SQL text) to
     the end user -- information disclosure.
   - No correlation/incident ID; nothing is logged from here.
--%>
<%@ page isErrorPage="true" %>
<%
    Integer code = (Integer) request.getAttribute("javax.servlet.error.status_code");
    int statusCode = code == null ? 500 : code.intValue();
    String pageTitle = statusCode == 404 ? "Page not found" : "Something went wrong";
    String activeNav = "";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    Throwable root = exception;
    while (root != null && root.getCause() != null) { root = root.getCause(); }
    String detail = root == null ? (String) request.getAttribute("javax.servlet.error.message") : root.getMessage();
    String uri = (String) request.getAttribute("javax.servlet.error.request_uri");
%>
      <div class="card" style="max-width:720px;margin:40px auto 0">
        <div class="card-body" style="padding:36px;text-align:center">
          <div class="kpi-icon <%= statusCode == 404 ? "tone-navy" : "tone-danger" %>" style="margin:0 auto 16px;width:56px;height:56px;border-radius:14px">
            <svg class="ico" style="width:28px;height:28px" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.3 3.9L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17v.01"/></svg>
          </div>
          <div class="muted mono">Error <%= statusCode %></div>
          <h1 style="font-size:26px;margin:6px 0 10px"><%= pageTitle %></h1>
          <p class="muted" style="margin:0 0 22px">
            <% if (statusCode == 404) { %>The page <span class="mono"><%= uri %></span> does not exist or has moved.
            <% } else { %>EMS could not complete your request. Please try again, or contact the helpdesk if the problem continues.<% } %>
          </p>
<% if (statusCode != 404 && detail != null) { %>
          <%-- NOTE: raw exception text shown to the user. --%>
          <div class="alert alert-danger" style="text-align:left">
            <div><b>Technical details</b><span class="mono" style="word-break:break-all"><%= detail %></span></div>
          </div>
<% } %>
          <div class="actions" style="justify-content:center">
            <a class="btn" href="javascript:history.back()">Go back</a>
            <a class="btn btn-primary" href="<%= ctx %>/dashboard.jsp">Go to dashboard</a>
          </div>
        </div>
      </div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
