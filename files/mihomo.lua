module("luci.controller.mihomo", package.seeall)

function index()

    entry(
        {"admin", "services", "mihomo"},
        template("mihomo/main"),
        _("UzumakiClash 🌀"),
        60
    ).dependent = false

end
