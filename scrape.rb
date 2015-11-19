username = ENV['DOMINION_USERNAME']
password = ENV['DOMINION_PASSWORD']
abort 'DOMINION_USERNAME and DOMINION_PASSWORD environment variables required' if username.nil? || password.nil?

require 'selenium-webdriver'
require 'docsplit'
require 'date'

profile = Selenium::WebDriver::Firefox::Profile.new
profile['browser.download.dir'] = File.join(Dir.pwd, 'tmp')
profile['browser.download.folderList'] = 2
profile['browser.helperApps.neverAsk.saveToDisk'] = 'images/jpeg, application/pdf, application/octet-stream'
profile['pdfjs.disabled'] = true
driver = Selenium::WebDriver.for(:firefox, profile: profile)

wait = Selenium::WebDriver::Wait.new(timeout: 15)

driver.navigate.to 'https://www.dom.com/residential/dominion-virginia-power'
driver.find_element(:name, 'user').send_keys(username)
driver.find_element(:name, 'password').send_keys(password)
driver.find_element(:name, 'main_0$signin_0$signinButton').click

input = wait.until {
  element = driver.find_element(:xpath, "//span[@link-tracking-title='View Current Bill PDF']")
  element if element.displayed?
}
input.click

print 'Downloading bill..'
while !File.exists?(File.join(Dir.pwd, 'tmp', 'ShowBillImage')) do
  print '.'
  sleep 0.5
end
puts
sleep 2 # hack to ensure file is completely written to disk

puts 'Parsing bill...'
Docsplit.extract_text(File.join(Dir.pwd, 'tmp', 'ShowBillImage'), pdf_opts: '-raw', pages: 0..0, output: 'tmp')

pdf_text = File.open('tmp/ShowBillImage_0.txt', "rb").read
due_date = pdf_text.match(/Due Date: (.*)/)[1]
total_amount = pdf_text.match(/Payment Received\n\n(.*)/)[1]
total_kwh = pdf_text.match(/Total kWh\n\n(.*)/)[1]

driver.navigate.to 'https://mya.dom.com/Usage/ViewPastUsage'

translated_due_date = DateTime.strptime(due_date, '%b %d, %Y').strftime("%m/%d/%Y")

end_date = nil
start_date = nil
driver.find_elements(:xpath, "//table[@id='billingAndPaymentsTable']//tr").each do |row|
  if end_date == nil && row.find_elements(:xpath, "td[text()[contains(.,'#{translated_due_date}')]]").any?
    end_date = row.find_element(:xpath, "td[1]").text
    next
  end

  next_elements = row.find_elements(:xpath, "td[3]")
  if next_elements.any? && !next_elements.first.text.strip.empty?
    start_date = row.find_element(:xpath, "td[1]").text
    break
  end
end

driver.quit

puts
puts 'Billing information'
puts "Usage: #{total_kwh}kWh"
puts "Bill amount: $#{total_amount}"
puts "Service start date: #{start_date}"
puts "Service end date: #{end_date}"
puts "Bill due date: #{translated_due_date}"

`rm -rf tmp/` # cleanup
