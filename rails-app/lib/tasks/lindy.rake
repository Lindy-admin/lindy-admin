namespace :lindy do
  desc "Adds people and registers them to courses"
  task seed: :environment do
    Course.all do |course|
      30.times do
        name = Faker::Name.name
        space = name.index(" ")
        firstname = name[0..space-1]
        lastname = name[space+1..-1]
        person = person.create({firstname: firstname, lastname: lastname, email: Faker::Internet.email, address: Faker::Address.street_address})

        registration = Registration.new
        registration.course = course
        registration.person = person
        registration.ticket = course.tickets.sample
        registration.role = [true, false].sample
        registration.save
      end
    end
  end

end
