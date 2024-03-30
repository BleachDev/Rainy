import Toybox.Lang;
import Toybox.WatchUi;

class RegisterDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onSelect() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_BLINK);
        return true;
    }
}