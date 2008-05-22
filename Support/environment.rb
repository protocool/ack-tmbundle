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
        self.ack = (ENV['TM_ACK'] || 'ack')
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
    
    delegate :bundle_support, :ack, :support_file, :lib_file, :nib_file, 
      :search_directory, :file_in_search_directory, :searched_in, :to => '::AckInProject::Environment'
  end

  class << self
    include Environment
    
    def show_search_dialog(&block)
      require lib_file('search_dialog')
      AckInProject::SearchDialog.new.show(&block)
    end

    def present_search(plist)
      require lib_file('search_results')
      require lib_file('search')
      AckInProject::SearchResults.new(plist).show
    end
  end
end

AckInProject::Environment.load_environment
