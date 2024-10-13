package it.innotechsys.smarthome.controller;

import it.innotechsys.smarthome.App;
import it.innotechsys.smarthome.drivers.TCPDriverInstance;
import it.innotechsys.smarthome.model.*;
import it.innotechsys.smarthome.util.CssHelper;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;

import java.util.Objects;

public class homeBcontroller extends Controller{
    /* LIGHT */
    @FXML public ImageView iv_light_livingroom;
    @FXML public ImageView iv_light_bathroom;
    @FXML public ImageView iv_light_kitchen;
    @FXML public ImageView iv_light_stairway;
    @FXML public ImageView iv_light_hallway;
    @FXML public ImageView iv_light_bedroom;
    /* LIGHT INTENSITY*/
    @FXML public ProgressBar pb_light_livingroom;
    @FXML public ProgressBar pb_light_bathroom;
    @FXML public ProgressBar pb_light_kitchen;
    @FXML public ProgressBar pb_light_stairway;
    @FXML public ProgressBar pb_light_hallway;
    @FXML public ProgressBar pb_light_bedroom;
    /* LIGHT PRESENCE SENSOR */
    @FXML public ImageView iv_presence_livingroom;
    @FXML public ImageView iv_presence_bathroom;
    @FXML public ImageView iv_presence_kitchen;
    @FXML public ImageView iv_presence_stairway;
    @FXML public ImageView iv_presence_hallway;
    @FXML public ImageView iv_presence_bedroom;
    /* HEATER */
    @FXML public ImageView iv_heater_livingroom;
    @FXML public ImageView iv_heater_bathroom;
    @FXML public ImageView iv_heater_kitchen;
    @FXML public ImageView iv_heater_hallway;
    @FXML public ImageView iv_heater_bedroom;
    /* TEMPERATURE DETECTED */
    @FXML public Label l_tempLivingRoom;
    @FXML public Label l_tempBathroom;
    @FXML public Label l_tempKitchen;
    @FXML public Label l_tempHallway;
    @FXML public Label l_tempBedroom;
    /* TEMPERATURE SETPOINT */
    @FXML public TextField tf_tempLivingRoom;
    @FXML public TextField tf_tempBathroom;
    @FXML public TextField tf_tempKitchen;
    @FXML public TextField tf_tempHallway;
    @FXML public TextField tf_tempBedroom;
    /* FAN DEHUMIDIFIER */
    @FXML public ImageView iv_fan_livingroom;
    @FXML public ImageView iv_fan_bathroom;
    @FXML public ImageView iv_fan_kitchen;
    @FXML public ImageView iv_fan_hallway;
    @FXML public ImageView iv_fan_bedroom;
    /* HUMIDITY DETECTED */
    @FXML public Label l_humLivingRoom;
    @FXML public Label l_humBathroom;
    @FXML public Label l_humKitchen;
    @FXML public Label l_humHallway;
    @FXML public Label l_humBedroom;
    /* HUMIDITY SETPOINT */
    @FXML public TextField tf_humLivingRoom;
    @FXML public TextField tf_humBathroom;
    @FXML public TextField tf_humKitchen;
    @FXML public TextField tf_humHallway;
    @FXML public TextField tf_humBedroom;
    /* ALARM */
    @FXML public ImageView iv_alarm_b;
    /* BUTTONS SET*/
    @FXML public Button b_temp_livingroom;
    @FXML public Button b_temp_bathroom;
    @FXML public Button b_temp_kitchen;
    @FXML public Button b_temp_hallway;
    @FXML public Button b_temp_bedroom;
    @FXML public Button b_hum_livingroom;
    @FXML public Button b_hum_bathroom;
    @FXML public Button b_hum_kitchen;
    @FXML public Button b_hum_hallway;
    @FXML public Button b_hum_bedroom;
    @FXML public Button b_alarm;

    private Heater h_livingroom;
    private Heater h_bathroom;
    private Heater h_kitchen;
    private Heater h_hallway;
    private Heater h_bedroom;

    private Vent v_livingroom;
    private Vent v_bathroom;
    private Vent v_kitchen;
    private Vent v_hallway;
    private Vent v_bedroom;

    private Alarm alarm;

    private Device[] devices;

    private final CssHelper css = CssHelper.getInstance();
    private final TCPDriverInstance tcp = TCPDriverInstance.getInstance();

    @FXML
    private void initialize() {
        /* DEVICES */
        Lamp l_livingroom = new Lamp(205, "", Device.Home.B, Device.Room.LIVINGROOM, iv_light_livingroom, pb_light_livingroom);
        Lamp l_bathroom = new Lamp(206, "", Device.Home.B, Device.Room.BATHROOM, iv_light_bathroom, pb_light_bathroom);
        Lamp l_kitchen = new Lamp(207, "", Device.Home.B, Device.Room.KITCHEN, iv_light_kitchen, pb_light_kitchen);
        Lamp l_stairway = new Lamp(208, "", Device.Home.B, Device.Room.STAIRWAY, iv_light_stairway, pb_light_stairway);
        Lamp l_hallway = new Lamp(209, "", Device.Home.B, Device.Room.HALLWAY, iv_light_hallway, pb_light_hallway);
        Lamp l_bedroom = new Lamp(210, "", Device.Home.B, Device.Room.BEDROOM, iv_light_bedroom, pb_light_bedroom);

        h_livingroom = new Heater(124, "", Device.Home.B, Device.Room.LIVINGROOM, iv_heater_livingroom, tf_tempLivingRoom, l_tempLivingRoom);
        h_bathroom = new Heater(125, "", Device.Home.B, Device.Room.BATHROOM, iv_heater_bathroom, tf_tempBathroom, l_tempBathroom);
        h_kitchen = new Heater(126, "", Device.Home.B, Device.Room.KITCHEN, iv_heater_kitchen, tf_tempKitchen, l_tempKitchen);
        h_hallway = new Heater(127, "", Device.Home.B, Device.Room.HALLWAY, iv_heater_hallway, tf_tempHallway, l_tempHallway);
        h_bedroom = new Heater(128, "", Device.Home.B, Device.Room.BEDROOM, iv_heater_bedroom, tf_tempBedroom, l_tempBedroom);

        v_livingroom = new Vent(134, "", Device.Home.B, Device.Room.LIVINGROOM, iv_fan_livingroom, tf_humLivingRoom, l_humLivingRoom);
        v_bathroom = new Vent(135, "", Device.Home.B, Device.Room.BATHROOM, iv_fan_bathroom, tf_humBathroom, l_humBathroom);
        v_kitchen = new Vent(136, "", Device.Home.B, Device.Room.KITCHEN, iv_fan_kitchen, tf_humKitchen, l_humKitchen);
        v_hallway = new Vent(137, "", Device.Home.B, Device.Room.HALLWAY, iv_fan_hallway, tf_humHallway, l_humHallway);
        v_bedroom = new Vent(138, "", Device.Home.B, Device.Room.BEDROOM, iv_fan_bedroom, tf_humBedroom, l_humBedroom);

        alarm = new Alarm(71, "", Device.Home.B, Device.Room.HALLWAY, iv_alarm_b, b_alarm);

        devices = new Device[]{l_livingroom, l_bathroom, l_kitchen, l_stairway, l_hallway, l_bedroom, h_livingroom, h_bathroom, h_kitchen, h_hallway, h_bedroom, v_livingroom, v_bathroom, v_kitchen, v_hallway, v_bedroom, alarm};

        tcp.send("REQ B ALL");
    }

    @FXML public void logOutB() {
        App.setRoot("login");
    }

    /* format: SET <id> <home> <room> <status> <currentValue> <setpoint> */
    public void updateDevice(String[] splitted) {
        int idx = Integer.parseInt(splitted[1]);
        if(idx == 71) {
            switch(Alarm.alarmStatus.valueOf(splitted[4])) {
                case ARMED -> alarm.setAlarmStatus(Alarm.alarmStatus.ARMED);
                case DEACTIVATED -> alarm.setAlarmStatus(Alarm.alarmStatus.DEACTIVATED);
                case ALARM -> alarm.setAlarmStatus(Alarm.alarmStatus.ALARM);
            }
        } else {
            boolean status = Boolean.parseBoolean(splitted[4]);
            double currentValue = Double.parseDouble(splitted[5]);
            double setPoint = Double.parseDouble(splitted[6]);
            for (Device d : devices) {
                if (d.getId() == idx) {
                    if (d instanceof Heater) {
                        ((Heater) d).setCurrentTemp(currentValue);
                        ((Heater) d).setSetTemperature(setPoint);
                        css.toValid(((Heater) d).getTextField());
                    } else if (d instanceof Vent) {
                        ((Vent) d).setCurrentHum(currentValue);
                        ((Vent) d).setSetHum(setPoint);
                        css.toValid(((Vent) d).getTextField());
                    }
                    d.setStatus(status);
                    break;
                }
            }
        }
    }

    public void updateDevice(Device.Room room, String type, boolean status) {
        for (Device d : devices) {
            if(d.getRoom().equals(room)) {
                if(type.equalsIgnoreCase("light") && d instanceof Lamp) {
                    d.setStatus(status);
                } else if (type.equalsIgnoreCase("temperature") && d instanceof Heater) {
                    d.setStatus(status);
                } else if (type.equalsIgnoreCase("humidity") && d instanceof Vent) {
                    d.setStatus(status);
                }
            }
        }
    }

    public void updateDevice(Device.Room room, String type, double value) {
        for (Device d : devices) {
            if(d.getRoom().equals(room)) {
                if(type.equalsIgnoreCase("light") && d instanceof Lamp) {
                    ((Lamp) d).setIntensity(value);
                } else if (type.equalsIgnoreCase("temperature") && d instanceof Heater) {
                    ((Heater) d).setCurrentTemp(value);
                } else if (type.equalsIgnoreCase("humidity") && d instanceof Vent) {
                    ((Vent) d).setCurrentHum(value);
                }
            }
        }
    }

    @FXML public void setAlarm() {
        tcp.send("SET " + alarm.toStringCommand());
    }

    @FXML public void setSetpoint(ActionEvent ae) {
        double value;
        TextField textField = null;
        Device device = null;
        switch(ae.getSource().toString().split("id=")[1].split(", ")[0]) {
            case "b_temp_livingroom":
                textField = tf_tempLivingRoom;
                device = h_livingroom;
                break;
            case "b_temp_bathroom":
                textField = tf_tempBathroom;
                device = h_bathroom;
                break;
            case "b_temp_kitchen":
                textField = tf_tempKitchen;
                device = h_kitchen;
                break;
            case "b_temp_hallway":
                textField = tf_tempHallway;
                device = h_hallway;
                break;
            case "b_temp_bedroom":
                textField = tf_tempBedroom;
                device = h_bedroom;
                break;
            case "b_hum_livingroom":
                textField = tf_humLivingRoom;
                device = v_livingroom;
                break;
            case "b_hum_bathroom":
                textField = tf_humBathroom;
                device = v_bathroom;
                break;
            case "b_hum_kitchen":
                textField = tf_humKitchen;
                device = v_kitchen;
                break;
            case "b_hum_hallway":
                textField = tf_humHallway;
                device = v_hallway;
                break;
            case "b_hum_bedroom":
                textField = tf_humBedroom;
                device = v_bedroom;
                break;
            default:
                System.err.println("ERROR");
        }
        assert textField != null;
        try {
            value = Double.parseDouble(textField.getText().trim().replace("°", "").replace("C", "").replace("%", ""));
            if (device instanceof Heater) {
                if(value < 15 || value > 50) {
                    css.toError(((Heater) device).getTextField(), "Min: 15 - Max: 50");
                } else {
                    ((Heater) device).setSetTemperature(value);
                    css.toBeApproved(((Heater) device).getTextField(), "Message sent. Waiting for response");
                    tcp.send("SET " + ((Heater) device).toStringCommand());
                }
            } else if (device instanceof Vent) {
                if (value < 35 || value > 65) {
                    css.toError(((Vent) device).getTextField(), "Min: 35 - Max: 65");
                } else {
                    ((Vent) device).setSetHum(value);
                    css.toBeApproved(((Vent) device).getTextField(), "Message sent. Waiting for response");
                    tcp.send("SET " + ((Vent) device).toStringCommand());
                }
            }
        } catch (NumberFormatException nfe) {
            if (device instanceof Heater) {
                css.toError(((Heater) device).getTextField(), "Insert number only");
            } else if (device instanceof Vent) {
                css.toError(((Vent) device).getTextField(), "Insert number only");
            }
        }
    }
}