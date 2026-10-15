package jakarta.servlet.http;
import jakarta.servlet.RequestDispatcher;
import java.io.UnsupportedEncodingException;
public interface HttpServletRequest {
 String getParameter(String name); String[] getParameterValues(String name);
 String getContextPath(); RequestDispatcher getRequestDispatcher(String p);
 void setAttribute(String k, Object v); void setCharacterEncoding(String enc) throws UnsupportedEncodingException;
}
