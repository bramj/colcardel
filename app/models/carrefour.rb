class Carrefour
	include Capybara::DSL
	
	def initialize()
		visit('/')
		click_link("verder gaan in het Nederlands")

		sleep 2
		find("#rd_shop_19-label").click # Hasselt
		sleep 1
		click_button("Begin met online winkelen")
		sleep 1

		# Save all the category text and href values [text, href]
		categories = get_categories

		categories.each do |category|
			category_name = category[0]
			visit category[1]
			puts "#{category_name}"
			
			subcategories = get_categories

			subcategories.each do |subcategory|
				subcategory_name = subcategory[0]
				visit subcategory[1]
				puts "\t#{subcategory_name}"

				extract_items

				# If there is a 'next page' button, click it and extract the products
				unless all(".modListHeader .next .page").empty?
					next_page_link = find(".modListHeader .next .page")
					unless next_page_link['href'].nil?
						next_page_link.click
						extract_items
					end
				end
				
				puts "\tFinished subcategory #{subcategory_name}"
			end
			puts "Finished category #{category_name}"
		end
	end

	def get_category_title
		find(".facetCategories-category h4").text
	end

	def get_categories
		# Expose all subcategories
		# begin
		# 	find(".shopByCat .showMoreFacets").click
		# rescue Capybara::ElementNotFound => e
		# 	# do nothing, all subcategories are on the page
		# end

		all("#navigation .page").map { |a| [a.text, a['href']] }
	end

	def extract_items
		all_product_links = all("#zoneProductList .heading a").map { |a| a['href'] }
		puts "\t\tExtracting #{all_product_links.size} products..."

		all_product_links.each do |prod_link|
			visit prod_link

			begin
				product = find(".product")

				picture = product.find(".img img")['src'] unless product.all(".img img").empty?
				name = product.find(".heading").text unless product.all(".heading").empty?
				description = product.find(".description .long").text unless product.all(".description .long").empty?

				brand = ""
				ingredients = ""
				nutritional_value = ""
				preservation = ""
				product_number = ""
				product.all(".specs .spec").each do |spec|
					content = spec.find(".caption").text
					case spec.find(".caption").text
					when "Merk"
						brand = content
					when "Ingredi\u00EBnten"
						ingredients = content
					when "Voedingswaarde"
						nutritional_value = content
					when "Bewaring"
						preservation = content
					when "Productnummer"
						product_number = content
					end
				end

				price_currency = product.find(".prices .currency").text	unless product.all(".prices .currency").empty?
				price_int = product.find(".prices .amount").text unless product.all(".prices .amount").empty?
				price_fraction = product.find(".prices .decimal").text unless product.all(".prices .decimal").empty?
				price_unit = product.find(".prices .unit").text unless product.all(".prices .unit").empty?

				puts "\t\t\t#{name} - #{brand} - #{description} - #{price_currency}#{price_int}.#{price_fraction}#{price_unit}"
			rescue Capybara::ElementNotFound => e
				debugger
				puts e.message
			end

			sleep 2
		end
	end
end
