// ============================================================================
// SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
// Term-contractor register lookups for the EMS web module. Same style as
// TicketDAO: string-concatenated SQL, no prepared statements.
// ============================================================================

package sg.demo.ems.web;

import sg.demo.ems.web.legacydb.LegacyConnection;
import sg.demo.ems.web.legacydb.LegacyDbEngine;
import sg.demo.ems.web.legacydb.LegacyResultSet;
import sg.demo.ems.web.legacydb.LegacySQLException;
import sg.demo.ems.web.legacydb.LegacyStatement;

/**
 * Known issues (deliberately left in for the modernization spec to catch):
 *  - SQL built by string concatenation; a category containing a quote
 *    (e.g. "Structural/Ceiling's") breaks the query.
 *  - Contractor e-mail and phone are returned to every view unfiltered.
 */
public class ContractorDAO {

    private static final LegacyConnection sharedConnection = LegacyDbEngine.connect();

    public LegacyResultSet listContractors() throws LegacySQLException {
        LegacyStatement stmt = sharedConnection.createStatement();
        return stmt.executeQuery("SELECT * FROM CONTRACTORS");
    }

    public LegacyResultSet findByCategory(String category) throws LegacySQLException {
        String sql = "SELECT * FROM CONTRACTORS WHERE CATEGORY = '" + category + "'";
        LegacyStatement stmt = sharedConnection.createStatement();
        return stmt.executeQuery(sql);
    }
}
