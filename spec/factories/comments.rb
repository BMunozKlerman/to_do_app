# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    text { Faker::Lorem.paragraph(sentence_count: 1) }
    token { SecureRandom.uuid }

    association :to_do_item
    association :user

    trait :short do
      text { Faker::Lorem.sentence(word_count: 3) }
    end

    trait :long do
      text { Faker::Lorem.paragraph(sentence_count: 5) }
    end

    trait :question do
      text { "#{Faker::Lorem.sentence(word_count: 4)}?" }
    end

    trait :suggestion do
      text { "Suggestion: #{Faker::Lorem.sentence(word_count: 4)}" }
    end
  end
end
