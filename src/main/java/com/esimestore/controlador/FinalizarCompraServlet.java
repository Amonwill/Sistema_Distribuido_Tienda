package com.esimestore.controlador;

import com.esimestore.config.ConexionDB;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/finalizar_compra")
public class FinalizarCompraServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        List<Map<String, Object>> carrito = (List<Map<String, Object>>) session.getAttribute("carrito");
        Integer idCliente = (Integer) session.getAttribute("idCliente");

        if (carrito == null || carrito.isEmpty()) {
            response.sendRedirect("tienda.jsp?error=vacio");
            return;
        }

        // Definimos el cliente a usar. Si idCliente es null, intentamos con 1.
        int idClienteFinal = (idCliente != null) ? idCliente : 1;

        try (Connection con = ConexionDB.getConexion()) {
            // 1. Validar que el cliente realmente exista en la tabla Clientes_Cat
            PreparedStatement psCheck = con.prepareStatement("SELECT ID_Cliente FROM Clientes_Cat WHERE ID_Cliente = ?");
            psCheck.setInt(1, idClienteFinal);
            ResultSet rsCheck = psCheck.executeQuery();

            if (!rsCheck.next()) {
                response.sendRedirect("tienda.jsp?error=cliente_no_registrado");
                return;
            }

            // 2. Buscar una caja abierta (Estado_Caja = 1)
            PreparedStatement psCaja = con.prepareStatement("SELECT ID_Session FROM Caja_General WHERE Estado_Caja = 1 LIMIT 1");
            ResultSet rsCaja = psCaja.executeQuery();
            
            if (!rsCaja.next()) {
                response.sendRedirect("tienda.jsp?error=caja_cerrada");
                return;
            }
            int idCajaActiva = rsCaja.getInt("ID_Session");

            // 3. Registrar cada producto en la venta
            for (Map<String, Object> item : carrito) {
                CallableStatement cs = con.prepareCall("{CALL sp_registrar_venta(?, ?, ?, ?, ?)}");
                cs.setInt(1, idClienteFinal);
                cs.setDouble(2, Double.parseDouble(item.get("precio").toString()));
                cs.setInt(3, Integer.parseInt(item.get("id").toString()));
                cs.setInt(4, 1); 
                cs.setInt(5, idCajaActiva);
                cs.execute();
            }
            
            // 4. Limpiar carrito y éxito
            session.removeAttribute("carrito");
            response.sendRedirect("tienda.jsp?msg=exito");
            
        } catch (Exception e) {
            e.printStackTrace();
            // Redirigir indicando el error técnico
            response.sendRedirect("tienda.jsp?error=sql_exception");
        }
    }
}