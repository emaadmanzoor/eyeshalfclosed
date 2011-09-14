class PandocFilter < Nanoc3::Filter
  
  # Runs the content through [Pandoc][http://johnmacfarlane.net/pandoc/]
  # via [pandoc-ruby][http://rdoc.info/github/alphabetum/pandoc-ruby]
  # to render mathematical symbols in the Markdown content

  identifier :pandoc
  
  def run(content, params={})
    require 'pandoc-ruby'
    @pandoc_options = params[:options].map { |option| option.to_sym }
    PandocRuby.new(content, *@pandoc_options).to_html
  end
end
