// ============================================================================
// SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
// Estate directory lookups for the EMS web module. Written in the same style
// as TicketDAO: string-concatenated SQL, no prepared statements, one shared
// connection for the life of the application.
// ============================================================================

package sg.demo.ems.web;

import sg.demo.ems.web.legacydb.LegacyConnection;
import sg.demo.ems.web.legacydb.LegacyDbEngine;
import sg.demo.ems.web.legacydb.LegacyResultSet;
import sg.demo.ems.web.legacydb.LegacySQLException;
import sg.demo.ems.web.legacydb.LegacyStatement;

/**
 * Known issues (deliberately left in for the modernization spec to catch):
 *  - SQL built by string concatenation from a request parameter
 *    (estate-detail.jsp passes ?estateId= straight through).
 *  - Duplicate shared-connection pattern copied from TicketDAO.
 */
public class EstateDAO {

    private static final LegacyConnection sharedConnection = LegacyDbEngine.connect();

    public LegacyResultSet listEstates() throws LegacySQLException {
        LegacyStatement stmt = sharedConnection.createStatement();
        return stmt.executeQuery("SELECT * FROM ESTATES");
    }

    public LegacyResultSet findById(String estateId) throws LegacySQLException {
        String sql = "SELECT * FROM ESTATES WHERE ESTATE_ID = '" + estateId + "'";
        LegacyStatement stmt = sharedConnection.createStatement();
        return stmt.executeQuery(sql);
    }

    /** Convenience used by several views: estate name, or the ID if unknown. */
    public String nameOf(String estateId) throws LegacySQLException {
        if (estateId == null) {
            return "";
        }
        LegacyResultSet rs = findById(estateId);
        if (rs.next()) {
            return rs.getString("estate_name");
        }
        return estateId;
    }
}
