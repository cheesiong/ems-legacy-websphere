package sg.demo.ems.web.legacydb;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * A deliberately naive, in-memory stand-in for the Oracle database the
 * legacy TicketDAO connects to in production ("ems-db-legacy"). It exists
 * ONLY so this demo can run on a laptop with a JDK and nothing else --
 * no Maven, no JDBC driver jar, no real database server.
 *
 * It does NOT behave like a real, safe database. It recognizes exactly
 * the four hand-built SQL string shapes TicketDAO produces, via regex --
 * and, faithfully to the point this demo exists to make, it is just as
 * fragile as the real string-concatenated SQL it's standing in for: a
 * description or category containing a single-quote character breaks the
 * INSERT the same way it would corrupt or fail against a real database.
 * That is intentional. See UseCase6_migration_spec.md for the fix.
 */
public final class LegacyDbEngine {

    private static final List<Map<String, String>> TICKETS = new ArrayList<>();

    private static final Pattern INSERT = Pattern.compile(
            "INSERT INTO TICKETS \\([^)]*\\) VALUES \\('([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', '([^']*)', 'Open', SYSDATE\\)");
    private static final Pattern UPDATE_STATUS = Pattern.compile(
            "UPDATE TICKETS SET STATUS = '([^']*)' WHERE TICKET_ID = '([^']*)'");
    private static final Pattern DELETE = Pattern.compile(
            "DELETE FROM TICKETS WHERE TICKET_ID = '([^']*)'");
    private static final Pattern SELECT_BY_ID = Pattern.compile(
            "SELECT \\* FROM TICKETS WHERE TICKET_ID = '([^']*)'");
    private static final Pattern SELECT_BY_ESTATE = Pattern.compile(
            "SELECT \\* FROM TICKETS WHERE ESTATE_ID = '([^']*)'");
    private static final Pattern SELECT_ALL = Pattern.compile("SELECT \\* FROM TICKETS\\s*");

    private LegacyDbEngine() {
    }

    /**
     * Populates the in-memory table so the app doesn't start empty.
     *
     * IMPORTANT: these are not made-up rows -- ticket_id, estate_id, unit_id,
     * category, status and opened_date are copied EXACTLY (same values, same
     * order) from UseCase3_maintenance_tickets.csv, the canonical ticket data
     * used elsewhere in this pack (Use Case 3, and referenced by
     * UseCase6_feature_spec.md). Only description/resident_nric/contact_no
     * are synthesized here, because that CSV doesn't carry those columns and
     * the legacy schema needs something in those fields; priority is in the
     * CSV but intentionally NOT carried over -- the legacy schema has no
     * priority concept, that's a capability the modernized app adds later.
     * If UseCase3_maintenance_tickets.csv ever changes, re-sync this list by
     * hand so the legacy app's records keep matching the CSV exactly.
     * Idempotent: calling it more than once is a no-op after the first call.
     */
    public static synchronized void seedSampleData() {
        if (!TICKETS.isEmpty()) {
            return;
        }
        addSeedRow("TCK-001", "EST-02", "UNIT-012", "Lift Fault", "Lift making loud noise before stopping", "S1234561A", "91234561", "Closed", "2026-01-15T00:00:00Z");
        addSeedRow("TCK-002", "EST-06", "UNIT-036", "Plumbing", "Bathroom pipe leaking under sink", "S1234562B", "91234562", "Closed", "2026-01-03T00:00:00Z");
        addSeedRow("TCK-003", "EST-03", "UNIT-016", "Electrical", "Power trip in living room", "S1234563C", "91234563", "In Progress", "2026-04-02T00:00:00Z");
        addSeedRow("TCK-004", "EST-02", "UNIT-011", "Pest Control", "Cockroach infestation in kitchen", "S1234564D", "91234564", "In Progress", "2026-04-10T00:00:00Z");
        addSeedRow("TCK-005", "EST-04", "UNIT-028", "Common Area Lighting", "Corridor light not turning on at night", "S1234565E", "91234565", "Closed", "2026-05-22T00:00:00Z");
        addSeedRow("TCK-006", "EST-05", "UNIT-032", "Electrical", "Sparking power socket in bedroom", "S1234566F", "91234566", "Open", "2026-01-19T00:00:00Z");
        addSeedRow("TCK-007", "EST-05", "UNIT-035", "Plumbing", "Toilet cistern leaking continuously", "S1234567G", "91234567", "Open", "2026-05-16T00:00:00Z");
        addSeedRow("TCK-008", "EST-05", "UNIT-033", "Car Park Barrier", "Season parking barrier not lifting", "S1234568H", "91234568", "Open", "2026-05-03T00:00:00Z");
        addSeedRow("TCK-009", "EST-02", "UNIT-012", "Plumbing", "Kitchen tap dripping constantly", "S1234569I", "91234569", "Closed", "2026-02-13T00:00:00Z");
        addSeedRow("TCK-010", "EST-02", "UNIT-008", "Structural/Ceiling", "Ceiling crack above living room", "S1234570J", "91234570", "In Progress", "2026-05-03T00:00:00Z");
        addSeedRow("TCK-011", "EST-04", "UNIT-027", "Common Area Lighting", "Stairwell light flickering", "S1234571K", "91234571", "In Progress", "2026-03-07T00:00:00Z");
        addSeedRow("TCK-012", "EST-03", "UNIT-021", "Electrical", "Light switch not working in hallway", "S1234572L", "91234572", "Open", "2026-06-10T00:00:00Z");
        addSeedRow("TCK-013", "EST-05", "UNIT-030", "Lift Fault", "Lift doors not closing properly", "S1234573M", "91234573", "Closed", "2026-01-15T00:00:00Z");
        addSeedRow("TCK-014", "EST-06", "UNIT-040", "Structural/Ceiling", "Ceiling patch peeling in bedroom", "S1234574N", "91234574", "Open", "2026-02-17T00:00:00Z");
        addSeedRow("TCK-015", "EST-03", "UNIT-017", "Electrical", "Fuse tripping repeatedly", "S1234575O", "91234575", "Closed", "2026-02-12T00:00:00Z");
        addSeedRow("TCK-016", "EST-03", "UNIT-019", "Electrical", "Kitchen power point not working", "S1234576P", "91234576", "In Progress", "2026-03-20T00:00:00Z");
        addSeedRow("TCK-017", "EST-05", "UNIT-034", "Plumbing", "Water heater leaking", "S1234577Q", "91234577", "In Progress", "2026-06-04T00:00:00Z");
        addSeedRow("TCK-018", "EST-02", "UNIT-009", "Lift Fault", "Lift stuck between floors", "S1234578R", "91234578", "Open", "2026-05-05T00:00:00Z");
        addSeedRow("TCK-019", "EST-03", "UNIT-018", "Lift Fault", "Lift buttons unresponsive", "S1234579S", "91234579", "Closed", "2026-02-22T00:00:00Z");
        addSeedRow("TCK-020", "EST-03", "UNIT-017", "Structural/Ceiling", "Wall crack near window", "S1234580T", "91234580", "Closed", "2026-01-03T00:00:00Z");
        addSeedRow("TCK-021", "EST-04", "UNIT-028", "Car Park Barrier", "Barrier stuck in down position", "S1234581U", "91234581", "Open", "2026-02-21T00:00:00Z");
        addSeedRow("TCK-022", "EST-03", "UNIT-017", "Electrical", "Intermittent power loss in unit", "S1234582V", "91234582", "In Progress", "2026-04-18T00:00:00Z");
        addSeedRow("TCK-023", "EST-01", "UNIT-001", "Plumbing", "Kitchen sink tap leaking", "S1234583W", "91234583", "Closed", "2026-02-18T00:00:00Z");
        addSeedRow("TCK-024", "EST-01", "UNIT-003", "Car Park Barrier", "Season parking barrier stuck open", "S1234584X", "91234584", "In Progress", "2026-04-05T00:00:00Z");
        addSeedRow("TCK-025", "EST-01", "UNIT-003", "Lift Fault", "Lift making grinding noise", "S1234585Y", "91234585", "Closed", "2026-01-12T00:00:00Z");
    }

    private static void addSeedRow(String ticketId, String estateId, String unitId, String category,
                                    String description, String nric, String contactNo, String status, String openedDate) {
        Map<String, String> row = new LinkedHashMap<>();
        row.put("TICKET_ID", ticketId);
        row.put("ESTATE_ID", estateId);
        row.put("UNIT_ID", unitId);
        row.put("CATEGORY", category);
        row.put("DESCRIPTION", description);
        row.put("RESIDENT_NRIC", nric);
        row.put("RESIDENT_CONTACT_NO", contactNo);
        row.put("STATUS", status);
        row.put("OPENED_DATE", openedDate);
        TICKETS.add(row);
    }

    public static LegacyConnection connect() {
        // NOTE: every "connection" hands back a handle onto the SAME static
        // table -- mirroring the legacy DAO's one-shared-Connection-forever
        // anti-pattern (see TicketDAO.java) rather than fixing it here.
        return new LegacyConnection();
    }

    static int executeUpdate(String sql) throws LegacySQLException {
        Matcher m = INSERT.matcher(sql);
        if (m.matches()) {
            Map<String, String> row = new LinkedHashMap<>();
            row.put("TICKET_ID", m.group(1));
            row.put("ESTATE_ID", m.group(2));
            row.put("UNIT_ID", m.group(3));
            row.put("CATEGORY", m.group(4));
            row.put("DESCRIPTION", m.group(5));
            row.put("RESIDENT_NRIC", m.group(6));
            row.put("RESIDENT_CONTACT_NO", m.group(7));
            row.put("STATUS", "Open");
            row.put("OPENED_DATE", java.time.Instant.now().toString());
            TICKETS.add(row);
            return 1;
        }

        m = UPDATE_STATUS.matcher(sql);
        if (m.matches()) {
            String newStatus = m.group(1);
            String ticketId = m.group(2);
            for (Map<String, String> row : TICKETS) {
                if (ticketId.equals(row.get("TICKET_ID"))) {
                    row.put("STATUS", newStatus);
                    return 1;
                }
            }
            return 0;
        }

        m = DELETE.matcher(sql);
        if (m.matches()) {
            String ticketId = m.group(1);
            return TICKETS.removeIf(row -> ticketId.equals(row.get("TICKET_ID"))) ? 1 : 0;
        }

        // Faithful failure mode: a value containing an unescaped single
        // quote (e.g. "Neighbour's leaking pipe" as a description) breaks
        // the regex match above the same way it would break -- or worse,
        // silently corrupt -- a real string-concatenated SQL statement.
        throw new LegacySQLException("SQL parse error (unrecognized or malformed statement -- "
                + "possibly an unescaped quote in an input field): " + sql);
    }

    static LegacyResultSet executeQuery(String sql) throws LegacySQLException {
        Matcher m = SELECT_BY_ID.matcher(sql);
        if (m.matches()) {
            String ticketId = m.group(1);
            List<Map<String, String>> result = new ArrayList<>();
            for (Map<String, String> row : TICKETS) {
                if (ticketId.equals(row.get("TICKET_ID"))) {
                    result.add(row);
                }
            }
            return new LegacyResultSet(result);
        }

        m = SELECT_BY_ESTATE.matcher(sql);
        if (m.matches()) {
            String estateId = m.group(1);
            List<Map<String, String>> result = new ArrayList<>();
            for (Map<String, String> row : TICKETS) {
                if (estateId.equals(row.get("ESTATE_ID"))) {
                    result.add(row);
                }
            }
            return new LegacyResultSet(result);
        }

        if (SELECT_ALL.matcher(sql).matches()) {
            return new LegacyResultSet(new ArrayList<>(TICKETS));
        }

        throw new LegacySQLException("SQL parse error (unrecognized statement): " + sql);
    }
}
