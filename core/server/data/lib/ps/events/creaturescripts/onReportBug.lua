-- The client's plain bug report (clients without the Reports window): a bug report with no category,
-- titled with the start of the text (lib/ps/systems/083-reports.lua)
function onReportBug(cid, comment)
    local text = tostring(comment or "")
    local title = text:match("^%s*([^\n]+)") or ""
    if (#title > 60) then
        title = title:sub(1, 57) .. "..."
    end
    local id, reason = Reports.create(cid, { kind = "bug", category = "other", title = title, description = text })
    if (id) then
        doPlayerSendCancel(cid, string.format("Bug report #%d was sent, thank you!", id))
    else
        doPlayerSendCancel(cid, reason)
    end
    return true
end
