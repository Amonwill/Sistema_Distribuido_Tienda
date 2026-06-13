package com.esimestore.dao;

import com.esimestore.config.ConexionDB;
import com.esimestore.modelo.Usuario;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UsuarioDAO {

    public Usuario validar(String username, String password) {
        Usuario usr = null;
        String sql = "SELECT ID_Usuario, Username, Rol FROM Usuarios WHERE Username = ? AND Password = ? AND Activo = 1";
        
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
             
            ps.setString(1, username);
            ps.setString(2, password);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    usr = new Usuario();
                    usr.setIdUsuario(rs.getInt("ID_Usuario"));
                    usr.setUsername(rs.getString("Username"));
                    usr.setRol(rs.getString("Rol"));
                }
            }
        } catch (Exception e) {
            System.err.println("Error en login: " + e.getMessage());
        }
        return usr;
    }
}