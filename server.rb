require 'sinatra'
require 'json'
require 'nokogiri'
require 'open-uri'

def scrape_data(url)
    Nokogiri::HTML(open(url, 'User-Agent' => 'Health Topic Generator'))
end

def r_health
  data = scrape_data("https://www.reddit.com/r/health")
  titles = data.css('div.thing a.title')
  choice = titles[rand(titles.length)]
  title = choice.text
  link = choice['href']
  return { :name => "/r/Health", :title => title, :link => link }
end

def wikipedia
	[0, 1].sample == 0 ? wikipedia_disorders : wikipedia_diseases
end

def wikipedia_disorders
	data = scrape_data("https://en.wikipedia.org/wiki/List_of_disorders")
	titles = data.css('#bodyContent .mw-parser-output > ul a:not(.new)')
	choice = titles[rand(titles.length)]
	title = choice.text
	link = "https://en.wikipedia.org" + choice['href']
	return { :name => "Wikipedia's List of Disorders", :title => title, :link => link }
end

def wikipedia_diseases
	random_letter = [*('A'..'Z')].sample
	data = scrape_data("https://en.wikipedia.org/wiki/List_of_diseases_("+random_letter+")")
	titles = data.css('#bodyContent .mw-parser-output > ul a:not(.new)')
	choice = titles[rand(titles.length)]
	title = choice.text
	link = "https://en.wikipedia.org" + choice['href']
	return { :name => "Wikipedia's List of Diseases", :title => title, :link => link }
end

def care_cards
	data = JSON.load(open("https://raw.githubusercontent.com/goinvo/CareCards/master/assets/data/care-cards.json"))
	choice = data['cards'].sample
	title = choice['name']
	link = "http://carecards.me"
	return { :name => "CareCards.me", :title => title, :link => link }
end

def ted_health
	data = scrape_data("https://www.ted.com/talks?topics%5B%5D=health&sort=newest")
	titles = data.css('.talk-link h4 a.ga-link')
	choice = titles[rand(titles.length)]
	title = choice.text
	link = "https://www.ted.com" + choice['href']
	return { :name => "TED Talks", :title => title, :link => link }
end

def nytimes
	data = scrape_data("https://www.nytimes.com/section/health")
	titles = data.css('.stream a.story-link')
	choice = titles[rand(titles.length)]
	title = choice.css('h2').text
	link = choice['href']
	return { :name => "NY Times", :title => title, :link => link }
end

def atlantic
	data = scrape_data("https://www.theatlantic.com/health")
	titles = data.css('li.article.blog-article > a')
	choice = titles[rand(titles.length)]
	title = choice.css('h2').text
	link = "https://www.theatlantic.com" + choice['href']
	return { :name => "The Atlantic", :title => title, :link => link }
end

def nautilus
	data = scrape_data("http://nautil.us/term/f/Health")
	titles = data.css('.article-title a')
	choice = titles[rand(titles.length)]
	title = choice.text
	link = "http://nautil.us" + choice['href']
	return { :name => "Nautilus", :title => title, :link => link }
end

def aeon
	data = scrape_data("https://aeon.co/health?page=1")
	titles = data.search("entry")
	choice = titles[rand(titles.length)]
	title = choice.search('title')[0].children.text
	link = choice.search('link')[0].attributes["href"].value
	return { :name => "Aeon", :title => title, :link => link }
end

Strategies = [
	method(:r_health),
	method(:wikipedia),
	method(:care_cards),
	method(:ted_health),
	method(:nytimes),
	method(:atlantic),
	method(:nautilus),
	method(:aeon),
]

=begin
	POTENTIAL FUTURE STRATEGIES:
	RSS feed from publications with health verticals
	podcasts
	JAMA
	'other health related subreddits' list on
=end

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/generate.json' do
  content_type :json
  return Strategies.sample.call.to_json
end
