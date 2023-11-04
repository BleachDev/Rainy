import Toybox.Lang;
import Toybox.WatchUi;

class SummaryDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelect() {
        return onMenu();
    }
}