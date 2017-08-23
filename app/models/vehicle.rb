class Vehicle < ActiveRecord::Base
  has_one :owner

 #This method is used in Rake Task - scrapper.rake
 #this scrapes the data from craigslist and populates the db
  def self.scrape

    require 'open-uri'
    require 'json'

        auth_token = "8f45896484dc3c1c1fc8bb3a282140d5"
        polling_url = "http://polling.3taps.com/poll"

          params = {

    auth_token: auth_token,
    anchor: 2294711907,
    #2263538537,

    #Source Reference
    #autotrader - AUTOC or #AUTOD
    #craigslist - CRAIG ### Cant do this anymore
    #ebay motors - EBAYM
    source: "AUTOD",

    #Vehicles
    category_group: "VVVV",

    #Vehicle automobile
    category: "VAUT",

    #Grab the for sale listings
    status: "for_sale",

    #Code references for cities
    #WPB -USA-MIA-WES
    #MIA - USA-MIA-MIF
    #FTL - USA-MIA-FOR
    #ORL - USA-ORL-ORL
    #TAMPA - USA-TPA-TAM
    'location.city' => ["USA-ORL-ORL"],

    #subsets were retreiving
    retvals: "location,external_url,timestamp,annotations,deleted,external_id"
    }

    #prepare API request
    uri = URI.parse(polling_url)
    uri.query = URI.encode_www_form(params)

    #Submit request
    result = JSON.parse(open(uri).read)

  #  binding.pry

    #Results
  result["postings"].each do |listing|
    next if result["postings"].empty?
    #create new vehicle
    @vehicle = get_vehicle listing

#binding.pry
    require "nokogiri"

    #Set URL and Nokogiri
    url = @vehicle.external_url
    #@vehicle.external_url
    page = Nokogiri::HTML(open(url))

  #scraping the name from the listing
 # p page.css(".reply_options > ul:nth-of-type(2) li")

    #This is grabbing all the images attached to a listing
    #grab the css that holds the image
##    page.css('div#thumbs a').each do |link|
##    end

    #seller comment
    @vehicle.notes = page.css('section#postingbody').text

    #price in cents
    #sub removes the '$' before the price
    #Ex. "$150" --> "150"
    #convert it to integer
    @vehicle.price_in_cents = page.css('span.price').text.sub(/\D/, '').to_i

  #  binding.pry

    #save
    #p 'saving...'
    @vehicle.save
   #binding.pry


 end
 nil
end




def self.get_vehicle(listing)
        vehicle = Vehicle.new(owner: Owner.new)

        #annotation variable
        annotations = listing['annotations']
        #location variable
        location = listing["location"]

        vehicle.v_make = annotations["make"]

        if vehicle.make.name == "chevy"
          vehicle.make.name.gsub!("chevy", "Chevrolet")
        end


        vehicle.v_model = annotations["model"]
        vehicle.submodel = annotations["type"] if annotations["type"].present?

        #Year Variable
        #year is a date in schema
        year = annotations["year"].to_i if annotations["year"].present?
        vehicle.year = Date.new(year, 1, 1)

        #mileage
        vehicle.mileage = annotations["mileage"] if annotations["mileage"].present?
        #transmission name nested
        vehicle.transmission = annotations["transmission"] if annotations["transmission"].present?
        #exterior color
        vehicle.exterior_color = annotations["paint_color"] if annotations["paint_color"].present?

        #source loc is giving the city

        vehicle.owner.city = annotations["source_loc"]
        if vehicle.owner.city == "westpalmbeach"
          vehicle.owner.city.gsub!("westpalmbeach", "West Palm Beach")
        end
       # binding.pry

      #External url to scrape the actual data on the individual listings
      #external id kinda useless but grab it anyways
      vehicle.external_id = listing["external_id"]
      vehicle.external_url = listing["external_url"]

      #add vin number entry -- at a later time.
      #vehicle.vin.vin_number = listing["vin"] if listing["vin"].present?

        #Owner Attributes
        vehicle.owner.street_address_1 = location["formatted_address"] if location["formatted_address"].present?
        vehicle.owner.latitude = location["lat"].to_f
        vehicle.owner.longitude = location["long"].to_f

        #Phone number
        #some data has a phone number and some dont
        #most listings have the number so it will display in the seller comments
        vehicle.owner.phone_number = annotations["phone"] if annotations["phone"].present?

        #postal code variable
        postal_code = location["zipcode"]
        #postal_code.sub is removing the USA- from string
        #Ex. "USA-32826" --> "32826"
        vehicle.owner.postal_code = postal_code.sub(/\USA-/, '') if postal_code

        #state variable
        #state.sub is removing the USA- from string
        #Ex. "USA-FL" --> "FL"
        state = location["state"]
        vehicle.owner.state = state.sub(/\USA-/, '')
        vehicle

end
end
