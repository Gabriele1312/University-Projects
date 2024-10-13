package it.innotechsys.smarthome;

import it.innotechsys.smarthome.drivers.TCPDriverInstance;
import it.innotechsys.smarthome.controller.Controller;
import javafx.application.Application;
import java.io.IOException;
import java.util.Objects;

import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class App extends Application {

    private static final Logger logger = LoggerFactory.getLogger(App.class);

    private final static double defaultWidth = 700;
    private final static double defaultHeight = 540;
    private final static double homeAWidth = 1290;
    private final static double homeAHeight = 840;
    private final static double homeBWidth = homeAWidth;
    private final static double homeBHeight = homeAHeight;

    private static FXMLLoader fxmlLoader;
    private static Stage stage;
    private static Scene scene;

    @Override
    public void start(Stage stage) {
        App.stage = stage;
        // Loading primary window
        scene = new Scene(Objects.requireNonNull(loadFXML("login")));
        stage.setWidth(defaultWidth);
        stage.setHeight(defaultHeight);
        stage.setResizable(false);
        stage.getIcons().add(new Image(Objects.requireNonNull(App.class.getResourceAsStream("icon/icon.png"))));
        stage.setScene(scene);
        stage.setTitle("Smarthome");
        stage.centerOnScreen();
        stage.show();
    }

    public static Parent loadFXML(String fxml) {
        fxmlLoader = new FXMLLoader(App.class.getResource("fxml/" + fxml + ".fxml"));
        try {
            return fxmlLoader.load();
        } catch (IOException e) {
            logger.error(e.toString());
            return null;
        }
    }

    public static Controller setRoot(String fxml) {
        scene.
                setRoot(loadFXML(fxml));
        Controller c = fxmlLoader.getController();
        stage.setWidth(defaultWidth);
        stage.setHeight(defaultHeight);
        switch (fxml) {
            case "login":
                //stage.setTitle("Smarthome - Login");
                break;
            case "homeA":
                //stage.setTitle("Smarthome - A");
                TCPDriverInstance.getInstance().setController(c);
                stage.setWidth(homeAWidth);
                stage.setHeight(homeAHeight);
                break;
            case "homeB":
                //stage.setTitle("Smarthome - B");
                TCPDriverInstance.getInstance().setController(c);
                stage.setWidth(homeBWidth);
                stage.setHeight(homeBHeight);
                break;
            default:
                System.err.println("[ERROR] WRONG FXML NAME: " + fxml);
                break;
        }
        //stage.centerOnScreen();
        return c;
    }

    public static void main(String[] args) {
        launch(args);
    }

}
