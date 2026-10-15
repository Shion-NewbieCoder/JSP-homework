package com.codegym;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

/**
 * An in-memory English -> Vietnamese dictionary for the servlet exercise.
 * This service has no dependencies on the Servlet API and is easy to test.
 */
public final class DictionaryService {
    private static final Map<String, String> WORDS = createWords();

    private DictionaryService() {
        // Utility class; callers use translate().
    }

    private static Map<String, String> createWords() {
        Map<String, String> dictionary = new LinkedHashMap<>();
        dictionary.put("hello", "Xin chào");
        dictionary.put("how", "Thế nào");
        dictionary.put("book", "Quyển sách");
        dictionary.put("computer", "Máy tính");
        dictionary.put("student", "Sinh viên");
        dictionary.put("teacher", "Giáo viên");
        dictionary.put("school", "Trường học");
        dictionary.put("university", "Trường đại học");
        dictionary.put("apple", "Quả táo");
        dictionary.put("water", "Nước");
        dictionary.put("house", "Ngôi nhà");
        dictionary.put("friend", "Bạn bè");
        dictionary.put("family", "Gia đình");
        dictionary.put("love", "Tình yêu");
        dictionary.put("goodbye", "Tạm biệt");
        dictionary.put("morning", "Buổi sáng");
        dictionary.put("evening", "Buổi tối");
        dictionary.put("cat", "Con mèo");
        dictionary.put("dog", "Con chó");
        dictionary.put("programming", "Lập trình");
        dictionary.put("language", "Ngôn ngữ");
        dictionary.put("study", "Học tập");
        dictionary.put("work", "Công việc");
        dictionary.put("name", "Tên");
        dictionary.put("thank you", "Cảm ơn");
        return Collections.unmodifiableMap(dictionary);
    }

    /**
     * Looks up a word regardless of leading/trailing whitespace or letter case.
     * @return Vietnamese meaning or null if the word is absent.
     */
    public static String translate(String word) {
        if (word == null) {
            return null;
        }
        return WORDS.get(word.strip().toLowerCase(Locale.ROOT));
    }

    public static int size() {
        return WORDS.size();
    }
}
