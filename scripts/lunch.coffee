# Ask devbot what you should do for lunch today!
# Just type 'devbot lunch me' and you get a selection.



lunch = [ "Sushi Fantastic",
	"Rincon Deli and Market",
	"Toaster Oven for a sandwich/soup",
	"That Indian buffet that always runs out of lamb curry",
	"Los Compadres",
	"The Rincon food court",
	"Subway - Eat Fresh",
	"Food truck roundup on Mission between Fremont and 1st",
	"Gotts",
	"Soup Co.",
	"Cafe Venue",
	"Kevin's Vietnamese food cart",
	"Redbull, chips, cookies, and cereal from the snack room"
]

module.exports = (robot) ->
 robot.hear /.*(lunch me).*/i, (msg) ->
    msg.send msg.random lunch