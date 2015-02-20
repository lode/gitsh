require 'spec_helper'
require 'gitsh/commands/git_command'

describe Gitsh::Commands::GitCommand do
  describe '#execute' do
    it 'delegates to the Gitsh::ShellCommandRunner' do
      env = double(:env, git_command: '/usr/bin/env git', config_variables: {})
      expected_result = double(:result)
      mock_runner = double(:shell_command_runner, run: expected_result)
      allow(Gitsh::ShellCommandRunner).to receive(:new).and_return(mock_runner)

      command = described_class.new(env, "commit", arguments("-m", "Some stuff"))
      result = command.execute

      expect(Gitsh::ShellCommandRunner).to have_received(:new).with(
        ["/usr/bin/env", "git", "commit", "-m", "Some stuff"],
        env,
      )
      expect(mock_runner).to have_received(:run)
      expect(result).to eq expected_result
    end

    it 'passes on configuration variables from the environment' do
      mock_runner = double(:shell_command_runner, run: true)
      allow(Gitsh::ShellCommandRunner).to receive(:new).and_return(mock_runner)
      env = double(
        :env,
        git_command: '/usr/bin/env git',
        config_variables: {
          :'test.example' => 'This is an example',
          :'foo.bar' => '1',
        },
      )
      command = described_class.new(
        env,
        'commit',
        arguments('-m', 'A test commit'),
      )

      command.execute

      expect(Gitsh::ShellCommandRunner).to have_received(:new).with(
        [
          '/usr/bin/env', 'git',
          '-c', 'test.example=This is an example',
          '-c', 'foo.bar=1',
          'commit',
          '-m', 'A test commit',
        ],
        env,
      )
    end
  end
end
