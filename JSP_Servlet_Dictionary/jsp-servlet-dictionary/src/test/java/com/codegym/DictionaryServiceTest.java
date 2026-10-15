package com.codegym;

import java.util.Objects;

/** Framework-free Java test runner: javac/java are enough, Maven is optional. */
public final class DictionaryServiceTest {
    private static int passed = 0;
    private static int total = 0;

    private static void check(String label, Object expected, Object actual) {
        total++;
        if (!Objects.equals(expected, actual)) {
            throw new AssertionError(label + ": expected [" + expected + "] but got [" + actual + "]");
        }
        passed++;
        System.out.println("PASS " + label);
    }

    public static void main(String[] args) {
        check("hello", "Xin chào", DictionaryService.translate("hello"));
        check("book", "Quyển sách", DictionaryService.translate("book"));
        check("computer", "Máy tính", DictionaryService.translate("computer"));
        check("student", "Sinh viên", DictionaryService.translate("student"));
        check("how", "Thế nào", DictionaryService.translate("how"));
        check("case insensitive", "Quyển sách", DictionaryService.translate("BOOK"));
        check("mixed case", "Máy tính", DictionaryService.translate("CoMpUtEr"));
        check("trim whitespace", "Xin chào", DictionaryService.translate("  hello  "));
        check("tabs and newline", "Sinh viên", DictionaryService.translate("\tstudent\n"));
        check("multiple words", "Cảm ơn", DictionaryService.translate("thank you"));
        check("missing key", null, DictionaryService.translate("not-a-word"));
        check("empty key", null, DictionaryService.translate(""));
        check("whitespace key", null, DictionaryService.translate("   "));
        check("null key", null, DictionaryService.translate(null));
        check("map word count", 25, DictionaryService.size());
        check("ampersand escaped", "a&amp;b", HtmlUtil.escape("a&b"));
        check("HTML escaped", "&lt;script&gt;", HtmlUtil.escape("<script>"));
        check("quotes escaped", "&quot;&#39;", HtmlUtil.escape("\"'"));
        check("null safely escaped", "", HtmlUtil.escape(null));
        System.out.printf("PASS %d/%d checks%n", passed, total);
    }
}
