// ============================================================================
// SYNTHETIC LEGACY SAMPLE — illustrative only, not real client code.
// Grab-bag of static helpers the JSP views call from scriptlets: row copying,
// date arithmetic, badge classes, icons. The classic "Util" class every
// legacy web module grows -- presentation, formatting and business rules
// (SLA / overdue) all mixed together.
// ============================================================================

package sg.demo.ems.web;

import sg.demo.ems.web.legacydb.LegacyResultSet;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Known issues (deliberately left in for the modernization spec to catch):
 *  - Business rules (overdue / SLA calculation) live in a view helper.
 *  - Uses java.util.Date + SimpleDateFormat (not thread-safe, new instance
 *    per call) instead of java.time.
 *  - No output-encoding helper exists, so views write raw values.
 */
public final class ViewUtil {

    public static final String[] TICKET_COLUMNS = {
        "ticket_id", "estate_id", "unit_id", "category", "description",
        "resident_nric", "resident_contact_no", "status", "opened_date"
    };

    public static final String[] ESTATE_COLUMNS = {
        "estate_id", "estate_name", "region", "block_count", "unit_count", "year_completed",
        "office_address", "officer_name", "office_phone", "office_hours"
    };

    public static final String[] CONTRACTOR_COLUMNS = {
        "contractor_id", "company_name", "category", "contact_person", "contact_phone",
        "contact_email", "response_hours", "resolution_days", "contract_start", "contract_end", "rating"
    };

    public static final String[] CATEGORIES = {
        "Plumbing", "Electrical", "Lift Fault", "Pest Control",
        "Structural/Ceiling", "Common Area Lighting", "Car Park Barrier"
    };

    public static final String[] STATUSES = {"Open", "In Progress", "Closed"};

    private static final long DAY_MS = 24L * 60 * 60 * 1000;

    private ViewUtil() {
    }

    /** Copies every row of a result set into a list of column maps (lower-case keys). */
    public static List<Map<String, String>> readRows(LegacyResultSet rs, String[] columns) {
        List<Map<String, String>> rows = new ArrayList<Map<String, String>>();
        while (rs.next()) {
            Map<String, String> row = new HashMap<String, String>();
            for (int i = 0; i < columns.length; i++) {
                row.put(columns[i], rs.getString(columns[i]));
            }
            rows.add(row);
        }
        return rows;
    }

    public static List<Map<String, String>> readTickets(LegacyResultSet rs) {
        return readRows(rs, TICKET_COLUMNS);
    }

    /** Newest first, by the ISO-8601 OPENED_DATE string. */
    public static void sortByOpenedDesc(List<Map<String, String>> tickets) {
        Collections.sort(tickets, new Comparator<Map<String, String>>() {
            public int compare(Map<String, String> a, Map<String, String> b) {
                String da = a.get("opened_date") == null ? "" : a.get("opened_date");
                String db = b.get("opened_date") == null ? "" : b.get("opened_date");
                return db.compareTo(da);
            }
        });
    }

    private static Date parse(String iso) {
        if (iso == null || iso.length() < 10) {
            return null;
        }
        try {
            return new SimpleDateFormat("yyyy-MM-dd").parse(iso.substring(0, 10));
        } catch (java.text.ParseException e) {
            return null;
        }
    }

    public static long daysOpen(String iso) {
        Date d = parse(iso);
        if (d == null) {
            return 0;
        }
        long diff = System.currentTimeMillis() - d.getTime();
        return diff < 0 ? 0 : diff / DAY_MS;
    }

    public static long daysUntil(String isoDate) {
        Date d = parse(isoDate);
        if (d == null) {
            return 0;
        }
        return (d.getTime() - System.currentTimeMillis()) / DAY_MS;
    }

    public static String formatDate(String iso) {
        Date d = parse(iso);
        return d == null ? "-" : new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH).format(d);
    }

    public static String today() {
        return new SimpleDateFormat("EEEE, d MMMM yyyy", Locale.ENGLISH).format(new Date());
    }

    public static String monthKey(String iso) {
        return iso == null || iso.length() < 7 ? "" : iso.substring(0, 7);
    }

    /** The last {@code n} month keys (yyyy-MM), oldest first, ending with the current month. */
    public static List<String> lastMonths(int n) {
        List<String> keys = new ArrayList<String>();
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
        cal.add(java.util.Calendar.MONTH, -(n - 1));
        SimpleDateFormat f = new SimpleDateFormat("yyyy-MM");
        for (int i = 0; i < n; i++) {
            keys.add(f.format(cal.getTime()));
            cal.add(java.util.Calendar.MONTH, 1);
        }
        return keys;
    }

    public static String monthLabel(String key) {
        try {
            Date d = new SimpleDateFormat("yyyy-MM").parse(key);
            return new SimpleDateFormat("MMM", Locale.ENGLISH).format(d);
        } catch (java.text.ParseException e) {
            return key;
        }
    }

    /** SLA rule: a ticket not yet Closed is overdue once it has been open longer than the contractor's resolution days. */
    public static boolean isOverdue(Map<String, String> ticket, int resolutionDays) {
        return !"Closed".equals(ticket.get("status")) && daysOpen(ticket.get("opened_date")) > resolutionDays;
    }

    /** Resolution-day target per category, from the contractor register. */
    public static Map<String, Integer> slaByCategory(List<Map<String, String>> contractors) {
        Map<String, Integer> sla = new HashMap<String, Integer>();
        for (Map<String, String> c : contractors) {
            try {
                sla.put(c.get("category"), Integer.valueOf(c.get("resolution_days")));
            } catch (NumberFormatException e) {
                sla.put(c.get("category"), Integer.valueOf(14));
            }
        }
        return sla;
    }

    public static int slaFor(Map<String, Integer> sla, String category) {
        Integer v = sla.get(category);
        return v == null ? 14 : v.intValue();
    }

    public static String statusClass(String status) {
        if ("Open".equals(status)) {
            return "open";
        }
        if ("In Progress".equals(status)) {
            return "progress";
        }
        if ("Closed".equals(status)) {
            return "closed";
        }
        return "neutral";
    }

    public static int percent(int part, int whole) {
        return whole == 0 ? 0 : Math.round(part * 100f / whole);
    }

    public static String initials(String name) {
        if (name == null || name.trim().length() == 0) {
            return "?";
        }
        String[] parts = name.trim().split("\\s+");
        String s = parts[0].substring(0, 1);
        if (parts.length > 1) {
            s += parts[parts.length - 1].substring(0, 1);
        }
        return s.toUpperCase();
    }

    /** Small inline SVG icon for a ticket category (stroke uses currentColor). */
    public static String categoryIcon(String category) {
        String path;
        if ("Lift Fault".equals(category)) {
            path = "<rect x='5' y='3' width='14' height='18' rx='2'/><path d='M9 10l3-3 3 3M9 14l3 3 3-3'/>";
        } else if ("Plumbing".equals(category)) {
            path = "<path d='M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11z'/>";
        } else if ("Electrical".equals(category)) {
            path = "<path d='M13 2L4 14h7l-1 8 9-12h-7z'/>";
        } else if ("Pest Control".equals(category)) {
            path = "<ellipse cx='12' cy='13' rx='4.5' ry='6'/><path d='M12 7V4M7.5 10L4 8M16.5 10L20 8M7.5 14H4M16.5 14H20M8 18l-3 2M16 18l3 2'/>";
        } else if ("Structural/Ceiling".equals(category)) {
            path = "<path d='M3 11l9-7 9 7'/><path d='M5 10v10h14V10'/><path d='M10 20v-5l2-2-1-2'/>";
        } else if ("Common Area Lighting".equals(category)) {
            path = "<path d='M9 18h6M10 21h4'/><path d='M12 3a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2.1h5c0-.9.4-1.6 1-2.1A6 6 0 0 0 12 3z'/>";
        } else if ("Car Park Barrier".equals(category)) {
            path = "<rect x='3' y='14' width='4' height='7' rx='1'/><path d='M7 16L21 9'/><path d='M11 14.1l1 1.6M15 12.2l1 1.6'/>";
        } else {
            path = "<circle cx='12' cy='12' r='8'/>";
        }
        return "<svg class='ico' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.8' "
                + "stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'>" + path + "</svg>";
    }
}
