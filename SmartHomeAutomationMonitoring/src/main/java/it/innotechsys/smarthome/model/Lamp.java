package it.innotechsys.smarthome.model;

import it.innotechsys.smarthome.App;
import javafx.scene.control.ProgressBar;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;

import java.util.Objects;

public class Lamp extends Device{
    private final ProgressBar linked_progressbar;

    private final Image lamp_on = new Image(Objects.requireNonNull(App.class.getResourceAsStream("icon/light_on.png")));
    private final Image lamp_off = new Image(Objects.requireNonNull(App.class.getResourceAsStream("icon/light_off.png")));


    public Lamp(int id, String name, Home home, Room room, ImageView image, ProgressBar progressbar) {
        super(id, name, home, room, image);
        this.linked_progressbar = progressbar;
    }

    public void setIntensity(double intensity) {
        this.linked_progressbar.setProgress(intensity);
    }

    @Override
    public void setStatus(boolean status) {
        super.setStatus(status);
        if(status) {
            super.getLinked_image().setImage(lamp_on);
        } else {
            super.getLinked_image().setImage(lamp_off);
        }
    }
}