import Toybox.Lang;
import Toybox.WatchUi;

class HintDelegate extends WatchUi.BehaviorDelegate {

    private var buttons;

    function initialize(buttons) {
        BehaviorDelegate.initialize();
        self.buttons = buttons;
    }

    public function onSelect() as Boolean {
        if (buttons.indexOf(0) != -1) {
            WatchUi.popView(WatchUi.SLIDE_BLINK);
            return true;
        }

        return false;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        if (buttons.indexOf(1) != -1) {
            WatchUi.popView(WatchUi.SLIDE_BLINK);
            return true;
        }
        return false;
    }
}