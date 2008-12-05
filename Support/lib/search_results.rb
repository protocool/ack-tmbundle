class AckInProject::SearchResults
  include AckInProject::Environment
  AckInProject::Environment.ghetto_include %w(web_preview escape), binding

  attr_accessor :plist
  
  def initialize(plist)
    self.plist = plist
  end

  def show
    puts html_head(
      :window_title => title,
      :page_title   => title,
      :html_head    => header_extra()
    )
    puts <<-HTML
      <h2>Searching for “#{ h search_string }” in #{ searched_in }</h2>
      <div id="counters"><span id="linecount">0 lines</span> matched in <span id="filecount">0 files</span></div>
      <script type="text/javascript">searchStarted();</script>
      <table id="results" width="100%" cellspacing="0">
    HTML

    AckInProject::Search.new(plist).search

    puts <<-HTML
      </table>
      <script type="text/javascript">searchCompleted();</script>
    HTML
    html_footer
  end
  
  def title 
    "Ack in Project"
  end
  
  def header_extra
    <<-HTML
      <link type="text/css" rel="stylesheet" href="file://#{e_url support_file('search.css')}" />
      <script type="text/javascript" src="file://#{e_url support_file('search.js')}" charset="utf-8"></script>
    HTML
  end
  
  def search_string
    plist['result']['returnArgument']
  end
  
  def h(string)
    CGI.escapeHTML(string)
  end
end