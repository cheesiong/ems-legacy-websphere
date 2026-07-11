// ============================================================================
// SYNTHETIC LEGACY SAMPLE — "EMS-WEB-TICKETS" module. Not real client code.
// Written circa Java 7 style: one servlet handling every operation,
// request-parameter dispatch instead of routes, no framework, no tests,
// no versioned API. This is the "before" state for the WebSphere 9 -> Liberty
// migration demo, packaged as ems.war. Only the DB driver layer differs from
// the illustrative original (in-memory stand-in instead of Oracle JDBC).
// ============================================================================

package sg.demo.ems.web;

import java.io.IOException;
import java.io.PrintWriter;
import sg.demo.ems.web.legacydb.LegacyResultSet;
import sg.demo.ems.web.legacydb.LegacySQLException;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles ALL maintenance-ticket operations for the Estate Maintenance
 * System web module. Dispatches on an "action" request parameter because
 * the servlet mapping in web.xml is a single catch-all ("/tickets/*").
 *
 * Known issues (deliberately left in for the modernization spec to catch):
 *  - No API versioning; this IS the API, forever, at /tickets.
 *  - Full request parameters (including resident NRIC and phone number)
 *    are written to the application log on every create.
 *  - No audit trail is written anywhere, including before delete.
 *  - SQL built by string concatenation in TicketDAO (see that file).
 *  - Business logic, HTTP handling, and JDBC calls are all in one class.
 */
public class TicketServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(TicketServlet.class.getName());
    private final TicketDAO ticketDAO = new TicketDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("create".equals(action)) {
            String estateId = req.getParameter("estateId");
            String unitId = req.getParameter("unitId");
            String category = req.getParameter("category");
            String description = req.getParameter("description");
            String residentNric = req.getParameter("residentNric");
            String residentContactNo = req.getParameter("residentContactNo");

            // NOTE: logs every parameter as-is, including NRIC and phone number.
            LOG.info("Creating ticket: estateId=" + estateId + ", unitId=" + unitId
                    + ", category=" + category + ", description=" + description
                    + ", residentNric=" + residentNric
                    + ", residentContactNo=" + residentContactNo);

            try {
                String ticketId = ticketDAO.insertTicket(estateId, unitId, category, description,
                        residentNric, residentContactNo);
                resp.setContentType("text/plain");
                resp.getWriter().println("CREATED:" + ticketId);
            } catch (LegacySQLException e) {
                throw new ServletException(e);
            }

        } else if ("updateStatus".equals(action)) {
            String ticketId = req.getParameter("ticketId");
            String newStatus = req.getParameter("newStatus");
            try {
                ticketDAO.updateStatus(ticketId, newStatus);
                resp.getWriter().println("UPDATED:" + ticketId);
            } catch (LegacySQLException e) {
                throw new ServletException(e);
            }

        } else if ("delete".equals(action)) {
            String ticketId = req.getParameter("ticketId");
            // NOTE: no audit log entry is written before (or after) this call.
            try {
                ticketDAO.deleteTicket(ticketId);
                resp.getWriter().println("DELETED:" + ticketId);
            } catch (LegacySQLException e) {
                throw new ServletException(e);
            }
        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action: " + action);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String ticketId = req.getParameter("ticketId");
        String estateId = req.getParameter("estateId");
        PrintWriter out = resp.getWriter();
        resp.setContentType("text/plain");

        try {
            if (ticketId != null) {
                LegacyResultSet rs = ticketDAO.findById(ticketId);
                if (rs.next()) {
                    printRow(out, rs);
                }
            } else {
                LegacyResultSet rs = ticketDAO.listByEstate(estateId);
                while (rs.next()) {
                    printRow(out, rs);
                }
            }
        } catch (LegacySQLException e) {
            throw new ServletException(e);
        }
    }

    private void printRow(PrintWriter out, LegacyResultSet rs) throws LegacySQLException {
        if (rs == null) return;
        out.println(rs.getString("ticket_id") + "," + rs.getString("unit_id") + ","
                + rs.getString("estate_id") + "," + rs.getString("category") + ","
                + rs.getString("status"));
    }
}
