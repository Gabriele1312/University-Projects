package it.innotechsys.smarthome.drivers;

import it.innotechsys.smarthome.controller.Controller;
import it.innotechsys.smarthome.controller.homeAcontroller;
import it.innotechsys.smarthome.controller.homeBcontroller;
import it.innotechsys.smarthome.model.Device;
import it.innotechsys.smarthome.util.Encryption;
import javafx.application.Platform;
import org.eclipse.paho.mqttv5.client.*;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.eclipse.paho.mqttv5.common.MqttMessage;
import org.eclipse.paho.mqttv5.common.packet.MqttProperties;

@SuppressWarnings("FieldCanBeLocal")
public class MqttDriver {
    private final String broker = "tcp://127.0.0.1:1883";
    private final String clientId = "java_dashboard";
    private final String topicL = "smart_home/+/+/light/#";
    private final String topicH = "smart_home/+/+/temperature/#";
    private final String topicV = "smart_home/+/+/humidity/#";
    private final int subQos = 2;
    private final int pubQos = 0;

    private homeAcontroller homeA;
    private homeBcontroller homeB;

    private final Encryption aes = Encryption.getInstance();
    private final MqttClient client;

    public MqttDriver() {
        try {
            client = new MqttClient(broker, clientId);
            MqttConnectionOptions options = new MqttConnectionOptions();
            client.connect(options);

            client.setCallback(new MqttCallback() {
                public void connectComplete(boolean reconnect, String serverURI) {
                    System.out.println("connected to: " + serverURI);
                }

                public void disconnected(MqttDisconnectResponse disconnectResponse) {
                    System.out.println("disconnected: " + disconnectResponse.getReasonString());
                }

                public void deliveryComplete(IMqttToken token) {
                    System.out.println("deliveryComplete: " + token.isComplete());
                }

                public void messageArrived(String topic, MqttMessage message) {
                    destinationSorting(topic, aes.decrypt(new String(message.getPayload())));
                    //System.out.println("topic: " + topic);
                    //System.out.println("qos: " + message.getQos());
                    //System.out.println("message enc: " + new String(message.getPayload()));
                    System.out.println("MQTT: " + topic + " - "+ aes.decrypt(new String(message.getPayload())));
                }

                public void mqttErrorOccurred(MqttException exception) {
                    System.out.println("mqttErrorOccurred: " + exception.getMessage());
                }

                public void authPacketArrived(int reasonCode, MqttProperties properties) {
                    System.out.println("authPacketArrived");
                }
            });

            TCPDriverInstance.getInstance().setMqttRef(this);
            client.subscribe(topicL, subQos);
            client.subscribe(topicH, subQos);
            client.subscribe(topicV, subQos);

            //MqttMessage message = new MqttMessage(msg.getBytes());
            //message.setQos(pubQos);
            //client.publish(topic, message);

        } catch (MqttException e) {
            throw new RuntimeException(e);
        }
    }

    private void destinationSorting(String topic, String value) {
        /* format: SET <id> <home> <room> <status> <currentValue> <setpoint> */
        String[] splitted = topic.split("/");
        Device.Home home = Device.Home.valueOf(splitted[1]);
        Device.Room room = Device.Room.valueOf(splitted[2].toUpperCase());
        String type = splitted[3];
        if(value.equalsIgnoreCase("false") || value.equalsIgnoreCase("true")) {
            try {
                boolean status = Boolean.parseBoolean(value);
                System.out.println(value + " - " + status);
                if (home.equals(Device.Home.A) && homeA != null) {
                    Platform.runLater(() -> homeA.updateDevice(room, type, status));
                } else if (home.equals(Device.Home.B) && homeB != null) {
                    Platform.runLater(() -> homeB.updateDevice(room, type, status));
                }
            } catch (NumberFormatException ignored) {
            }
        } else {
            try {
                double current = Double.parseDouble(value);
                if (home.equals(Device.Home.A) && homeA != null) {
                    Platform.runLater(() -> homeA.updateDevice(room, type, current));
                } else if (home.equals(Device.Home.B) && homeB != null) {
                    Platform.runLater(() -> homeB.updateDevice(room, type, current));
                }
            } catch (NumberFormatException ignored) {
            }
        }
    }

    protected void setHomeController(Controller c) {
        if(c instanceof homeAcontroller) {
            this.homeA = (homeAcontroller) c;
        } else if (c instanceof homeBcontroller) {
            this.homeB = (homeBcontroller) c;
        }
    }

    public void close() {
        try {
            client.disconnect();
            client.close();
        } catch (MqttException e) {
            throw new RuntimeException(e);
        }
    }
}

