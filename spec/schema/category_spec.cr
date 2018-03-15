require "../spec_helper"
require "../../src/schema"

describe Initializr::Schema::Category do
  let(mgr) { MockPackageManager.new }
  let(app) { Initializr::Context.new(MockRunner.new, MockManagersList.new(mgr)) }
  let(name) { "my-package" }
  let(unit) { Initializr::Schema::Installable.new app, name }
  let(pkg) { Initializr::Schema::Package.new app, name, install: [unit] }

  let!(ctx) { Initializr::Schema::Script.new app, packageManager: "test" }
  subject { Initializr::Schema::Category.new "my-category", packages: [name] }

  context "when package exists" do
    it "can be installed" do
      ctx.packages << pkg
      subject.mark_install ctx
      expect(mgr.install_list).to eq([name])
    end
  end

  context "when package does not exist" do
    it "cannot be installed" do
      subject.mark_install ctx
      expect(mgr.install_list.empty?).to be_true
    end
  end
end
