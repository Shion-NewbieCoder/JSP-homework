package jakarta.servlet.http;
import java.io.IOException;
public interface HttpServletResponse {
 int SC_BAD_REQUEST=400, SC_NOT_FOUND=404;
 void sendError(int s) throws IOException; void sendError(int s,String m) throws IOException;
 void setStatus(int s); void sendRedirect(String loc) throws IOException;
}
