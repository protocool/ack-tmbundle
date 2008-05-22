class AckInProject::SearchDialog
  include AckInProject::Environment

  def show(params = {}, &block)
    raise ArgumentError, 'show_search_dialog requires a block' if block.nil?

    command = %Q{#{TM_DIALOG} -cm -p #{e_sh params.to_plist} -d #{e_sh defaults.to_plist} #{e_sh nib_file('AckInProjectSearch.nib')}}
    plist = OSX::PropertyList::load(%x{#{command}})
    if plist['result']
      block.call(plist)
    end
  end
  
  def defaults
    %w(ackMatchWholeWords ackIgnoreCase ackLiteralMatch ackShowContext ackFollowSymlinks).inject({}) do |hsh,v|
      hsh[v] = false
      hsh
    end
  end
end


