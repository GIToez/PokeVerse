-- Shows the messages the payment service left for online players and staff (data/lib/ps/systems/101-payments.lua).
function onThink(interval)
    if (Payments.enabled()) then
        Payments.deliverNotices()
    end
    return true
end
