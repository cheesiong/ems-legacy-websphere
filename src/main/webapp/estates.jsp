<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Estate directory: one card per estate with live ticket counts.

  Known issues (deliberately left in for the modernization spec to catch):
   - N+1 query pattern: one full ticket query per estate card.
   - DAO calls and counting logic in the view.
--%>
<%@ page import="sg.demo.ems.web.legacydb.LegacyResultSet" %>
<%@ page import="sg.demo.ems.web.EstateDAO" %>
<%
    String pageTitle = "Estates";
    String activeNav = "estates";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    List estates = ViewUtil.readRows(new EstateDAO().listEstates(), ViewUtil.ESTATE_COLUMNS);
    int totalUnits = 0, totalBlocks = 0;
    for (int i = 0; i < estates.size(); i++) {
        Map es = (Map) estates.get(i);
        totalUnits += Integer.parseInt((String) es.get("unit_count"));
        totalBlocks += Integer.parseInt((String) es.get("block_count"));
    }
%>
      <div class="page-head">
        <div>
          <div class="crumbs"><a href="<%= ctx %>/dashboard.jsp">Home</a> <span>/</span> Estates</div>
          <h1>Estates</h1>
          <p><%= estates.size() %> estates &middot; <%= totalBlocks %> blocks &middot; <%= totalUnits %> residential units under management</p>
        </div>
      </div>

      <div class="estate-grid">
<%
    for (int i = 0; i < estates.size(); i++) {
        Map es = (Map) estates.get(i);
        String eid = (String) es.get("estate_id");
        // NOTE: one query per estate (N+1).
        int open = 0, prog = 0, all = 0;
        LegacyResultSet rs = new TicketDAO().listByEstate(eid);
        while (rs.next()) {
            all++;
            if ("Open".equals(rs.getString("status"))) open++;
            else if ("In Progress".equals(rs.getString("status"))) prog++;
        }
%>
        <div class="card estate-card">
          <div class="estate-banner">
            <svg class="skyline" viewBox="0 0 150 60" fill="#fff"><path d="M0 60V30h14V18h12v42h6V8h16v52h6V26h12v34h6V14h14v46h6V34h12v26h6V22h14v38h26z"/></svg>
            <div class="eid"><%= eid %> &middot; <%= es.get("region") %></div>
            <h3><%= es.get("estate_name") %></h3>
          </div>
          <div class="estate-stats">
            <div><b><%= es.get("block_count") %></b><span>Blocks</span></div>
            <div><b><%= es.get("unit_count") %></b><span>Units</span></div>
            <div><b><%= open + prog %></b><span>Active tickets</span></div>
          </div>
          <div class="card-body" style="font-size:13px">
            <dl class="kv" style="grid-template-columns:110px 1fr;gap:6px 12px">
              <dt>Estate officer</dt><dd><%= es.get("officer_name") %></dd>
              <dt>Office</dt><dd><%= es.get("office_address") %></dd>
              <dt>Completed</dt><dd><%= es.get("year_completed") %></dd>
            </dl>
          </div>
          <div class="estate-foot" style="border-top:1px solid var(--line)">
            <span>
              <% if (open > 0) { %><span class="badge open"><%= open %> open</span><% } %>
              <% if (prog > 0) { %><span class="badge progress"><%= prog %> in progress</span><% } %>
              <% if (open + prog == 0) { %><span class="badge closed">All clear</span><% } %>
            </span>
            <a class="btn btn-sm" href="<%= ctx %>/estate-detail.jsp?estateId=<%= eid %>">View estate &rarr;</a>
          </div>
        </div>
<%
    }
%>
      </div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
