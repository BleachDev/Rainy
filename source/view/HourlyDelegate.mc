import Toybox.Lang;
import Toybox.WatchUi;

class HourlyDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelectOrSwipe(softAction as Boolean) as Boolean {
        HourlyView.page = HourlyView.page == 2 ? 0 : HourlyView.page + 1;
        WatchUi.requestUpdate();
        return HourlyView.page != 0 || !softAction;
    }
}