class AppsearchController < ApplicationController

	require 'rubygems'
	require 'open-uri'
	require 'nokogiri'
	require 'httparty'
	require 'mechanize'

	def index
		if params[:keyword].blank?
			# random words generator
			doc = Nokogiri.HTML(open('http://randomword.setgetgo.com/get.php', 'User-Agent' => "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.89 Safari/537.36"))
			@keyword = doc.xpath("//body").text.chomp
		else
			@keyword = params[:keyword]
		end

		if params[:number].blank? || params[:number].chomp.to_i <= 0
			@number = 1
		elsif params[:number].chomp.to_i > 30
			@number = 30
		else
			@number = params[:number].chomp.to_i
		end

		# search results for the keyword
		result = Nokogiri.HTML(open("https://www.appannie.com/search/?q=#{@keyword}&vertical=apps&market=ios", 'User-Agent' => "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.89 Safari/537.36"))

		aFile = File.new("search.xml", "w+")
		aFile.syswrite(result)

		f = File.open(aFile)
		searchresult = Nokogiri::XML(f)
		f.close

		# simulate login to scrape app details
		agent = Mechanize.new
		login = agent.get('https://www.appannie.com/account/login')
		login_form = login.form
		username_field = login_form.field_with(:name => "username")
		username_field.value = ENV["USERNAME"]
		password_field = login_form.field_with(:name => "password")
		password_field.value = ENV["PASSWORD"]
		home_page = login_form.submit

		i = 1
		# get the list of search results
		while i <= @number
			@record = searchresult.xpath("(//td[@class='app-infos'])[#{i}]/h3/a").text
			@link = searchresult.xpath("(//td[@class='app-infos'])[#{i}]/h3/a/@href").text
			if @record.blank?
				flash[:notice] = "No results for #{@keyword}"
				render :action => "index"
			else
				detail = agent.get("https://www.appannie.com#{@link}")
				bFile = File.new("app.xml", "w+")
				bFile.syswrite(detail.body)

				f = File.open(bFile)
				currentfile = Nokogiri::XML(f)
				f.close

				# app icon
				@icon = currentfile.xpath("//img[@class='itc']/@src").text

				# app store
				#@store = currentfile.xpath("//span[@itemprop='seller']/span[@itemprop='name']/@content").text
				@store = currentfile.xpath("//a[@title='iOS Store']").text
				# app price
				@price = currentfile.xpath("//span[@itemprop='price']/@content").text

				# app description
				@description = currentfile.xpath("//div[@itemprop='description']").text.gsub(/\n/, " ")

				# Average Ratings's country
				@country = currentfile.xpath("//span[@class='country']").text

				# get the 10 rating distribution numbers, current5 means the amount of five star rating
				@current5 = currentfile.xpath("//div[@id='r_current_content']//tr[1]//td[@class='count']").text.delete("(").delete(")").delete(",")
				@current4 = currentfile.xpath("//div[@id='r_current_content']//tr[2]//td[@class='count']").text.delete("(").delete(")").delete(",")
				@current3 = currentfile.xpath("//div[@id='r_current_content']//tr[3]//td[@class='count']").text.delete("(").delete(")").delete(",")
				@current2 = currentfile.xpath("//div[@id='r_current_content']//tr[4]//td[@class='count']").text.delete("(").delete(")").delete(",")
				@current1 = currentfile.xpath("//div[@id='r_current_content']//tr[5]//td[@class='count']").text.delete("(").delete(")").delete(",")
				@all5 = currentfile.xpath("//div[@id='r_all_content']//tr[1]//td[@class='count']").text.delete("(").delete(")").delete(",")
				@all4 = currentfile.xpath("//div[@id='r_all_content']//tr[2]//td[@class='count']").text.delete("(").delete(")").delete(",")
				@all3 = currentfile.xpath("//div[@id='r_all_content']//tr[3]//td[@class='count']").text.delete("(").delete(")").delete(",")
				@all2 = currentfile.xpath("//div[@id='r_all_content']//tr[4]//td[@class='count']").text.delete("(").delete(")").delete(",")
				@all1 = currentfile.xpath("//div[@id='r_all_content']//tr[5]//td[@class='count']").text.delete("(").delete(")").delete(",")

				# average & total volume
				@average_current = currentfile.xpath("//div[@id='r_current_content']//strong[1]").text
				@total_current = currentfile.xpath("//div[@id='r_current_content']//strong[last()]").text.delete(",")

				@average_all = currentfile.xpath("//div[@id='r_all_content']//strong[1]").text
				@total_all = currentfile.xpath("//div[@id='r_all_content']//strong[last()]").text.delete(",")

				# app compatibility
				@compatibility = currentfile.xpath("//b[.='Compatibility:']/following-sibling::text()[1]").text
				# app category
				@category = currentfile.xpath("//b[.='Category:']/following-sibling::text()[1]").text
				# app updated_date
				@updated_date = currentfile.xpath("//b[.='Updated:']/following-sibling::text()[1]").text
				# app size
				@size = currentfile.xpath("//b[.='Size:']/following-sibling::text()[1]").text
				# app seller
				@seller = currentfile.xpath("//b[.='Seller:']/following-sibling::text()[1]").text
				# app rating rated
				@rated = currentfile.xpath("//b[.='Rating: ']/following-sibling::text()[1]").text
				# app requirements
				@requirements = currentfile.xpath("//b[.='Requirements:']/following-sibling::text()[1]").text
				# app bundle id
				@bundleid = currentfile.xpath("//b[.='Bundle ID:']/following-sibling::text()[1]").text

				# screenshot, scrape only top five screenshots here
				@screenshot1 = currentfile.xpath("(//div[@id='screenshots']//div[@class='img-holder'])[1]/a/@href").text
				@screenshot2 = currentfile.xpath("(//div[@id='screenshots']//div[@class='img-holder'])[2]/a/@href").text
				@screenshot3 = currentfile.xpath("(//div[@id='screenshots']//div[@class='img-holder'])[3]/a/@href").text
				@screenshot4 = currentfile.xpath("(//div[@id='screenshots']//div[@class='img-holder'])[4]/a/@href").text
				@screenshot5 = currentfile.xpath("(//div[@id='screenshots']//div[@class='img-holder'])[5]/a/@href").text

			Appsearch.create(:link => @link, :appname => @record, :icon => @icon, :store => @store, :price => @price,
									:description => @description, :country => @country,
									:average_current => @average_current, :total_current => @total_current,
									:average_all => @average_all, :total_all => @total_all, 
									:current1 => @current1, :current2 => @current2, :current3 => @current3, :current4 => @current4, :current5 => @current5,
									:all1 => @all1, :all2 => @all2, :all3 => @all3, :all4 => @all4, :all5 => @all5,
									:compatibility => @compatibility, :category => @category, :updated_date => @updated_date, 
									:size => @size, :seller => @seller, :rated => @rated, :requirements => @requirements, :bundleid => @bundleid,
									:screenshot1 => @screenshot1, :screenshot2 => @screenshot2, :screenshot3 => @screenshot3, 
									:screenshot4 => @screenshot4, :screenshot5 => @screenshot5)

				bFile.chmod(0777)
				File.delete(bFile)
      	sleep (5 + Random.rand(1))
				flash[:notice] = "Successful!"
			end
			i = i + 1
		end

		aFile.chmod(0777)
		File.delete(aFile)
	end

end
