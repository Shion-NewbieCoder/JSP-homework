import com.codegym.model.*;
import com.codegym.strategy.*;
import com.codegym.service.*;
import java.nio.file.*;
import java.util.*;
public class InotesTest {
  static int pass=0;
  static void check(boolean c, String msg) { if(!c) throw new AssertionError(msg); pass++; }
  static void raises(Runnable r) { boolean ok=false;try {r.run();}catch (StorageException | IllegalStateException e){ok=true;}check(ok,"exception expected"); }
  public static void main(String[] args) throws Exception {
    Path dir=Files.createTempDirectory("inotes-test-");Path file=dir.resolve("notes.txt");
    NoteFileStrategy fs=new NoteFileStrategy(file);NoteManagement mgr=new NoteManagement(fs);
    check(mgr.findAll().size()==0,"empty");
    check(mgr.findTypes().size()==3,"three categories");
    String title="Lịch họp | thứ Hai \\ sớm";
    String body="Đầu tiên | lưu ý\\test\nDòng thứ 2\rDòng thứ 3";
    Note n1=mgr.addNote(title,body,2);
    check(n1.getId()==1,"id1");check(Files.exists(file),"file created");
    String raw=Files.readString(file);check(raw.contains("\\|")&&raw.contains("\\n")&&raw.contains("\\\\"),"escaped");
    check(!raw.contains("Dòng thứ 2\r"),"no raw CR");
    Note reopened=new NoteFileStrategy(file).findById(1);
    check(title.equals(reopened.getTitle()),"title restored");check(body.equals(reopened.getContent()),"body restored");
    check(reopened.getTypeId()==2,"type restored");
    check(mgr.searchNotes("lỊch HỌp").size()==1,"search case fold title");
    check(mgr.searchNotes("dÒng thứ 2").size()==1,"search body");
    check(mgr.searchNotes("none").isEmpty(),"search miss");
    check(mgr.searchNotes("   ").size()==1,"search blank");
    Note n2=mgr.addNote("Java Strategy", "Coding", 3);
    check(n2.getId()==2,"increment id");
    check(mgr.findAll().get(0).getId()==2,"sort descending");
    mgr.updateNote(1,"Đã sửa", "new content", 1);
    check(mgr.findById(1).getTitle().equals("Đã sửa"),"edit title");
    check(mgr.findById(1).getTypeId()==1,"edit category");
    check(mgr.findById(1).getContent().equals("new content"),"edit content");
    raises(()->mgr.updateNote(789,"a","b",1));
    raises(()->mgr.deleteNote(789));
    mgr.deleteNote(2);
    check(mgr.findById(2)==null,"delete");
    check(mgr.findAll().size()==1,"delete persistence");
    check(mgr.findById(1).getExcerpt().equals("new content"),"excerpt");
    raises(()->new Note().save());
    mgr.setStrategy(new NoteFileStrategy(dir.resolve("other.txt")));
    check(mgr.findAll().isEmpty(),"switch strategy");
    mgr.setStrategy(new NoteFileStrategy(file));
    check(mgr.findAll().size()==1,"return strategy");
    // Corruption is surfaced rather than silently discarded.
    Files.writeString(file,"10|broken|unknown\\q|2\n");
    raises(()->mgr.findAll());
    System.out.println("PASS "+pass+" Java assertions. File: "+dir);
  }
}
