package com.esimestore.modelo;

public class Caja {
    private int idSession;
    private String nombreCaja;
    private String fechaApertura;
    private double saldoInicial;
    private double ingresosTotales;
    private double egresosTotales;
    private double saldoActual;
    private String estatus;

    public Caja() {}

    public int getIdSession() { return idSession; }
    public void setIdSession(int idSession) { this.idSession = idSession; }
    public String getNombreCaja() { return nombreCaja; }
    public void setNombreCaja(String nombreCaja) { this.nombreCaja = nombreCaja; }
    public String getFechaApertura() { return fechaApertura; }
    public void setFechaApertura(String fechaApertura) { this.fechaApertura = fechaApertura; }
    public double getSaldoInicial() { return saldoInicial; }
    public void setSaldoInicial(double saldoInicial) { this.saldoInicial = saldoInicial; }
    public double getIngresosTotales() { return ingresosTotales; }
    public void setIngresosTotales(double ingresosTotales) { this.ingresosTotales = ingresosTotales; }
    public double getEgresosTotales() { return egresosTotales; }
    public void setEgresosTotales(double egresosTotales) { this.egresosTotales = egresosTotales; }
    public double getSaldoActual() { return saldoActual; }
    public void setSaldoActual(double saldoActual) { this.saldoActual = saldoActual; }
    public String getEstatus() { return estatus; }
    public void setEstatus(String estatus) { this.estatus = estatus; }
}