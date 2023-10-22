import Toybox.Lang;
import Toybox.WatchUi;

class SummaryDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelect() {
        return onMenu();
    }

    //! Handle going to the next view
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
        WatchUi.switchToView(new HourlyView(), new HourlyDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        WatchUi.switchToView(new WaterView(), new WaterDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }
}