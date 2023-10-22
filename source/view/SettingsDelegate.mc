import Toybox.Lang;
import Toybox.WatchUi;

class SettingsDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        System.println(item.getId());
        if (item.getId() == 0) {
            data.fahrenheit = !data.fahrenheit;
            item.setSubLabel(data.fahrenheit ? "Fahrenheit" : "Celcius");
        }
    }
}