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
--%>
<%@ page import="sg.demo.ems.web.legacydb.LegacyResultSet" %>
<%@ page import="sg.demo.ems.web.TicketDAO" %>
<%
    String estateId = request.getParameter("estateId");
    TicketDAO ticketDAO = new TicketDAO();
    LegacyResultSet rs = ticketDAO.listByEstate(estateId);
%>
<html>
<head><title>EMS - Maintenance Tickets</title></head>
<body>
<h2>Maintenance Tickets<% if (estateId != null) { %> - Estate <%= estateId %><% } %></h2>

<table border="1">
  <tr>
    <th>Ticket ID</th><th>Unit</th><th>Estate</th><th>Category</th>
    <th>Description</th><th>Status</th><th>Action</th>
  </tr>
<%
    while (rs.next()) {
%>
  <tr>
    <td><%= rs.getString("ticket_id") %></td>
    <td><%= rs.getString("unit_id") %></td>
    <td><%= rs.getString("estate_id") %></td>
    <td><%= rs.getString("category") %></td>
    <%-- NOTE: description is written straight into the page, unescaped. --%>
    <td><%= rs.getString("description") %></td>
    <td><%= rs.getString("status") %></td>
    <td>
      <form method="post" action="tickets">
        <input type="hidden" name="action" value="updateStatus" />
        <input type="hidden" name="ticketId" value="<%= rs.getString("ticket_id") %>" />
        <select name="newStatus">
          <option>Open</option>
          <option>In Progress</option>
          <option>Closed</option>
        </select>
        <input type="submit" value="Update" />
      </form>
    </td>
  </tr>
<%
    }
%>
</table>

<p><a href="ticket-form.jsp<% if (estateId != null) { %>?estateId=<%= estateId %><% } %>">Raise a new ticket</a></p>
</body>
</html>
