#!/usr/bin/env ruby

require "nokogiri"
require "open-uri"
require "CSV"

# Uncomment the feeds you are interested in
WRR_FEEDS = [
  #"https://weworkremotely.com/remote-jobs.rss", # All Jobs
  #"https://weworkremotely.com/categories/remote-customer-support-jobs.rss", # Customer Support
  #"https://weworkremotely.com/categories/remote-product-jobs.rss", # Product Jobs
  #"https://weworkremotely.com/categories/remote-full-stack-programming-jobs.rss", # Full-Stack Programming
  "https://weworkremotely.com/categories/remote-back-end-programming-jobs.rss", # Back-End Programming
  #"https://weworkremotely.com/categories/remote-front-end-programming-jobs.rss", # Front-End Programming
  #"https://weworkremotely.com/categories/remote-programming-jobs.rss", # All Programming
  #"https://weworkremotely.com/categories/remote-sales-and-marketing-jobs.rss", # Sales and Marketing
  #"https://weworkremotely.com/categories/remote-management-finance-jobs.rss", # Management and Finance
  #"https://weworkremotely.com/categories/remote-design-jobs.rss", # Design
  "https://weworkremotely.com/categories/remote-devops-sysadmin-jobs.rss", # Devops and System Admin
  #"https://weworkremotely.com/categories/all-other-remote-jobs.rss", # All other
]

# Since a job can occur in multiple feeds (ex All Programming and Back-End
# Programming), this approach ensures we are only returning each job once
job_listings = {}

# Parse the feeds
WRR_FEEDS.each do |feed_url|
  puts "Parsing #{feed_url}"
  URI.open(feed_url) do |feed_data|
    # Why Nokogiri? Because I can easily get the tags that aren't in the RSS spec.
    doc = Nokogiri::XML(feed_data)
    doc.xpath("/rss/channel/item").each do |item|
      guid = item.xpath("guid").text
      next unless job_listings[guid].nil? # Only parse this job once.

      job_listings[guid] = {
        title: item.xpath("title").text,
        category: item.xpath("category").text,
        type: item.xpath("type").text,
        region: item.xpath("region").text,
        posted_on: DateTime.parse(item.xpath("pubDate").text).strftime("%Y-%m-%d"),
        link: item.xpath("link").text,
      }
    end
  end
end

puts "Saving CSV"

# Make it an array now
job_listings = job_listings.values

# Sort the items
job_listings.sort_by!{ |h| h[:pub_date] }

# Save as a CSV
csv_filename = "we_work_remotely_jobs_#{Time.now.strftime("%Y%m%d%H%M%S")}.csv"

CSV.open(csv_filename, "wb") do |csv|
  csv << job_listings.first.keys # adds the attributes name on the first line
  job_listings.each do |job|
    csv << job.values
  end
end

puts "CSV Created: #{csv_filename}"