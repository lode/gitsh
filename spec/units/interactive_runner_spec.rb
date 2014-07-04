require 'spec_helper'
require 'gitsh/interactive_runner'

describe Gitsh::InteractiveRunner do
  describe '#run' do
    it 'loads the history' do
      runner = build_interactive_runner
      runner.run

      expect(history).to have_received(:load)
    end

    it 'saves the history' do
      runner = build_interactive_runner
      runner.run

      expect(history).to have_received(:save)
    end

    it 'sets up the line editor' do
      runner = build_interactive_runner
      runner.run

      expect(line_editor).to have_received(:completion_append_character=)
      expect(line_editor).to have_received(:completion_proc=)
    end

    it 'loads the ~/.gitshrc file' do
      runner = build_interactive_runner

      runner.run

      expect(script_runner).to have_received(:run).
        with("#{ENV['HOME']}/.gitshrc")
    end

    it 'handles a SIGINT' do
      runner = build_interactive_runner

      line_editor.stubs(:readline).
        returns('a').
        then.raises(Interrupt).
        then.returns('b').
        then.raises(SystemExit)

      begin
        runner.run
      rescue SystemExit
      end

      expect(interpreter).to have_received(:execute).twice
      expect(interpreter).to have_received(:execute).with('a')
      expect(interpreter).to have_received(:execute).with('b')
    end

    it 'handles a SIGWINCH' do
      line_editor = SignallingLineEditor.new('WINCH')
      line_editor.stubs(:set_screen_size)
      runner = build_interactive_runner(line_editor: line_editor)

      expect { runner.run }.not_to raise_exception
      expect(line_editor).to have_received(:set_screen_size).with(24, 80)
    end
  end

  def build_interactive_runner(options={})
    Gitsh::InteractiveRunner.new(
      interpreter: interpreter,
      line_editor: options.fetch(:line_editor, line_editor),
      history: history,
      env: env,
      term_info: term_info,
      script_runner: script_runner,
    )
  end

  def script_runner
    @script_runner ||= stub('script_runner', run: nil)
  end

  def interpreter
    @interpreter ||= stub('interpreter', execute: nil)
  end

  def history
    @history ||= stub('history', load: nil, save: nil)
  end

  def line_editor
    @line_editor ||= stub('LineEditor', {
      :'completion_append_character=' => nil,
      :'completion_proc=' => nil,
      readline: nil
    })
  end

  def env
    @env ||= stub('Environment', {
      print: nil,
      puts: nil,
      repo_initialized?: false,
      repo_config_color: '',
      fetch: '',
      :[] => nil
    })
  end

  def term_info
    stub('term_info', color_support?: true, lines: 24, cols: 80)
  end
end
