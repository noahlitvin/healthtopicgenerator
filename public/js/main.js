App = {

	slideshowMode: false,

	init: function(){
		$("a.button").click(function(e){
			e.preventDefault();
			App.generateSuggestion();
		});
		App.initSlideshowController();
		App.generateSuggestion();
	},

	generateSuggestion: function() {
		$("h2").html('<em>loading...</em>');
		$('a.more').attr("href", "#");
		$("span.strategy-name").html('<em>loading...</em>');
		$.getJSON( "/generate.json", function( strategy ) {
			$("span.strategy-name").text(strategy.name);
			$('a.more').attr("href", strategy.link);
			$("h2").text(strategy.title);
		});
	},

	initSlideshowController: function(){

		$('body').keyup(function(e){
			if(e.keyCode == 32){
				$("body").toggleClass("slideshow-mode");
				App.slideshowMode = !App.slideshowMode;
			}
		});
		setInterval(function(){
			if(App.slideshowMode){
				$("a.button").click();
			}
		}, 10000);
	},

};

$(document).ready(function(){
	App.init();
});