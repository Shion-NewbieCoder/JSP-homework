package jakarta.servlet.annotation;
import java.lang.annotation.*;
@Retention(RetentionPolicy.RUNTIME) @Target(ElementType.TYPE)
public @interface WebServlet { String name(); String[] urlPatterns(); }
