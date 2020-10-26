# frozen_string_literal: true

require "rails"
require "active_record"
require "logger"

# for postgres: RAILS_DATABASE="postgres://user:pw@localhost:5432/database"
ActiveRecord::Base.establish_connection(ENV.fetch("RAILS_DATABASE", "sqlite3::memory:"))
ActiveRecord::Base.logger = Logger.new(IO::NULL)
ActiveRecord::Schema.verbose = false

require "ksuid/activerecord"
require "ksuid/activerecord/table_definition"
require "ksuid/activerecord/connection_adapters"

ActiveRecord::Schema.define do
  begin
    # TODO make this nicer. only execute for postgres connections
    execute("CREATE DOMAIN ksuid AS text ")
  rescue
  end

  create_table :events, force: true do |t|
    t.ksuid :ksuid, index: true, unique: true
  end

  create_table :event_primary_keys, force: true, id: false do |t|
    t.ksuid :id, primary_key: true
  end

  create_table :event_multis, force: true, id: false do |t|
    t.ksuid :id, primary_key: true
    t.ksuid :foo
  end

  create_table :event_binaries, force: true do |t|
    t.ksuid_binary :ksuid, index: true, unique: true
  end

  create_table :patients, force: true, id: false do |t|
    t.ksuid :id, primary_key: true
    t.ksuid :foo
  end
end

# A demonstration model for testing KSUID::ActiveRecord
class Event < ActiveRecord::Base
  act_as_ksuid :ksuid
end

class EventMulti < ActiveRecord::Base
  act_as_ksuids :id, :foo
end

# A demonstration of KSUIDs as the primary key on a record
class EventPrimaryKey < ActiveRecord::Base
  act_as_ksuid # assumes :id
end

# A demonstration of KSUIDs persisted as binaries
class EventBinary < ActiveRecord::Base
  act_as_ksuid :ksuid, binary: true
end

# A demonstration of a model with reflected KSUID types
class Patient < ActiveRecord::Base
end

RSpec.describe "ActiveRecord integration" do
  context "with a non-primary field as the KSUID" do
    after { Event.delete_all }

    it "won't generate a KSUID upon initialization" do
      event = Event.new
      expect(event.ksuid).to be_nil
    end

    it "restores a KSUID from the database" do
      ksuid = Event.create!(ksuid: KSUID.new).ksuid
      event = Event.last

      expect(event.ksuid).to eq(ksuid)
    end

    it "allows multiple" do
      event = EventMulti.create!

      expect(event.id).to be_a(KSUID::Type)
      expect(event.id.to_s.size).to eq(27)
      expect(event.foo).to be_nil
    end

    it "can be looked up via a string, byte array, or KSUID" do
      id = KSUID.new
      event = Event.create!(ksuid: id)

      expect(Event.find_by(ksuid: id.to_s)).to eq(event)
      expect(Event.find_by(ksuid: id.to_bytes)).to eq(event)
      expect(Event.find_by(ksuid: id)).to eq(event)
    end
  end

  context "with a primary key field as the KSUID" do
    after { EventPrimaryKey.delete_all }

    it "generates a KSUID upon initialization" do
      event = EventPrimaryKey.new
      expect(event.id).to be_a(KSUID::Type)
      expect(event.id.to_s.size).to eq(27)
    end
  end

  context "with a binary KSUID field" do
    after { EventBinary.delete_all }

    it "persists the KSUID to the database" do
      event = EventBinary.create(ksuid: KSUID.new)
      expect(event.ksuid).to be_a(KSUID::Type)
    end
  end

  context "with reflected KSUID type" do
    after { Patient.delete_all }

    it "initializes a new record with a new KSUID" do
      p = Patient.new
      expect(p.id).to be_a(KSUID::Type)
      expect(p.id.to_s.size).to eq(27)

      # only initialize primary key
      expect(p.foo).to eq(nil)
    end

    it "doesn't initialize a new record with a new KSUID if KSUID is already given" do
      id = KSUID.new
      p = Patient.new(id: id)
      expect(p.id).to eq(id)
      expect(p.foo).to eq(nil)

      p2 = Patient.create(id: id)
      expect(p2.id).to eq(id)
      expect(p2.foo).to eq(nil)
    end

    it "doesn't initialize a persisted record" do
      p = Patient.create!
      p2 = Patient.find(p.id)
      expect(p2.persisted?).to be true
      expect(p2.id).to eq(p.id)
      expect(p2.foo).to eq(nil)
    end

    it "only initializes in after_initialize" do
      p = Patient.new
      p.id = nil
      expect { p.save }.to raise_exception ActiveRecord::NotNullViolation
    end

    it "can be looked up via a string, byte array, or KSUID" do
      id = KSUID.new
      patient = Patient.create!(id: id)

      expect(Patient.find_by(id: id.to_s)).to eq(patient)
      expect(Patient.find_by(id: id.to_bytes)).to eq(patient)
      expect(Patient.find_by(id: id)).to eq(patient)
    end
  end
end
