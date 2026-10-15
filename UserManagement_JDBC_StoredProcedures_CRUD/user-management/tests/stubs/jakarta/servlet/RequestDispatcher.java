package jakarta.servlet;
import jakarta.servlet.http.*;
import java.io.IOException;
public interface RequestDispatcher { void forward(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException; }
