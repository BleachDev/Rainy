import Toybox.Lang;
import Toybox.WatchUi;

class HourlyDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelectOrSwipe() as Boolean {
        HourlyView.page = HourlyView.page == 3 ? 0 : HourlyView.page + 1;
        WatchUi.requestUpdate();
        return true;
    }
}