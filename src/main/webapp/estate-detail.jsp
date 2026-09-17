<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Estate profile: office details, ticket summary, units with reported
  faults, and the estate's ticket list.

  Known issues (deliberately left in for the modernization spec to catch):
   - estateId request parameter is concatenated into SQL by EstateDAO and
     TicketDAO, and echoed into the page unescaped.
   - Unit roll-up computed in the view on every request.
--%>
<%@ page import="sg.demo.ems.web.EstateDAO" %>
<%
    String estateId = request.getParameter("estateId");
    String pageTitle = "Estate " + estateId;
    String activeNav = "estates";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    List el = ViewUtil.readRows(new EstateDAO().findById(estateId), ViewUtil.ESTATE_COLUMNS);
    if (el.isEmpty()) {
%>
      <div class="page-head">
        <div>
          <div class="crumbs"><a href="<%= ctx %>/dashboard.jsp">Home</a> <span>/</span> <a href="<%= ctx %>/estates.jsp">Estates</a> <span>/</span> Not found</div>
          <h1>Estate not found</h1>
          <p>No estate with ID <b><%= estateId %></b>.</p>
        </div>
        <div class="actions"><a class="btn" href="<%= ctx %>/estates.jsp">Back to estates</a></div>
      </div>
<%
    } else {
        Map es = (Map) el.get(0);
        List tickets = ViewUtil.readTickets(new TicketDAO().listByEstate(estateId));
        ViewUtil.sortByOpenedDesc(tickets);

        int open = 0, prog = 0, closed = 0;
        Map units = new TreeMap();   // unit -> int[]{total, active}
        Map cats = new LinkedHashMap();
        for (int i = 0; i < tickets.size(); i++) {
            Map t = (Map) tickets.get(i);
            String st = (String) t.get("status");
            boolean active = !"Closed".equals(st);
            if ("Open".equals(st)) open++; else if ("In Progress".equals(st)) prog++; else closed++;
            int[] u = (int[]) units.get(t.get("unit_id"));
            if (u == null) { u = new int[2]; units.put(t.get("unit_id"), u); }
            u[0]++;
            if (active) u[1]++;
            Integer cc = (Integer) cats.get(t.get("category"));
            cats.put(t.get("category"), new Integer(cc == null ? 1 : cc.intValue() + 1));
        }
        int maxCat = 1;
        for (Iterator it = cats.values().iterator(); it.hasNext();) { int v = ((Integer) it.next()).intValue(); if (v > maxCat) maxCat = v; }
%>
      <div class="page-head">
        <div>
          <div class="crumbs"><a href="<%= ctx %>/dashboard.jsp">Home</a> <span>/</span> <a href="<%= ctx %>/estates.jsp">Estates</a> <span>/</span> <%= es.get("estate_name") %></div>
          <h1><%= es.get("estate_name") %> <span class="muted" style="font-weight:500;font-size:16px"><%= es.get("estate_id") %></span></h1>
          <p><%= es.get("region") %> region &middot; <%= es.get("block_count") %> blocks &middot; <%= es.get("unit_count") %> units &middot; completed <%= es.get("year_completed") %></p>
        </div>
        <div class="actions">
          <a class="btn" href="<%= ctx %>/ticket-list.jsp?estateId=<%= estateId %>">Open in ticket list</a>
          <a class="btn btn-primary" href="<%= ctx %>/ticket-form.jsp?estateId=<%= estateId %>">
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
            Raise ticket here
          </a>
        </div>
      </div>

      <div class="kpis four">
        <div class="card kpi"><div class="kpi-icon tone-navy"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><path d="M4 7a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v2a2 2 0 0 0 0 4v2a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-2a2 2 0 0 0 0-4z"/></svg></div><div><div class="kpi-label">Tickets</div><div class="kpi-value"><%= tickets.size() %></div></div></div>
        <div class="card kpi"><div class="kpi-icon tone-open"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="9"/><path d="M12 8v4l2.5 2.5"/></svg></div><div><div class="kpi-label">Open</div><div class="kpi-value"><%= open %></div></div></div>
        <div class="card kpi"><div class="kpi-icon tone-progress"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><path d="M14.7 6.3a4 4 0 0 0-5.4 5.4L3 18l3 3 6.3-6.3a4 4 0 0 0 5.4-5.4l-2.5 2.5-2.4-.6-.6-2.4z"/></svg></div><div><div class="kpi-label">In progress</div><div class="kpi-value"><%= prog %></div></div></div>
        <div class="card kpi"><div class="kpi-icon tone-closed"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="9"/><path d="M8 12l3 3 5-6"/></svg></div><div><div class="kpi-label">Closed</div><div class="kpi-value"><%= closed %></div></div></div>
      </div>

      <div class="cols">
        <div class="stack">
          <div class="card">
            <div class="card-head"><h3>Tickets</h3><a class="sub" href="<%= ctx %>/ticket-list.jsp?estateId=<%= estateId %>">Manage &rarr;</a></div>
            <div class="table-wrap">
              <table class="data">
                <thead><tr><th>Ticket</th><th>Unit</th><th>Category</th><th>Description</th><th>Opened</th><th>Status</th></tr></thead>
                <tbody>
<%
        for (int i = 0; i < tickets.size(); i++) {
            Map t = (Map) tickets.get(i);
%>
                  <tr>
                    <td class="nowrap"><a class="mono" href="<%= ctx %>/ticket-detail.jsp?ticketId=<%= t.get("ticket_id") %>"><b><%= t.get("ticket_id") %></b></a></td>
                    <td class="nowrap"><%= t.get("unit_id") %></td>
                    <td><span class="cat"><%= ViewUtil.categoryIcon((String) t.get("category")) %><%= t.get("category") %></span></td>
                    <td class="desc"><%= t.get("description") %></td>
                    <td class="nowrap"><%= ViewUtil.formatDate((String) t.get("opened_date")) %></td>
                    <td><span class="badge <%= ViewUtil.statusClass((String) t.get("status")) %>"><%= t.get("status") %></span></td>
                  </tr>
<%
        }
        if (tickets.isEmpty()) {
%>
                  <tr><td colspan="6"><div class="empty">No tickets recorded for this estate.</div></td></tr>
<%
        }
%>
                </tbody>
              </table>
            </div>
          </div>

          <div class="card">
            <div class="card-head"><h3>Units with reported faults</h3><span class="sub"><%= units.size() %> of <%= es.get("unit_count") %> units</span></div>
            <div class="table-wrap">
              <table class="data">
                <thead><tr><th>Unit</th><th class="right">Tickets raised</th><th class="right">Active</th><th>Flag</th></tr></thead>
                <tbody>
<%
        for (Iterator it = units.entrySet().iterator(); it.hasNext();) {
            Map.Entry en = (Map.Entry) it.next();
            int[] u = (int[]) en.getValue();
%>
                  <tr>
                    <td class="mono"><%= en.getKey() %></td>
                    <td class="right"><%= u[0] %></td>
                    <td class="right"><%= u[1] %></td>
                    <td><% if (u[0] >= 3) { %><span class="badge danger plain">Repeat faults</span><% } else if (u[1] > 0) { %><span class="badge progress plain">Follow up</span><% } else { %><span class="muted">&ndash;</span><% } %></td>
                  </tr>
<%
        }
%>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div class="stack">
          <div class="card">
            <div class="card-head"><h3>Estate office</h3></div>
            <div class="card-body">
              <div style="display:flex;gap:12px;align-items:center;margin-bottom:14px">
                <span class="avatar"><%= ViewUtil.initials((String) es.get("officer_name")) %></span>
                <div><b><%= es.get("officer_name") %></b><div class="muted" style="font-size:12.5px">Estate Officer</div></div>
              </div>
              <dl class="kv" style="grid-template-columns:80px 1fr">
                <dt>Address</dt><dd><%= es.get("office_address") %></dd>
                <dt>Phone</dt><dd><%= es.get("office_phone") %></dd>
                <dt>Hours</dt><dd><%= es.get("office_hours") %></dd>
              </dl>
            </div>
          </div>

          <div class="card">
            <div class="card-head"><h3>Faults by category</h3></div>
            <div class="card-body">
<%
        if (cats.isEmpty()) {
%>
              <p class="muted" style="margin:0">No faults reported.</p>
<%
        }
        for (Iterator it = cats.entrySet().iterator(); it.hasNext();) {
            Map.Entry en = (Map.Entry) it.next();
            int n = ((Integer) en.getValue()).intValue();
%>
              <div class="bar-row" style="grid-template-columns:150px 1fr 24px">
                <span class="bar-label"><span class="cat"><%= ViewUtil.categoryIcon((String) en.getKey()) %><%= en.getKey() %></span></span>
                <div class="bar-track"><div class="bar-fill" style="width:<%= n * 100 / maxCat %>%"></div></div>
                <div class="bar-val"><%= n %></div>
              </div>
<%
        }
%>
            </div>
          </div>
        </div>
      </div>
<%
    }
%>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
