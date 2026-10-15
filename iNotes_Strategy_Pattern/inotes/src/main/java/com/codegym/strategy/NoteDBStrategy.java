package com.codegym.strategy;

import com.codegym.model.Note;
import com.codegym.model.NoteType;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Lưu trữ MySQL bằng JDBC/PreparedStatement (bảng inotes_db.notes). */
public class NoteDBStrategy implements NoteStrategy {
    private final String url;
    private final String username;
    private final String password;

    public NoteDBStrategy(String url, String username, String password) {
        this.url = url; this.username = username; this.password = password;
    }
    private Connection connect() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
    private static Note mapNote(ResultSet rs) throws SQLException {
        return new Note(rs.getInt("id"), rs.getString("title"),
                rs.getString("content"), rs.getInt("type_id"));
    }
    @Override public void save(Note note) {
        if (note.getId() <= 0) {
            String sql = "INSERT INTO notes(title, content, type_id) VALUES (?, ?, ?)";
            try (Connection conn = connect();
                 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, note.getTitle());
                ps.setString(2, note.getContent());
                ps.setInt(3, note.getTypeId());
                if (ps.executeUpdate() != 1) throw new StorageException("Không thể thêm ghi chú");
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) throw new StorageException("Không nhận được ID ghi chú mới");
                    note.setId(keys.getInt(1));
                }
            } catch (SQLException ex) { throw new StorageException("Không thể lưu ghi chú vào MySQL", ex); }
        } else {
            String sql = "UPDATE notes SET title=?, content=?, type_id=? WHERE id=?";
            try (Connection conn = connect(); PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, note.getTitle());
                ps.setString(2, note.getContent());
                ps.setInt(3, note.getTypeId());
                ps.setInt(4, note.getId());
                if (ps.executeUpdate() == 0) throw new StorageException("Không tìm thấy ghi chú cần sửa");
            } catch (SQLException ex) { throw new StorageException("Không thể sửa ghi chú trong MySQL", ex); }
        }
    }
    @Override public void delete(int id) {
        try (Connection conn = connect(); PreparedStatement ps = conn.prepareStatement("DELETE FROM notes WHERE id=?")) {
            ps.setInt(1, id);
            if (ps.executeUpdate() == 0) throw new StorageException("Không tìm thấy ghi chú cần xóa");
        } catch (SQLException ex) { throw new StorageException("Không thể xóa ghi chú khỏi MySQL", ex); }
    }
    @Override public List<Note> findAll() {
        return query("SELECT id,title,content,type_id FROM notes ORDER BY id DESC", null);
    }
    @Override public List<Note> search(String keyword) {
        if (keyword == null || keyword.isBlank()) return findAll();
        String escaped = keyword.trim().toLowerCase(Locale.ROOT)
                .replace("!", "!!").replace("%", "!%").replace("_", "!_");
        return query("SELECT id,title,content,type_id FROM notes "
                + "WHERE LOWER(title) LIKE ? ESCAPE '!' OR LOWER(COALESCE(content,'')) LIKE ? ESCAPE '!' "
                + "ORDER BY id DESC", "%" + escaped + "%");
    }
    private List<Note> query(String sql, String pattern) {
        List<Note> result = new ArrayList<>();
        try (Connection conn = connect(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (pattern != null) { ps.setString(1, pattern); ps.setString(2, pattern); }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) result.add(mapNote(rs));
            }
        } catch (SQLException ex) { throw new StorageException("Không thể đọc danh sách MySQL", ex); }
        return result;
    }
    @Override public Note findById(int id) {
        try (Connection conn = connect(); PreparedStatement ps = conn.prepareStatement(
                "SELECT id,title,content,type_id FROM notes WHERE id=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? mapNote(rs) : null; }
        } catch (SQLException ex) { throw new StorageException("Không thể tìm ghi chú MySQL", ex); }
    }
    @Override public List<NoteType> findTypes() {
        List<NoteType> result = new ArrayList<>();
        try (Connection conn = connect(); PreparedStatement ps = conn.prepareStatement(
                "SELECT id,name,description FROM note_type ORDER BY id"); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) result.add(new NoteType(rs.getInt("id"), rs.getString("name"), rs.getString("description")));
        } catch (SQLException ex) { throw new StorageException("Không thể tải danh mục MySQL", ex); }
        return result;
    }
}
