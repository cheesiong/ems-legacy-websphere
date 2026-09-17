<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Management reports: category x status matrix, estate performance and
  monthly intake. Printable; CSV comes from the /tickets endpoint.

  Known issues (deliberately left in for the modernization spec to catch):
   - Report aggregation done in JSP scriptlets over a full table scan.
   - No date-range filter; reports always cover all history.
--%>
<%@ page import="sg.demo.ems.web.EstateDAO" %>
<%@ page import="sg.demo.ems.web.ContractorDAO" %>
<%
    String pageTitle = "Reports";
    String activeNav = "reports";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    List tickets = ViewUtil.readTickets(new TicketDAO().listByEstate(null));
    List estates = ViewUtil.readRows(new EstateDAO().listEstates(), ViewUtil.ESTATE_COLUMNS);
    Map sla = ViewUtil.slaByCategory(ViewUtil.readRows(new ContractorDAO().listContractors(), ViewUtil.CONTRACTOR_COLUMNS));
    String[] cats = ViewUtil.CATEGORIES;
    String[] sts = ViewUtil.STATUSES;

    int[][] matrix = new int[cats.length][sts.length];
    int[] colTotals = new int[sts.length];
    for (int i = 0; i < tickets.size(); i++) {
        Map t = (Map) tickets.get(i);
        for (int c = 0; c < cats.length; c++) {
            if (!cats[c].equals(t.get("category"))) continue;
            for (int s = 0; s < sts.length; s++) {
                if (sts[s].equals(t.get("status"))) { matrix[c][s]++; colTotals[s]++; }
            }
        }
    }
    List months = ViewUtil.lastMonths(9);
    String generated = new java.text.SimpleDateFormat("dd MMM yyyy, HH:mm", Locale.ENGLISH).format(new Date());
%>
      <div class="page-head">
        <div>
          <div class="crumbs"><a href="<%= ctx %>/dashboard.jsp">Home</a> <span>/</span> Reports</div>
          <h1>Reports</h1>
          <p>Maintenance performance across all estates &middot; generated <%= generated %></p>
        </div>
        <div class="actions">
          <a class="btn" href="<%= ctx %>/tickets">
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 4v11M7 10l5 5 5-5M5 20h14"/></svg>
            Export CSV
          </a>
          <button class="btn btn-primary" type="button" data-print>
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round"><path d="M6 9V3h12v6M6 18H4v-7h16v7h-2M6 14h12v7H6z"/></svg>
            Print report
          </button>
        </div>
      </div>

      <div class="stack">
        <div class="card">
          <div class="card-head"><h3>Tickets by category and status</h3><span class="sub"><%= tickets.size() %> tickets</span></div>
          <div class="table-wrap">
            <table class="data">
              <thead><tr><th>Category</th><% for (int s = 0; s < sts.length; s++) { %><th class="right"><%= sts[s] %></th><% } %><th class="right">Total</th><th>Resolution target</th><th>Share</th></tr></thead>
              <tbody>
<%
    for (int c = 0; c < cats.length; c++) {
        int rowTotal = 0;
        for (int s = 0; s < sts.length; s++) rowTotal += matrix[c][s];
%>
                <tr>
                  <td><span class="cat"><%= ViewUtil.categoryIcon(cats[c]) %><%= cats[c] %></span></td>
                  <% for (int s = 0; s < sts.length; s++) { %><td class="right"><%= matrix[c][s] == 0 ? "<span class='muted'>0</span>" : String.valueOf(matrix[c][s]) %></td><% } %>
                  <td class="right"><b><%= rowTotal %></b></td>
                  <td><%= ViewUtil.slaFor(sla, cats[c]) %> days</td>
                  <td class="nowrap"><span class="progress-mini"><i style="width:<%= ViewUtil.percent(rowTotal, tickets.size()) %>%"></i></span><%= ViewUtil.percent(rowTotal, tickets.size()) %>%</td>
                </tr>
<%
    }
%>
              </tbody>
              <tfoot>
                <tr><td>Total</td><% for (int s = 0; s < sts.length; s++) { %><td class="right"><%= colTotals[s] %></td><% } %><td class="right"><%= tickets.size() %></td><td></td><td></td></tr>
              </tfoot>
            </table>
          </div>
        </div>

        <div class="cols">
          <div class="card">
            <div class="card-head"><h3>Estate performance</h3></div>
            <div class="table-wrap">
              <table class="data">
                <thead><tr><th>Estate</th><th class="right">Tickets</th><th class="right">Active</th><th class="right">Past SLA</th><th class="right">Avg age (active)</th><th>Closure rate</th></tr></thead>
                <tbody>
<%
    for (int e = 0; e < estates.size(); e++) {
        Map es = (Map) estates.get(e);
        int n = 0, active = 0, over = 0, closedN = 0;
        long ageSum = 0;
        for (int i = 0; i < tickets.size(); i++) {
            Map t = (Map) tickets.get(i);
            if (!es.get("estate_id").equals(t.get("estate_id"))) continue;
            n++;
            if ("Closed".equals(t.get("status"))) { closedN++; continue; }
            active++;
            ageSum += ViewUtil.daysOpen((String) t.get("opened_date"));
            if (ViewUtil.isOverdue(t, ViewUtil.slaFor(sla, (String) t.get("category")))) over++;
        }
        int rate = ViewUtil.percent(closedN, n);
%>
                  <tr>
                    <td><a href="<%= ctx %>/estate-detail.jsp?estateId=<%= es.get("estate_id") %>"><b><%= es.get("estate_name") %></b></a><div class="muted" style="font-size:12px"><%= es.get("estate_id") %> &middot; <%= es.get("region") %></div></td>
                    <td class="right"><%= n %></td>
                    <td class="right"><%= active %></td>
                    <td class="right"><%= over > 0 ? "<b style='color:var(--danger)'>" + over + "</b>" : "0" %></td>
                    <td class="right"><%= active == 0 ? "&ndash;" : (ageSum / active) + " days" %></td>
                    <td class="nowrap"><span class="progress-mini"><i style="width:<%= rate %>%"></i></span><%= rate %>%</td>
                  </tr>
<%
    }
%>
                </tbody>
              </table>
            </div>
          </div>

          <div class="card">
            <div class="card-head"><h3>Monthly intake</h3><span class="sub">Tickets opened</span></div>
            <div class="table-wrap">
              <table class="data">
                <thead><tr><th>Month</th><th class="right">Opened</th><th class="right">Still active</th></tr></thead>
                <tbody>
<%
    for (int m = months.size() - 1; m >= 0; m--) {
        String mk = (String) months.get(m);
        int opened = 0, stillActive = 0;
        for (int i = 0; i < tickets.size(); i++) {
            Map t = (Map) tickets.get(i);
            if (!mk.equals(ViewUtil.monthKey((String) t.get("opened_date")))) continue;
            opened++;
            if (!"Closed".equals(t.get("status"))) stillActive++;
        }
%>
                  <tr>
                    <td><%= ViewUtil.monthLabel(mk) %> <%= mk.substring(0, 4) %></td>
                    <td class="right"><%= opened %></td>
                    <td class="right"><%= stillActive %></td>
                  </tr>
<%
    }
%>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
