require "csv"
require "google/apis/civicinfo_v2"
require "erb"

def clean_zipcode(zipcode)
  zipcode = zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    legislators = civic_info.representative_info_by_address(
                                address: zipcode,
                                levels: "country",
                                roles: ["legislatorUpperBody", "legislatorLowerBody"]
                              ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end


contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_latter = File.read "form_letter.erb"
erb_letter_template = ERB.new template_latter

contents.each do |row|
  first_name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_letter_template.result(binding)

  puts form_letter
  
  #puts "#{first_name}(#{zipcode}) : #{legislators}"
end


