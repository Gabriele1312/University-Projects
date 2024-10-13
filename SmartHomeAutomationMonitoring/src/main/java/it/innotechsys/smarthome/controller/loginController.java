package it.innotechsys.smarthome.controller;

import it.innotechsys.smarthome.App;
import it.innotechsys.smarthome.drivers.TCPDriverInstance;
import it.innotechsys.smarthome.model.Device;
import it.innotechsys.smarthome.util.Encryption;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;

public class loginController extends  Controller {

    @FXML public TextField tf_username;
    @FXML public PasswordField tf_password;
    @FXML public Label l_error;

    private final TCPDriverInstance tcp = TCPDriverInstance.getInstance();

    public loginController(){}

    @FXML
    public void login() {
        tcp.setController(this);
        String username = tf_username.getText().strip();
        String password = tf_password.getText().strip();
        if(!username.isEmpty() && !password.isEmpty()) {
            tcp.send(String.join(" ", "LOGIN", username, password));
        }
    }

    public void loginValidation(boolean status, Device.Home home) {
        Controller c;
        if(status & home.equals(Device.Home.A)) {
            System.out.println("Login to smarthome A");
            l_error.setVisible(false);
            c = App.setRoot("homeA");
        }
        else if(status & home.equals(Device.Home.B)) {
            System.out.println("Login to smarthome B");
            l_error.setVisible(false);
            c = App.setRoot("homeB");
        }
        else {
            l_error.setVisible(true);
        }
    }
}
