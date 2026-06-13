package com.esimestore.dao;

import com.esimestore.config.ConexionDB;
import com.esimestore.modelo.Producto;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ProductoDAO {

    public List<Producto> listarProductos() {
        List<Producto> lista = new ArrayList<>();
        String sql = "{CALL sp_gestion_inventario('ver', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)}";
        
        try (Connection con = ConexionDB.getConexion();
             CallableStatement cs = con.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
             
            while (rs.next()) {
                Producto p = new Producto();
                p.setIdProducto(rs.getInt("ID_Producto"));
                p.setNombre(rs.getString("Nombre_Producto"));
                p.setDescripcion(rs.getString("Descripcion_Producto"));
                p.setPrecioCompra(rs.getDouble("Precio_Compra"));
                p.setPrecioVenta(rs.getDouble("Precio_Venta"));
                p.setCantidad(rs.getInt("Cantidad"));
                p.setNumLote(rs.getString("Num_Lote"));
                p.setFechaCaducidad(rs.getString("Fecha_Caducidad"));
                p.setNombreProveedor(rs.getString("Nombre_Proveedor"));
                lista.add(p);
            }
        } catch (Exception e) {
            System.err.println("Error al listar: " + e.getMessage());
        }
        return lista;
    }

    public boolean agregarProducto(String nombre, String desc, double pCompra, double pVenta, int cant, String numLote, String caducidad, String proveedor) {
        String sql = "{CALL sp_gestion_inventario('agregar', NULL, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection con = ConexionDB.getConexion(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setString(1, nombre);
            cs.setString(2, desc);
            cs.setDouble(3, pCompra);
            cs.setDouble(4, pVenta);
            cs.setInt(5, cant);
            cs.setString(6, numLote);
            cs.setString(7, caducidad);
            cs.setString(8, proveedor);
            return cs.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error al agregar: " + e.getMessage());
            return false;
        }
    }

    public boolean actualizarProducto(int id, String nombre, String desc, double pCompra, double pVenta, int cant, String proveedor) {
        String sql = "{CALL sp_gestion_inventario('actualizar', ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection con = ConexionDB.getConexion(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, id);
            cs.setString(2, nombre);
            cs.setString(3, desc);
            cs.setDouble(4, pCompra);
            cs.setDouble(5, pVenta);
            cs.setInt(6, cant);
            cs.setNull(7, java.sql.Types.VARCHAR); 
            cs.setNull(8, java.sql.Types.DATE);    
            cs.setString(9, proveedor);
            return cs.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error al actualizar: " + e.getMessage());
            return false;
        }
    }

    public boolean eliminarProducto(int id) {
        String sql = "{CALL sp_gestion_inventario('eliminar', ?, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)}";
        try (Connection con = ConexionDB.getConexion(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, id);
            return cs.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error al eliminar: " + e.getMessage());
            return false;
        }
    }
}