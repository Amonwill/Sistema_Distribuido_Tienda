package com.esimestore.dao;

import com.esimestore.config.ConexionDB;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;

public class VentaDAO {

    public String procesarCarrito(int idCliente, double pagoInicial, String[] idsProductos, String[] cantidades, int idSession) {
        double pagoRestante = pagoInicial;
        double sumaTotales = 0;

        try (Connection con = ConexionDB.getConexion()) {
            
            for (int i = 0; i < idsProductos.length; i++) {
                int idProd = Integer.parseInt(idsProductos[i]);
                int cantidad = Integer.parseInt(cantidades[i]);

                try (CallableStatement cs = con.prepareCall("{CALL sp_registrar_venta(?, ?, ?, ?, ?)}")) {
                    cs.setInt(1, idCliente);
                    cs.setDouble(2, pagoRestante); 
                    cs.setInt(3, idProd);
                    cs.setInt(4, cantidad);
                    cs.setInt(5, idSession);

                    try (ResultSet rs = cs.executeQuery()) {
                        if (rs.next()) {
                            double totalItem = rs.getDouble("total");
                            pagoRestante = rs.getDouble("cambio"); 
                            sumaTotales += totalItem;
                        }
                    }
                }
            }
            return "EXITO|Venta completada con éxito. Cobrado: $" + sumaTotales + " | Cambio entregado: $" + pagoRestante;
            
        } catch (Exception e) {
            return "ERROR|Error al registrar: " + e.getMessage();
        }
    }
}