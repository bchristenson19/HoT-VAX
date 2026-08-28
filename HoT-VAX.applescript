-- HoT-VAX — drag-and-drop macOS quarantine stripper
--
-- Removes the `com.apple.quarantine` extended attribute (the thing that
-- triggers "<App> is damaged and can't be opened" / "cannot be opened because
-- the developer cannot be verified") from unsigned apps we build in-house.
--
-- Two ways to use it:
--   • Drag one or more .app / .dmg / files / folders onto the droplet.
--   • Double-click the droplet to get a file/folder picker.
--
-- It runs `xattr -rd com.apple.quarantine` on each item (recursive, so a whole
-- .app bundle or a folder of builds is handled), then reports what it did.

-- Entry point when items are dropped onto the app icon.
on open theItems
	processItems(theItems)
end open

-- Entry point when the app is double-clicked (no drop). Ask for items.
on run
	set chosen to {}
	try
		-- Let the user pick either files or folders. `multiple selections`
		-- plus `invisibles false` keeps it simple; .app bundles are chosen
		-- as single items here.
		set chosen to choose file with prompt ¬
			"Select app(s) or file(s) to vaccinate:" with multiple selections allowed without invisibles
	on error number -128 -- user cancelled the file picker
		-- Offer a folder picker as a fallback before giving up.
		try
			set chosen to {choose folder with prompt "…or choose a folder to vaccinate:"}
		on error number -128
			return -- cancelled again; quit quietly
		end try
	end try
	processItems(chosen)
end run

-- Core: strip quarantine from every supplied item, then summarise.
on processItems(theItems)
	if theItems is {} then return

	set okCount to 0
	set failCount to 0
	set failNames to {}

	repeat with anItem in theItems
		set posixPath to POSIX path of anItem
		set itemName to name of (info for anItem)
		try
			-- Recursively delete the quarantine attribute. `-rd` is
			-- idempotent: it exits 0 even when the attribute is absent, so
			-- "already clean" is treated as success.
			do shell script "/usr/bin/xattr -r -d com.apple.quarantine " & quoted form of posixPath
			set okCount to okCount + 1
		on error errMsg
			set failCount to failCount + 1
			set end of failNames to itemName
		end try
	end repeat

	-- Build a human-readable summary dialog.
	set theTitle to "HoT-VAX"
	if failCount is 0 then
		if okCount is 1 then
			set msg to "Vaccinated 1 item. It should now open without Gatekeeper warnings."
		else
			set msg to "Vaccinated " & okCount & " items. They should now open without Gatekeeper warnings."
		end if
		display dialog msg with title theTitle buttons {"OK"} default button "OK" with icon note giving up after 10
	else
		set failList to my joinList(failNames, ", ")
		set msg to "Vaccinated " & okCount & " item(s)." & return & return & ¬
			"Could not process " & failCount & " item(s): " & failList & return & return & ¬
			"They may need administrator rights or live in a protected location."
		display dialog msg with title theTitle buttons {"OK"} default button "OK" with icon caution
	end if
end processItems

-- Join a list of strings with a delimiter (AppleScript has no built-in).
on joinList(theList, theDelim)
	set savedDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to theDelim
	set theString to theList as text
	set AppleScript's text item delimiters to savedDelims
	return theString
end joinList
