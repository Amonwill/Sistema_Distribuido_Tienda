package com.esimestore.dao;

import com.esimestore.config.ConexionDB;
import com.esimestore.modelo.Caja;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CajaDAO {

    public List<Caja> listarCajas() {
        List<Caja> lista = new ArrayList<>();
        String sql = "{CALL sp_corte_por_caja(NULL)}";
        
        try (Connection con = ConexionDB.getConexion();
             CallableStatement cs = con.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
             
            while (rs.next()) {
                Caja c = new Caja();
                c.setNombreCaja(rs.getString("Nombre_Caja"));
                c.setIdSession(rs.getInt("ID_Session"));
                c.setFechaApertura(rs.getString("Fecha_Apertura"));
                c.setSaldoInicial(rs.getDouble("Saldo_Inicial"));
                c.setIngresosTotales(rs.getDouble("Ingresos_Totales"));
                c.setEgresosTotales(rs.getDouble("Egresos_Totales"));
                c.setSaldoActual(rs.getDouble("Saldo_Actual"));
                c.setEstatus(rs.getString("Estatus"));
                lista.add(c);
            }
        } catch (Exception e) {
            System.err.println("Error al listar cajas: " + e.getMessage());
        }
        return lista;
    }

    public boolean abrirCaja(int idCajaFisica, double saldoInicial) {
        String sql = "INSERT INTO Caja_General (ID_Caja_Fisica, Saldo_Inicial) VALUES (?, ?)";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
             
            ps.setInt(1, idCajaFisica);
            ps.setDouble(2, saldoInicial);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error al abrir caja: " + e.getMessage());
            return false;
        }
    }

    public boolean cerrarCaja(int idSession) {
        String sql = "UPDATE Caja_General SET Estado_Caja = 0, Fecha_Cierre = NOW() WHERE ID_Session = ?";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
             
            ps.setInt(1, idSession);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error al cerrar caja: " + e.getMessage());
            return false;
        }
    }
    public int obtenerSesionActiva() {
        String sql = "SELECT ID_Session FROM Caja_General WHERE Estado_Caja = 1 ORDER BY ID_Session DESC LIMIT 1";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            if (rs.next()) {
                return rs.getInt("ID_Session");
            }
        } catch (Exception e) {
            System.err.println("Error al buscar sesion activa: " + e.getMessage());
        }
        return -1; 
    }
}