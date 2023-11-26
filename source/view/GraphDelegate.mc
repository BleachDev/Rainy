import Toybox.Lang;
import Toybox.WatchUi;

class GraphDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelectOrSwipe(softAction as Boolean) as Boolean {
        GraphView.page = GraphView.page >= (data.hourlySymbol.size() - 1) / 12 ? 0 : GraphView.page + 1;
        WatchUi.requestUpdate();
        return GraphView.page != 0 || !softAction;
    }
}