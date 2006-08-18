/**
 *	GuidaTV Widget
 *
 *	© Claudio Procida 2005
 *
 *	Disclaimer
 *
 *	The GuidaTV Widget software (from now, the "Software") and the accompanying materials
 *	are provided “AS IS” without warranty of any kind. IN NO EVENT SHALL THE AUTHOR(S) BE
 *	LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES,
 *	INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN
 *	IF THE AUTHOR(S) HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. The entire risk as to
 *	the results and performance of this software is assumed by you. If the software is
 *	defective, you, and not Claudio Procida, assume the entire cost of all necessary servicing,
 *	repairs and corrections. If you do not agree to these terms and conditions, you may not
 *	install or use this software.
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
	RESULTS_START = "<!-- RISULTATO -->",
	RESULTS_END = "<!-- /RISULTATO -->",
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

	text = text.substring(text.indexOf(RESULTS_START) + RESULTS_START.length, text.lastIndexOf(RESULTS_END));
	
 	var TOKEN_SEPARATOR = "<!-- /RISULTATO -->\n\n\t\t\t\t  \n\t\t\n\t\t\t\t   \t\n\t\t\n\t\t\t\t   \t\n\n\n<!-- RISULTATO -->",
 		REGEXP = /\n+<tr valign="top">\n+\t+<td id="col-canale(-end)?">\n+\t+\n+<a href="\?tipo=3&channel=(\d+)">([^<]*)<\/a><\/td>\n+\t+\n+\t+\n+\t+<td id="col-orario(-end)?" bgcolor="#(E1D8AD|ECE7C9)">\n+\t+\n+\t+\n+\t+\n+\t+<div id="testo-orario(-chiaro)?">\n+\t+\n+(\d{2}:\d{2})<\/div><\/td>\n+\t+\n+\t+\n+\t+(\n+\t+)?<td id="col-programma(-chiaro)?(-end)?" bgcolor="#(D1D1D1|E4E4E2)">\n+\t+\n+\t+\n+\t+\n+<div id="bg-programma(-in-onda)?(-chiaro)?">(\n+)?(<img src="http:\/\/images\.virgilio\.it\/n_canali\/cinema\/guida_tv\/freccia_in_onda\.gif" alt="ora in onda"\/>)?<a href="\?tipo=1&qs=(\d+)">(.+)\n+<\/div><\/td>\n+\t+\n+\t+\n+\t+(\n+\t+)?<td id="col-genere(-chiaro)?(-end)?" bgcolor="#?(DFDFE1|ECECEE)">\n+\t+\n+\t+(\n+\t+)?<div id="testo-genere(-chiaro)?">\n+\t+\n+(.+)\n+<\/div>\n+<\/td>\n+<\/tr>\n+/;
 		
	var programs = new Array(),
		tokens = text.split(TOKEN_SEPARATOR),
		channel = null,
		date = null,
		time = null,
		genre = null,
		title = null;
		
	for (var i = 0; i < tokens.length; i++)
	{
		var m = tokens[i].match(REGEXP);
		if (!m) continue;
		channel = m[2];
		time = m[7];
		onair = m[12];
		progid = m[16];
		title = m[17];
		genre = m[24];
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