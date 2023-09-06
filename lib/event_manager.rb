require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone_number)
  phone_number = phone_number.to_s.gsub(/\D/, '')
  if phone_number.length == 10
    phone_number
  elsif phone_number.length > 10 && phone_number[0] == "1"
    phone_number = phone_number[1..9]
  else
    phone_number = "Number invalid"
  end
  return phone_number
end

def peak_hours(reg_date)
  # Parses string to time
  reg_date =  DateTime.strptime(reg_date,"%m/%d/%y %k:%M")
  #Display how we want it
  reg_date = reg_date.strftime("%I %p") 
  #sign_time.strftime("%I:%M %p")  
end

def peak_day(reg_day)
    # Parses string to time
    reg_day =  DateTime.strptime(reg_day,"%m/%d/%y %k:%M")
    #Display how we want it
    reg_day = reg_day.wday
    #sign_time.strftime("%I:%M %p")  
    if reg_day == 0
        reg_day = "Sunday"
       elsif reg_day == 1
        reg_day = "Monday"
        elsif reg_day == 2
          reg_day = "Tuesday"
        elsif reg_day == 3
          reg_day = "Wednesday"
        elsif reg_day == 4
          reg_day = "Thursday"
        elsif reg_day == 5
          reg_day = "Friday"
        elsif reg_day == 6
          reg_day = "Saturday"
      end
  end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
array = []
day_array = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  phone_number = clean_phone_number(row[:homephone])

  # Handles most popular time
  reg_date = peak_hours(row[:regdate])
  array.push(reg_date)

  #most popular day
  reg_day = peak_day(row[:regdate])
  day_array.push(reg_day)

  puts "#{name} #{reg_day}"
end

def count_day(day_array)
    day_hash = day_array.tally
    day_hash.each { |k, v| puts "Most sign ups on: #{k}" if v == day_hash.values.max }
end
count_day(day_array)


def count_sign_ups(array)
    hash = array.tally
    hash.each { |k, v| puts "Most sign ups around: #{k}" if v == hash.values.max }

end 
count_sign_ups(array)