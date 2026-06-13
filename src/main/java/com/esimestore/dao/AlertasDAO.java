package com.esimestore.dao;

import com.esimestore.config.ConexionDB;
import java.sql.*;
import java.util.*;

public class AlertasDAO {
    public List<Map<String, String>> obtenerAlertas() {
        List<Map<String, String>> alertas = new ArrayList<>();
        try (Connection con = ConexionDB.getConexion()) {
            con.prepareCall("{CALL sp_generar_alertas()}").execute();
            
            String sql = "SELECT Mensaje, Tipo_Alerta, TIMESTAMPDIFF(MINUTE, Fecha_Generada, NOW()) as MinutosPasados FROM Bandeja_Alertas ORDER BY Fecha_Generada DESC";
            try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql)) {
                while (rs.next()) {
                    Map<String, String> alerta = new HashMap<>();
                    alerta.put("mensaje", rs.getString("Mensaje"));
                    alerta.put("tipo", rs.getString("Tipo_Alerta"));
                    alerta.put("tiempo", rs.getString("MinutosPasados") + " min");
                    alertas.add(alerta);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return alertas;
    }
}