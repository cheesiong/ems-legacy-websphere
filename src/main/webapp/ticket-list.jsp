<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Server-rendered view for EMS-WEB-TICKETS. Written the way JSP views
  commonly looked before templating engines/MVC frameworks were standard:
  Java scriptlets (<% %>) mixed directly into markup, direct JDBC-style
  access from the view layer via TicketDAO, no escaping of output.

  Known issues (deliberately left in for the modernization spec to catch):
   - Business/data logic (TicketDAO calls) invoked directly from the view.
   - Ticket fields (including category/description, resident-entered text)
     are written straight into the HTML with no escaping -- a stored-XSS
     surface if a resident's free-text description ever contains markup.
   - No pagination; loads every ticket for the estate on every request.
   - The estateId request parameter is passed straight into TicketDAO's
     string-concatenated SQL.
   - Status / category / keyword filtering is done in the view, row by row,
     after a second full-table query is run just to count the status tabs.
   - Search term and filter values are reflected back unescaped.
--%>
<%@ page import="sg.demo.ems.web.legacydb.LegacyResultSet" %>
<%@ page import="sg.demo.ems.web.TicketDAO" %>
<%@ page import="sg.demo.ems.web.EstateDAO" %>
<%
    String pageTitle = "Maintenance Tickets";
    String activeNav = "tickets";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    String estateId = request.getParameter("estateId");
    if (estateId != null && estateId.length() == 0) { estateId = null; }
    String status = request.getParameter("status");
    if (status != null && status.length() == 0) { status = null; }
    String category = request.getParameter("category");
    if (category != null && category.length() == 0) { category = null; }
    String q = request.getParameter("q");
    if (q != null && q.trim().length() == 0) { q = null; }

    TicketDAO ticketDAO = new TicketDAO();
    EstateDAO estateDAO = new EstateDAO();

    // estate names for the filter drop-down and the Location column
    Map estateNames = new LinkedHashMap();
    LegacyResultSet ers = estateDAO.listEstates();
    while (ers.next()) { estateNames.put(ers.getString("estate_id"), ers.getString("estate_name")); }

    // pass 1: count rows per status for the tabs (full query #1)
    int cAll = 0, cOpen = 0, cProg = 0, cClosed = 0;
    LegacyResultSet countRs = ticketDAO.listByEstate(estateId);
    while (countRs.next()) {
        cAll++;
        String s = countRs.getString("status");
        if ("Open".equals(s)) cOpen++; else if ("In Progress".equals(s)) cProg++; else if ("Closed".equals(s)) cClosed++;
    }

    // pass 2: the rows themselves (full query #2)
    LegacyResultSet rs = ticketDAO.listByEstate(estateId);

    String base = "ticket-list.jsp?q=" + (q == null ? "" : java.net.URLEncoder.encode(q, "UTF-8"))
            + "&estateId=" + (estateId == null ? "" : estateId)
            + "&category=" + (category == null ? "" : java.net.URLEncoder.encode(category, "UTF-8"));
    String exportUrl = "tickets" + (estateId == null ? "" : "?estateId=" + estateId);
    String here = base + (status == null ? "" : "&status=" + java.net.URLEncoder.encode(status, "UTF-8"))
            + "&msg=updated&ticketId={ticketId}";
%>
      <div class="page-head">
        <div>
          <div class="crumbs"><a href="<%= ctx %>/dashboard.jsp">Home</a> <span>/</span> Tickets</div>
          <h1>Maintenance Tickets<% if (estateId != null) { %> - <%= estateNames.get(estateId) == null ? estateId : estateNames.get(estateId) %><% } %></h1>
          <p>Track, update and close resident maintenance requests across all estates.</p>
        </div>
        <div class="actions">
          <a class="btn" href="<%= exportUrl %>" title="Plain-text export from the /tickets endpoint">
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 4v11M7 10l5 5 5-5M5 20h14"/></svg>
            Export CSV
          </a>
          <a class="btn btn-primary" href="ticket-form.jsp<% if (estateId != null) { %>?estateId=<%= estateId %><% } %>">
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
            Raise a new ticket
          </a>
        </div>
      </div>

      <div class="card">
        <div class="tabs">
          <a class="tab<%= status == null ? " active" : "" %>" href="<%= base %>">All <span class="n"><%= cAll %></span></a>
          <a class="tab<%= "Open".equals(status) ? " active" : "" %>" href="<%= base %>&status=Open">Open <span class="n"><%= cOpen %></span></a>
          <a class="tab<%= "In Progress".equals(status) ? " active" : "" %>" href="<%= base %>&status=In+Progress">In progress <span class="n"><%= cProg %></span></a>
          <a class="tab<%= "Closed".equals(status) ? " active" : "" %>" href="<%= base %>&status=Closed">Closed <span class="n"><%= cClosed %></span></a>
        </div>

        <form class="filters" method="get" action="ticket-list.jsp">
          <% if (status != null) { %><input type="hidden" name="status" value="<%= status %>"><% } %>
          <input class="input input-sm grow" type="search" name="q" value="<%= q == null ? "" : q %>" placeholder="Filter by ticket ID, unit or description">
          <select class="input input-sm" name="estateId" data-autosubmit>
            <option value="">All estates</option>
<%
    for (Iterator it = estateNames.entrySet().iterator(); it.hasNext();) {
        Map.Entry en = (Map.Entry) it.next();
%>
            <option value="<%= en.getKey() %>"<%= en.getKey().equals(estateId) ? " selected" : "" %>><%= en.getKey() %> &middot; <%= en.getValue() %></option>
<%
    }
%>
          </select>
          <select class="input input-sm" name="category" data-autosubmit>
            <option value="">All categories</option>
<%
    for (int ci = 0; ci < ViewUtil.CATEGORIES.length; ci++) {
%>
            <option<%= ViewUtil.CATEGORIES[ci].equals(category) ? " selected" : "" %>><%= ViewUtil.CATEGORIES[ci] %></option>
<%
    }
%>
          </select>
          <button class="btn btn-sm" type="submit">Apply</button>
          <% if (q != null || estateId != null || category != null) { %><a class="btn btn-sm" href="ticket-list.jsp<%= status == null ? "" : "?status=" + java.net.URLEncoder.encode(status, "UTF-8") %>">Clear</a><% } %>
        </form>

        <% if (q != null) { %>
        <div class="result-line" style="border-top:0;border-bottom:1px solid var(--line)"><span>Results for &ldquo;<%= q %>&rdquo;</span></div>
        <% } %>

        <div class="table-wrap">
        <table class="data">
          <thead>
          <tr>
            <th>Ticket ID</th><th>Unit</th><th>Estate</th><th>Category</th>
            <th>Description</th><th>Opened</th><th>Status</th><th>Action</th>
          </tr>
          </thead>
          <tbody>
<%
    int shown = 0;
    while (rs.next()) {
        // NOTE: filtering happens here, in the view, one row at a time.
        if (status != null && !status.equals(rs.getString("status"))) continue;
        if (category != null && !category.equals(rs.getString("category"))) continue;
        if (q != null) {
            String needle = q.toLowerCase();
            String hay = (rs.getString("ticket_id") + " " + rs.getString("unit_id") + " " + rs.getString("description")).toLowerCase();
            if (hay.indexOf(needle) < 0) continue;
        }
        shown++;
        String rowStatus = rs.getString("status");
%>
          <tr>
            <td class="nowrap"><a class="mono" href="ticket-detail.jsp?ticketId=<%= rs.getString("ticket_id") %>"><b><%= rs.getString("ticket_id") %></b></a></td>
            <td class="nowrap"><%= rs.getString("unit_id") %></td>
            <td class="nowrap"><%= rs.getString("estate_id") %><div class="muted" style="font-size:12px"><%= estateNames.get(rs.getString("estate_id")) %></div></td>
            <td><span class="cat"><%= ViewUtil.categoryIcon(rs.getString("category")) %><%= rs.getString("category") %></span></td>
            <%-- NOTE: description is written straight into the page, unescaped. --%>
            <td class="desc"><%= rs.getString("description") %></td>
            <td class="nowrap"><%= ViewUtil.formatDate(rs.getString("opened_date")) %><div class="muted" style="font-size:12px"><%= ViewUtil.daysOpen(rs.getString("opened_date")) %> days</div></td>
            <td><span class="badge <%= ViewUtil.statusClass(rowStatus) %>"><%= rowStatus %></span></td>
            <td>
              <form class="inline-form" method="post" action="tickets">
                <input type="hidden" name="action" value="updateStatus" />
                <input type="hidden" name="ticketId" value="<%= rs.getString("ticket_id") %>" />
                <input type="hidden" name="returnTo" value="<%= here %>" />
                <select class="input input-sm" name="newStatus">
                  <option<%= "Open".equals(rowStatus) ? " selected" : "" %>>Open</option>
                  <option<%= "In Progress".equals(rowStatus) ? " selected" : "" %>>In Progress</option>
                  <option<%= "Closed".equals(rowStatus) ? " selected" : "" %>>Closed</option>
                </select>
                <input class="btn btn-sm" type="submit" value="Update" />
                <a class="btn btn-sm" href="ticket-detail.jsp?ticketId=<%= rs.getString("ticket_id") %>" title="View details">View</a>
              </form>
            </td>
          </tr>
<%
    }
    if (shown == 0) {
%>
          <tr><td colspan="8"><div class="empty">No tickets match these filters.</div></td></tr>
<%
    }
%>
          </tbody>
        </table>
        </div>
        <div class="result-line">
          <span>Showing <b><%= shown %></b> of <%= cAll %> tickets</span>
          <span>Page 1 of 1</span>
        </div>
      </div>

<%@ include file="/WEB-INF/jspf/footer.jspf" %>
