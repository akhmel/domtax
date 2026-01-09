namespace :fund_load_restrictions do
  task :seed_rules => :environment do
    puts "Seeding Fund Load Restrictions rules"
    #load seeds from lib/fund_load_restrictions/db/seeds.rb
    seed_file = Rails.root.join('lib', 'fund_load_restrictions', 'db', 'seeds.rb')
    if File.exist?(seed_file)
      require seed_file
      puts "Seed file loaded: #{seed_file}"
      puts "Seeded #{FundLoadRestrictions::VelocityLimitRule.count} rules"
      load seed_file
    else
      puts "Seed file not found: #{seed_file}"
    end
  end
end