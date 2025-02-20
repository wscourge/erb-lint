# frozen_string_literal: true

require "spec_helper"
require "pry"

describe ERBLint::Reporters::JunitReporter do
  describe ".show" do
    subject { described_class.new(stats, false).show }

    let(:stats) do
      ERBLint::Stats.new(
        found: 2,
        processed_files: {
          "app/views/index.html.erb" => [],
          "app/views/subscriptions/_loader.html.erb" => offenses,
        },
        corrected: 1
      )
    end

    let(:offenses) do
      [
        instance_double(
          ERBLint::Offense,
          message: "Extra space detected where there should be no space.",
          line_number: 1,
          column: 7,
          simple_name: "SpaceInHtmlTag",
          last_line: 1,
          last_column: 9,
          length: 2,
        ),
        instance_double(
          ERBLint::Offense,
          message: "Remove newline before `%>` to match start of tag.",
          line_number: 52,
          column: 10,
          simple_name: "ClosingErbTagIndent",
          last_line: 54,
          last_column: 10,
          length: 10,
        ),
      ]
    end

    let(:expected_xml) do
      File.read(File.expand_path("./spec/erb_lint/fixtures/junit.xml"))
    end

    it "displays formatted offenses output" do
      expect { subject }.to(output(expected_xml).to_stdout)
    end
  end
end
