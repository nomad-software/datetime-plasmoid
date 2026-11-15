.pragma library

// English ordinal suffix for a day of the month: 1st, 2nd, 3rd, 4th, 11th, 22nd...
function ordinalSuffix(n) {
    const lastTwo = n % 100;
    if (lastTwo >= 11 && lastTwo <= 13) return "th";
    switch (n % 10) {
    case 1: return "st";
    case 2: return "nd";
    case 3: return "rd";
    default: return "th";
    }
}

// Formats a date with a Qt date/time format string, plus the custom code
// [th], which becomes the ordinal suffix of the day (use as d[th] -> 15th).
function format(date, fmt) {
    if (!fmt) return "";
    const suffix = "'" + ordinalSuffix(date.getDate()) + "'";
    return Qt.formatDateTime(date, fmt.split("[th]").join(suffix));
}

// Joins the formatted date and time with the separator, skipping empty parts.
function line(date, dateFmt, timeFmt, separator) {
    const parts = [];
    if (dateFmt) parts.push(format(date, dateFmt));
    if (timeFmt) parts.push(format(date, timeFmt));
    return parts.join(separator);
}
