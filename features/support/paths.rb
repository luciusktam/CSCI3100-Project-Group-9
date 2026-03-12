module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in homepage_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /the community page/
      '/community'
    when /the chat page/
      '/chat'
    when /the sell page/
      '/sell'
    when /the profile page/
      '/profile'
    when /the login page/
      '/login'
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" \
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end