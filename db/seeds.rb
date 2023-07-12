# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
# Uncomment the following to create an Admin user for Production in Jumpstart Pro
user = User.create(
  name: "Admin User",
  email: "admin@test.com",
  password: "admin123",
  password_confirmation: "admin123",
  terms_of_service: true
)
Jumpstart.grant_system_admin!(user)
