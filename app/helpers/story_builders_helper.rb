module StoryBuildersHelper
  def ai_text_parser(text)
    scanner = StringScanner.new
    words = []
    
    while scanner.scan_until(/\{\{([^{}]+)\}\}/)
      word = scanner[1]

      words << word
    end

    words
  end
end
