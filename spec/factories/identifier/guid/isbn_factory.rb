# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_guid_isbn, :class => 'Identifier::Global::Isbn', traits: [:housekeeping] do
  end
end
