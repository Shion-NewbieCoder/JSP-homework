package com.codegym.strategy;

import com.codegym.model.Note;
import com.codegym.model.NoteType;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

/** File UTF-8: một ghi chú/dòng, định dạng id|title|content|typeId; \ và |, newline được escape. */
public class NoteFileStrategy implements NoteStrategy {
    private static final Object FILE_LOCK = new Object();
    private static final List<NoteType> TYPES = List.of(
            new NoteType(1, "Cá nhân", "Ghi chú cá nhân"),
            new NoteType(2, "Công việc", "Lịch trình và công việc"),
            new NoteType(3, "Học tập", "Bài học và ôn tập"));
    private final Path file;

    public NoteFileStrategy(Path file) { this.file = file.toAbsolutePath().normalize(); }

    @Override public void save(Note note) {
        synchronized (FILE_LOCK) {
            List<Note> notes = read();
            if (note.getId() <= 0) {
                int id = notes.stream().mapToInt(Note::getId).max().orElse(0) + 1;
                note.setId(id);
                notes.add(copy(note));
            } else {
                int pos = -1;
                for (int i = 0; i < notes.size(); i++) {
                    if (notes.get(i).getId() == note.getId()) { pos = i; break; }
                }
                if (pos < 0) throw new StorageException("Không tìm thấy ghi chú cần sửa");
                notes.set(pos, copy(note));
            }
            write(notes);
        }
    }
    @Override public void delete(int id) {
        synchronized (FILE_LOCK) {
            List<Note> notes = read();
            if (!notes.removeIf(note -> note.getId() == id)) {
                throw new StorageException("Không tìm thấy ghi chú cần xóa");
            }
            write(notes);
        }
    }
    @Override public List<Note> findAll() {
        synchronized (FILE_LOCK) {
            List<Note> notes = read();
            notes.sort(Comparator.comparingInt(Note::getId).reversed());
            return notes;
        }
    }
    @Override public List<Note> search(String keyword) {
        if (keyword == null || keyword.isBlank()) return findAll();
        String k = keyword.strip().toLowerCase(Locale.ROOT);
        List<Note> matches = new ArrayList<>();
        for (Note note : findAll()) {
            if (note.getTitle().toLowerCase(Locale.ROOT).contains(k)
                    || (note.getContent() != null && note.getContent().toLowerCase(Locale.ROOT).contains(k))) {
                matches.add(note);
            }
        }
        return matches;
    }
    @Override public Note findById(int id) {
        synchronized (FILE_LOCK) {
            return read().stream().filter(n -> n.getId() == id).findFirst().orElse(null);
        }
    }
    @Override public List<NoteType> findTypes() { return TYPES; }

    private static Note copy(Note n) { return new Note(n.getId(), n.getTitle(), n.getContent(), n.getTypeId()); }
    private List<Note> read() {
        List<Note> notes = new ArrayList<>();
        if (!Files.exists(file)) return notes;
        try {
            for (String line : Files.readAllLines(file, StandardCharsets.UTF_8)) {
                if (line.isEmpty()) continue;
                List<String> parts = parse(line);
                if (parts.size() != 4) throw new IllegalArgumentException("Số cột sai");
                int id = Integer.parseInt(parts.get(0));
                int type = Integer.parseInt(parts.get(3));
                notes.add(new Note(id, parts.get(1), parts.get(2), type));
            }
        } catch (IOException | IllegalArgumentException ex) {
            throw new StorageException("Dữ liệu notes.txt không hợp lệ hoặc không thể đọc", ex);
        }
        return notes;
    }
    private void write(List<Note> notes) {
        Path temp = null;
        try {
            Path parent = file.getParent();
            Files.createDirectories(parent);
            temp = Files.createTempFile(parent, "inotes-", ".tmp");
            List<String> lines = new ArrayList<>();
            for (Note n : notes) {
                lines.add(n.getId() + "|" + escape(n.getTitle()) + "|"
                        + escape(n.getContent()) + "|" + n.getTypeId());
            }
            Files.write(temp, lines, StandardCharsets.UTF_8, StandardOpenOption.TRUNCATE_EXISTING);
            try {
                Files.move(temp, file, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
            } catch (AtomicMoveNotSupportedException ex) {
                Files.move(temp, file, StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException ex) {
            throw new StorageException("Không thể ghi notes.txt", ex);
        } finally {
            if (temp != null) {
                try { Files.deleteIfExists(temp); } catch (IOException ignored) { /* best effort */ }
            }
        }
    }
    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("|", "\\|")
                .replace("\n", "\\n").replace("\r", "\\r");
    }
    private static List<String> parse(String line) {
        List<String> fields = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        boolean escaped = false;
        for (int i = 0; i < line.length(); i++) {
            char ch = line.charAt(i);
            if (escaped) {
                switch (ch) {
                    case 'n' -> current.append('\n');
                    case 'r' -> current.append('\r');
                    case '|' -> current.append('|');
                    case '\\' -> current.append('\\');
                    default -> throw new IllegalArgumentException("Escape không hợp lệ");
                }
                escaped = false;
            } else if (ch == '\\') {
                escaped = true;
            } else if (ch == '|') {
                fields.add(current.toString()); current.setLength(0);
            } else {
                current.append(ch);
            }
        }
        if (escaped) throw new IllegalArgumentException("Escape thiếu ký tự");
        fields.add(current.toString());
        return fields;
    }
}
