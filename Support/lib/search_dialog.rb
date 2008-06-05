class AckInProject::SearchDialog
  include AckInProject::Environment
  AckInProject::Environment.ghetto_include %w(web_preview), binding
  
  def show(&block)
    raise ArgumentError, 'show_search_dialog requires a block' if block.nil?

    verify_project_directory or return
    
    command = %Q{#{TM_DIALOG} -cm -p #{e_sh params.to_plist} -d #{e_sh defaults.to_plist} #{e_sh nib_file('AckInProjectSearch.nib')}}
    plist = OSX::PropertyList::load(%x{#{command}})
    if plist['result']
      block.call(plist)
    end
  end
  
  def defaults
    %w(
      ackMatchWholeWords ackIgnoreCase ackLiteralMatch 
      ackShowContext ackFollowSymlinks ackLoadAckRC
    ).inject({}) do |hsh,v|
      hsh[v] = false
      hsh
    end
  end
  
  def params
    history = AckInProject.search_history
    {
      #'contentHeight' => 168,
      'ackExpression' => AckInProject.pbfind,
      'ackHistory' => history
    }
  end
  
  def verify_project_directory
    return true if project_directory
    
    puts <<-HTML
    <html><body>
      <h1>Can't determine project directory (TM_PROJECT_DIR)</h1>
    </body></html>
    HTML
  end
end


