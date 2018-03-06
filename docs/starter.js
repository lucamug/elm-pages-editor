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
