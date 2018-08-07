fromAll()
.when({
    $any: function(s,e){
        if (!e.eventType.startsWith("$")) {
            linkTo("app-all", e, e.metadata);
        }
    }
})