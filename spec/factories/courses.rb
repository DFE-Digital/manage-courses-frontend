FactoryBot.define do
  factory :course, class: Hash do
    transient do
      relationships { %i[site_statuses provider accrediting_provider] }
      include_nulls { [] }
    end

    sequence(:id)
    sequence(:course_code) { |n| "X10#{n}" }
    name { "English" }
    description { "PGCE with QTS" }
    findable? { true }
    open_for_applications? { false }
    has_vacancies? { false }
    site_statuses { [] }
    provider      { nil }
    study_mode    { 'full_time' }
    content_status { "published" }
    ucas_status { 'running' }
    accrediting_provider { nil }
    qualifications { %w[qts pcge] }
    start_date     { Time.new(2019) }
    funding        { 'fee' }

    trait :with_vacancy do
      has_vacancies? { true }
    end

    trait :with_full_time_or_part_time_vacancy do
      with_vacancy
      full_time_or_part_time
    end

    trait :with_full_time_vacancy do
      with_vacancy
      full_time
    end

    trait :with_part_time_vacancy do
      with_vacancy
      part_time
    end

    trait :full_time_or_part_time do
      study_mode { 'full_time_or_part_time' }
    end

    trait :full_time do
      study_mode { 'full_time' }
    end

    trait :part_time do
      study_mode { 'part_time' }
    end

    after :initialize do |course|
      course.provider_code = provider.provider_code if course.provider
    end

    initialize_with do |_evaluator|
      data_attributes = attributes.except(:id, *relationships)
      relationships_map = Hash[
        relationships.map do |relationship|
          [relationship, __send__(relationship)]
        end
      ]

      JSONAPIMockSerializable.new(
        id,
        'courses',
        attributes: data_attributes,
        relationships: relationships_map,
        include_nulls: include_nulls
      )
    end
  end
end
