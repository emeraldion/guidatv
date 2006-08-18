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
 
var flipShown = false,
	channel = null,
	animation = {duration:0, starttime:0, to:1.0, now:0.0, from:0.0, firstElement:null, timer:null},
	noisetimer = null;

/**
 *	Constants
 */


/**
 *	Init function
 */
	
function setup() {
	if (window.widget) {
	    widget.onshow = onshow;
	    widget.onhide = onhide;
	}
	
	// handlers
	
	document.onkeydown = onkeydown;
	
	// bootstrap

	loadUI();
	populateRemote();
	updateTimeslice();
	
	// operation

	powerOn();
	new VersionChecker().checkUpdate();
	tune();
}

/**
 *	Dashboard event handlers
 */

function onshow() {
	updateTimeslice();
	updateDaySelector();
	tune();
}

function onhide() {
}

function onkeydown(event) {
	if (event.metaKey) {
		switch (event.keyCode) {
			case 70:
				showObj("controls");
				getObj("filter").focus();
				event.stopPropagation();
				event.preventDefault();
				break;
		}
	}
}

/**
 *	Preference handling functions
 */

function readPrefs() {
	if (window.widget) {
		//dummyProperty = widget.preferenceForKey("dummyProperty");
	}
}

function savePrefs() {
	if (window.widget) {
		//widget.setPreferenceForKey(dummyProperty, "dummyProperty");
	}
}

function showPrefs() {
	var front = getObj("front");
	var back = getObj("back");

	if (window.widget)
		widget.prepareForTransition("ToBack");
       
	front.style.display="none";
	back.style.display="block";

	if (window.widget)
		setTimeout ('widget.performTransition();', 0);
}

function hidePrefs() {
	
	var front = getObj("front");
	var back = getObj("back");

	if (window.widget)
		widget.prepareForTransition("ToFront");

	hidefliprollie();
	
	back.style.display="none";
	front.style.display="block";

	if (window.widget)
		setTimeout ('widget.performTransition();', 0);
		
	setTimeout("tune()", 1000);
}

/**
 *	Internationalization support
 */

function getLocalizedString (key) {
	try {
		var ret = localizedStrings[key];
		if (ret === undefined)
			ret = key;
		return ret;
	}
	catch (ex) {
	}
	return key;
}

/**
 *	Interface boundary handlers
 */
 
function donate() { // Thank you!
	goToUrl("http://www.emeraldion.it/software/widgets/guidatv/donate/");
}

function info() {
	goToUrl("http://www.emeraldion.it/software/widgets/guidatv/instructions/");
}

/**
 *	Visual FX functions
 */

function showfliprollie() { // convenience method
	showObj("fliprollie");
}

function hidefliprollie() { // convenience method
	hideObj("fliprollie");
}

function animate() { // shows a glowing effect
	var T;
	var ease;
	var time = (new Date).getTime();
   

	T = clampTo(time-animation.starttime, 0, animation.duration);

	if (T >= animation.duration) {
		clearInterval (animation.timer);
		animation.timer = null;
		animation.now = animation.to;
	}
	else {
		ease = 0.5 - (0.5 * Math.cos(Math.PI * T / animation.duration));
		animation.now = computeNextFloat (animation.from, animation.to, ease);
	}

	animation.firstElement.style.opacity = animation.now;
}

/**
 *	Interface event handlers
 */

function mousescroll(event) {
	scrollBy(window.event.wheelDelta / 20);
}

function mousemove (event) {
	if (!flipShown) {
		if (animation.timer != null) {
			clearInterval (animation.timer);
			animation.timer  = null;
		}
 
		var starttime = (new Date).getTime() - 13;
 
		animation.duration = 500;
		animation.starttime = starttime;
		animation.firstElement = document.getElementById ("flip");
		animation.timer = setInterval ("animate();", 13);
		animation.from = animation.now;
		animation.to = 1.0;
		animate();
		flipShown = true;
	}
}

function mouseexit (event) {
	if (flipShown) {
		// fade in the info button
		if (animation.timer != null) {
			clearInterval (animation.timer);
			animation.timer  = null;
		}

		var starttime = (new Date).getTime() - 13;

		animation.duration = 500;
		animation.starttime = starttime;
		animation.firstElement = document.getElementById ("flip");
		animation.timer = setInterval ("animate();", 13);
		animation.from = animation.now;
		animation.to = 0.0;
		animate();
		flipShown = false;
	}
}

function enterflip(event) {
	showfliprollie();
}

function exitflip(event) {
	hidefliprollie();
}

/**
 *	Notification and visualization functions
 */

function showResults(response) {
	hideObj("container");
	showObj("bars");
	calculateAndShowThumb(getObj("container"));
}

function showError(message) {
	showObj("bars");
	hideObj("container");
	calculateAndShowThumb(getObj("bars"));
}

/**
 *	Miscellaneous utilities
 */
 
function getObj(id) { // retrieves an element
	return document.getElementById(id);
}

function showObj(id) { // shows an element
	getObj(id).style.display = 'block';
}

function hideObj(id) { // hides an element
	getObj(id).style.display = 'none';
}

function responseString() { // provides a toString method for responses
	var str = '';
	if (this.date)
		str += '<div style="float: left">' + strftime(this.date) + '</div>';
	if (this.place)
		str += '<div style="float: right">' + this.place + '</div>';
	str += '<br style="clear: both" />' + this.text;
	return str;
}

function goToUrl(url) { // opens a URL
	if (window.widget) {
		widget.openURL(url);
	}
	else {
		window.open(url);
	}
}

function clampTo(value, min, max) { // constrains a value between two limits
	return value < min ? min : value > max ? max : value;
}

function computeNextFloat (from, to, ease) { // self explaining
	return from + (to - from) * ease;
}

function showPrograms(programs) {
	makeDummy();
	getObj("content").style.top = 0;
	getObj("content").innerHTML = new Separator();
	for (var i = 0; i < programs.length; i++) {
		getObj("content").innerHTML += programs[i];
	}
	getObj("content").innerHTML += new Separator(true);	
	applyZebraStripes();
	calculateAndShowThumb(getObj("content"));
	fadeFromTo("bars", "container");
}

function powerOn() {
	if (fade.timer != null) {
		clearInterval (fade.timer);
		fade.timer  = null;
	}
	var starttime = (new Date).getTime() - 13;

	fade.duration = 1000;
	fade.starttime = starttime;
	fade.firstElement = getObj("bars");
	fade.timer = setInterval ("fade();", 13);
	fade.from = 0.0;
	fade.to = 1.0;
	fade();
	showObj("poweron");
}

function powerOff() {
	if (fade.timer != null) {
		clearInterval (fade.timer);
		fade.timer  = null;
	}
	var starttime = (new Date).getTime() - 13;

	fade.duration = 1000;
	fade.starttime = starttime;
	fade.firstElement = getObj("bars");
	fade.timer = setInterval ("fade();", 13);
	fade.from = 1.0;
	fade.to = 0.0;
	fade();
}

function fade() {
	var T;
	var ease;
	var time = (new Date).getTime();   

	T = clampTo(time-fade.starttime, 0, fade.duration);
	if (T >= fade.duration) {
		clearInterval (fade.timer);
		fade.timer = null;
		fade.now = fade.to;
	}
	else {
		ease = 0.5 - (0.5 * Math.cos(Math.PI * T / fade.duration));
		fade.now = computeNextFloat (fade.from, fade.to, ease);
	}
	
	with (fade.firstElement.style) {
		opacity = fade.now;
	}
}

function someWhiteNoise() {
	getObj("noise").style.opacity = 0.0;
	showObj("noise");
	noisestart = (new Date()).getTime();
	if (noisetimer) {
		clearInterval(noisetimer);
	}
	noisetimer = setInterval("whiteNoise();", 17);
}

function whiteNoise() {
	var elapsed = (new Date()).getTime() - noisestart;
	getObj("noise").style.backgroundPositionX = Math.floor(100 * Math.random()) + "px";
	getObj("noise").style.backgroundPositionY = Math.floor(100 * Math.random()) + "px";
	getObj("noise").style.opacity = elapsed > 1500 ?
		1.0 - ((elapsed - 1500) / 1000):
		elapsed < 1000 ?
			elapsed / 1000:
			1.0;

	if (elapsed > 2500) {
		clearInterval(noisetimer);
		getObj("noise").style.opacity = 0.0;
		hideObj("noise");
	}
}

function applyZebraStripes() {
	var nodes = getObj("content").childNodes,
		n = 0;
	for (var i = 0; i < nodes.length; i++) {
		removeClass(nodes[i], "even");
		removeClass(nodes[i], "odd");

		if (nodes[i].nodeType == 1 &&
			nodes[i].style.display != "none") {
			if (n++ % 2 == 0) {
				addClass(nodes[i], "odd");
			}
		}
	}
	removeClass(getObj("content"), "odd");
	removeClass(getObj("content"), "even");
	if (n % 2) {
		addClass(getObj("content"), "odd");
	}
	else {
		addClass(getObj("content"), "even");
	}
}

function fadeFromTo(fromPanel, toPanel) {
	/**
	 *	Rumore bianco 0->1
	 *	Nascondere fromPanel
	 *	Rivelare toPanel
	 *	Rumore bianco 1->0
	 */
	someWhiteNoise();
	setTimeout(function(from, to) { hideObj(from); hideObj("dummy"); showObj(to); }, 1517, fromPanel, toPanel);
}

function makeDummy() {
	getObj("dummy").innerHTML = getObj("content").innerHTML;
	showObj("dummy");
}

function Separator(last) {
	this.last = last;
}

Separator.prototype.toString = function() { return '<div class="' + (this.last ? "lastNode" : "firstNode") + '"></div>'; };

function makeHour(num) {
	var s = new String(num);
	return (s.length < 2 ? ('0' + s) : s) + ':00';
}

function loadUI() {
	scrollerInit(getObj("myScrollBar"), getObj("myScrollTrack"), getObj("myScrollThumb"));

	getObj("update-text").innerHTML = getLocalizedString("Aggiornamento disponibile");
	getObj("version").innerHTML = "v" + getWidgetProperty("CFBundleVersion");

	createGenericButton(getObj("done"), getLocalizedString("Fine"), hidePrefs);
	createGenericButton(getObj("donate"), getLocalizedString("Dona"), donate);
	createGenericButton(getObj("info"), getLocalizedString("?"), info);
}

function addClass(el, sel) {
	var classes = el.className.split(" ");
	if (!inArray(classes, sel)) {
		classes.push(sel);
		el.className = classes.join(" ");
	}	
}

function removeClass(el, sel) {
	var classes = el.className.split(" ");
	if (inArray(classes, sel)) {
		el.className = arrayRemove(classes, sel).join(" ");
	}	
}

function inArray(arr, obj) {
	for (var i = 0; i < arr.length; i++)
		if (arr[i] == obj)
			return true;
	return false;
}

function arrayRemove(arr, obj) {
	var newarr = [];
	for (var i = 0; i < arr.length; i++)
		if (arr[i] != obj)
			newarr.push(arr[i]);
	return newarr;
}