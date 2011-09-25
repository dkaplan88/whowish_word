
if defined?(ActionView) and defined?(ActionView::Base)

  class ActionView::Base
    
    def whowish_word_javascript_and_css(force = false)
      
      return "" if @whowish_word_edit_mode != true and force == false
      
      script_text = <<-HTML
        <script type="text/javascript">
          $w(function() {
            $w.whowishWord();
          });
        </script>
      HTML
      
      return javascript_include_tag("/whowish_word.js") + \
              stylesheet_link_tag("/whowish_word.css") + \
              script_text.html_safe
    end

    def global_word_for(namespace, id, *variables)
      
      if @whowish_word_edit_mode == true
        return WhowishWord.word_for_in_edit_mode(namespace, id, *variables)
      else
        return WhowishWord.word_for(namespace, id, *variables)
      end
      
    end
    
    def global_word_for_attr(namespace, id, *variables)
      
      if @whowish_word_edit_mode == true
        return WhowishWord.word_for_attr_in_edit_mode(namespace, id, *variables)
      else
        return WhowishWord.word_for_attr(namespace, id, *variables)
      end
      
    end
  
    def word_for(id, *variables)
      
      namespace = get_relative_view_path(@whowish_word_page)
      global_word_for(namespace, id, *variables)
      
    end
    
    def word_for_attr(id, *variables)
      
      namespace = get_relative_view_path(@whowish_word_page)
      global_word_for_attr(namespace, id, *variables)
      
    end
    
    private
      def get_relative_view_path(full_path)
        result = @whowish_word_page.match(/[\/\\](([^\/\\]+)[\/\\]([^\/\\]+))\Z/)
        return result[1]
    end

  end

end