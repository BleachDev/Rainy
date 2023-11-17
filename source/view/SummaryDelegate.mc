import Toybox.Lang;
import Toybox.WatchUi;

class SummaryDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelectOrSwipe() as Boolean {
        return onMenu();
    }
}