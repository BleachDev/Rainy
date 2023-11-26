import Toybox.Lang;
import Toybox.WatchUi;

class SpellSearchDelegate extends TextPickerDelegate {

    function initialize() {
        TextPickerDelegate.initialize();
    }

    function onTextEntered(text, changed) {
        if (changed) {
            var menu = new Menu2({:title => "Location"});
            menu.addItem(new MenuItem("Loading Locations..", "Please Wait :)", 0, {}));

            data.request("https://api.bleach.dev/weather/search?q=" + text, method(:fetchSearch));

            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(menu, new Menu2InputDelegate(), WatchUi.SLIDE_IMMEDIATE);
            WatchUi.pushView(menu, new Menu2InputDelegate(), WatchUi.SLIDE_IMMEDIATE); // Not good but onTextEntered pops the last view after returning
        }

        return false;
    }

    function fetchSearch(responseCode as Number, data as Dictionary?) as Boolean {
        System.println(data);

        if (WatchUi.getCurrentView()[0] instanceof Menu2) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }

        if (responseCode != 200 || data == null) {
            var menu = new Menu2({:title => "Location"});
            menu.addItem(new MenuItem("Error", "Connection Error", 0, {}));
            WatchUi.pushView(menu, new Menu2InputDelegate(), WatchUi.SLIDE_BLINK);
            return false;
        }

        var menu = new Menu2({:title => "Location" });
        for (var i = 0; i < data.size(); i++) {
            menu.addItem(new MenuItem(data[i]["name"], data[i]["region"] + " (" + data[i]["code"] + "), El. " + data[i]["elevation"] + "m", i, {}));
        }

        WatchUi.pushView(menu, new SpellListDelegate(data), WatchUi.SLIDE_BLINK);
        return true;
    }
}

class SpellListDelegate extends Menu2InputDelegate {

    private var dt as Dictionary?;

    function initialize(dt as Dictionary?) {
        Menu2InputDelegate.initialize();
        self.dt = dt;
    }

    function onSelect(item) {
        data.autoLocation = false;
        data.update(dt[item.getId()]["position"]);
        WatchUi.popView(WatchUi.SLIDE_BLINK);
    }
}