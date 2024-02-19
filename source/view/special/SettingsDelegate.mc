import Toybox.Lang;
import Toybox.WatchUi;

class SettingsDelegate extends Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        System.println(item.getId());
        if (item.getId() == 0) {
            if (!(WatchUi has :TextPicker)) {
                item.setSubLabel("Spell Search Unavailable!");
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
            }
        } else if (item.getId() == 1) {
            data.pageOrder = !data.pageOrder;
            item.setSubLabel(data.pageOrder ? "Graph First" : "Tables First");
        } else if (item.getId() == 2) {
            data.windUnits = (data.windUnits + 1) % 3;
            item.setSubLabel(data.windUnits == 0 ? "m/s" : data.windUnits == 1 ? "km/h" : "mph");
        } else if (item.getId() == 3) {
            data.update(data.position);
            WatchUi.popView(WatchUi.SLIDE_BLINK);
        }
        
    }
}