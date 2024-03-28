import Toybox.Lang;
import Toybox.WatchUi;

class DailyDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelectOrSwipe(softAction as Boolean) as Boolean {
        DailyView.page = DailyView.page == DailyView.pageCount - 1 ? 0 : DailyView.page + 1;
        WatchUi.requestUpdate();
        return DailyView.page != 0 || !softAction;
    }
}