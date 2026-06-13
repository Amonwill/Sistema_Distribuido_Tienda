package com.esimestore.controlador;

import com.esimestore.dao.MetricasDAO;
import java.io.IOException;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "MetricasServlet", urlPatterns = {"/metricas"})
public class MetricasServlet extends HttpServlet {
    
    private MetricasDAO metricasDAO = new MetricasDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Map<String, Object> dashboard = metricasDAO.obtenerDashboard();
        
        request.setAttribute("dashboard", dashboard);
        
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}