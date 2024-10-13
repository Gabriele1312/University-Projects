package it.innotechsys.smarthome.model;

import it.innotechsys.smarthome.App;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;

import java.util.Objects;

public class Heater extends Device{
    private double currentTemperature = 22.0;
    private double setTemperature = 22.0;
    private final TextField tf_setpointTemp;
    private final Label l_currentTemp;

    private final Image heater_on = new Image(Objects.requireNonNull(App.class.getResourceAsStream("icon/heater_off.png")));
    private final Image heater_off = new Image(Objects.requireNonNull(App.class.getResourceAsStream("icon/heater_off.png")));

    public Heater(int id, String name, Home home, Room room, ImageView image, TextField setpoint, Label current) {
        super(id, name, home, room, image);
        this.tf_setpointTemp = setpoint;
        this.l_currentTemp = current;
    }

    public void setCurrentTemp(double temperature) {
        this.currentTemperature = temperature;
        setCurrentLabel(String.valueOf(temperature));
    }

    public double getSetTemp() { return setTemperature; }

    public void setSetTemperature(double temperature) {
        this.setTemperature = temperature;
        setSetpointLabel(String.valueOf(temperature));
    }

    private void setSetpointLabel(String value) {
        this.tf_setpointTemp.setText(value + " °C");
    }

    private void setCurrentLabel(String value) {
        this.l_currentTemp.setText(value + " °C");
    }

    public TextField getTextField() {
        return tf_setpointTemp;
    }

    @Override
    public void setStatus(boolean status) {
        super.setStatus(status);
        if(status) {
            super.getLinked_image().setImage(heater_on);
        } else {
            super.getLinked_image().setImage(heater_off);
        }
    }

    public String toStringCommand() {
        return super.getId() + " " + super.getHome() + " " + super.getRoom() + " " + this.getSetTemp();
    }
}
