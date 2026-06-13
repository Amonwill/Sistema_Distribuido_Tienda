package com.esimestore.controlador;

import com.esimestore.dao.MetricasDAO;
import java.io.IOException;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ReporteServlet", urlPatterns = {"/reporte-semanal"})
public class ReporteServlet extends HttpServlet {
    
    private MetricasDAO metricasDAO = new MetricasDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Map<String, Object> reporte = metricasDAO.obtenerReporteSemanal();
        
        request.setAttribute("reporte", reporte);
        
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"Reporte_Semanal.pdf\"");
        
        request.getRequestDispatcher("reporte.jsp").forward(request, response);
    }
}