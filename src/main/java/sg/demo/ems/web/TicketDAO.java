// ============================================================================
// SYNTHETIC LEGACY SAMPLE — RUNNABLE ADAPTATION, illustrative only.
// Identical anti-patterns to UseCase6_legacy_app/TicketDAO.java (the
// original, non-runnable illustrative version): SQL built by string
// concatenation, one shared connection for the app's lifetime, no prepared
// statements, no input validation. The ONLY thing changed is the driver:
// java.sql.* + the Oracle driver (which needs a real Oracle DB and a JDBC
// driver jar this sandbox can't download) is swapped for
// sg.demo.ems.web.legacydb (an in-memory stand-in, see LegacyDbEngine.java)
// so this compiles and runs with nothing but a JDK. Everything else --
// including the fragility of the string-concatenated SQL -- is preserved
// on purpose: try a description containing an apostrophe and watch it fail,
// the same way it would against a real database.
// ============================================================================

package sg.demo.ems.web;

import sg.demo.ems.web.legacydb.LegacyConnection;
import sg.demo.ems.web.legacydb.LegacyDbEngine;
import sg.demo.ems.web.legacydb.LegacyResultSet;
import sg.demo.ems.web.legacydb.LegacySQLException;
import sg.demo.ems.web.legacydb.LegacyStatement;

import java.util.UUID;

/**
 * Known issues (deliberately left in for the modernization spec to catch):
 *  - SQL built by string concatenation -> breaks (or, against a real
 *    database, is an injection surface) on any value containing a quote.
 *  - A single shared connection is opened once and reused for the life of
 *    the application (no pooling, no per-request lifecycle).
 *  - No prepared statements, no parameter binding, no input validation.
 */
public class TicketDAO {

    // NOTE: one shared connection for the entire application's lifetime,
    // exactly like the original Oracle-backed version.
    private static final LegacyConnection sharedConnection = LegacyDbEngine.connect();

    static {
        // Seed the same 25 sample tickets the demo pack ships (UseCase3 CSV)
        // so the app shows data on first start, like the real system would.
        LegacyDbEngine.seedSampleData();
    }

    public String insertTicket(String estateId, String unitId, String category, String description,
                                String residentNric, String residentContactNo) throws LegacySQLException {
        String ticketId = "TCK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        // NOTE: string-concatenated SQL. A description containing a quote
        // character breaks this query today; a malicious one is worse.
        String sql = "INSERT INTO TICKETS (TICKET_ID, ESTATE_ID, UNIT_ID, CATEGORY, DESCRIPTION, "
                + "RESIDENT_NRIC, RESIDENT_CONTACT_NO, STATUS, OPENED_DATE) VALUES ('"
                + ticketId + "', '" + estateId + "', '" + unitId + "', '" + category + "', '"
                + description + "', '" + residentNric + "', '" + residentContactNo + "', "
                + "'Open', SYSDATE)";

        LegacyStatement stmt = sharedConnection.createStatement();
        stmt.executeUpdate(sql);
        return ticketId;
    }

    public void updateStatus(String ticketId, String newStatus) throws LegacySQLException {
        String sql = "UPDATE TICKETS SET STATUS = '" + newStatus + "' WHERE TICKET_ID = '" + ticketId + "'";
        LegacyStatement stmt = sharedConnection.createStatement();
        stmt.executeUpdate(sql);
    }

    public void deleteTicket(String ticketId) throws LegacySQLException {
        // NOTE: no audit trail written anywhere before this executes.
        String sql = "DELETE FROM TICKETS WHERE TICKET_ID = '" + ticketId + "'";
        LegacyStatement stmt = sharedConnection.createStatement();
        stmt.executeUpdate(sql);
    }

    public LegacyResultSet findById(String ticketId) throws LegacySQLException {
        String sql = "SELECT * FROM TICKETS WHERE TICKET_ID = '" + ticketId + "'";
        LegacyStatement stmt = sharedConnection.createStatement();
        return stmt.executeQuery(sql);
    }

    public LegacyResultSet listByEstate(String estateId) throws LegacySQLException {
        String sql = (estateId == null)
                ? "SELECT * FROM TICKETS"
                : "SELECT * FROM TICKETS WHERE ESTATE_ID = '" + estateId + "'";
        LegacyStatement stmt = sharedConnection.createStatement();
        return stmt.executeQuery(sql);
    }
}
