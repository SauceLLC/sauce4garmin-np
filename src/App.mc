import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;


class SauceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new SauceDataField()];
    }
}


function getApp() as SauceApp {
    return Application.getApp() as SauceApp;
}
