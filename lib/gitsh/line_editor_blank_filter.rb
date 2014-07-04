require 'gitsh/module_delegator'

class LineEditorBlankFilter < ModuleDelegator
  def readline(prompt, add_hist = false)
    module_delegator_target.readline(prompt, add_hist).tap do |result|
      if add_hist && result && result.strip.empty?
        module_delegator_target::HISTORY.pop
      end
    end
  end
end