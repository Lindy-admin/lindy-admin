namespace :lindy do
  desc "Adds members and registers them to courses"
  task seed: :environment do
    Course.all.each do |course|
      print "seeding #{course.title}\n"
      30.times do
        name = Faker::Name.name
        space = name.index(" ")
        firstname = name[0..space-1]
        lastname = name[space+1..-1]

        member = Member.create!({firstname: firstname, lastname: lastname, email: Faker::Internet.email, address: Faker::Address.street_address})
        ticket = course.tickets.sample
        role = [true, false].sample

        course.register(member, {}, role, ticket)
      end
    end
    print "done\n"
  end

end
