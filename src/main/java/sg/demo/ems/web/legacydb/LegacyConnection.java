package sg.demo.ems.web.legacydb;

/** Stand-in for java.sql.Connection. See LegacyDbEngine for what backs it. */
public class LegacyConnection {

    LegacyConnection() {
    }

    public LegacyStatement createStatement() {
        return new LegacyStatement();
    }
}
