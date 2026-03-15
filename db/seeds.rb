# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.development? || Rails.env.test?
  admin_email = ENV["SEED_ADMIN_EMAIL"].to_s.strip.downcase
  admin_password = ENV["SEED_ADMIN_PASSWORD"]

  if admin_email.blank? || admin_password.blank?
    warn "Skipping admin seed: set SEED_ADMIN_EMAIL and SEED_ADMIN_PASSWORD in your .env to seed an admin account."
  elsif !admin_email.end_with?("@link.cuhk.edu.hk")
    warn "Skipping admin seed: SEED_ADMIN_EMAIL must end with @link.cuhk.edu.hk"
  else
    admin = User.find_or_initialize_by(email: admin_email)
    admin.assign_attributes(
      username: "admin",
      password: admin_password,
      password_confirmation: admin_password,
      role: :admin,
      email_verified: true,
      verified_at: Time.current
    )
    admin.save!
    puts "Admin account seeded: #{admin_email}"
  end
end
