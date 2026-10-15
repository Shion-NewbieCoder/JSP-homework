package com.codegym.service;

import com.codegym.strategy.NoteDBStrategy;
import com.codegym.strategy.NoteFileStrategy;
import com.codegym.strategy.NoteStrategy;
import java.nio.file.Path;

/** Tạo Strategy theo cấu hình, không hardcode mật khẩu vào GitHub. */
public final class StorageStrategyFactory {
    private StorageStrategyFactory() { }
    public static NoteStrategy create(String name) {
        if ("mysql".equals(name)) {
            return new NoteDBStrategy(
                    env("INOTES_DB_URL", "jdbc:mysql://localhost:3306/inotes_db?useUnicode=true&characterEncoding=UTF-8"),
                    env("INOTES_DB_USER", "root"),
                    env("INOTES_DB_PASSWORD", ""));
        }
        String defaultPath = Path.of(System.getProperty("user.home"), ".inotes", "notes.txt").toString();
        return new NoteFileStrategy(Path.of(env("INOTES_FILE_PATH", defaultPath)));
    }
    private static String env(String key, String fallback) {
        String value = System.getenv(key);
        return value == null || value.isBlank() ? fallback : value;
    }
}
