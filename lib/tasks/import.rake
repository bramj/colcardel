require 'nokogiri'
require 'open-uri'
require 'mechanize'

require "capybara"
require "capybara/dsl"
require "capybara-webkit"

namespace :import do
	
	desc "Import Colruyt prices."
	task :colruyt => :environment do
		url = "http://www.collectandgo.be/"
		Colruyt.new
	end

	desc "Import Delhaize prices."
	task :delhaize => :environment do
		url = "http://shop.delhaize.be/"
		Delhaize.new
	end

	desc "Import Carrefour prices."
	task :carrefour => :environment do
		url = "https://eshop.carrefour.eu/"
		Carrefour.new
	end

end

def init
	Capybara.run_server = false
	Capybara.current_driver = :selenium
	Capybara.app_host = url
end