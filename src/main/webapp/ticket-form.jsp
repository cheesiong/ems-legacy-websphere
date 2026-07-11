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
--%>
<html>
<head><title>EMS - Raise Maintenance Ticket</title></head>
<body>
<h2>Raise a Maintenance Ticket</h2>
<form method="post" action="tickets">
  <input type="hidden" name="action" value="create" />

  <label>Estate ID: <input type="text" name="estateId" value="<%= request.getParameter("estateId") == null ? "" : request.getParameter("estateId") %>" /></label><br/>
  <label>Unit ID: <input type="text" name="unitId" /></label><br/>
  <label>Category:
    <select name="category">
      <option>Plumbing</option>
      <option>Electrical</option>
      <option>Lift Fault</option>
      <option>Pest Control</option>
      <option>Structural/Ceiling</option>
      <option>Common Area Lighting</option>
      <option>Car Park Barrier</option>
    </select>
  </label><br/>
  <label>Description: <textarea name="description" rows="3" cols="40"></textarea></label><br/>

  <%-- NOTE: resident NRIC and contact number are collected on this same
       form, submitted as plain form fields, and logged in full by
       TicketServlet.java on the server side. --%>
  <label>Resident NRIC: <input type="text" name="residentNric" /></label><br/>
  <label>Resident Contact No: <input type="text" name="residentContactNo" /></label><br/>

  <input type="submit" value="Submit Ticket" />
</form>
</body>
</html>
