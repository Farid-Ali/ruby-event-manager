require "csv"

def clean_zipcode(zipcode)
  zipcode = zipcode.to_s.rjust(5, "0")[0..4]
end

puts "Event Manager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

contents.each do |row|
  first_name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  puts "#{first_name} : #{zipcode}"
end


