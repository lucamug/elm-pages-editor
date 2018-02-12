// __START__ Webpack specific section

// Importing stuff
// import './main.css';
// import bannerSrc from "./Images/skyline.jpg";
import registerServiceWorker from './registerServiceWorker';
import {
    Main
} from './Main.elm';
const Elm = {
    Main: Main
};

// Loading data from packages
const pack = require('../package.json');

registerServiceWorker();

// __END__ Webpack specific setion


// The following section is inside an self-invoking anonymous
// function because it can be used as standalone, wihtout Webpack

// __START__ Generic Section
(function() {
    "use strict";
    var elmApp = Elm.Main.fullscreen({
        localStorage: (localStorage.getItem("elmLocalStorage") || ""),
        packVersion: typeof pack === "undefined" ? "1.0.0" : pack.version,
        width: window.innerWidth,
        height: window.innerHeight
    });

    elmApp.ports.urlChange.subscribe(function(title) {
        window.requestAnimationFrame(function() {
            document.title = title;
            document.querySelector('meta[name="description"]').setAttribute("content", title);
        });
    });

    elmApp.ports.sendValueToJsLocalStore.subscribe(function(value) {
        localStorage.setItem("elmLocalStorage", value);
    });

    window.addEventListener("storage", function(event) {
        if (event.storageArea === localStorage && event.key === "elmLocalStorage") {
            elmApp.ports.onLocalStorageChange.send(event.newValue);
        }
    }, false);
})();
// __END__ Generic Section
