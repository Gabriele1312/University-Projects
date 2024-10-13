module it.innotechsys.smarthome {
    requires javafx.controls;
    requires javafx.fxml;
    requires javafx.web;

    requires net.synedra.validatorfx;
    requires org.kordamp.ikonli.javafx;
    requires eu.hansolo.tilesfx;
    requires org.mongodb.driver.sync.client;
    requires org.mongodb.driver.core;
    requires org.mongodb.bson;
    requires org.slf4j;
    requires org.eclipse.paho.mqttv5.client;

    opens it.innotechsys.smarthome to javafx.fxml;
    exports it.innotechsys.smarthome;
    opens it.innotechsys.smarthome.controller to javafx.fxml;
    exports it.innotechsys.smarthome.controller;
}