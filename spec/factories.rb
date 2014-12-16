FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :school do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:address) { |n| "#{n} Test Street"}
    website "www.test.edu"
    latitude "25"
    longitude "25"
  end

  factory :course do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:description) { |n| "Description #{n}"}
    department "Test"
    number "1"
    school
  end
end