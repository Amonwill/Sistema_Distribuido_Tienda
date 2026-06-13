package com.esimestore.dao;

import com.esimestore.config.ConexionDB;
import java.sql.*;
import java.util.*;

public class ProveedoresDAO {

    public List<Map<String, String>> listarProveedores() {
        List<Map<String, String>> lista = new ArrayList<>();
        String sql = "SELECT ID_Proveedor, Nombre_Proveedor FROM Proveedores_Cat WHERE Proveedor_Activo = 1";
        
        try (Connection con = ConexionDB.getConexion(); 
             Statement st = con.createStatement(); 
             ResultSet rs = st.executeQuery(sql)) {
             
            while (rs.next()) {
                Map<String, String> p = new HashMap<>();
                p.put("id", String.valueOf(rs.getInt("ID_Proveedor")));
                p.put("nombre", rs.getString("Nombre_Proveedor"));
                lista.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}