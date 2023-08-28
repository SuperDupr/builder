# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
# Uncomment the following to create an Admin user for Production in Jumpstart Pro
# user = User.create(
#   name: "Admin User",
#   email: "admin@test.com",
#   password: "admin123",
#   password_confirmation: "admin123",
#   terms_of_service: true
# )
# Jumpstart.grant_system_admin!(user)

# Create Organizations
# organizations = []
# teams = []
# organization_names = ["Beyond Code", "Drifting Ruby", "Go Rails", "Railscasts", "Deanin", "Brad Traversy", "Level Up Coding", "WebCrunch", "Avdi Grimm", "Beyond Science"]
# team_names = ["Sales", "Marketing", "Admin", "HR", "Content Writing", "Development", "Design"]

# 10.times do |i|
#   organizations << Organization.create!(name: organization_names.sample)
# end

# puts "*** #{organizations.count} organizations created! ***"

# # Create teams
# organizations.each do |organization|
#   3.times { teams << organization.teams.create!(name: team_names.sample) }
# end

# puts "*** #{teams.count} teams created! ***"

story_builder = StoryBuilder.find_or_create_by(title: "Fichteen's Curve")
story_titles = ["Alpha Curse", "Egyptian Pyramids", "World War II"]

user = User.find_by_email("beyondcoding@example.com")

50.times do |i|
  Story.create(
    title: story_titles.sample,
    creator_id: user.id,
    story_builder_id: story_builder.id,
    account_id: user.accounts.first.id,
    private_access: [true, false].sample,
    viewable: [true, false].sample
  )
end
