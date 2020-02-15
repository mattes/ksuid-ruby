require "rails"
require "active_record"
require "logger"

require "ksuid/activerecord"
require "ksuid/activerecord/table_definition"
require "ksuid/activerecord/schema_statements"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(IO::NULL)
ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define do
  create_table :physicians, force: true, id: :ksuid do |t|
    t.string :name
  end

  create_table :appointments, force: true, id: :ksuid do |t|
    t.ksuid :physician_id
    t.ksuid :patient_id
  end

  create_table :patients, force: true, id: :ksuid do |t|
    t.string :name
  end

  create_table :problem_patients, force: true, id: :ksuid do |t|
    t.string :name
  end
end

class Physician < ActiveRecord::Base
  act_as_ksuid :id
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ActiveRecord::Base
  act_as_ksuids :id, :physician_id, :patient_id
  belongs_to :physician
  belongs_to :patient
end

class Patient < ActiveRecord::Base
  act_as_ksuid :id
  has_many :appointments
  has_many :physicians, through: :appointments
end

class ProblemPatient < ActiveRecord::Base
  act_as_ksuid :id
  has_many :critical_appointments, class_name: "Appointment"
  has_many :physicians, through: :critical_appointments
end

ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)

RSpec.describe "ActiveRecord integration" do
  it "loads all associations correctly" do
    patient = Patient.create!(name: "Will")
    physician = Physician.create!(name: "Dr. Bob")
    appointment = Appointment.create!(patient_id: patient.id, physician_id: physician.id)

    expect(patient.physicians.first).to eq(physician)
    expect(physician.patients.first).to eq(patient)
    expect(patient.appointments.first).to eq(appointment)
    expect(physician.appointments.first).to eq(appointment)
  end

  it "loads all associations correctly when class_name is used" do
    patient = ProblemPatient.create!(name: "Will")
    physician = Physician.create!(name: "Dr. Bob")
    appointment = Appointment.create!(patient_id: patient.id, physician_id: physician.id)

    expect(patient.physicians.first).to eq(physician)
    expect(physician.patients.first).to eq(patient)
    expect(patient.appointments.first).to eq(appointment)
    expect(physician.appointments.first).to eq(appointment)
  end
end