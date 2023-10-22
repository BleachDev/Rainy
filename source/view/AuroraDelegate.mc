import Toybox.Lang;
import Toybox.WatchUi;

class AuroraDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    //! Handle going to the next view
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
        WatchUi.switchToView(new WaterView(), new WaterDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        WatchUi.switchToView(new GraphView(), new GraphDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }
}