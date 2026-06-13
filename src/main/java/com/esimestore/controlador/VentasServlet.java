package com.esimestore.controlador;

import com.esimestore.dao.CajaDAO;
import com.esimestore.dao.ProductoDAO;
import com.esimestore.dao.VentaDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "VentasServlet", urlPatterns = {"/ventas"})
public class VentasServlet extends HttpServlet {

    private CajaDAO cajaDAO = new CajaDAO();
    private ProductoDAO productoDAO = new ProductoDAO();
    private VentaDAO ventaDAO = new VentaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int idSessionActiva = cajaDAO.obtenerSesionActiva();
        
        if (idSessionActiva != -1) {
            request.setAttribute("cajaAbierta", true);
            request.setAttribute("idSession", idSessionActiva);
            request.setAttribute("listaProductos", productoDAO.listarProductos());
        } else {
            request.setAttribute("cajaAbierta", false);
        }
        
        request.getRequestDispatcher("ventas.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int idSession = Integer.parseInt(request.getParameter("idSession"));
        int idCliente = Integer.parseInt(request.getParameter("idCliente"));
        double pagoTotal = Double.parseDouble(request.getParameter("pagoTotal"));
        
        String[] idsProductos = request.getParameterValues("itemProducto");
        String[] cantidades = request.getParameterValues("itemCantidad");
        
        if (idsProductos != null && cantidades != null) {
            String resultado = ventaDAO.procesarCarrito(idCliente, pagoTotal, idsProductos, cantidades, idSession);
            String[] partes = resultado.split("\\|");
            
            if ("EXITO".equals(partes[0])) {
                request.getSession().setAttribute("msgExito", partes[1]);
            } else {
                request.getSession().setAttribute("msgError", partes[1]);
            }
        }
        
        response.sendRedirect("ventas");
    }
}