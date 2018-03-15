require "../spec_helper"
require "../../src/schema"

describe Initializr::Schema::Unit do
  let(pkg) { MockPackageManager.new }
  let(app) { Initializr::Context.new(MockRunner.new, MockManagersList.new(pkg)) }
  let(ctx) { Initializr::Schema::Script.new app, packageManager: "test" }
  let(name) { "system-pkg" }

  context "when manager is nil" do
    subject { Initializr::Schema::Unit.new app, name }

    it "can be installed" do
      subject.mark_install(ctx)
      expect(pkg.install_list).to eq([name])
    end
  end

  context "when manager is defined" do
    subject { Initializr::Schema::Unit.new app, name, "test" }

    it "can be installed" do
      subject.mark_install(ctx)
      expect(pkg.install_list).to eq([name])
    end
  end
end
