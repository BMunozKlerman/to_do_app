# To-Do App

A modern, feature-rich to-do application built with Ruby on Rails 8, featuring real-time updates, AI-powered duration estimation, and a responsive design.

## Features

### Core Functionality
- **Task Management**: Create, edit, and manage to-do items with due dates
- **User Management**: Assign tasks to users and track who created them
- **Status Tracking**: Mark tasks as pending or completed with checkbox toggles
- **Comments System**: Add comments to tasks with real-time updates
- **Follower System**: Follow tasks to stay updated on changes
- **AI Duration Estimation**: Get AI-powered time estimates for tasks using Google Gemini

### User Interface
- **Card-based Layout**: Organized sections for pending and completed tasks
- **Collapsible Sections**: Completed tasks can be collapsed/expanded
- **Real-time Updates**: Live updates across multiple browser tabs
- **Modern UI**: Clean, intuitive interface with Tailwind CSS

### Technical Features
- **Token-based URLs**: Secure, non-sequential URLs for all resources
- **Real-time Communication**: WebSocket support via ActionCable
- **Component Architecture**: Reusable ViewComponents for maintainable code
- **Comprehensive Testing**: Full test coverage with RSpec, FactoryBot, and Faker

## Tech Stack

- **Backend**: Ruby on Rails 8.0.2
- **Database**: PostgreSQL
- **Frontend**: Tailwind CSS, Stimulus.js, Hotwire/Turbo
- **Templating**: Slim
- **Testing**: RSpec, FactoryBot, Capybara, Faker
- **AI Integration**: Google Gemini API
- **Deployment**: Docker, Railway

## Prerequisites

- Ruby 3.4.5
- PostgreSQL 9.3+
- Node.js 22.17.1
- npm

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd to_do_app
   ```

2. **Install dependencies**
   ```bash
   bundle install
   npm install
   ```

3. **Set up environment variables**
   Create a `.env` file in the root directory:
   ```bash
   DATABASE_USERNAME=your_postgres_username
   DATABASE_PASSWORD=your_postgres_password
   DATABASE_HOST=localhost
   DATABASE_PORT=5432
   GEMINI_API_KEY=your_gemini_api_key
   ```

4. **Set up the database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

5. **Start the application**
   ```bash
   rails server
   ```

   The app will be available at `http://localhost:3000`

## Database Schema

### Users
- `name` (string): User's display name
- `token` (uuid): Unique identifier for URLs

### ToDoItems
- `name` (string): Task title
- `description` (text): Task description
- `status` (string): "pending" or "completed"
- `due_date` (date): When the task is due
- `estimated_duration` (string): AI-estimated time to complete
- `followers` (jsonb): Array of user IDs following this task
- `token` (uuid): Unique identifier for URLs
- `assigned_to_id` (foreign key): User assigned to the task
- `created_by_id` (foreign key): User who created the task

### Comments
- `text` (text): Comment content
- `token` (uuid): Unique identifier for URLs
- `to_do_item_id` (foreign key): Associated task
- `user_id` (foreign key): Comment author

## API Integration

### Google Gemini AI
The app integrates with Google Gemini API for task duration estimation:
- Service: `DurationEstimationService`
- Configuration: Set `GEMINI_API_KEY` environment variable
- Usage: Click "Estimate Duration" button on task details page

## Testing

Run the test suite:
```bash
# All tests
bundle exec rspec

# Specific test types
bundle exec rspec spec/models/     # Model tests
bundle exec rspec spec/controllers/ # Controller tests
bundle exec rspec spec/components/  # Component tests
bundle exec rspec spec/services/   # Service tests
```

## Deployment

### Docker
The app includes a production-ready Dockerfile:

```bash
# Build the image
docker build -t to_do_app .

# Run the container
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=<your_master_key> \
  -e DATABASE_URL=<your_database_url> \
  -e GEMINI_API_KEY=<your_gemini_key> \
  --name to_do_app to_do_app
```

### Railway
The app is configured for deployment on Railway:
- Automatic database seeding on first deployment
- Environment variable configuration
- Production-ready Docker setup

## Development

### Code Quality
- **Linting**: RuboCop for Ruby code style
- **Testing**: Comprehensive test coverage with RSpec
- **Components**: Reusable ViewComponents for UI elements

### Key Directories
- `app/components/`: Reusable UI components
- `app/services/`: Business logic services
- `app/models/`: Data models
- `app/controllers/`: Request handling
- `spec/`: Test files
