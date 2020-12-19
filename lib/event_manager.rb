require "csv"
require "google/apis/civicinfo_v2"
require "erb"

def clean_zipcode(zipcode)
  zipcode = zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone_number(phone_number)
  #Delete all non digit characters form phone number
  phone_number = phone_number.delete("^0-9")

  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11 && phone_number.match?(/1.../, 0)
    phone_number.delete_prefix("1")
  else
    "Incorrect phone number"
  end
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

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exist? "output"

  file_name = "output/thanks_#{id}.html"

  File.open(file_name, "w") do |file|
    file.puts form_letter
  end
end


contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_latter = File.read "form_letter.erb"
erb_letter_template = ERB.new template_latter

contents.each do |row|
  id = row[0]
  first_name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = row[:homephone]
  legislators = legislators_by_zipcode(zipcode)
  clean_phone_number = clean_phone_number(phone)

  form_letter = erb_letter_template.result(binding)

  save_thank_you_letter(id, form_letter)

  puts clean_phone_number
  #puts form_letter
  
  #puts "#{first_name}(#{zipcode}) : #{legislators}"
end


