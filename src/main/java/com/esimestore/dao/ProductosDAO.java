package com.esimestore.dao;

import com.esimestore.config.ConexionDB;
import java.sql.*;
import java.util.*;

public class ProductosDAO {

    public List<Map<String, Object>> listarProductosFiltrados(String nombre, String idProveedor) {
        List<Map<String, Object>> productos = new ArrayList<>();
        String sql = "SELECT p.*, pr.Nombre_Proveedor FROM Productos_Cat p " +
                     "JOIN Proveedores_Cat pr ON p.ID_Prove = pr.ID_Proveedor " +
                     "WHERE p.Producto_Activo = 1";
        
        if (nombre != null && !nombre.isEmpty()) sql += " AND p.Nombre_Producto LIKE ?";
        if (idProveedor != null && !idProveedor.isEmpty()) sql += " AND p.ID_Prove = ?";

        try (Connection con = ConexionDB.getConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            int index = 1;
            if (nombre != null && !nombre.isEmpty()) ps.setString(index++, "%" + nombre + "%");
            if (idProveedor != null && !idProveedor.isEmpty()) ps.setString(index++, idProveedor);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> p = new HashMap<>();
                p.put("id", rs.getInt("ID_Producto"));
                p.put("nombre", rs.getString("Nombre_Producto"));
                p.put("precio", rs.getDouble("Precio_Venta"));
                p.put("proveedor", rs.getString("Nombre_Proveedor"));
                productos.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return productos;
    }
}