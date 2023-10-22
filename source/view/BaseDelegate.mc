import Toybox.Lang;
import Toybox.WatchUi;

class BaseDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        var menu = new WatchUi.Menu2({:title=>"Yr Settings"});
        menu.addItem(
            new MenuItem(
                "Temperature Units",
                data.fahrenheit ? "Fahrenheit" : "Celcius",
                0,
                {}
            )
        );
        WatchUi.pushView(menu, new SettingsDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}