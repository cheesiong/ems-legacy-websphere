<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Raise-a-ticket form for EMS-WEB-TICKETS.

  Known issues (deliberately left in for the modernization spec to catch):
   - Plain HTML form fields for residentNric / residentContactNo -- posted
     straight to TicketServlet, which (see TicketServlet.java) logs them
     to the application log in full, and TicketDAO.java, which concatenates
     them directly into SQL.
   - No client- or server-side validation of NRIC format, phone format, or
     required fields.
   - No CSRF token on the form.
   - The estateId request parameter is echoed into the page unescaped.
   - Post-submit redirect target is supplied by the form itself ("returnTo")
     and followed by the servlet without validation.
--%>
<%@ page import="sg.demo.ems.web.EstateDAO" %>
<%@ page import="sg.demo.ems.web.ContractorDAO" %>
<%
    String pageTitle = "Raise Maintenance Ticket";
    String activeNav = "new";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<%
    String preEstate = request.getParameter("estateId") == null ? "" : request.getParameter("estateId");
    List estates = ViewUtil.readRows(new EstateDAO().listEstates(), ViewUtil.ESTATE_COLUMNS);
    List contractors = ViewUtil.readRows(new ContractorDAO().listContractors(), ViewUtil.CONTRACTOR_COLUMNS);
%>
      <div class="page-head">
        <div>
          <div class="crumbs"><a href="<%= ctx %>/dashboard.jsp">Home</a> <span>/</span> <a href="<%= ctx %>/ticket-list.jsp">Tickets</a> <span>/</span> New</div>
          <h1>Raise a Maintenance Ticket</h1>
          <p>Log a resident's maintenance request. It is routed to the term contractor for the selected category.</p>
        </div>
      </div>

      <div class="cols">
        <form class="card" method="post" action="tickets">
          <input type="hidden" name="action" value="create" />
          <input type="hidden" name="returnTo" value="ticket-detail.jsp?ticketId={ticketId}&msg=created" />

          <div class="card-head"><h3>1. Location</h3></div>
          <div class="card-body grid-2">
            <label class="field"><span>Estate ID</span>
              <%-- Free-text on purpose (legacy); the datalist only suggests values. --%>
              <input class="input" type="text" name="estateId" list="estate-list" value="<%= preEstate %>" placeholder="e.g. EST-02" />
              <datalist id="estate-list">
<%
    for (int i = 0; i < estates.size(); i++) {
        Map es = (Map) estates.get(i);
%>
                <option value="<%= es.get("estate_id") %>"><%= es.get("estate_name") %></option>
<%
    }
%>
              </datalist>
              <small>Estate code as shown on the estate directory.</small>
            </label>
            <label class="field"><span>Unit ID</span>
              <input class="input" type="text" name="unitId" placeholder="e.g. UNIT-012" />
              <small>Use the unit reference from the tenancy record.</small>
            </label>
          </div>

          <div class="card-head" style="border-top:1px solid var(--line)"><h3>2. Issue</h3></div>
          <div class="card-body">
            <label class="field"><span>Category</span>
              <select class="input" name="category">
                <option>Plumbing</option>
                <option>Electrical</option>
                <option>Lift Fault</option>
                <option>Pest Control</option>
                <option>Structural/Ceiling</option>
                <option>Common Area Lighting</option>
                <option>Car Park Barrier</option>
              </select>
            </label>
            <label class="field"><span>Description</span>
              <textarea class="input" name="description" rows="4" maxlength="500" data-counter="desc-count" placeholder="What is the problem, where exactly, and since when?"></textarea>
              <small><span id="desc-count">0 / 500</span> &middot; Describe the fault as reported by the resident.</small>
            </label>
          </div>

          <%-- NOTE: resident NRIC and contact number are collected on this same
               form, submitted as plain form fields, and logged in full by
               TicketServlet.java on the server side. --%>
          <div class="card-head" style="border-top:1px solid var(--line)"><h3>3. Resident</h3></div>
          <div class="card-body grid-2">
            <label class="field"><span>Resident NRIC</span>
              <input class="input" type="text" name="residentNric" placeholder="e.g. S1234567A" />
            </label>
            <label class="field"><span>Resident Contact No</span>
              <input class="input" type="text" name="residentContactNo" placeholder="e.g. 91234567" />
            </label>
          </div>

          <div class="card-body" style="border-top:1px solid var(--line);display:flex;justify-content:flex-end;gap:8px">
            <a class="btn" href="<%= ctx %>/ticket-list.jsp">Cancel</a>
            <input class="btn btn-primary" type="submit" value="Submit Ticket" />
          </div>
        </form>

        <div class="stack">
          <div class="card">
            <div class="card-head"><h3>Service levels</h3></div>
            <div class="card-body flush">
              <table class="data">
                <thead><tr><th>Category</th><th class="right">Respond</th><th class="right">Resolve</th></tr></thead>
                <tbody>
<%
    for (int i = 0; i < contractors.size(); i++) {
        Map c = (Map) contractors.get(i);
%>
                  <tr>
                    <td><span class="cat"><%= ViewUtil.categoryIcon((String) c.get("category")) %><%= c.get("category") %></span></td>
                    <td class="right nowrap"><%= c.get("response_hours") %> h</td>
                    <td class="right nowrap"><%= c.get("resolution_days") %> d</td>
                  </tr>
<%
    }
%>
                </tbody>
              </table>
            </div>
          </div>
          <div class="alert alert-warn" style="margin:0">
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.3 3.9L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17v.01"/></svg>
            <div><b>Emergencies</b>For lift entrapment, gas leaks or fire, call the 24-hour emergency line on 6555 0999 before raising a ticket.</div>
          </div>
        </div>
      </div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
