package it.innotechsys.smarthome.model;

import javafx.animation.Animation;
import javafx.animation.Interpolator;
import javafx.animation.RotateTransition;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.image.ImageView;
import javafx.util.Duration;

public class Vent extends Device{
    private double currentHumidity = 60.0;
    private double setHumidity = 60.0;
    private final TextField tf_setpointHum;
    private final Label l_currentHum;

    public Vent(int id, String name, Home home, Room room, ImageView image, TextField setpoint, Label current) {
        super(id, name, home, room, image);
        this.tf_setpointHum = setpoint;
        this.l_currentHum = current;
    }

    public void setCurrentHum(double humidity) {
        this.currentHumidity = humidity;
        setCurrentLabel(String.valueOf(humidity));
    }

    public double getSetHum() { return setHumidity; }

    public void setSetHum(double humidity) {
        this.setHumidity = humidity;
        setSetpointLabel(String.valueOf(humidity));
    }

    private void setSetpointLabel(String value) { this.tf_setpointHum.setText(value + " %"); }

    private void setCurrentLabel(String value) { this.l_currentHum.setText(value + " %"); }

    public TextField getTextField() { return tf_setpointHum; }

    @Override
    public void setStatus(boolean status) {
        super.setStatus(status);
        RotateTransition rt = new RotateTransition(Duration.seconds(2), super.getLinked_image());
        rt.setByAngle(360f);
        rt.setCycleCount(Animation.INDEFINITE);
        rt.setInterpolator(Interpolator.LINEAR);
        if(status) {
            rt.play();
        } else {
            rt.stop();
        }
    }

    public String toStringCommand() {
        return super.getId() + " " + super.getHome() + " " + super.getRoom() + " " + this.getSetHum();
    }
}
