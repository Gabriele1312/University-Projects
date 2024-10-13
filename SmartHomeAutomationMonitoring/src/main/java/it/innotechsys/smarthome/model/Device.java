package it.innotechsys.smarthome.model;

import javafx.scene.image.ImageView;

//classe generale dei device
public class Device {
    private final int id;
    private final String name;
    private final Home home;
    private final Room room;
    private boolean status = false;
    private final ImageView linked_image;

    public Device(int id, String name, Home home, Room room, ImageView linked_image) {
        this.id = id;
        this.name = name;
        this.home = home;
        this.room = room;
        this.linked_image = linked_image;
    }

    public int getId() {
        return id;
    }

    public Home getHome() {
        return home;
    }

    public Room getRoom() {
        return room;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public ImageView getLinked_image() {
        return linked_image;
    }

    public enum Home {none, A, B}

    public enum Room {KITCHEN, BEDROOM, BATHROOM, LIVINGROOM, STAIRWAY, HALLWAY}

}
