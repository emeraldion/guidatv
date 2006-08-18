on clicked theObject
	(*Add your script here.*)
	
	set addedItems to false -- tracks if we added anything 
	tell application "iCal"
		set calTitles to title of every calendar whose writable is true
		--repeat with cal in (every calendar whose writable is true)
		--	set calTitles to calTitles & (title of cal as string)
		--end repeat
	end tell
	
	-- dialog asking user to choose calendar
	set chosenCalendar to choose from list calTitles with prompt "Scegli un calendario" cancel button name "Annulla" OK button name "Aggiungi ad iCal" default items (first item of calTitles) without empty selection allowed and multiple selections allowed
	
	if chosenCalendar is false then
		exit repeat
		
	else if (count of chosenCalendar) is 1 then
		
		--set chosenCalUID to (item of calUIDs whose index is (index of (chosenCalendar) in calTitles))
		
		set eventSummary to "GuidaTV" -- subject of theMessage as Unicode text
		set eventDescription to "GuidaTV" -- content of theMessage as Unicode text
		
		tell application "iCal"
			set theCalendar to (first calendar whose title is (chosenCalendar as string))
			tell theCalendar
				set newEvent to make new event at end of events with properties {start date:current date, summary:eventSummary, description:eventDescription}
			end tell
		end tell
		
		set addedItems to true
		
	end if -- chose a calendar from dialog - if none chosen, move silently to next Mail message
	
	if addedItems is true then
		tell application "iCal"
			activate
			
			tell application "System Events" to click menu item "iCal" of menu "Finestra" of menu bar item "Finestra" of menu bar 1 of process "iCal"
			
			show newEvent
			
		end tell
	end if
end clicked

