require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'environment')


require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'trollop'
require 'twitter'


#configure do
#  set :views, "#{File.dirname(__FILE__)}/views"
#end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  # add your helpers here
end

get '/hi' do
 "Hello World"
end

get '/mashery' do
  hackday("mashery")
end


get '/3scale' do
  hackday("3scale")
end



def trendo(word,month=6,year=2013)

  url = "http://www.google.com/trends/fetchComponent?hl=en&q=#{word}&date=#{month}/#{year}+1m&cmpt=q&content=1&cid=TIMESERIES_GRAPH_0&export=5&w=500&h=330"
  page_content = Net::HTTP.get(URI.parse(url))
  return [url,"N/A"] if page_content =~ /You have reached your quota limit/
  raw_data_array = page_content.split("rows\":")[1].split("var htmlChart").first
  split_raw = raw_data_array.split("],")
  total = 0
  split_raw.each do |sr|
    source = sr.split("Date(")[1].split(",")
    date = source[0]+'-'+(source[1].gsub(/\s/,"").to_i+1).to_s+'-'+source[2].gsub(/\s/,"").gsub(/\)\}/,"") #.gsub(/)},/,'')
    num = source[5]
    total += num.to_i  unless num.nil?
  end
  return [url,total]
end

 
 def hackday(company)

  f = ""
query = "http://api.crunchbase.com/v/1/company/#{company}.js?api_key=jsefacarrw363wza4yp6yf74"
result_text = Net::HTTP.get(URI(query))
result = JSON.parse(result_text)

name = ["name", "description", "homepage_url", "twitter_username"]

# info = [ "crunchbase_url", "homepage_url", "blog_url", "blog_feed_url", "twitter_username", "number_of_employees",
# "email_address", "phone_number",  "created_at", "updated_at",
# "products", "relationships", "competitions", "providerships",
# "total_money_raised", "funding_rounds",  "investments",
# "acquisition", "acquisitions", "milestones", "ipo"]
#
# founded = ["founded_year",  "founded_month", "founded_day" ]
#
# location = ["offices"]

company_url = result["homepage_url"]
twitter_user=result["twitter_username"]

  f << "COMPANY: \n" <<  name.map { |x| "#{x}: #{result[x]}" }.join("\n") << "\n\n"

# Wolfram API
app_id = "QJ9ELV-V5U573PUQ8"
query = "http://api.wolframalpha.com/v2/query?appid=#{app_id}&input=#{company_url}%20traffic&format=plaintext"
result_text = Net::HTTP.get(URI(query))

wolves = []
result_text.split("\n").each do |x|
  next unless x =~ /daily page views/ or x =~ /site rank/
  x.gsub!("   <plaintext>","")
  x.gsub!(" |",":")
  wolves << x
end

  f << "TRAFFIC: \n" <<  wolves.join("\n") << "\n\n"


#google trends
trends = trendo(company)
  f << "GOOGLE TRENDS: " << trends.last << "\n" << trends.first << "\n\n"

# customers mashery hack
num_website_customers = 0
case company
when "mashery"
  url = "http://www.mashery.com/customers"
  css = "div.views-field-field_customer_api a"
when "3scale"
  url = "http://www.3scale.net/our-customers"
  css = "ul#customers a"
end

doc = Nokogiri::HTML(open(url))
customers = []
doc.search(css).map do |link|
  customers << link['href']
  num_website_customers +=1
end

  f << "NUM WEBSITE CUSTOMERS: " << num_website_customers << "\n" << customers[0..9].join(", ") << "\n\n"



consumer_key = 'KI5Grl68x0B4VdTIX4Ak1Q'
consumer_secret = 'q1GHsUqbx3KqBFoMme4rHlFFf5b1hY6Z1pVS8AEkT8M'
access_token = '14159546-bNxOIhoXJGzALTy8mSvWMxByTOe9Do7hPv90Jn0xi'
access_token_secret = 'eZZ8oBQsAomROh7mYdTurEL2SMMB2k3mkSNb2ToJE'

Twitter.configure do |config|
  config.consumer_key = consumer_key
  config.consumer_secret = consumer_secret
  config.oauth_token = access_token
  config.oauth_token_secret = access_token_secret
end

num_followers =  Twitter.follower_ids( {:user=>"Mashery"} ).all.size

  f << "NUM TWITTER FOLLOWERS " << num_followers << " " << num_retweets << "\n\n"
 f
    
    end
