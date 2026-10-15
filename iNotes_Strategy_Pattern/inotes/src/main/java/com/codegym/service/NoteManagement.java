package com.codegym.service;

import com.codegym.model.Note;
import com.codegym.model.NoteType;
import com.codegym.strategy.NoteStrategy;
import java.util.List;
import java.util.Objects;

/** Context của Strategy Pattern: nghiệp vụ không biết kho lưu trữ là MySQL hay file. */
public class NoteManagement {
    private NoteStrategy strategy;
    public NoteManagement(NoteStrategy strategy) { setStrategy(strategy); }
    public void setStrategy(NoteStrategy strategy) { this.strategy = Objects.requireNonNull(strategy); }
    public NoteStrategy getStrategy() { return strategy; }
    public List<Note> findAll() { return strategy.findAll(); }
    public List<Note> searchNotes(String keyword) { return strategy.search(keyword); }
    public List<NoteType> findTypes() { return strategy.findTypes(); }
    public Note findById(int id) { return strategy.findById(id); }
    public Note addNote(String title, String content, int typeId) {
        Note note = new Note(0, title, content, typeId).using(strategy);
        note.save();
        return note;
    }
    public void updateNote(int id, String title, String content, int typeId) {
        new Note(id, title, content, typeId).using(strategy).save();
    }
    public void deleteNote(int id) { new Note().using(strategy).delete(id); }
}
