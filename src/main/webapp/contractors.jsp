<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Term-contractor register with contract expiry, SLA and current workload.

  Known issues (deliberately left in for the modernization spec to catch):
   - SLA / overdue business rule evaluated inside the view (via ViewUtil).
   - Contractor contact details exposed to every user of the module.
   - Contract-expiry threshold (90 days) hard-coded in the page.
--%>
<%@ page import="sg.demo.ems.web.ContractorDAO" %>
<%
    String pageTitle = "Contractors";
    String activeNav = "contractors";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    List contractors = ViewUtil.readRows(new ContractorDAO().listContractors(), ViewUtil.CONTRACTOR_COLUMNS);
    List tickets = ViewUtil.readTickets(new TicketDAO().listByEstate(null));
    int expiring = 0, totalActive = 0, totalOverdue = 0;
    double ratingSum = 0;
    // NOTE: first pass just for the summary tiles (the table loop repeats the same work).
    for (int i = 0; i < contractors.size(); i++) {
        Map c = (Map) contractors.get(i);
        int sla = Integer.parseInt((String) c.get("resolution_days"));
        for (int j = 0; j < tickets.size(); j++) {
            Map t = (Map) tickets.get(j);
            if (!c.get("category").equals(t.get("category")) || "Closed".equals(t.get("status"))) continue;
            totalActive++;
            if (ViewUtil.isOverdue(t, sla)) totalOverdue++;
        }
        long dl = ViewUtil.daysUntil((String) c.get("contract_end"));
        if (dl >= 0 && dl <= 90) expiring++;
        ratingSum += Double.parseDouble((String) c.get("rating"));
    }
%>
      <div class="page-head">
        <div>
          <div class="crumbs"><a href="<%= ctx %>/dashboard.jsp">Home</a> <span>/</span> Contractors</div>
          <h1>Term Contractors</h1>
          <p>Contracted service providers, their service levels and current workload.</p>
        </div>
        <div class="actions">
          <button class="btn" type="button" data-print>
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round"><path d="M6 9V3h12v6M6 18H4v-7h16v7h-2M6 14h12v7H6z"/></svg>
            Print register
          </button>
        </div>
      </div>

      <div class="kpis four">
        <div class="card kpi"><div><div class="kpi-label">Contractors</div><div class="kpi-value"><%= contractors.size() %></div><div class="kpi-note">One per trade</div></div></div>
        <div class="card kpi"><div><div class="kpi-label">Active jobs</div><div class="kpi-value"><%= totalActive %></div><div class="kpi-note">Open + in progress</div></div></div>
        <div class="card kpi"><div><div class="kpi-label">Jobs past SLA</div><div class="kpi-value" style="color:var(--danger)"><%= totalOverdue %></div><div class="kpi-note">Candidates for liquidated damages</div></div></div>
        <div class="card kpi"><div><div class="kpi-label">Contracts due for renewal</div><div class="kpi-value" style="color:var(--progress)"><%= expiring %></div><div class="kpi-note">Within 90 days &middot; avg rating <%= contractors.isEmpty() ? "-" : String.valueOf(Math.round(ratingSum / contractors.size() * 10) / 10.0) %></div></div></div>
      </div>

      <div class="card">
        <div class="table-wrap">
          <table class="data">
            <thead>
              <tr><th>Contractor</th><th>Trade</th><th>Contact</th><th title="Respond within / resolve within">SLA</th><th>Contract</th><th>Rating</th><th>Workload</th></tr>
            </thead>
            <tbody>
<%
    for (int i = 0; i < contractors.size(); i++) {
        Map c = (Map) contractors.get(i);
        String cat = (String) c.get("category");
        int sla = Integer.parseInt((String) c.get("resolution_days"));
        int active = 0, over = 0;
        for (int j = 0; j < tickets.size(); j++) {
            Map t = (Map) tickets.get(j);
            if (!cat.equals(t.get("category")) || "Closed".equals(t.get("status"))) continue;
            active++;
            if (ViewUtil.isOverdue(t, sla)) over++;
        }
        long daysLeft = ViewUtil.daysUntil((String) c.get("contract_end"));
        boolean isExpiring = daysLeft >= 0 && daysLeft <= 90;   // NOTE: hard-coded threshold
%>
              <tr>
                <td>
                  <div style="display:flex;gap:10px;align-items:center">
                    <span class="avatar" style="background:var(--teal);width:34px;height:34px"><%= ViewUtil.initials((String) c.get("company_name")) %></span>
                    <div style="min-width:150px"><b><%= c.get("company_name") %></b><div class="muted mono" style="font-size:11.5px"><%= c.get("contractor_id") %></div></div>
                  </div>
                </td>
                <td><a class="cat" href="<%= ctx %>/ticket-list.jsp?category=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>"><%= ViewUtil.categoryIcon(cat) %><%= cat %></a></td>
                <td><%= c.get("contact_person") %> &middot; <span class="nowrap"><%= c.get("contact_phone") %></span><div style="font-size:12px"><a href="mailto:<%= c.get("contact_email") %>"><%= c.get("contact_email") %></a></div></td>
                <td class="nowrap">Respond <b><%= c.get("response_hours") %>h</b><div class="muted" style="font-size:12px">Resolve <%= sla %> days</div></td>
                <td class="nowrap">
                  <span style="font-size:12.5px">until <%= ViewUtil.formatDate((String) c.get("contract_end")) %></span><br>
                  <% if (daysLeft < 0) { %><span class="badge danger plain">Expired</span>
                  <% } else if (isExpiring) { %><span class="badge progress plain">Renew in <%= daysLeft %> days</span>
                  <% } else { %><span class="badge closed plain">Active</span><% } %>
                </td>
                <td class="nowrap"><span class="stars">&#9733;</span> <b><%= c.get("rating") %></b></td>
                <td>
                  <span class="nowrap"><b><%= active %></b> active</span>
                  <% if (over > 0) { %><div><span class="badge danger plain" style="margin-top:4px"><%= over %> past SLA</span></div><% } %>
                </td>
              </tr>
<%
    }
%>
            </tbody>
          </table>
        </div>
      </div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
