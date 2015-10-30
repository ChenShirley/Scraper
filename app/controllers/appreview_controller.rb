class AppreviewController < ApplicationController

	require 'rubygems'
	require 'open-uri'
	require 'nokogiri'
	require 'httparty'

	def index
		# review's URL --> https://www.appannie.com/apps/ios/app/462638897/reviews/?country=US&date=2015-09-27~2015-10-27
		# link of app has already store into DB (https://www.appannie.com/apps/ios/app/462638897/)
		# content is dynamic loading (<div class="main-app-content">), so we can't get the full content automatically
		# issue: make mechanize wait for webpage loading

		# "show how many rows" triggered by javascript (default = 10 rows)
		# if we want more reviews, using file instead (using inspector to get app's latest 5/10/50/200 reviews and save as XML file)
		# issue: how to select "show rows" or "next page"automatically

		# the file used here is for 10 rows showed
		f = File.open("/home/shirley/Scraper/public/fitbit_review.xml")
		doc = Nokogiri::XML(f)
		f.close

		show_rows = 10

		@appname = doc.xpath("//h2[@class='asset-name']").text
		@appdetail = Appdetail.find_by_appname(@appname)

		# ratings --> need to count "star-whole.png", one review with 6 img (5 star and 1 country flag)
		# equal to @rating = doc.xpath("//div[@class='ngCellText cell-inner ng-scope']/span[@aa-stars='']/nobr//img/@src")
		@rating = doc.xpath("//img/@src")

		# review title
		@title = doc.xpath("//div[@class='ngCellText cell-inner cell-review ng-scope']/div/strong[@class='ng-binding']")

		# review author
		@author = doc.xpath("//div[@class='ngCellText cell-inner cell-review ng-scope']/div/span/strong[@class='ng-binding']")

		# review content
		@content = doc.xpath("//div[@class='review-content ng-binding']")

		# review date
		@date = doc.xpath("//div[@class='ngCellText cell-inner colt2 col-date']/span[@class='ng-binding']")

		# review country
		@country = doc.xpath("//div[@class='ngCellText cell-inner cell-country ng-scope']/span[@class='ng-binding']/@title")

		# review version
		@version = doc.xpath("//div[@class='ngCellText cell-inner colt4 col-version']/span[@class='ng-binding']")

		# only scrape "show_rows" (default is 10) reviews here, to calculate which attritube are in the same review
		i=1
		whole="/media/pictures/star-whole.png"
		blank="/media/pictures/star-blank.png"
		while ( i <= show_rows )
			if @rating[6*i-2].text.eql?(whole)
				star=5
			elsif @rating[6*i-2].text.eql?(blank) && @rating[6*i-3].text.eql?(whole)
				star=4
			elsif @rating[6*i-2].text.eql?(blank) && @rating[6*i-3].text.eql?(blank) && @rating[6*i-4].text.eql?(whole)
				star=3
			elsif @rating[6*i-2].text.eql?(blank) && @rating[6*i-3].text.eql?(blank) && @rating[6*i-4].text.eql?(blank) && @rating[6*i-5].text.eql?(whole)
				star=2
			else
				star=1
			end

				Appreview.create(:appname => @appname, :star => star, 
												 :title => @title[i-1].text, :author => @author[i-1].text, :content => @content[i-1].text, 
												 :date => @date[i-1].text, :country => @country[i-1].text, :version => @version[i-1].text,
												 :appdetail_id => @appdetail.id)
				i = i + 1
		end
	end

end
