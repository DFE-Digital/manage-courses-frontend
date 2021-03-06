class User < Base
  include AASM

  has_many :organisation_users
  has_many :organisations, through: :organisation_users

  custom_endpoint :accept_terms, on: :member, request_method: :patch

  def self.member(id)
    new(id: id)
  end

  aasm whiny_transitions: false do
    state :new, initial: true
    state :transitioned
    state :rolled_over
    state :accepted_rollover_2021
    state :notifications_configured

    event :accept_transition_screen do
      transitions from: :new, to: :transitioned
    end
  end

  def next_state
    aasm.states(permitted: true)
        .map(&:name)
        .first
  end

  # We need to over-write `aasm_read_state` and `aasm_write_state`
  # as we are not using a database.
  def aasm_read_state(_name = :default)
    state.try(:to_sym).presence || self.class.aasm.initial_state
  end

  def aasm_write_state(new_state, _name = :default)
    update(state: new_state.to_s)
  end

  # It's possible that user state may be nil.
  # See https://github.com/DFE-Digital/teacher-training-api/pull/1427
  # If so we need to set a default state
  def aasm_ensure_initial_state
    self.aasm_state = :new
  end

  def self.generate_and_send_magic_link(email)
    MagicLink::GenerateAndSendService.call(email: email, site: site)
  end

  def accepted_terms?
    accept_terms_date_utc.present?
  end
end
