package com.esimestore.controlador;

import com.esimestore.config.ConexionDB;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        String accion = request.getParameter("accion"); 

        try (Connection con = ConexionDB.getConexion()) {
            if ("registrar".equals(accion)) {
                con.setAutoCommit(false);
                
                try {
                    PreparedStatement psCliente = con.prepareStatement(
                        "INSERT INTO Clientes_Cat (Nombre, Apellido_Paterno, Apellido_Materno, Numero_Telefono) VALUES ('Nuevo', 'Usuario', '', '0000000000')", 
                        Statement.RETURN_GENERATED_KEYS);
                    psCliente.executeUpdate();
                    
                    ResultSet rsKeys = psCliente.getGeneratedKeys();
                    int idNuevoCliente = 0;
                    if (rsKeys.next()) {
                        idNuevoCliente = rsKeys.getInt(1);
                    }

                    PreparedStatement psUser = con.prepareStatement(
                        "INSERT INTO Usuarios (Username, Password, Rol, ID_Cliente) VALUES (?, ?, 'CLIENTE', ?)");
                    psUser.setString(1, user);
                    psUser.setString(2, pass);
                    psUser.setInt(3, idNuevoCliente);
                    psUser.executeUpdate();

                    con.commit(); 
                    response.sendRedirect("login.jsp?msg=registrado");
                } catch (Exception e) {
                    con.rollback(); 
                    throw e;
                }
            } else {
                PreparedStatement ps = con.prepareStatement("SELECT * FROM Usuarios WHERE Username=? AND Password=?");
                ps.setString(1, user);
                ps.setString(2, pass);
                ResultSet rs = ps.executeQuery();
                
                if (rs.next()) {
                    HttpSession session = request.getSession();
                    session.setAttribute("usuario", user);
                    session.setAttribute("rol", rs.getString("Rol"));
                    
                    int idCliente = rs.getInt("ID_Cliente");
                    if (!rs.wasNull()) {
                        session.setAttribute("idCliente", idCliente);
                    }
                    
                    response.sendRedirect("ADMIN".equals(rs.getString("Rol")) ? "index.jsp" : "tienda.jsp");
                } else {
                    response.sendRedirect("login.jsp?error=1");
                }
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
            response.sendRedirect("login.jsp?error=system");
        }
    }
}