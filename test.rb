require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

require "capybara"
require "capybara/dsl"
require "capybara-webkit"

require 'debugger'

url = "http://shop.delhaize.be/"

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = url

class Test
	include Capybara::DSL
	
	def initialize()
		visit('/')
		click_button("Nederlands")
		links = find("#hpNavigationLeft").all("a")

		# Save all the href values
		link_hrefs = links.map { |link| link['href'] }

		link_hrefs.each do |link|
			visit(link)
			# Make sure all products are on the page
			begin
				while(true) do click_button("Meer producten tonen"); end
			rescue Capybara::ElementNotFound => e
				# do nothing, all products are on the page
			end

			all(".mini-grid").each do |product|
				begin
					picture = product.all("img").first['src']
					details = product.find(".details")
					name = details.find(".productInformation").text
					manufacturer = details.find(".manufacturerName").text				
					price_int = details.find("#totalint").text
					price_fraction = details.find("#totalfraction").text
					extra = details.find(".nomargin").text

					puts "#{name} - #{manufacturer} - #{price_int}.#{price_fraction} (#{extra})"
				rescue Capybara::ElementNotFound => e
					puts e.message
				end
			end
			puts "Finished page"
		end
	end
end

Test.new

# evaluate_script('window.history.back()')


