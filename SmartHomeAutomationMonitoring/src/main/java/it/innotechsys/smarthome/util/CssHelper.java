package it.innotechsys.smarthome.util;

import it.innotechsys.smarthome.model.Alarm;
import javafx.scene.control.Button;
import javafx.scene.control.Control;
import javafx.scene.control.Tooltip;
import javafx.util.Duration;

public class CssHelper {
    private static CssHelper instance = null;

    private CssHelper() {}

    public static CssHelper getInstance() {
        if(instance == null){
            instance = new CssHelper();
        }
        return instance;
    }

    public void toError(Control c, String tooltipText) {
        toDefault(c);
        c.getStyleClass().add("field-error");
        if(tooltipText != null) {
            Tooltip t = new Tooltip(tooltipText);
            t.getStyleClass().add("tooltip-error");
            t.setShowDelay(Duration.ZERO);
            c.setTooltip(t);
        }
    }

    public void toValid(Control c) {
        toDefault(c);
        c.getStyleClass().add("field-valid");
    }


    public void toBeApproved(Control c, String tooltipText) {
        toDefault(c);
        c.getStyleClass().add("field-to-be-approved");
        if(tooltipText != null) {
            Tooltip t = new Tooltip(tooltipText);
            t.getStyleClass().add("tooltip-to-be-approved");
            t.setShowDelay(Duration.ZERO);
            c.setTooltip(t);
        }
    }

    public void toInfo(Control c, String tooltipText) {
        toDefault(c);
        c.getStyleClass().add("field-info");
        if(tooltipText != null) {
            Tooltip t = new Tooltip(tooltipText);
            t.getStyleClass().add("tooltip-info");
            t.setShowDelay(Duration.ZERO);
            c.setTooltip(t);
        }
    }

    public void toDefault(Control c) {
        c.getStyleClass().remove("field-valid");
        c.getStyleClass().remove("field-be-approved");
        c.getStyleClass().remove("field-info");
        c.getStyleClass().remove("field-error");
        c.setTooltip(null);
    }

    public void setAlarm(Button b, Alarm.alarmStatus status) {
        b.getStyleClass().remove("my-button");
        b.getStyleClass().remove("alarm-armed");
        b.getStyleClass().remove("alarm-active");
        switch(status) {
            case DEACTIVATED -> b.getStyleClass().add("my-button");
            case ARMED -> b.getStyleClass().add("alarm-armed");
            case ALARM -> b.getStyleClass().add("alarm-active");
        }
    }

}
