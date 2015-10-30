class TopchartsRankingController < ApplicationController

	require 'rubygems'
	require 'open-uri'
	require 'nokogiri'
	require 'httparty'

	def index
		# top 100 apps ranking for free, paid, grossing (can scrape without login)
		# web_data = open("https://www.appannie.com/apps/ios/top/united-states/?device=iphone", "User-Agent" => "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.89 Safari/537.36")
		# doc = Nokogiri.HTML(web_data)

		# trigger "Load all" button to get the whole top 500 apps, using inspector to store as XML file
		# issue: how to trigger "Load all" button automatically
		f = File.open("/home/shirley/AppAnnie-Scraper/public/top500.xml")
		doc = Nokogiri::XML(f)
		f.close

		# scrape app name & link
		@apprank = doc.xpath("//span[@class='oneline-info title-info']//a")
		@apprank.each do |record|
			Ranking.create(:appname => record.text, :link => "https://www.appannie.com#{record['href']}")
		end

		# using rank id to calculate apps' real ranking order and type (free, paid, grossing)
		# HTML structure in //table //tr //td : free --> paid --> grossing
		@rank = Ranking.all

		free_count = 1
		paid_count = 1
		grossing_count = 1
		@rank.each do |apptype|
			if apptype.id.to_i % 3 == 1
				apptype.update_attributes!(:apptype => "free", :rank => free_count)
				free_count = free_count + 1
			elsif apptype.id.to_i % 3 == 2
				apptype.update_attributes!(:apptype => "paid", :rank => paid_count)
				paid_count = paid_count + 1
			else
				apptype.update_attributes!(:apptype => "grossing", :rank => grossing_count)
				grossing_count = grossing_count + 1
			end
		end
	end

end
