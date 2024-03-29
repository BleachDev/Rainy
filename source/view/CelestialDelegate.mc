import Toybox.Lang;
import Toybox.WatchUi;

class CelestialDelegate extends BaseDelegate {

    function initialize() {
        BaseDelegate.initialize();
    }

    function onSelectOrSwipe(softAction as Boolean) as Boolean {
        CelestialView.page = CelestialView.page == 1 ? 0 : CelestialView.page + 1;
        WatchUi.requestUpdate();
        return CelestialView.page != 0 || !softAction;
    }
}