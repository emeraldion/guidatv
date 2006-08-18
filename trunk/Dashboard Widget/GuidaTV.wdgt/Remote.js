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
 
var sources = {
	"Terrestri": 1,
	"Satellitari": 2
};
 
var channels = {
	"Tutti": 0,
	"Rai Uno": 1,
	"Rai Due": 3,
	"Rai Tre": 16,
	"Rete 4": 24,
	"Canale 5": 22,
	"Italia 1": 23,
	"La 7": 75,
	"MTV": 73,
	"All Music": 72
};

var satchannels = {
	"Tutti": 0,
	"Cult Network Italia": 107,
	"Duel Tv": 57,
	"Fox": 104,
	"Fox Life": 125,
	"Happy Channel": 41,
	"Jimmy": 35,
	"Eurosport": 33,
	"RaiSat Extra": 105,
	"RaiSat Cinema World": 115,
	"RaiSat Premium": 106,
	"Sky Cinema 1": 110,
	"Sky Cinema 16:9": 113,
	"Sky Cinema 3": 111,
	"Sky Cinema Autore": 112,
	"Sky Cinema Classics": 124,
	"Sky Cinema Max": 114,
	"Studio Universal": 60,
	"Sky Sport 1": 116,
	"Sky Sport 2": 117,
	"Sky Sport 3": 123	
};

var genres = {
	"Tutti": 0,
	"Attualità": 17,
	"Bambini": 12,
	"Film": 9,
	"Musicale": 20,
	"Notizie": 13,
	"Quiz": 19,
	"Serial": 11,
	"Sport": 5,
	"Film TV": 16,
	"Talk show": 14,
	"Varietà": 18,
	"Altro": 15
};

function populateRemote() {
	var sourceSelector = getObj("source-selector");
	for (var i in sources) {
		var opt = document.createElement("option");
		opt.text = i;
		opt.value = sources[i];
		sourceSelector.appendChild(opt);
	}
	sourceSelector.onchange = swapChannels;

	var channelSelector = getObj("channel-selector");
	for (var i in channels) {
		var opt = document.createElement("option");
		opt.text = i;
		opt.value = channels[i];
		channelSelector.appendChild(opt);
	}
	//channelSelector.onchange = toggleAlltimeslices;

	var timeslicesSelector = getObj("timeslice-selector");
	for (var i = 0; i < 24; i++) {
		var opt = document.createElement("option");
		opt.text = makeHour(i);
		opt.value = i;
		timeslicesSelector.appendChild(opt);
	}

	var genresSelector = getObj("genre-selector");
	for (var i in genres) {
		var opt = document.createElement("option");
		opt.text = i;
		opt.value = genres[i];
		genresSelector.appendChild(opt);
	}

	populateDaySelector();
}

function swapChannels() {
	var source = getObj("source-selector").value,
		list = null;
	switch (source) {
		case "1": list = channels; break;
		case "2": list = satchannels; break;
	}

	var channelSelector = getObj("channel-selector");

	// cleanup

	var oldOptions = channelSelector.getElementsByTagName("option");
	for (var i = oldOptions.length - 1; i >= 0; i--) {
		channelSelector.removeChild(oldOptions[i]);
	}

	// refill

	for (var i in list) {
		var opt = document.createElement("option");
		opt.text = i;
		opt.value = list[i];
		channelSelector.appendChild(opt);
	}

}

function toggleAlltimeslices() {
	var timesliceSelector = getObj("timeslice-selector");
	var options = timesliceSelector.getElementsByTagName("option");
	if (getObj("channel-selector").value != 0) {
		if (options[0].value) {
			var opt = document.createElement("option");
			opt.text = "Tutte";
			opt.value = "";
			timesliceSelector.insertBefore(opt, options[0]);
		}
	}
	else {
		timesliceSelector.removeChild(options[0]);
	}
}

function updateTimeslice() {
	var hours = new Date().getHours();
	// seleziona l'elemento i-esimo ottenendo l'indice in base all'ora del giorno
	getObj("timeslice-selector").selectedIndex = hours;
}

function updateDaySelector() {
	var daySelector = getObj("day-selector");
	// cleanup

	var oldOptions = daySelector.getElementsByTagName("option");
	for (var i = oldOptions.length - 1; i >= 0; i--) {
		daySelector.removeChild(oldOptions[i]);
	}

	// refill
	populateDaySelector();
}

function populateDaySelector() {
	var daySelector = getObj("day-selector");
	var today = new Date();
	//alert(today);
	for (var i = 0; i < 5; i++) {
		var opt = document.createElement("option");
		opt.text = makedate(today, i, true /* human readable */);
		opt.value = makedate(today, i);
		daySelector.appendChild(opt);
	}
}

function makedate(base_date, offset, human) {
	var the_date = new Date(base_date.getTime() + 24 * 3600 * 1000 * offset);
	if (human) {
		if (offset == 0)
			return getLocalizedString("Oggi");
		else if (offset == 1)
			return getLocalizedString("Domani");
		else
			return day_names[the_date.getDay()] + " " + the_date.getDate();
	}
	else
		return the_date.getDate() + "/" + (the_date.getMonth() + 1) + "/" + the_date.getFullYear();	
}

var day_names = ["Domenica", "Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato"];
var month_names = ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"];