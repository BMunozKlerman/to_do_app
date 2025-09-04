# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Create users
puts "Creating users..."
user_names = [
  'Alice Johnson', 'Bob Smith', 'Charlie Brown', 'Diana Prince',
  'Eve Wilson', 'Frank Miller', 'Grace Lee', 'Henry Davis', 'Ivy Chen'
]

users = user_names.map do |name|
  User.find_or_create_by!(name: name) do |user|
    puts "  ✓ Created user: #{name}"
  end
end

# Create to-do items
puts "Creating to-do items..."
task_data = [
  {
    name: "Design new landing page",
    description: "Create wireframes and mockups for the new company landing page with modern UI/UX principles.",
    due_date: 7.days.from_now,
    status: "pending"
  },
  {
    name: "Implement user authentication",
    description: "Set up secure login and registration system with JWT tokens and password encryption.",
    due_date: 14.days.from_now,
    status: "pending"
  },
  {
    name: "Optimize database queries",
    description: "Review and optimize slow database queries to improve application performance.",
    due_date: 5.days.from_now,
    status: "pending"
  },
  {
    name: "Write API documentation",
    description: "Create comprehensive API documentation with examples and endpoint descriptions.",
    due_date: 10.days.from_now,
    status: "completed"
  },
  {
    name: "Set up CI/CD pipeline",
    description: "Configure automated testing and deployment pipeline using GitHub Actions.",
    due_date: 21.days.from_now,
    status: "pending"
  },
  {
    name: "Conduct security audit",
    description: "Perform comprehensive security review and implement necessary security measures.",
    due_date: 3.days.from_now,
    status: "completed"
  }
]

task_data.each do |task_attrs|
  # Randomly assign users
  assigned_to = users.sample
  created_by = users.sample

  ToDoItem.find_or_create_by!(name: task_attrs[:name]) do |task|
    task.description = task_attrs[:description]
    task.due_date = task_attrs[:due_date]
    task.status = task_attrs[:status]
    task.assigned_to = assigned_to
    task.created_by = created_by

    # Add some random followers
    random_followers = users.sample(rand(0..3))
    task.followers = random_followers.map(&:id)

    puts "  ✓ Created task: #{task.name} (assigned to #{assigned_to.name})"
  end
end

puts "✅ Database seeded successfully!"
puts "   - #{User.count} users created"
puts "   - #{ToDoItem.count} to-do items created"
