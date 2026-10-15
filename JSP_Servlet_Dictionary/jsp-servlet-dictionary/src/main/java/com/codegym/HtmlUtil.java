package com.codegym;

/** Escapes untrusted text before inserting it into HTML content or attributes. */
public final class HtmlUtil {
    private HtmlUtil() {
    }

    public static String escape(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
