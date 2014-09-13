require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

require "capybara"
require "capybara/dsl"
require "capybara-webkit"

require 'debugger'

url = "http://www.collectandgo.be/"

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = url

class Colruyt
	include Capybara::DSL
	
	def initialize()
		tree_url = "http://www.collectandgo.be/cogo/no_deploy/cogoBoom3759N.js"
		# tree_url = "tree.js"
		tree = JSON.load(open(tree_url), nil, symbolize_names: true)

		recursive(tree, 0)
	end

	# parent so we can create categories within categories
	def recursive(category, level, parent_category = nil)
		indentation = ""
		level.times { indentation = indentation + "\t" }

		if category[:data]
			current_category = category[:data][:title]
			puts "#{indentation}#{current_category}"

			# Visit the products page if we're in a leaf node
			unless category.keys.include? :children
				visit get_category_url(category[:data][:attr][:id])
				extract_items
				puts "#{indentation}=> extracted products from #{current_category}..."
			end
		end

		if category.keys.include? :children
			category[:children].each do |child|
				recursive(child, level + 1, current_category)
			end
		end
	end

	def get_category_url(id)
		"http://www.collectandgo.be/cogo/nl/branch/#{id}/"
	end

	def extract_items
		product_detail_links = all(".product .prodHeading a").map { |a| a['href'] }

		all(".product").each do |product|
			begin
				picture = product.find(".prodImage img")["src"]

				new_item = product['class'].include? "prodNew"
				red_price = product['class'].include? "redPrice"

				if product.all(".prodHeading .caption").empty?
					name = product.find(".prodHeading .detail").text
				else
					name = product.find(".prodHeading .caption").text
					description = product.find(".prodHeading .detail").text
				end
				price_total = product.find(".totalPrice").text
				price_sep = product.find(".sepPrice").text

				puts "\t\t\t#{name} - #{price_total}"
			rescue Capybara::ElementNotFound => e
				puts e.message
			end
		end
	end
end

Colruyt.new


