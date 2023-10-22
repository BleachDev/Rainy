import Toybox.Lang;
import Toybox.WatchUi;

class GraphDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelect() as Boolean {
        GraphView.page = GraphView.page >= (data.hourlySymbol.size() - 1) / 12 ? 0 : GraphView.page + 1;
        WatchUi.requestUpdate();
        return true;
    }

    //! Handle going to the next view
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
        WatchUi.switchToView(new AuroraView(), new AuroraDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        WatchUi.switchToView(new HourlyView(), new HourlyDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }
}