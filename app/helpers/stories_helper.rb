module StoriesHelper
  def render_ai_content_div
    content_tag(:div, "", { id: "aiContentDiv" })
  end

  def render_error_container
    content_tag(:div, "Please select an option to save response", { 
      class: "text-red-500 text-center mt-1 hidden",
      id: "errorText" 
    })    
  end

  def render_prompt_heading(text_content:)
    content_tag(
      :h5,
      text_content,
      class: "w-full mb-6"
    )
  end
end
