package com.esimestore.controlador;

import com.esimestore.dao.ProveedorDAO;
import com.esimestore.modelo.Proveedor;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ProveedorServlet", urlPatterns = {"/proveedores"})
public class ProveedorServlet extends HttpServlet {
    
    private ProveedorDAO proveedorDAO = new ProveedorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Proveedor> proveedores = proveedorDAO.listarProveedores();
        request.setAttribute("listaProveedores", proveedores);
        request.getRequestDispatcher("proveedores.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        
        if ("eliminar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("idProveedor"));
            proveedorDAO.eliminarProveedor(id);
        } else {
            Proveedor p = new Proveedor();
            p.setNombre(request.getParameter("nombre"));
            p.setDescripcion(request.getParameter("empresa"));
            p.setTelefono(request.getParameter("telefono"));
            p.setCorreo(request.getParameter("email"));
            p.setDireccion(request.getParameter("direccion"));
            p.setCiudad(request.getParameter("ciudad"));
            
            if ("actualizar".equals(accion)) {
                p.setIdProveedor(Integer.parseInt(request.getParameter("idProveedor")));
                proveedorDAO.actualizarProveedor(p);
            } else {
                proveedorDAO.agregarProveedor(p);
            }
        }
        response.sendRedirect("proveedores");
    }
}