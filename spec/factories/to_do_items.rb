# frozen_string_literal: true

FactoryBot.define do
  factory :to_do_item do
    name { Faker::Lorem.sentence(word_count: 3) }
    status { "pending" }
    due_date { Faker::Date.forward(days: 7) }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    token { SecureRandom.uuid }
    estimated_duration { nil }

    association :created_by, factory: :user
    association :assigned_to, factory: :user

    trait :completed do
      status { "completed" }
    end

    trait :overdue do
      due_date { 1.day.ago }
      status { "completed" } # Must be completed to bypass validation
    end

    trait :due_today do
      due_date { Date.current }
    end

    trait :due_tomorrow do
      due_date { 1.day.from_now }
    end

    trait :due_next_week do
      due_date { Faker::Date.forward(days: 7) }
    end

    trait :with_estimated_duration do
      estimated_duration { Faker::Number.between(from: 1, to: 8) }
    end

    trait :with_followers do
      after(:create) do |item|
        create_list(:user, Faker::Number.between(from: 1, to: 3)).each do |user|
          item.add_follower(user.id)
        end
      end
    end

    trait :with_comments do
      after(:create) do |item|
        create_list(:comment, Faker::Number.between(from: 1, to: 5), to_do_item: item)
      end
    end

    trait :urgent do
      name { "URGENT: #{Faker::Lorem.sentence(word_count: 2)}" }
      due_date { Faker::Time.between(from: Time.current, to: 1.day.from_now) }
    end

    trait :low_priority do
      name { "#{Faker::Lorem.sentence(word_count: 2)} (low priority)" }
      due_date { 2.weeks.from_now }
    end
  end
end
