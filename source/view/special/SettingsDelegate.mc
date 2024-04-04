import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class SettingsDelegate extends Menu2InputDelegate {

    public static var WIND_UNITS = [ "m/s", "km/h", "mph", "Bft." ];

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        System.println(item.getId());
        if (item.getId() == 0) {
            if (!(WatchUi has :TextPicker)) {
                item.setSubLabel("See Mobile Settings!");
                return;
            }

            if (data.autoLocation) {
                WatchUi.pushView(
                    new TextPicker(""),
                    new SpellSearchDelegate(),
                    WatchUi.SLIDE_LEFT
                );
            } else {
                item.setSubLabel("Automatic (GPS)");
                data.autoLocation = true;
                Properties.setValue("autoLocation", data.autoLocation);
            }
        } else if (item.getId() == 1) {
            data.pageOrder = !data.pageOrder;
            Properties.setValue("pageOrder", data.pageOrder);
            item.setSubLabel(data.pageOrder ? "Graph First" : "Tables First");
        } else if (item.getId() == 2) {
            data.windUnits = (data.windUnits + 1) % 4;
            Properties.setValue("windUnits", data.windUnits);
            item.setSubLabel(WIND_UNITS[data.windUnits]);
        } else if (item.getId() == 3) {
            data.update(data.position);
            WatchUi.popView(WatchUi.SLIDE_BLINK);
        }
        
    }
}