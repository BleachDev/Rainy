import Toybox.Lang;
import Toybox.WatchUi;

class GraphDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelectOrSwipe() as Boolean {
        GraphView.page = GraphView.page >= (data.hourlySymbol.size() - 1) / 12 ? 0 : GraphView.page + 1;
        WatchUi.requestUpdate();
        return true;
    }
}