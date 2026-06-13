package com.esimestore.dao;

import com.esimestore.config.ConexionDB;
import com.esimestore.modelo.Proveedor;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ProveedorDAO {

    public List<Proveedor> listarProveedores() {
        List<Proveedor> lista = new ArrayList<>();
        String sql = "SELECT * FROM Proveedores_Cat WHERE Proveedor_Activo = 1";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Proveedor p = new Proveedor();
                p.setIdProveedor(rs.getInt("ID_Proveedor"));
                p.setNombre(rs.getString("Nombre_Proveedor"));
                p.setDescripcion(rs.getString("Descripcion_Proveedor"));
                p.setTelefono(rs.getString("Telefono_Proveedor"));
                p.setCorreo(rs.getString("Correo_Proveedor"));
                p.setDireccion(rs.getString("Direccion_Completa"));
                p.setCiudad(rs.getString("Ciudad_Estado"));
                lista.add(p);
            }
        } catch (Exception e) {
            System.err.println("Error listar proveedores: " + e.getMessage());
        }
        return lista;
    }

    public boolean agregarProveedor(Proveedor p) {
        String sql = "INSERT INTO Proveedores_Cat (Nombre_Proveedor, Descripcion_Proveedor, Telefono_Proveedor, Correo_Proveedor, Direccion_Completa, Ciudad_Estado, Proveedor_Activo) VALUES (?, ?, ?, ?, ?, ?, 1)";
        try (Connection con = ConexionDB.getConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setString(3, p.getTelefono());
            ps.setString(4, p.getCorreo());
            ps.setString(5, p.getDireccion());
            ps.setString(6, p.getCiudad());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error agregar proveedor: " + e.getMessage());
            return false;
        }
    }

    public boolean actualizarProveedor(Proveedor p) {
        String sql = "UPDATE Proveedores_Cat SET Nombre_Proveedor=?, Descripcion_Proveedor=?, Telefono_Proveedor=?, Correo_Proveedor=?, Direccion_Completa=?, Ciudad_Estado=? WHERE ID_Proveedor=?";
        try (Connection con = ConexionDB.getConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setString(3, p.getTelefono());
            ps.setString(4, p.getCorreo());
            ps.setString(5, p.getDireccion());
            ps.setString(6, p.getCiudad());
            ps.setInt(7, p.getIdProveedor());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error actualizar prov: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminarProveedor(int id) {
        String sql = "UPDATE Proveedores_Cat SET Proveedor_Activo = 0 WHERE ID_Proveedor = ?";
        try (Connection con = ConexionDB.getConexion(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error eliminar prov: " + e.getMessage());
            return false;
        }
    }
}