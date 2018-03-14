require "yaml"
require "../spec_helper"
require "../../src/schema"

describe Initializr::Schema::Script do
  let(pkg) { MockPackageManager.new }
  let(runner) { MockRunner.new }
  let(app) { Initializr::Context.new(runner, MockManagersList.new(pkg)) }
  let(fixtures) { YAML.parse(File.open("#{{{ __DIR__ }}}/fixtures.yml"))["scripts"] }
  subject!(empty) { Initializr::Schema::Script.new app, packageManager: "test" }
  subject! {
    ctx = Initializr::Schema::Script.new app, packageManager: "test"
    ctx.read fixtures["good"].raw
  }

  describe "#read" do
    context "when is valid input" do
      it "parses without errors" do
        expect { empty.read fixtures["good"].raw }.not_to raise_error(Exception)
      end
    end

    context "when is invalid input" do
      it "throws errors" do
        fixtures["bad"].each do |node|
          expect { empty.read node.raw }.to raise_error(Exception)
        end
      end
    end
  end

  describe "#get_category" do
    let(name) { "my-category" }
    context "when category exists" do
      it "returns the same" do
        c = Initializr::Schema::Category.new name
        empty.categories << c
        expect(empty.get_category(name).hash).to eq(c.hash)
      end
    end
    context "when category does not exist" do
      it "creates a new one" do
        expect(empty.categories.empty?).to be_true
        c = empty.get_category(name)
        expect(empty.categories).to eq([c])
      end
    end
  end

  let(packages) { ["python", "mercurial"] }

  describe "#install" do
    it "can install packages" do
      single = packages[0..0]
      subject.install(single)
      expect(pkg.install_list).to eq(single)
    end

    it "can install categories" do
      subject.install(["default"])
      expect(pkg.install_list).to eq(packages)
    end

    it "can install both packages and categories" do
      subject.install([packages[0], "vcs"])
      expect(pkg.install_list).to eq(packages)
    end

    it "gets an error if not exist" do
      expect { subject.install(["bad"]) }.to raise_error(Exception)
    end
  end

  describe "#run" do
    let(deps) { ["git", "ssh"] }
    it "should run everything" do
      subject.install(["default"])
      subject.run

      # check mocks & clear
      expect(pkg.mock).to eq(deps + packages)
      expect(runner.mock.empty?).to be_true
      pkg.clear
      runner.clear
    end
  end
end
