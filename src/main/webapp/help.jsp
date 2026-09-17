<%--
  SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
  Help centre: FAQ, support contacts, About (version + runtime), privacy
  statement and terms of use. Mostly static content.

  Known issues (deliberately left in for the modernization spec to catch):
   - "About" section prints server, JVM and OS details to any visitor.
--%>
<%
    String pageTitle = "Help & Support";
    String activeNav = "help";
%>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
      <div class="page-head">
        <div>
          <div class="crumbs"><a href="<%= ctx %>/dashboard.jsp">Home</a> <span>/</span> Help &amp; support</div>
          <h1>Help &amp; Support</h1>
          <p>Answers to common questions, support contacts and system information.</p>
        </div>
      </div>

      <div class="cols">
        <div class="stack">
          <div class="card">
            <div class="card-head"><h3>Frequently asked questions</h3></div>
            <details class="faq" open>
              <summary>How do I raise a ticket for a resident?</summary>
              <p>Go to <a href="<%= ctx %>/ticket-form.jsp">Tickets &rsaquo; Raise a ticket</a>, enter the estate and unit, choose the fault category, describe the problem and record the resident's NRIC and contact number. The ticket is routed to the term contractor for that category.</p>
            </details>
            <details class="faq">
              <summary>How are tickets assigned to contractors?</summary>
              <p>Automatically, by category. Each category has one term contractor in the <a href="<%= ctx %>/contractors.jsp">contractor register</a>, with agreed response and resolution times.</p>
            </details>
            <details class="faq">
              <summary>What does "Past SLA" mean?</summary>
              <p>The ticket is not closed and has been open for longer than the contractor's resolution target for that category. Past-SLA tickets appear on the dashboard under <em>Needs attention</em>.</p>
            </details>
            <details class="faq">
              <summary>Why can't I see who changed a ticket's status?</summary>
              <p>This version of EMS stores only the current status of each ticket. Change history is planned for the next release.</p>
            </details>
            <details class="faq">
              <summary>My description with an apostrophe (e.g. "neighbour's") fails to save.</summary>
              <p>This is a known issue in EMS-WEB-TICKETS 1.0. Avoid quote characters in the description for now, or contact the helpdesk to log the ticket for you.</p>
            </details>
            <details class="faq">
              <summary>How do I export tickets to Excel?</summary>
              <p>Use <b>Export CSV</b> on the ticket list or reports page. The file is comma-separated and opens in any spreadsheet tool.</p>
            </details>
          </div>

          <div class="card" id="about">
            <div class="card-head"><h3>About EMS</h3></div>
            <div class="card-body">
              <p style="margin-top:0">The Estate Maintenance System (EMS) lets estate officers log, route and track maintenance faults reported by residents across all managed estates.</p>
              <dl class="kv">
                <dt>Module</dt><dd>EMS-WEB-TICKETS</dd>
                <dt>Version</dt><dd>1.0.0 (build 2019.11.4)</dd>
                <dt>Application server</dt><dd><%= application.getServerInfo() %></dd>
                <dt>Servlet API</dt><dd><%= application.getMajorVersion() %>.<%= application.getMinorVersion() %></dd>
                <dt>Java runtime</dt><dd><%= System.getProperty("java.vendor") %> <%= System.getProperty("java.version") %></dd>
                <dt>Operating system</dt><dd><%= System.getProperty("os.name") %> <%= System.getProperty("os.arch") %></dd>
                <dt>Server time</dt><dd><%= new Date() %></dd>
              </dl>
            </div>
            <div class="card-head" style="border-top:1px solid var(--line)"><h3>Release history</h3></div>
            <div class="table-wrap">
              <table class="data">
                <thead><tr><th>Version</th><th>Date</th><th>Notes</th></tr></thead>
                <tbody>
                  <tr><td class="mono">1.0.0</td><td class="nowrap">Nov 2019</td><td>Estate directory, contractor register, dashboard and reports.</td></tr>
                  <tr><td class="mono">0.9.2</td><td class="nowrap">Mar 2016</td><td>Ticket status updates from the list view; CSV export.</td></tr>
                  <tr><td class="mono">0.9.0</td><td class="nowrap">Aug 2013</td><td>Moved to WebSphere Application Server.</td></tr>
                  <tr><td class="mono">0.5.0</td><td class="nowrap">Jun 2011</td><td>First release: raise and list maintenance tickets.</td></tr>
                </tbody>
              </table>
            </div>
          </div>

          <div class="card" id="privacy">
            <div class="card-head"><h3>Privacy statement</h3></div>
            <div class="card-body">
              <p style="margin-top:0">EMS collects resident identification and contact details only to follow up on maintenance requests. Access is limited to authorised estate staff and appointed contractors. Personal data is kept only as long as needed for the request.</p>
            </div>
          </div>

          <div class="card" id="terms">
            <div class="card-head"><h3>Terms of use</h3></div>
            <div class="card-body">
              <p style="margin:0">EMS is for authorised users only. Activity may be monitored. Do not share your account or copy resident data out of the system.</p>
            </div>
          </div>
        </div>

        <div class="stack">
          <div class="card" id="contact">
            <div class="card-head"><h3>Contact support</h3></div>
            <div class="card-body flush">
              <div class="list-item"><span class="cat-tile"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.4 1.8.7 2.7a2 2 0 0 1-.5 2.1L8 9.8a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.4c.9.3 1.8.6 2.7.7a2 2 0 0 1 1.7 2z"/></svg></span><span class="grow"><span class="title" style="display:block">EMS Helpdesk</span><span class="meta">6555 0100 ext 2 &middot; Mon&ndash;Fri 8:30am&ndash;6:00pm</span></span></div>
              <div class="list-item"><span class="cat-tile"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg></span><span class="grow"><span class="title" style="display:block">E-mail</span><span class="meta">ems-helpdesk@example.com</span></span></div>
              <div class="list-item"><span class="cat-tile" style="background:var(--danger-bg);color:var(--danger)"><svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10.3 3.9L1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17v.01"/></svg></span><span class="grow"><span class="title" style="display:block">24-hour emergency line</span><span class="meta">6555 0999 &middot; lift entrapment, gas, fire</span></span></div>
            </div>
          </div>

          <div class="card">
            <div class="card-head"><h3>Service status</h3></div>
            <div class="card-body">
              <div style="display:flex;justify-content:space-between;margin-bottom:10px"><span>Ticketing</span><span class="badge closed">Operational</span></div>
              <div style="display:flex;justify-content:space-between;margin-bottom:10px"><span>Contractor routing</span><span class="badge closed">Operational</span></div>
              <div style="display:flex;justify-content:space-between"><span>Nightly CSV export</span><span class="badge progress">Degraded</span></div>
            </div>
          </div>

          <div class="alert alert-info" style="margin:0">
            <svg class="ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7.5v.01"/></svg>
            <div><b>Demonstration system</b>All estates, residents, NRICs and contractors shown in EMS are synthetic.</div>
          </div>
        </div>
      </div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
