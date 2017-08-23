require 'open-uri'
require 'json'

#I'm using a web scrapper to scrap the privatre seller used cars from craigslist
#Temporary fix for one side of the chicken in the egg

#It will grab cars in a few cities Orlando, West Palm Beach, Miami, FT.Lauderdale.
#South florida basically

# Set API Token and url
auth_token = "8f45896484dc3c1c1fc8bb3a282140d5"
polling_url = "http://polling.3taps.com/poll"

#specify request parameters
params = {

	auth_token: auth_token,
	archor: 2156265076,
	source: "CRAIG",
	category_group: "VVVV",
	category: "VAUT",
	'location.city' => "USA-ORL-ORL",
	retvals: "location,external_url,timestamp,annotations,deleted"
}

#prepare API request
uri = URI.parse(polling_url)
uri.query = URI.encode_ww_form(params)

#submit request
result = JSON.parse(open(uri).read)

#Display results to screen
puts JSON.pretty_generate result
