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

class Delhaize
	include Capybara::DSL
	
	def initialize()
		visit('/')
		click_button("Nederlands")

		# Save all the category text and href values [text, href]
		categories = find("#hpNavigationLeft").all("a").map { |a| [a.text, a['href']] }

		categories.each do |category|
			category_name = category[0]
			visit category[1]
			puts "#{category_name}"
			
			subcategories = get_subcategories

			subcategories.each do |subcategory|
				subcategory_name = subcategory[0]
				visit subcategory[1]
				puts "\t#{subcategory_name}"

				subsubcategories = get_subcategories

				subsubcategories.each do |subsubcategory|
					subsubcategory_name = subsubcategory[0]
					visit subsubcategory[1]
					puts "\t\t#{subsubcategory_name}"

					extract_items
					puts "\t\tFinished subsubcategory #{subsubcategory_name}"
				end
				puts "\tFinished subcategory #{subcategory_name}"
			end
			puts "Finished category #{category_name}"
		end
	end

	def get_category_title
		find(".facetCategories-category h4").text
	end

	def get_subcategories
		# Expose all subcategories
		begin
			find(".shopByCat .showMoreFacets").click
		rescue Capybara::ElementNotFound => e
			# do nothing, all subcategories are on the page
		end

		all(".facetGpExpanded .productViewLayout").map { |a| [a.text, a['href']] }
	end

	def extract_items
		# Make sure all products are on the page
		begin
			while(true) do click_button("Meer producten tonen"); end
		rescue Capybara::ElementNotFound => e
			# do nothing, all products are on the page
		end

		all_products = all(".mini-grid")
		puts "\t\tExtracting #{all_products.size} products..."
		all_products.each do |product|
			begin
				picture = product.all("img").first['src']
				details = product.find(".details")
				name = details.find(".productInformation").text
				manufacturer = details.find(".manufacturerName").text
				price_currency = details.find(".currencyPrice").text	
				price_int = details.find(".valuePrice").text
				price_fraction = details.find(".sup").text
				extra = details.find(".nomargin").text

				puts "\t\t\t#{name} - #{manufacturer} - #{price_currency}#{price_int}.#{price_fraction} (#{extra})"
			rescue Capybara::ElementNotFound => e
				puts e.message
			end
		end
	end
end

Delhaize.new

# evaluate_script('window.history.back()')


