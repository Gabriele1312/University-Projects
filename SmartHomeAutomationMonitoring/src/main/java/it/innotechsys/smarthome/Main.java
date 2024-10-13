package it.innotechsys.smarthome;

import it.innotechsys.smarthome.drivers.MqttDriver;
import it.innotechsys.smarthome.drivers.TCPServerDriver;

public class Main {

    private static String[] args;

    public static void main(String[] args) {
        Main.args = args;
        appGUI.start();
        mqtt.start();
        tcp.start();
    }

    static Thread appGUI = new Thread(() -> App.main(Main.args));

    static Thread tcp = new Thread(TCPServerDriver::new);
    static Thread mqtt = new Thread(MqttDriver::new);
}
