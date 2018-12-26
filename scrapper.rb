require 'nokogiri'
require 'httparty'
require 'byebug'
require 'ruby-progressbar'
require 'pg'





def scrapper 
   
    url = 'https://blockwork.cc/'
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page)
    job_listing = parsed_page.css("div.listingCard") # about 50 jobs
    jobs = Array.new

    page = 1
   
    per_page = job_listing.count #counter
    total = parsed_page.css("div.job-count").text.split(" ")[1].gsub(",","").to_i # total number of jobs listings
    last_page = (total.to_f / per_page.to_f).round 

    #setting up a progressbar
    progressbar = ProgressBar.create(:title => "progress", :total => last_page)



    while page <= last_page
        
        pagination_url = "https://blockwork.cc/listings?page=#{page}"
        pagination_unparsed_page = HTTParty.get(pagination_url)
        pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
        pagination_job_listing = pagination_parsed_page.css("div.listingCard")

        #iterating over the job listings
        pagination_job_listing.each do |job_l|
             job={
                title:job_l.css("span.job-title").text,
                company:job_l.css("span.company").text,
                location:job_l.css("span.location").text,
               url:"https://blockwork.cc"+job_l.css('a')[0].attributes["href"].value
             }
            jobs << job
            end
        page+=1
        progressbar.increment
    end
    return jobs
    #byebug     
end


def insert_data jobs_arr,db_connect
    db_connect.set_error_verbosity(PG::PQERRORS_VERBOSE)
    jobs_arr.each do |job|
        db_connect.exec("INSERT INTO public.jobs_table(job_title, company, location, url)VALUES (\'#{job[:title].gsub("'","''")}\',\'#{job[:company].gsub("'","''")}\',\'#{job[:location].gsub("'","''")}\',\'#{job[:url]}\');") do |result|
            puts result
        end
    end
end




arr_jobs = scrapper


db_connect = PG.connect(dbname: "ruby_scrapper_db",password: "ruby",user: "ruby_client")


insert_data(arr_jobs,db_connect)





