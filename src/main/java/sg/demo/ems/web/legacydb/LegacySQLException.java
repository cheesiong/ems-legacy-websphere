package sg.demo.ems.web.legacydb;

/**
 * Stand-in for java.sql.SQLException. Real java.sql.Connection/Statement/
 * ResultSet are interfaces with ~70-140 methods each -- implementing them
 * fully just to run four fixed query shapes would be pure boilerplate, so
 * this package defines its own minimal, JDBC-shaped API instead (same
 * method names: createStatement, executeUpdate, executeQuery, next,
 * getString -- so TicketDAO.java reads exactly like real JDBC code).
 */
// Unchecked so the same DAO can be called from both the servlet (which
// catches it) and the JSP view scriptlets (whose generated _jspService only
// declares ServletException/IOException) without changing the JDBC-shaped API.
public class LegacySQLException extends RuntimeException {
    public LegacySQLException(String message) {
        super(message);
    }
}
