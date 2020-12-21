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

def hour_of_the_day_when_user_registered(registration_date_time)
  #create ruby date time object
  registration_date_time_object = DateTime.strptime(registration_date_time, "%m/%d/%y %H:%M")

  #format date time object(There are no use case for this now may be use it later)
  #registration_date_time = registration_date_time.strftime("%Y,%m,%d,%k,%M,%S")

  #find the hour of the day when user register
  registration_hour = registration_date_time_object.hour
end

def day_of_the_week_when_user_registered(registration_date_time)
  registration_date_time_object = DateTime.strptime(registration_date_time, "%m/%d/%y %H:%M")

  registration_day = registration_date_time_object.day
end

#save the user matrics like when most user registered in a specific hour of a day and day of a week
def save_user_matrics(user_matrics)
  Dir.mkdir("output_admin") unless Dir.exist? "output_admin"

  File.open("output_admin/user_matrics.html", "w") do |file|
    file.puts user_matrics
  end
end


def no_of_user_registered_in_a_specific_hour(registration_hours)
  template_user_matrics = File.read "user_matrics.erb"
  template_user_matrics_erb_object = ERB.new template_user_matrics

  user_matrics = template_user_matrics_erb_object.result(binding)
  save_user_matrics(user_matrics)
end




contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_latter = File.read "form_letter.erb"
template_latter_erb_object = ERB.new template_latter

#array for storing the hours in a day when user register
registration_hours = Array.new
#array for storing the days of the week when user register
registration_days = Array.new

contents.each do |row|
  id = row[0]
  first_name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = row[:homephone]
  
  #insert registration_hour in registration_hours array when user registered
  registration_hours << hour_of_the_day_when_user_registered(row[:regdate])
  #insert registration_days in registraion_day array when user registered
  registration_days << day_of_the_week_when_user_registered(row[:regdate])

  
  legislators = legislators_by_zipcode(zipcode)
  phone_number = clean_phone_number(phone)

  form_letter = template_latter_erb_object.result(binding)
  save_thank_you_letter(id, form_letter)
end


no_of_user_registered_in_a_specific_hour(registration_hours)
