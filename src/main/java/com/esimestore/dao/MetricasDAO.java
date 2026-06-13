package com.esimestore.dao;

import com.esimestore.config.ConexionDB;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MetricasDAO {

    public Map<String, Object> obtenerDashboard() {
        Map<String, Object> result = new HashMap<>();
        String sql = "{CALL sp_metricas_ventas()}";
        
        try (Connection con = ConexionDB.getConexion(); CallableStatement cs = con.prepareCall(sql)) {
            boolean hasResults = cs.execute();
            
            if (hasResults) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        result.put("TotalDinero", rs.getDouble("TotalDinero"));
                        result.put("TotalVentas", rs.getInt("TotalVentas"));
                        result.put("TicketPromedio", rs.getDouble("TicketPromedio"));
                    }
                }
            }
            
            if (cs.getMoreResults()) {
                try (ResultSet rs = cs.getResultSet()) {
                    List<Map<String, String>> topProd = new ArrayList<>();
                    while (rs.next()) {
                        Map<String, String> p = new HashMap<>();
                        p.put("Nombre", rs.getString("Nombre_Producto"));
                        p.put("Cantidad", rs.getString("CantidadVendida"));
                        topProd.add(p);
                    }
                    result.put("TopProductos", topProd);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error SQL en Dashboard: " + e.getMessage());
        }
        return result;
    }

    public Map<String, Object> obtenerReporteSemanal() {
        Map<String, Object> result = new HashMap<>();
        String sql = "{CALL sp_reporte_semanal()}";
        
        try (Connection con = ConexionDB.getConexion(); CallableStatement cs = con.prepareCall(sql)) {
            boolean hasResults = cs.execute();
            
            if (hasResults) {
                try (ResultSet rs = cs.getResultSet()) {
                    List<Map<String, Object>> dias = new ArrayList<>();
                    while (rs.next()) {
                        Map<String, Object> d = new HashMap<>();
                        d.put("fecha", rs.getString("Fecha"));
                        d.put("dia", rs.getString("DiaNombre"));
                        d.put("total", rs.getDouble("VentaDiaria"));
                        d.put("ops", rs.getInt("Operaciones"));
                        dias.add(d);
                    }
                    result.put("ventasSemanales", dias);
                }
            }
            
            if (cs.getMoreResults()) {
                try (ResultSet rs = cs.getResultSet()) {
                    List<Map<String, Object>> topProd = new ArrayList<>();
                    while (rs.next()) {
                        Map<String, Object> p = new HashMap<>();
                        p.put("Nombre", rs.getString("Nombre_Producto"));
                        p.put("cantidad", rs.getInt("CantidadTotal"));
                        topProd.add(p);
                    }
                    result.put("topProductosSemana", topProd);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error SQL en Reporte Semanal: " + e.getMessage());
        }
        return result;
    }

    public Map<String, Object> obtenerCorteCaja() {
        Map<String, Object> result = new HashMap<>();
        String sql = "{CALL sp_obtener_datos_corte_diario()}";
        
        try (Connection con = ConexionDB.getConexion(); CallableStatement cs = con.prepareCall(sql)) {
            boolean hasResults = cs.execute();
            List<Map<String, Object>> sesiones = new ArrayList<>();
            
            if (hasResults) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        Map<String, Object> s = new HashMap<>();
                        s.put("ID_Session", rs.getInt("ID_Session"));
                        s.put("Nombre_Caja", rs.getString("Nombre_Caja"));
                        s.put("Saldo_Inicial", rs.getDouble("Saldo_Inicial"));
                        s.put("Ingresos_Totales", rs.getDouble("Ingresos_Totales"));
                        s.put("Egresos_Totales", rs.getDouble("Egresos_Totales"));
                        s.put("productos", new ArrayList<Map<String, Object>>());
                        sesiones.add(s);
                    }
                }
            }
            
            if (cs.getMoreResults()) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        int idSession = rs.getInt("ID_Session");
                        Map<String, Object> p = new HashMap<>();
                        p.put("Nombre_Producto", rs.getString("Nombre_Producto"));
                        p.put("total_cant", rs.getInt("Cantidad"));
                        p.put("subtotal_prod", rs.getDouble("Subtotal"));
                        
                        for (Map<String, Object> sesion : sesiones) {
                            if ((Integer) sesion.get("ID_Session") == idSession) {
                                ((List<Map<String, Object>>) sesion.get("productos")).add(p);
                                break;
                            }
                        }
                    }
                }
            }
            result.put("sesiones", sesiones);
        } catch (SQLException e) {
            System.err.println("Error SQL en Corte Caja: " + e.getMessage());
        }
        return result;
    }
}