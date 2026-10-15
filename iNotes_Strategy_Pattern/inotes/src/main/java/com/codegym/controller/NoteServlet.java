package com.codegym.controller;

import com.codegym.model.Note;
import com.codegym.model.NoteType;
import com.codegym.service.NoteManagement;
import com.codegym.service.StorageStrategyFactory;
import com.codegym.strategy.StorageException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Locale;

/** MVC Controller: cùng View và nghiệp vụ cho cả 2 chiến lược lưu trữ. */
@WebServlet(name = "NoteServlet", urlPatterns = "/notes")
public class NoteServlet extends HttpServlet {
    private static final String VIEW = "/WEB-INF/views/notes/";

    private NoteManagement manager(HttpServletRequest request) {
        Object chosen = request.getSession().getAttribute("storage");
        String storage = "mysql".equals(chosen) ? "mysql" : "file";
        return new NoteManagement(StorageStrategyFactory.create(storage));
    }
    private static String currentStorage(HttpServletRequest request) {
        return "mysql".equals(request.getSession().getAttribute("storage")) ? "mysql" : "file";
    }
    private void prepare(HttpServletRequest request, NoteManagement service) {
        request.setAttribute("types", service.findTypes());
        request.setAttribute("storage", currentStorage(request));
        Object flash = request.getSession().getAttribute("flash");
        if (flash != null) {
            request.setAttribute("flash", flash);
            request.getSession().removeAttribute("flash");
        }
    }
    private void forward(HttpServletRequest req, HttpServletResponse res, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher(VIEW + page + ".jsp").forward(req, res);
    }
    private static Integer parseId(String raw) {
        try { int id = Integer.parseInt(raw); return id > 0 ? id : null; }
        catch (NumberFormatException ex) { return null; }
    }
    private Note requireNote(NoteManagement service, HttpServletRequest req, HttpServletResponse res) throws IOException {
        Integer id = parseId(req.getParameter("id"));
        if (id == null) { res.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID không hợp lệ"); return null; }
        Note note = service.findById(id);
        if (note == null) { res.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy ghi chú"); }
        return note;
    }

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        res.setCharacterEncoding("UTF-8");
        NoteManagement service = manager(req);
        String action = req.getParameter("action");
        if (action == null) action = "list";
        try {
            prepare(req, service);
            switch (action) {
                case "create" -> {
                    req.setAttribute("note", new Note());
                    req.setAttribute("editing", false);
                    forward(req, res, "form");
                }
                case "view", "edit", "delete" -> {
                    Note note = requireNote(service, req, res);
                    if (note == null) return;
                    req.setAttribute("note", note);
                    req.setAttribute("editing", "edit".equals(action));
                    forward(req, res, switch (action) {
                        case "view" -> "view";
                        case "edit" -> "form";
                        default -> "delete";
                    });
                }
                case "list" -> {
                    String keyword = req.getParameter("q");
                    String typeStr = req.getParameter("type");
                    Integer type = parseId(typeStr);
                    List<Note> notes = service.searchNotes(keyword);
                    if (type != null) notes = notes.stream().filter(n -> n.getTypeId() == type).toList();
                    req.setAttribute("notes", notes);
                    req.setAttribute("q", keyword == null ? "" : keyword);
                    req.setAttribute("selectedType", type == null ? 0 : type);
                    forward(req, res, "list");
                }
                default -> res.sendError(HttpServletResponse.SC_NOT_FOUND, "Action không tồn tại");
            }
        } catch (StorageException ex) { showStorageError(req, res, ex); }
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) { res.sendError(400); return; }
        if ("switch".equals(action)) {
            String target = req.getParameter("storage");
            if (!"file".equals(target) && !"mysql".equals(target)) { res.sendError(400); return; }
            req.getSession().setAttribute("storage", target);
            req.getSession().setAttribute("flash", "Đã chuyển kho lưu trữ sang " + ("mysql".equals(target) ? "MySQL" : "File TXT")
                    + ". Dữ liệu giữa hai kho không tự động đồng bộ.");
            res.sendRedirect(req.getContextPath() + "/notes");
            return;
        }
        NoteManagement service = manager(req);
        try {
            switch (action) {
                case "save" -> saveNote(req, res, service);
                case "delete" -> {
                    Note note = requireNote(service, req, res);
                    if (note == null) return;
                    service.deleteNote(note.getId());
                    req.getSession().setAttribute("flash", "Đã xóa ghi chú.");
                    res.sendRedirect(req.getContextPath() + "/notes");
                }
                default -> res.sendError(400);
            }
        } catch (StorageException ex) { showStorageError(req, res, ex); }
    }
    private void saveNote(HttpServletRequest req, HttpServletResponse res, NoteManagement service)
            throws ServletException, IOException {
        String title = req.getParameter("title") == null ? "" : req.getParameter("title").trim();
        String content = req.getParameter("content") == null ? "" : req.getParameter("content");
        Integer id = parseId(req.getParameter("id"));
        boolean editing = req.getParameter("id") != null && !req.getParameter("id").isBlank();
        Integer type = parseId(req.getParameter("typeId"));
        Note draft = new Note(id == null ? 0 : id, title, content, type == null ? 0 : type);
        String error = null;
        if (editing && id == null) error = "ID ghi chú không hợp lệ.";
        else if (title.isBlank() || title.length() > 255) error = "Tiêu đề phải có từ 1 đến 255 ký tự.";
        else if (content.length() > 12_000) error = "Nội dung không được vượt quá 12.000 ký tự.";
        else if (type == null || service.findTypes().stream().noneMatch(t -> t.getId() == type))
            error = "Vui lòng chọn phân loại hợp lệ.";
        if (error != null) {
            prepare(req, service);
            req.setAttribute("formError", error);
            req.setAttribute("note", draft);
            req.setAttribute("editing", editing);
            res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            forward(req, res, "form");
            return;
        }
        if (editing) {
            if (service.findById(id) == null) { res.sendError(404); return; }
            service.updateNote(id, title, content, type);
        } else {
            service.addNote(title, content, type);
        }
        req.getSession().setAttribute("flash", editing ? "Đã cập nhật ghi chú." : "Đã tạo ghi chú mới.");
        res.sendRedirect(req.getContextPath() + "/notes");
    }
    private void showStorageError(HttpServletRequest req, HttpServletResponse res, StorageException ex)
            throws ServletException, IOException {
        getServletContext().log("iNotes storage failure", ex);
        req.setAttribute("storage", currentStorage(req));
        req.setAttribute("message", "Không thể truy cập kho dữ liệu. Kiểm tra cấu hình MySQL hoặc đường dẫn file trong README.");
        res.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        forward(req, res, "error");
    }
}
