package sg.demo.ems.web.legacydb;

import java.util.List;
import java.util.Map;

/** Stand-in for java.sql.ResultSet -- cursor over a list of column maps. */
public class LegacyResultSet {
    private final List<Map<String, String>> rows;
    private int cursor = -1;

    LegacyResultSet(List<Map<String, String>> rows) {
        this.rows = rows;
    }

    public boolean next() {
        cursor++;
        return cursor < rows.size();
    }

    public String getString(String column) {
        if (cursor < 0 || cursor >= rows.size()) {
            return null;
        }
        // java.sql.ResultSet.getString(columnLabel) is case-insensitive per
        // the JDBC spec; match that here since the rows are keyed by the
        // upper-case column names used in TicketDAO's SQL.
        Map<String, String> row = rows.get(cursor);
        for (Map.Entry<String, String> entry : row.entrySet()) {
            if (entry.getKey().equalsIgnoreCase(column)) {
                return entry.getValue();
            }
        }
        return null;
    }
}
