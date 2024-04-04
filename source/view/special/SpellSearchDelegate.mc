import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class SpellSearchDelegate extends TextPickerDelegate {

    function initialize() {
        TextPickerDelegate.initialize();
    }

    function onTextEntered(text, changed) {
        if (changed) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            data.enterText(text);
            WatchUi.pushView(new View(), null, WatchUi.SLIDE_IMMEDIATE); // Not good but onTextEntered pops the last view after returning
            return true;
        }

        return false;
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
        Properties.setValue("autoLocation", data.autoLocation);
        data.update(dt[item.getId()]["position"]);
        WatchUi.popView(WatchUi.SLIDE_BLINK);
    }
}