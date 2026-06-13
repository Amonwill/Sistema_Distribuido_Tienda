package com.esimestore.controlador;

import com.esimestore.dao.CajaDAO;
import com.esimestore.modelo.Caja;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "CajasServlet", urlPatterns = {"/cajas"})
public class CajasServlet extends HttpServlet {
    
    private CajaDAO cajaDAO = new CajaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Caja> lista = cajaDAO.listarCajas();
        request.setAttribute("listaCajas", lista);
        request.getRequestDispatcher("cajas.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        
        if ("abrir".equals(accion)) {
            int idCajaFisica = Integer.parseInt(request.getParameter("idCajaFisica"));
            double saldoInicial = Double.parseDouble(request.getParameter("saldoInicial"));
            cajaDAO.abrirCaja(idCajaFisica, saldoInicial);
        } else if ("cerrar".equals(accion)) {
            int idSession = Integer.parseInt(request.getParameter("idSession"));
            cajaDAO.cerrarCaja(idSession);
        }
        
        response.sendRedirect("cajas");
    }
}