/**
 *	GuidaTV Widget
 *
 *	Copyright 2005-2007 Claudio Procida. All rights reserved.
 *	http://www.emeraldion.it
 * 
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 * 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 * 
 *  Bug fixes, suggestions and comments should be sent to:
 *  claudio@emeraldion.it
 *
 */

/**
 *	Variables
 */

var req = null,
	tuning = false;

/**
 *	Constants
 */

var NOTFOUND_MARKER = "<b>Nessun risultato trovato</b>",
	POLL_URL = "http://spettacolo.virgilio.it/guidatv/cgi/index.cgi",
	POLL_HOST = "spettacolo.virgilio.it",
	DESC_START = '<table cellpadding="0" cellspacing="0" border="0" width="100%" id="scheda">',
	DESC_END = "</td></tr>",
	TAPPO = "http://images.virgilio.it/n_canali/cinema/guida_tv/img_tappo.gif",
	NO_IMAGE = "img/huh.png";
	
function tune() {

	/**
	 *	Formato richiesta:
	 *
	 *	Parametro	      Valore
	 *  -----------------+-------
	 *	TIME_CHK_FormF   | 02 (?)
	 *	DATE_FROM_FormF  | oggi|domani
	 *	DATE_TO_FormF    | oggi|domani
	 *	CHAN001_FormF    | <channel>
	 *	TIME_ZONES_FormF | <timeslice>
	 *	KIND001_FormF    | <genre>
	 *
	 */

	var url = buildRequestURL();
	
	req = new XMLHttpRequest();
	req.onreadystatechange = handleResponse;
	req.open("GET", url, true);
	req.send(null);
}

function buildRequestURL() {
	var date = new Date(); // then give the user a chance to choose the day
	var url = POLL_URL + "?";
	
	if (getObj("channel-selector").value && !getObj("timeslice-selector").value) { // palinsesto di un canale specifico
		url += "tipo=3&" +
			"channel=" + getObj("channel-selector").value;
	}
	else { // programmi per fascia oraria
		url += "tipo=2&" +
			"chtype=" + getObj("source-selector").value + "&" +
			// "day=" + date.getDate() + "/" + (date.getMonth() + 1) + "/" + date.getFullYear() + "&" +
			"day=" + getObj("day-selector").value + "&" +
			"channel=" + getObj("channel-selector").value + "&" +
			"hour=" + getObj("timeslice-selector").value + "&" +
			"type=" + getObj("genre-selector").value;
	}
		
	return url;
}

function buildDetailsURL(progid) {
	var url = POLL_URL + "?";
	
	if (progid) { // dettagli su un programma specifico
		url += "tipo=1&" +
			"qs=" + progid;
	}
		
	return url;
}

function handleResponse() {
	if (req.readyState == 4) {
		var response = "";
		if (req.status == 200) {
			if (programsAvailable(req.responseText)) {
				showPrograms(parseResponse(req.responseText));
			}
			else {
				//showError("Informazioni non disponibili");
			}
		}
		else {
			//showError("No response from server.");
		}
	}
}

function parseResponse(text) {

	// This is the Regular Expression that matches the program listed in the summary
 	var REGEXP = /<!--\s+RISULTATO\s+-->\s+<tr\s+valign="top">\s+<td\s+id="col-canale(-end)?">\s+<a\s+href="\?tipo=3&channel=([\d]+)">([^<]*)<\/a><\/td>\s+<td\s+id="col-orario(-end)?"\s+bgcolor="#(ECE7C9|E1D8AD)">\s+<div\s+id="testo-orario(-chiaro)?">\s+([^<]+)<\/div><\/td>\s+<td\s+id="col-programma(-chiaro)?(-end)?"\s+bgcolor="#(E4E4E2|D1D1D1)">\s+<div\s+id="bg-programma(-in-onda)?(-chiaro)?">\s*(<img\s+src="http:\/\/images.alice.it\/n_canali\/cinema\/guida_tv\/freccia_in_onda.gif"\s+alt="ora\s+in\s+onda"\/>)?\s*<a\s+href="\?tipo=1&qs=([^"]+)">([^<]+)\s+<\/div><\/td>\s+<td\s+id="col-genere(-chiaro)?(-end)?"\s+bgcolor="#?(ECECEE|DFDFE1)">\s+<div\s+id="testo-genere(-chiaro)?">\s+([^<]+)\s+<\/div>\s+<\/td>\s+<\/tr>\s+<!--\s+\/RISULTATO\s+-->/gi;
 		
	var programs = new Array(),
		channel = null,
		date = null,
		time = null,
		genre = null,
		title = null;
	
	var matches = null;

	// Repeatedly call RegExp.exec() until matches are found
	while (matches = REGEXP.exec(text))
	{
		channel = matches[2];
		time = matches[7];
		onair = matches[11];
		progid = matches[14];
		title = matches[15];
		genre = matches[20];
		programs[programs.length] = new Program(channel, progid, time, genre, title, onair);
	}
	return programs;
}

function Program(channel, progid, time, genre, title, onair) {
	this.channel = strtochannel(channel);
	this.progid = progid;
	this.time = time;
	this.genre = genre;
	this.title = title;
	this.date = strtotime(getObj("day-selector").value);
	this.onair = onair;
	return this;
}

Program.prototype.toString = function() { // provides a toString method for programs
	var str = '<div class="program" onclick="toggleDetails(this, \'' + this.progid + '\');"><div class="datario">' +
		strftime(this.time, this.date) + '</div><div class="genere">' +
		this.genre + '</div><br /><div class="canale">' +
		this.channel + '</div><div class="titolo' + (this.onair ?  ' onair' : '') + '">' +
		this.title + '</div></div>';

	return str;
};

function strtotime(str) {
	str = str.split("/");
	return new Date(str[1]+"/"+str[0]+"/"+str[2]);
}

var dayNames = ["Dom", "Lun", "Mar", "Mer", "Gio", "Ven", "Sab"];

function strftime(time, date) {
	var str = dayNames[date.getDay()] + " " + date.getDate() + "/" + (date.getMonth() + 1) + " ore " + time;
	return str;
}

function strtochannel(str) {
	return '<img src="img/chan/' + str + '.png" title="' + channelName(str) + '" />';
}

function programsAvailable(responseText) {
	return true;
	var available = responseText.indexOf(NOTFOUND_MARKER) == -1;
	return available;
}

function channelName(str) {
	for (var i in channels) {
		if (channels[i] == str) {
			return i;
		}
	}
	for (var i in satchannels) {
		if (satchannels[i] == str) {
			return i;
		}
	}
}

function programUrl(progid) {
	return "goToUrl('" + POLL_URL + "?tipo=1&qs=" + progid + "')";
}

function filter(event, text) {
	if (event.keyCode == 27) { // Esc
		hideObj("controls");
	}
	var el = getObj("content").getElementsByTagName("div");
	var len = el.length;
	for (var i = 0; i < len; i++) {
		if (el[i].className.indexOf("program") != -1) {
			if (programContains(el[i], text)) {
				el[i].style.display = "block";
			}
			else {
				el[i].style.display = "none";
			}
		}
	}		
	applyZebraStripes();
	getObj("content").style.top = 0;
	calculateAndShowThumb(getObj("content"));
}

function programContains(el, text) {
	if (!text) return true;
	var elText = innerText(el);
	return (elText.toLowerCase().indexOf(text.toLowerCase()) != -1);
}

function innerText(node) {
    // is this a text or CDATA node?
    if (node.nodeType == 3 || node.nodeType == 4) {
        return node.data;
    }
    var i;
    var returnValue = [];
    for (i = 0; i < node.childNodes.length; i++) {
        returnValue.push(innerText(node.childNodes[i]));
    }
    return returnValue.join(' ');
}

function toggleDetails(el, progid) {
	if (el.loading) return;
	if (el.loaded) {
		el.details.style.display = (el.details.style.display == "none") ? "block" : "none";
		calculateAndShowThumb(getObj("content"));
	}
	else {
		loadDetails(el, progid);
	}	
}

function loadDetails(el, progid) {
	el.loading = true;

	var throb = new Throbber(progid);
	throb.img = new ThrobberImage(progid);

	el.appendChild(throb.img);
	throb.start();

	var url = buildDetailsURL(progid);
	
	req = new XMLHttpRequest();
	req.target = el;
	req.throb = throb;
	req.onreadystatechange = handleDetails;
	req.open("GET", url, true);
	req.send(null);
}

function handleDetails() {
	if (req.readyState == 4) {
		var response = "";
		if (req.status == 200) {
			var details = new Description(parseDescription(req.responseText));
			req.target.appendChild(details);
			setTimeout('calculateAndShowThumb(getObj("content"));', 1000);
			req.throb.stop();
			req.target.removeChild(req.throb.img);
			req.target.loading = false;
			req.target.loaded = true;
			req.target.details = details;
		}
		else {
			//showError("No response from server.");
		}
	}
}

function Description(text) {
	var desc = document.createElement("div");
	desc.className = "description";
	desc.innerHTML = text;
	return desc;
}

function parseDescription(text) {
	var desc = text.slice(text.indexOf(DESC_START), text.indexOf(DESC_END, text.indexOf(DESC_START)));
	desc = desc.replace(/id=/gi, "class=").replace(TAPPO, NO_IMAGE);
	return desc;
}

function ThrobberImage(id) {
	var img = document.createElement("img");
	img.id = id;
	img.className = "throbber";
	return img;
}