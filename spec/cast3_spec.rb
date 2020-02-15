require "rails"
require "active_record"
require "logger"

# EXAMPLE WITHOUT KSUID WORKS

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(IO::NULL)
ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define do
  create_table :physicians, force: true do |t|
    t.string :name
  end

  create_table :appointments, force: true do |t|
    t.integer :physician_id
    t.integer :patient_id
  end

  create_table :patients, force: true do |t|
    t.string :name
  end
end

class Physician < ActiveRecord::Base
  has_many :foobar, class_name: "Appointment"
  has_many :patients, through: :foobar
end

class Appointment < ActiveRecord::Base
  belongs_to :physician
  belongs_to :patient
end

class Patient < ActiveRecord::Base
  has_many :foobar, class_name: "Appointment" # <---- using class_name here
  has_many :physicians, through: :foobar
end

ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)

RSpec.describe "ActiveRecord integration" do
  it "loads all associations correctly" do
    patient = Patient.create!(name: "Will")
    physician = Physician.create!(name: "Dr. Bob")
    appointment = Appointment.create!(patient_id: patient.id, physician_id: physician.id)

    expect(patient.foobar.first).to eq(appointment)
    expect(physician.foobar.first).to eq(appointment)

    expect(patient.physicians.first).to eq(physician) # <----- works
    expect(physician.patients.first).to eq(patient)   # <----- works
  end
end
