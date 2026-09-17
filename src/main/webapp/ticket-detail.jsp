<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Ticket detail screen: full record, resident details, assigned contractor,
  SLA, status update and delete.

  Known issues (deliberately left in for the modernization spec to catch):
   - ticketId request parameter goes straight into TicketDAO's
     string-concatenated SQL.
   - Resident NRIC and phone number are displayed in full to every user
     (no masking, no role check, no access logging).
   - Delete is a hard delete with no audit trail and no authorisation check.
   - "Activity" is reconstructed from the current row only -- the legacy
     schema keeps no history of status changes.
--%>
<%@ page import="sg.demo.ems.web.legacydb.LegacyResultSet" %>
<%@ page import="sg.demo.ems.web.EstateDAO" %>
<%@ page import="sg.demo.ems.web.ContractorDAO" %>
<%
    String ticketId = request.getParameter("ticketId");
    String pageTitle = "Ticket " + ticketId;
    String activeNav = "tickets";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    List found = ViewUtil.readTickets(new TicketDAO().findById(ticketId));
    if (found.isEmpty()) {
%>
      <div class="page-head">
        <div>
          <div class="crumbs"><a href="<%= ctx %>/dashboard.jsp">Home</a> <span>/</span> <a href="<%= ctx %>/ticket-list.jsp">Tickets</a> <span>/</span> Not found</div>
          <h1>Ticket not found</h1>
          <p>No ticket exists with ID <b><%= ticketId %></b>. It may have been deleted.</p>
        </div>
        <div class="actions"><a class="btn" href="<%= ctx %>/ticket-list.jsp">Back to tickets</a></div>
      </div>
<%
    } else {
        Map t = (Map) found.get(0);
        String st = (String) t.get("status");
        String cat = (String) t.get("category");
        String eid = (String) t.get("estate_id");

        Map estate = null;
        List el = ViewUtil.readRows(new EstateDAO().findById(eid), ViewUtil.ESTATE_COLUMNS);
        if (!el.isEmpty()) { estate = (Map) el.get(0); }

        Map con = null;
        List cl = ViewUtil.readRows(new ContractorDAO().findByCategory(cat), ViewUtil.CONTRACTOR_COLUMNS);
        if (!cl.isEmpty()) { con = (Map) cl.get(0); }

        int slaDays = 14;
        if (con != null) { try { slaDays = Integer.parseInt((String) con.get("resolution_days")); } catch (NumberFormatException nfe) { } }
        long age = ViewUtil.daysOpen((String) t.get("opened_date"));
        boolean overdue = ViewUtil.isOverdue(t, slaDays);

        // related: other tickets for the same unit (another full scan)
        List related = new ArrayList();
        LegacyResultSet rrs = new TicketDAO().listByEstate(eid);
        while (rrs.next()) {
            if (rrs.getString("unit_id").equals(t.get("unit_id")) && !rrs.getString("ticket_id").equals(ticketId)) {
                Map rm = new HashMap();
                rm.put("ticket_id", rrs.getString("ticket_id"));
                rm.put("category", rrs.getString("category"));
                rm.put("status", rrs.getString("status"));
                rm.put("opened_date", rrs.getString("opened_date"));
                related.add(rm);
            }
        }
%>
      <div class="page-head">
        <div>
          <div class="crumbs"><a href="<%= ctx %>/dashboard.jsp">Home</a> <span>/</span> <a href="<%= ctx %>/ticket-list.jsp">Tickets</a> <span>/</span> <%= ticketId %></div>
          <h1 style="display:flex;align-items:center;gap:12px;flex-wrap:wrap">
            <span class="mono" style="font-size:24px"><%= t.get("ticket_id") %></span>
            <span class="badge <%= ViewUtil.statusClass(st) %>"><%= st %></span>
            <% if (overdue) { %><span class="badge danger">Past SLA</span><% } %>
          </h1>
          <p><span class="cat"><%= ViewUtil.categoryIcon(cat) %><%= cat %></span> &middot; <%= estate == null ? eid : estate.get("estate_name") %>, <%= t.get("unit_id") %> &middot; opened <%= ViewUtil.formatDate((String) t.get("opened_date")) %></p>
        </div>
        <div class="actions">
          <a class="btn" href="<%= ctx %>/ticket-list.jsp?estateId=<%= eid %>">All <%= eid %> tickets</a>
          <button class="btn" type="button" data-print>
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round"><path d="M6 9V3h12v6M6 18H4v-7h16v7h-2M6 14h12v7H6z"/></svg>
            Print job sheet
          </button>
        </div>
      </div>

      <div class="cols">
        <div class="stack">
          <div class="card">
            <div class="card-head"><h3>Fault details</h3></div>
            <div class="card-body">
              <%-- NOTE: resident-entered text rendered unescaped. --%>
              <p style="margin:0 0 18px;font-size:15px"><%= t.get("description") %></p>
              <dl class="kv">
                <dt>Category</dt><dd><%= cat %></dd>
                <dt>Estate</dt><dd><a href="<%= ctx %>/estate-detail.jsp?estateId=<%= eid %>"><%= eid %><%= estate == null ? "" : " &middot; " + estate.get("estate_name") %></a></dd>
                <dt>Unit</dt><dd><%= t.get("unit_id") %></dd>
                <dt>Opened</dt><dd><%= ViewUtil.formatDate((String) t.get("opened_date")) %> <span class="muted">(<%= age %> days ago)</span></dd>
                <dt>Resolution target</dt><dd><%= slaDays %> days
                  <% if (!"Closed".equals(st)) { %>
                    <% if (overdue) { %><span class="badge danger plain" style="margin-left:6px"><%= age - slaDays %> days over</span>
                    <% } else { %><span class="badge closed plain" style="margin-left:6px"><%= slaDays - age %> days left</span><% } %>
                  <% } %>
                </dd>
              </dl>
            </div>
          </div>

          <div class="card">
            <div class="card-head"><h3>Resident</h3><span class="sub">From the ticket record</span></div>
            <div class="card-body">
              <%-- NOTE: full NRIC and phone number shown, unmasked. --%>
              <dl class="kv">
                <dt>NRIC</dt><dd class="mono"><%= t.get("resident_nric") %></dd>
                <dt>Contact number</dt><dd class="mono"><%= t.get("resident_contact_no") %></dd>
                <dt>Address</dt><dd><%= t.get("unit_id") %>, <%= estate == null ? eid : estate.get("estate_name") %></dd>
              </dl>
            </div>
          </div>

          <div class="card">
            <div class="card-head"><h3>Other tickets for this unit</h3><span class="sub"><%= related.size() %> found</span></div>
            <div class="card-body flush">
<%
        if (related.isEmpty()) {
%>
              <div class="empty" style="padding:24px">No other tickets for <%= t.get("unit_id") %>.</div>
<%
        }
        for (int i = 0; i < related.size(); i++) {
            Map rm = (Map) related.get(i);
%>
              <a class="list-item" href="<%= ctx %>/ticket-detail.jsp?ticketId=<%= rm.get("ticket_id") %>">
                <span class="cat-tile"><%= ViewUtil.categoryIcon((String) rm.get("category")) %></span>
                <span class="grow"><span class="title mono" style="display:block"><%= rm.get("ticket_id") %></span><span class="meta"><%= rm.get("category") %> &middot; <%= ViewUtil.formatDate((String) rm.get("opened_date")) %></span></span>
                <span class="badge <%= ViewUtil.statusClass((String) rm.get("status")) %>"><%= rm.get("status") %></span>
              </a>
<%
        }
%>
            </div>
          </div>
        </div>

        <div class="stack">
          <div class="card no-print">
            <div class="card-head"><h3>Update status</h3></div>
            <div class="card-body">
              <form method="post" action="tickets">
                <input type="hidden" name="action" value="updateStatus" />
                <input type="hidden" name="ticketId" value="<%= t.get("ticket_id") %>" />
                <input type="hidden" name="returnTo" value="ticket-detail.jsp?ticketId={ticketId}&msg=updated" />
                <label class="field"><span>New status</span>
                  <select class="input" name="newStatus">
                    <option<%= "Open".equals(st) ? " selected" : "" %>>Open</option>
                    <option<%= "In Progress".equals(st) ? " selected" : "" %>>In Progress</option>
                    <option<%= "Closed".equals(st) ? " selected" : "" %>>Closed</option>
                  </select>
                </label>
                <input class="btn btn-primary" style="width:100%;justify-content:center" type="submit" value="Save status" />
              </form>
            </div>
          </div>

          <div class="card">
            <div class="card-head"><h3>Assigned contractor</h3></div>
            <div class="card-body">
<%
        if (con == null) {
%>
              <p class="muted" style="margin:0">No term contractor registered for this category.</p>
<%
        } else {
%>
              <div style="display:flex;gap:12px;align-items:center;margin-bottom:14px">
                <span class="avatar" style="background:var(--teal)"><%= ViewUtil.initials((String) con.get("company_name")) %></span>
                <div><b><%= con.get("company_name") %></b><div class="muted" style="font-size:12.5px"><%= con.get("contractor_id") %> &middot; <span class="stars">&#9733;</span> <%= con.get("rating") %></div></div>
              </div>
              <dl class="kv" style="grid-template-columns:110px 1fr">
                <dt>Contact</dt><dd><%= con.get("contact_person") %></dd>
                <dt>Phone</dt><dd><%= con.get("contact_phone") %></dd>
                <dt>Respond in</dt><dd><%= con.get("response_hours") %> hours</dd>
              </dl>
<%
        }
%>
            </div>
          </div>

          <div class="card">
            <div class="card-head"><h3>Activity</h3></div>
            <div class="card-body">
              <ul class="timeline">
                <li><b>Ticket raised</b><small><%= ViewUtil.formatDate((String) t.get("opened_date")) %> &middot; via EMS web</small></li>
                <% if (con != null) { %><li><b>Routed to <%= con.get("company_name") %></b><small>Automatic, by category</small></li><% } %>
                <li class="<%= "Closed".equals(st) ? "" : "warn" %>"><b>Current status: <%= st %></b><small>Time of change not recorded</small></li>
              </ul>
              <div class="alert alert-info" style="margin:6px 0 0;font-size:12.5px">
                <div>This module does not keep a history of status changes.</div>
              </div>
            </div>
          </div>

          <div class="card no-print" style="border-color:#f1c1bc">
            <div class="card-head"><h3 style="color:var(--danger)">Danger zone</h3></div>
            <div class="card-body">
              <p class="muted" style="margin:0 0 12px;font-size:13px">Permanently delete this ticket. This cannot be undone.</p>
              <form method="post" action="tickets" data-confirm="Delete ticket <%= t.get("ticket_id") %>? This cannot be undone.">
                <input type="hidden" name="action" value="delete" />
                <input type="hidden" name="ticketId" value="<%= t.get("ticket_id") %>" />
                <input type="hidden" name="returnTo" value="ticket-list.jsp?msg=deleted&ticketId={ticketId}" />
                <input class="btn btn-danger" type="submit" value="Delete ticket" />
              </form>
            </div>
          </div>
        </div>
      </div>
<%
    }
%>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
