import Toybox.Lang;
import Toybox.WatchUi;

class HourlyDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelect() as Boolean {
        HourlyView.page = HourlyView.page == 3 ? 0 : HourlyView.page + 1;
        WatchUi.requestUpdate();
        return true;
    }

    //! Handle going to the next view
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
        WatchUi.switchToView(new GraphView(), new GraphDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        WatchUi.switchToView(new SummaryView(), new SummaryDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }
}