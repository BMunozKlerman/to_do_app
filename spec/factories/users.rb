# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    token { SecureRandom.uuid }

    trait :with_todos do
      after(:create) do |user|
        create_list(:to_do_item, 3, created_by: user)
        create_list(:to_do_item, 2, assigned_to: user)
      end
    end

    trait :with_completed_todos do
      after(:create) do |user|
        create_list(:to_do_item, 2, :completed, created_by: user)
      end
    end

    trait :with_overdue_todos do
      after(:create) do |user|
        # Create completed todos first, then make them pending with past due dates
        todos = create_list(:to_do_item, 2, :completed, created_by: user)
        todos.each do |todo|
          todo.update!(status: 'pending', due_date: 1.day.ago)
        end
      end
    end
  end
end
