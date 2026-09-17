<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Operations dashboard (landing page) for the EMS web module.

  Known issues (deliberately left in for the modernization spec to catch):
   - All aggregation (counts, SLA/overdue, monthly trend) is computed in
     scriptlets on every request by scanning the full ticket table.
   - DAO calls from the view; no service layer, no caching.
   - Values written into the page without output encoding.
--%>
<%@ page import="sg.demo.ems.web.EstateDAO" %>
<%@ page import="sg.demo.ems.web.ContractorDAO" %>
<%
    String pageTitle = "Dashboard";
    String activeNav = "dashboard";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    List tickets = ViewUtil.readTickets(new TicketDAO().listByEstate(null));
    List estates = ViewUtil.readRows(new EstateDAO().listEstates(), ViewUtil.ESTATE_COLUMNS);
    Map sla = ViewUtil.slaByCategory(ViewUtil.readRows(new ContractorDAO().listContractors(), ViewUtil.CONTRACTOR_COLUMNS));

    int total = tickets.size(), open = 0, inProgress = 0, closed = 0, overdue = 0;
    Map byCategory = new LinkedHashMap();
    for (int c = 0; c < ViewUtil.CATEGORIES.length; c++) { byCategory.put(ViewUtil.CATEGORIES[c], new int[1]); }
    Map byEstate = new LinkedHashMap();
    for (int e = 0; e < estates.size(); e++) { byEstate.put(((Map) estates.get(e)).get("estate_id"), new int[3]); }
    List months = ViewUtil.lastMonths(9);
    Map byMonth = new HashMap();
    List attention = new ArrayList();

    for (int i = 0; i < tickets.size(); i++) {
        Map t = (Map) tickets.get(i);
        String st = (String) t.get("status");
        String cat = (String) t.get("category");
        int sIdx = 2;
        if ("Open".equals(st)) { open++; sIdx = 0; }
        else if ("In Progress".equals(st)) { inProgress++; sIdx = 1; }
        else { closed++; }
        if (ViewUtil.isOverdue(t, ViewUtil.slaFor(sla, cat))) { overdue++; attention.add(t); }
        if (byCategory.get(cat) == null) { byCategory.put(cat, new int[1]); }
        ((int[]) byCategory.get(cat))[0]++;
        int[] est = (int[]) byEstate.get(t.get("estate_id"));
        if (est != null) { est[sIdx]++; }
        String mk = ViewUtil.monthKey((String) t.get("opened_date"));
        Integer mc = (Integer) byMonth.get(mk);
        byMonth.put(mk, new Integer(mc == null ? 1 : mc.intValue() + 1));
    }
    ViewUtil.sortByOpenedDesc(attention);
    Collections.reverse(attention);

    int maxCat = 1;
    for (Iterator it = byCategory.values().iterator(); it.hasNext();) { int v = ((int[]) it.next())[0]; if (v > maxCat) maxCat = v; }
    int maxMonth = 1;
    for (int m = 0; m < months.size(); m++) { Integer v = (Integer) byMonth.get(months.get(m)); if (v != null && v.intValue() > maxMonth) maxMonth = v.intValue(); }

    List recent = new ArrayList(tickets);
    ViewUtil.sortByOpenedDesc(recent);

    int hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);
    String greeting = hour < 12 ? "Good morning" : (hour < 18 ? "Good afternoon" : "Good evening");
    String firstName = emsUser.indexOf(' ') > 0 ? emsUser.substring(0, emsUser.indexOf(' ')) : emsUser;
    int pOpen = ViewUtil.percent(open, total), pProg = ViewUtil.percent(inProgress, total);
%>
      <div class="page-head">
        <div>
          <div class="crumbs">Home <span>/</span> Dashboard</div>
          <h1><%= greeting %>, <%= firstName %></h1>
          <p><%= ViewUtil.today() %> &middot; Here is what is happening across your <%= estates.size() %> estates.</p>
        </div>
        <div class="actions">
          <a class="btn" href="<%= ctx %>/reports.jsp">
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/></svg>
            View reports
          </a>
          <a class="btn btn-primary" href="<%= ctx %>/ticket-form.jsp">
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
            Raise ticket
          </a>
        </div>
      </div>

      <div class="kpis">
        <div class="card kpi">
          <div class="kpi-icon tone-navy"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><path d="M4 7a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v2a2 2 0 0 0 0 4v2a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-2a2 2 0 0 0 0-4z"/></svg></div>
          <div><div class="kpi-label">Total tickets</div><div class="kpi-value"><%= total %></div><div class="kpi-note">All estates, all time</div></div>
        </div>
        <a class="card kpi" href="<%= ctx %>/ticket-list.jsp?status=Open" style="color:inherit;text-decoration:none">
          <div class="kpi-icon tone-open"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 8v4l2.5 2.5"/></svg></div>
          <div><div class="kpi-label">Open</div><div class="kpi-value"><%= open %></div><div class="kpi-note">Awaiting assignment</div></div>
        </a>
        <a class="card kpi" href="<%= ctx %>/ticket-list.jsp?status=In+Progress" style="color:inherit;text-decoration:none">
          <div class="kpi-icon tone-progress"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14.7 6.3a4 4 0 0 0-5.4 5.4L3 18l3 3 6.3-6.3a4 4 0 0 0 5.4-5.4l-2.5 2.5-2.4-.6-.6-2.4z"/></svg></div>
          <div><div class="kpi-label">In progress</div><div class="kpi-value"><%= inProgress %></div><div class="kpi-note">With contractors</div></div>
        </a>
        <a class="card kpi" href="<%= ctx %>/ticket-list.jsp?status=Closed" style="color:inherit;text-decoration:none">
          <div class="kpi-icon tone-closed"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M8 12l3 3 5-6"/></svg></div>
          <div><div class="kpi-label">Closed</div><div class="kpi-value"><%= closed %></div><div class="kpi-note"><%= ViewUtil.percent(closed, total) %>% closure rate</div></div>
        </a>
        <div class="card kpi">
          <div class="kpi-icon tone-danger"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.3 3.9L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17v.01"/></svg></div>
          <div><div class="kpi-label">Past SLA</div><div class="kpi-value"><%= overdue %></div><div class="kpi-note">Unresolved beyond target</div></div>
        </div>
      </div>

      <div class="cols" style="margin-bottom:18px">
        <div class="card">
          <div class="card-head"><h3>Tickets opened per month <span class="sub">&middot; last 9 months</span></h3></div>
          <div class="card-body">
            <div class="columns-chart">
<%
    for (int m = 0; m < months.size(); m++) {
        Integer v = (Integer) byMonth.get(months.get(m));
        int n = v == null ? 0 : v.intValue();
%>
              <div class="col" title="<%= n %> tickets">
                <div class="col-val"><%= n %></div>
                <div class="col-bar" style="height:<%= Math.max(2, n * 100 / maxMonth) %>%"></div>
                <div class="col-lab"><%= ViewUtil.monthLabel((String) months.get(m)) %></div>
              </div>
<%
    }
%>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-head"><h3>Status mix</h3><a class="sub" href="<%= ctx %>/ticket-list.jsp">View all</a></div>
          <div class="card-body" style="display:flex;align-items:center;gap:22px">
            <div style="width:140px;height:140px;border-radius:50%;flex:none;position:relative;background:conic-gradient(var(--open) 0 <%= pOpen %>%, #e0912f <%= pOpen %>% <%= pOpen + pProg %>%, #4fb286 <%= pOpen + pProg %>% 100%)">
              <div style="position:absolute;inset:22px;background:#fff;border-radius:50%;display:grid;place-items:center;text-align:center">
                <div><div class="kpi-value"><%= total %></div><div class="kpi-note">tickets</div></div>
              </div>
            </div>
            <div style="flex:1;display:grid;gap:12px">
              <div><span class="badge open">Open</span><b style="float:right"><%= open %></b></div>
              <div><span class="badge progress">In Progress</span><b style="float:right"><%= inProgress %></b></div>
              <div><span class="badge closed">Closed</span><b style="float:right"><%= closed %></b></div>
            </div>
          </div>
        </div>
      </div>

      <div class="cols" style="margin-bottom:18px">
        <div class="card">
          <div class="card-head"><h3>Tickets by category</h3><a class="sub" href="<%= ctx %>/reports.jsp">Breakdown</a></div>
          <div class="card-body">
<%
    for (Iterator it = byCategory.entrySet().iterator(); it.hasNext();) {
        Map.Entry en = (Map.Entry) it.next();
        int n = ((int[]) en.getValue())[0];
%>
            <div class="bar-row">
              <a class="bar-label" href="<%= ctx %>/ticket-list.jsp?category=<%= java.net.URLEncoder.encode((String) en.getKey(), "UTF-8") %>"><span class="cat"><%= ViewUtil.categoryIcon((String) en.getKey()) %><%= en.getKey() %></span></a>
              <div class="bar-track"><div class="bar-fill" style="width:<%= n * 100 / maxCat %>%"></div></div>
              <div class="bar-val"><%= n %></div>
            </div>
<%
    }
%>
          </div>
        </div>

        <div class="card">
          <div class="card-head"><h3>Needs attention</h3><span class="badge danger"><%= overdue %> past SLA</span></div>
          <div class="card-body flush">
<%
    if (attention.isEmpty()) {
%>
            <div class="empty">Nothing overdue. Nice work.</div>
<%
    }
    for (int a = 0; a < attention.size() && a < 5; a++) {
        Map t = (Map) attention.get(a);
%>
            <a class="list-item" href="<%= ctx %>/ticket-detail.jsp?ticketId=<%= t.get("ticket_id") %>">
              <span class="cat-tile" style="background:var(--danger-bg);color:var(--danger)"><%= ViewUtil.categoryIcon((String) t.get("category")) %></span>
              <span class="grow">
                <span class="title" style="display:block"><%= t.get("description") %></span>
                <span class="meta"><%= t.get("ticket_id") %> &middot; <%= t.get("estate_id") %> / <%= t.get("unit_id") %> &middot; <%= ViewUtil.daysOpen((String) t.get("opened_date")) %> days open</span>
              </span>
              <span class="badge <%= ViewUtil.statusClass((String) t.get("status")) %>"><%= t.get("status") %></span>
            </a>
<%
    }
%>
          </div>
        </div>
      </div>

      <div class="cols">
        <div class="card">
          <div class="card-head"><h3>Recently raised</h3><a class="sub" href="<%= ctx %>/ticket-list.jsp">All tickets &rarr;</a></div>
          <div class="table-wrap">
            <table class="data">
              <thead><tr><th>Ticket</th><th>Category</th><th>Location</th><th>Opened</th><th>Status</th></tr></thead>
              <tbody>
<%
    for (int r = 0; r < recent.size() && r < 6; r++) {
        Map t = (Map) recent.get(r);
%>
                <tr>
                  <td><a class="mono" href="<%= ctx %>/ticket-detail.jsp?ticketId=<%= t.get("ticket_id") %>"><b><%= t.get("ticket_id") %></b></a><div class="muted desc" style="font-size:12.5px"><%= t.get("description") %></div></td>
                  <td><span class="cat"><%= ViewUtil.categoryIcon((String) t.get("category")) %><%= t.get("category") %></span></td>
                  <td class="nowrap"><%= t.get("estate_id") %> / <%= t.get("unit_id") %></td>
                  <td class="nowrap"><%= ViewUtil.formatDate((String) t.get("opened_date")) %></td>
                  <td><span class="badge <%= ViewUtil.statusClass((String) t.get("status")) %>"><%= t.get("status") %></span></td>
                </tr>
<%
    }
%>
              </tbody>
            </table>
          </div>
        </div>

        <div class="card">
          <div class="card-head"><h3>Estate workload</h3><a class="sub" href="<%= ctx %>/estates.jsp">Estates &rarr;</a></div>
          <div class="card-body">
            <div class="legend" style="margin-bottom:14px"><span><i style="background:var(--open)"></i>Open</span><span><i style="background:#e0912f"></i>In progress</span><span><i style="background:#4fb286"></i>Closed</span></div>
<%
    for (int e = 0; e < estates.size(); e++) {
        Map es = (Map) estates.get(e);
        int[] cnt = (int[]) byEstate.get(es.get("estate_id"));
        int sum = cnt[0] + cnt[1] + cnt[2];
        int scale = sum == 0 ? 1 : sum;
%>
            <div class="bar-row" style="grid-template-columns:120px 1fr 28px">
              <a class="bar-label" href="<%= ctx %>/estate-detail.jsp?estateId=<%= es.get("estate_id") %>"><%= es.get("estate_name") %></a>
              <div class="bar-track" style="height:12px">
                <div class="bar-fill open" style="width:<%= cnt[0] * 100 / scale %>%"></div>
                <div class="bar-fill progress" style="width:<%= cnt[1] * 100 / scale %>%"></div>
                <div class="bar-fill closed" style="width:<%= cnt[2] * 100 / scale %>%"></div>
              </div>
              <div class="bar-val"><%= sum %></div>
            </div>
<%
    }
%>
          </div>
        </div>
      </div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
