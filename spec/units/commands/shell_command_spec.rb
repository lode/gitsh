require 'spec_helper'
require 'gitsh/commands/shell_command'

describe Gitsh::Commands::ShellCommand do
  describe '#execute' do
    it 'delegates to the Gitsh::ShellCommandRunner' do
      env = double(:env)
      expected_result = double(:result)
      mock_runner = double(:shell_command_runner, run: expected_result)
      allow(Gitsh::ShellCommandRunner).to receive(:new).and_return(mock_runner)

      command = described_class.new(env, "echo", arguments("Hello", "world"))
      result = command.execute

      expect(Gitsh::ShellCommandRunner).to have_received(:new).with(
        ["echo", "Hello", "world"],
        env,
      )
      expect(mock_runner).to have_received(:run)
      expect(result).to eq expected_result
    end
  end
end
