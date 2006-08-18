/**
 *	Throbber class
 *
 *	© Claudio Procida 2005
 *
 *	Disclaimer
 *
 *	This software library (from now, the "Software") and the accompanying materials
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

/**
 *	Constants
 */

/**
 *	Functions
 */
 
function Throbber(id) {
	this.index = 1;
	this.id = id || "throbber";
	this.timer = null;
	this.animate = function() {
		getObj(this.id).src = "img/throbber/throbber_" + this.index + ".png";
		this.index = this.index > 11 ? 1 : this.index + 1;
	};
	this.start = function() {
		if (this.timer)
			clearInterval(this.timer);
		this.timer = setInterval(function(throb) {throb.animate();}, 67, this);
	};
	this.stop = function() {
		getObj(this.id).src = "img/null.gif";
		clearInterval(this.timer);
	};
}