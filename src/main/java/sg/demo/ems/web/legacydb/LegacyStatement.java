package sg.demo.ems.web.legacydb;

/** Stand-in for java.sql.Statement -- no prepared statements, no binding, by design (see TicketDAO.java). */
public class LegacyStatement {

    public int executeUpdate(String sql) throws LegacySQLException {
        return LegacyDbEngine.executeUpdate(sql);
    }

    public LegacyResultSet executeQuery(String sql) throws LegacySQLException {
        return LegacyDbEngine.executeQuery(sql);
    }

    public void close() {
        // no-op: the legacy code never pools or closes statements consistently either.
    }
}
