require 'base64'

class Module
  # lifted from Rails
  def delegate(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end

    methods.each do |method|
      module_eval(<<-EOS, "(__DELEGATION__)", 1)
        def #{method}(*args, &block)
          #{to}.__send__(#{method.inspect}, *args, &block)
        end
      EOS
    end
  end
end

module AckInProject
  module Environment
    class << self
      attr_accessor :bundle_support, :ack
    
      def load_environment
        %w{ui exit_codes}.each { |lib| require textmate_lib_file(lib) }
        
        self.bundle_support = File.expand_path(ENV['TM_BUNDLE_SUPPORT'])
        self.ack = (ENV['TM_ACK'] || support_file('ack-standalone.sh'))
      end

      def ghetto_include(to_include, target_binding)
        [*to_include].each do |lib|
          lib_file = textmate_lib_file(lib + '.rb')
          eval(IO.read(lib_file), target_binding, lib_file)
        end
      end

      def textmate_lib_file(called)
        "%s/lib/%s" % [ENV['TM_SUPPORT_PATH'], called]
      end

      def support_file(*elements)
        File.join(bundle_support, *elements)
      end

      def lib_file(filename)
        support_file('lib', filename)
      end
      
      def nib_file(filename)
        support_file('nibs', filename)
      end
      
      def search_directory
        @search_directory ||= guess_search_directory()
      end
      
      def file_in_search_directory(file)
        File.expand_path(File.join(search_directory, file))
      end
      
      def searched_in
        @searched_in ||= search_directory.gsub(/^#{project_directory}/, File.basename(project_directory))
      end
      
      def project_directory
        ENV['TM_PROJECT_DIRECTORY']
      end
      
      protected

      def guess_search_directory
        directory = ENV['TM_SELECTED_FILE'] || project_directory || 
                    ( ENV['TM_FILEPATH'] && File.dirname(ENV['TM_FILEPATH']) )
        File.file?(directory) ? project_directory : directory
      end
    end
    
    delegate :bundle_support, :ack, :support_file, :lib_file, :nib_file, :project_directory, 
      :search_directory, :file_in_search_directory, :searched_in, :to => '::AckInProject::Environment'
  end

  class << self
    include Environment
    AckInProject::Environment.ghetto_include %w(escape), binding
    
    def show_search_dialog(&block)
      require lib_file('search_dialog')
      AckInProject::SearchDialog.new.show(&block)
    end

    def present_search(plist)
      require lib_file('search_results')
      require lib_file('search')
      AckInProject::SearchResults.new(plist).show
    end
    
    # sigh... defaults is giving me grief when searches contain quotes
    def search_history
      unless @search_history
        history_command = "defaults read com.macromates.textmate ackHistory 2>/dev/null"
        @search_history = OSX::PropertyList::load(Base64.decode64(%x{#{history_command}}))
      end
      @search_history
    rescue
      @search_history = [] # oh the humanity!
    end
    
    def update_search_history(search)
      search_history.unshift(search)
      search_history.uniq!
      search_history.compact!
      search_history.replace search_history[0..9]

      history = Base64.encode64(search_history.to_plist)

      history_command = %Q|defaults write com.macromates.textmate ackHistory -string #{e_sh history} 2>/dev/null|
      %x{#{history_command}}
    rescue
    end
    
    def pbfind
      @pbfind ||= %x[pbpaste -pboard find]
    end
    
    def update_pbfind(search)
      @pbfind = search
      IO.popen('pbcopy -pboard find', 'w') {|pbcopy| pbcopy.write @pbfind}
    end
    
  end
end

AckInProject::Environment.load_environment
