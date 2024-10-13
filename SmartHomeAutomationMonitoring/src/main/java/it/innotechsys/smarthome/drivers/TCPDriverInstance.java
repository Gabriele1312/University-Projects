package it.innotechsys.smarthome.drivers;
import it.innotechsys.smarthome.controller.Controller;
import it.innotechsys.smarthome.controller.homeAcontroller;
import it.innotechsys.smarthome.controller.homeBcontroller;
import it.innotechsys.smarthome.controller.loginController;
import it.innotechsys.smarthome.model.Device;
import it.innotechsys.smarthome.util.Encryption;
import javafx.application.Platform;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;

public class TCPDriverInstance implements Runnable {
    private static TCPDriverInstance instance = null;
    private final Encryption aes = Encryption.getInstance();
    private Socket socketReceive;
    private homeAcontroller homeA;
    private homeBcontroller homeB;
    private loginController login;
    private MqttDriver mqtt;

    public static TCPDriverInstance getInstance() {
        if(instance == null) {
            instance = new TCPDriverInstance();
        }
        return instance;
    }

    private TCPDriverInstance() {}

    public void setClientSocketR(Socket clientSocket) {
        this.socketReceive = clientSocket;
    }

    @Override
    public void run() {
        try (BufferedReader in = new BufferedReader(new InputStreamReader(socketReceive.getInputStream(), StandardCharsets.UTF_8))) {
            String message;
            while ((message = in.readLine()) != null) {
                message = aes.decrypt(message);
                System.out.println("RECEIVED: " + message);
                destinationSorting(message);
            }
        } catch (IOException e) {
            System.err.println("Error in TCPDriverInstance: " + e.getMessage());
        }
    }

    public void send(String message) {
            try {
                PrintWriter out = new PrintWriter(new OutputStreamWriter(new Socket("localhost", 9091).getOutputStream(), StandardCharsets.UTF_8));
                out.write(aes.encrypt(message));
                out.close();
                System.out.println("SENT: " + message);
            } catch (IOException e) {
                e.printStackTrace();
            }
    }

    public void setController(Controller c) {
        if(c instanceof homeAcontroller) {
            this.homeA = (homeAcontroller) c;
            if(mqtt != null) {
                mqtt.setHomeController(this.homeA);
            }
        } else if (c instanceof homeBcontroller) {
            this.homeB = (homeBcontroller) c;
            if(mqtt != null) {
                mqtt.setHomeController(this.homeB);
            }
        } else if (c instanceof loginController) {
            this.login = (loginController) c;
        }
    }

    public void setMqttRef(MqttDriver mqtt) {
        this.mqtt = mqtt;
    }

    private void destinationSorting(String message) {
        String[] msg = message.split(" ");
        switch (msg[0]) {
            /* format: LOGIN <OK/KO> <A/B>*/
            case "LOGIN":
                if(msg[1].equals("OK")) {
                    if(msg[2].equals("A")) {
                        Platform.runLater(() -> login.loginValidation(true, Device.Home.A));
                    } else if (msg[2].equals("B")) {
                        Platform.runLater(() -> login.loginValidation(true, Device.Home.B));
                    }
                } else {
                    Platform.runLater(() -> login.loginValidation(false, Device.Home.none));
                }
                break;
            /* format: SET <id> <home> <room> <status> <currentValue> <setpoint> */
            case "SET":
                if(msg[2].equals("A")) {
                    Platform.runLater(() -> homeA.updateDevice(msg));
                } else if (msg[2].equals("B")) {
                    Platform.runLater(() -> homeB.updateDevice(msg));
                }
                break;
            default:
                System.out.println("UNEXPECTED INIT");
                break;
        }
    }
}