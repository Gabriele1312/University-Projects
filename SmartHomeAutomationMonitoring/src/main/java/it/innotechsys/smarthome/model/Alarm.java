package it.innotechsys.smarthome.model;

import it.innotechsys.smarthome.util.CssHelper;
import javafx.scene.control.Button;
import javafx.scene.image.ImageView;

public class Alarm extends Device {

    private final Button linkedButton;
    private alarmStatus status = alarmStatus.DEACTIVATED;

    private final CssHelper css = CssHelper.getInstance();

    public Alarm(int id, String name, Home home, Room room, ImageView linked_image, Button linked_button) {
        super(id, name, home, room, linked_image);
        linkedButton = linked_button;
    }

    public void setAlarmStatus(alarmStatus status) {
        switch(status) {
            case DEACTIVATED:
                this.status = status;
                this.linkedButton.setText("Deactivate");
                break;
            case ARMED:
                this.status = status;
                this.linkedButton.setText("Activate");
                break;
        }
        css.setAlarm(linkedButton, status);
    }

    public String toStringCommand() {
        return super.getId() + " " + super.getHome() + " " + super.getRoom() + " TOGGLE";
    }

    public enum alarmStatus {ARMED, ALARM, DEACTIVATED}
}