function onStaminaChange(cid, stamina, change)
    if (EventCalendar.isActive("summer")) then
        JulyVacationEvent.onStaminaChange(cid, stamina, change)
    end
    return true
end