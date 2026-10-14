package com.codegym.servlet;

import com.codegym.model.Calculator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "CalculatorServlet", urlPatterns = "/calculate")
public class CalculatorServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            String firstText = request.getParameter("first-operand");
            String secondText = request.getParameter("second-operand");
            String operatorText = request.getParameter("operator");
            if (firstText == null || secondText == null || operatorText == null
                    || firstText.isBlank() || secondText.isBlank()
                    || operatorText.length() != 1) {
                throw new IllegalArgumentException("Vui lòng nhập đủ hai toán hạng và phép toán.");
            }

            double firstOperand = Double.parseDouble(firstText.trim());
            double secondOperand = Double.parseDouble(secondText.trim());
            char operator = operatorText.charAt(0);
            double result = Calculator.calculate(firstOperand, secondOperand, operator);

            request.setAttribute("firstOperand", firstOperand);
            request.setAttribute("secondOperand", secondOperand);
            request.setAttribute("operator", Character.toString(operator));
            request.setAttribute("result", result);
        } catch (NumberFormatException exception) {
            request.setAttribute("error", "Vui lòng nhập hai số hợp lệ.");
        } catch (ArithmeticException | IllegalArgumentException exception) {
            request.setAttribute("error", exception.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/result.jsp")
                .forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/");
    }
}
