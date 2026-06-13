package com.esimestore.controlador;

import com.esimestore.dao.ProductoDAO;
import com.esimestore.modelo.Producto;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "InventarioServlet", urlPatterns = {"/inventario"})
public class InventarioServlet extends HttpServlet {
    
    private ProductoDAO productoDAO = new ProductoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Producto> productos = productoDAO.listarProductos();
        request.setAttribute("listaProductos", productos);
        request.getRequestDispatcher("inventario.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8"); 
        String accion = request.getParameter("accion"); 
        
        if ("eliminar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("idProducto"));
            productoDAO.eliminarProducto(id);
        } 
        else if ("actualizar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("idProducto"));
            String nombre = request.getParameter("nombre");
            String descripcion = request.getParameter("descripcion");
            double pCompra = Double.parseDouble(request.getParameter("precioCompra"));
            double pVenta = Double.parseDouble(request.getParameter("precioVenta"));
            int cantidad = Integer.parseInt(request.getParameter("cantidad"));
            String proveedor = request.getParameter("proveedor");
            productoDAO.actualizarProducto(id, nombre, descripcion, pCompra, pVenta, cantidad, proveedor);
        } 
        else {
            String nombre = request.getParameter("nombre");
            String descripcion = request.getParameter("descripcion");
            double pCompra = Double.parseDouble(request.getParameter("precioCompra"));
            double pVenta = Double.parseDouble(request.getParameter("precioVenta"));
            int cantidad = Integer.parseInt(request.getParameter("cantidad"));
            String proveedor = request.getParameter("proveedor");
            String lote = request.getParameter("lote");
            String caducidad = request.getParameter("caducidad");
            productoDAO.agregarProducto(nombre, descripcion, pCompra, pVenta, cantidad, lote, caducidad, proveedor);
        }
        
        response.sendRedirect("inventario");
    }
}