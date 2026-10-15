package com.codegym.model;

import com.codegym.strategy.NoteStrategy;
import java.util.Objects;

/** Model ghi chú; save/delete là các phương thức tiện ích ủy quyền qua Strategy được gắn. */
public class Note {
    private int id;
    private String title;
    private String content;
    private int typeId;
    private transient NoteStrategy strategy;

    public Note() { }
    public Note(int id, String title, String content, int typeId) {
        this.id = id; this.title = title; this.content = content; this.typeId = typeId;
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public String getExcerpt() {
        if (content == null || content.isBlank()) return "Chưa có nội dung";
        String text = content.replaceAll("\\s+", " ").trim();
        return text.length() > 105 ? text.substring(0, 105) + "…" : text;
    }
    public Note using(NoteStrategy selectedStrategy) {
        this.strategy = Objects.requireNonNull(selectedStrategy);
        return this;
    }
    public void save() { requireStrategy().save(this); }
    public void delete(int id) { requireStrategy().delete(id); }
    private NoteStrategy requireStrategy() {
        if (strategy == null) throw new IllegalStateException("Chưa cấu hình NoteStrategy");
        return strategy;
    }
}
