require "yaml"
require "../spec_helper"
require "../../src/schema"

describe Initializr::Schema::Package do
  let(pkg) { MockPackageManager.new }
  let(runner) { MockRunner.new }
  let(app) { Initializr::Context.new(runner, MockManagersList.new(pkg)) }
  let(ctx) { Initializr::Schema::Script.new app, packageManager: "test" }
  let(name) { "my-package" }

  let(fixtures) { YAML.parse(File.open("#{{{ __DIR__ }}}/fixtures.yml"))["packages"] }

  describe "#read" do
    subject! { Initializr::Schema::Package.new app, name }
    context "when is valid input" do
      it "parses without errors" do
        fixtures["good"].each do |node|
          expect { subject.read node.raw }.not_to raise_error(Exception)
        end
      end
    end

    context "when is invalid input" do
      it "throws errors" do
        fixtures["bad"].each do |node|
          expect { subject.read node.raw }.to raise_error(Exception)
        end
      end
    end
  end

  subject {
    pkg = Initializr::Schema::Package.new app, name
    pkg.read fixtures["good"][0].raw
  }
  let(config) { ["echo \"hello\""] }
  it "can be installed" do
    subject.mark_install(ctx)
    expect(pkg.install_list).to eq(["wget", "curl"])
    expect(pkg.dependency_list).to eq(["python3", "ruby"])
    expect(pkg.should_update).to be_true
    expect(runner.preconfigs).to eq(config)
    expect(runner.configs).to eq(config)
  end
end
