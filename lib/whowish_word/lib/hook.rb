require File.dirname(__FILE__)+"/../config"

paths = ["controllers","views","models/#{WHOWISH_WORD_DATABASE_ENGINE}"]

# load all controllers, helpers, and models
paths.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH.insert(0, path)
  ActiveSupport::Dependencies.autoload_paths.insert(0, path)
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

ActionController::Base.append_view_path(File.join(File.dirname(__FILE__), 'app', 'views'))

class ActionController::Base
  
  def choose_locale
    
    $locale = "en"
    $locale = session[:whowish_locale].downcase.strip if session[:whowish_locale]
    $locale = params[:whowish_locale].downcase.strip if params[:whowish_locale]
    
    session[:whowish_locale] = $locale
    
    logger.debug { "locale=#{$locale}"}
    
  end
  
end

class ActionView::Base
  
  @@whowish_word = {}
  
  def self.whowish_word
    @@whowish_word
  end

  def self.init_whowish_word

    words = WhowishWord.all() + WhowishWordEmail.all()
    
    @@whowish_word = {}
    words.each { |word|
      @@whowish_word[word.word_id] = word.content
    }
  end
  
  def self.whowish_word_for(page_id,id,*p)
    
    $locale = "en" if !$locale

    word_id = WhowishWord.generate_word_id(page_id,id,$locale)

    css = "cursor:pointer;\
          position:absolute;\
          left:0px;\
          top:-15px;\
          width:15px;\
          height:18px;";
          
    js_arg = []
    
    content = "##{page_id}:#{id}(#{$locale})".downcase
    if p.length > 0
      content_params = []
      p[0].each_pair { |key,val|
          content_params.push("#{key}: \"#{val}\"")
      }
      content += "{#{content_params.join(',')}}"
    end
    
      
    if @@whowish_word[word_id]
      
      content = "#{@@whowish_word[word_id]}"
      
     if p.length > 0
        p = p[0]

        p.each_pair { |key,val|
          content.gsub!("{#{key}}","#{val}")
          js_arg.push("\"#{key}\":\"#{val.to_s.gsub('"','\\"')}\"")
        }
      end
  
    end

    edit_icon = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAKDSURBVHjabJJLaJRXGIaf75z5J5M4TLxFF4GELLIUqsa6kNqAiyJ0odBVRUHBhfQmIgpSLzVIcFFcRKGblBYC2dh2RCjiptgGNCZBUTBVaRwTkpCQONO5/Zdz/v+48BLR+dbPw/vy8skv7e00PBESY8jE8f5sS8vBxNpDkTEFEVlBbl79o7GrFLZc3TR/4fxINF3IrV+3rpTW+mgURb86514xC/cHG8pKkFC80YWltm1PL/3M0o08q3M5VmUyl40x3wCIvf9Do1xw9vugdK/Pxydq/4on+VkeX+pHlhcHtE59CyDhvb5Gck9UfXo7qDxM2foUopuwXUcpTHUXlsf+3aS0VAEkmDj9nqfTcbh4xy+Ob3YuxARzpJs7sLVJW87u2hXkdv4tLnqF+mMn310JFwcX/eLdE4hgg3mUtxqcJaoXTokL+sXFK3h99LsV2bnPg8rk9cT+j0rliKNldHotUfXJrSSu9YIADiUWRYyURs+9qZsinHkUlW51Z1p7MP5zdLoN4z+v2XBhq4g8VsQIMcW4i1LcibwYH3iT24HSBS1lofIAbJ0kqRP5018L5koKQyXZwH/Bp8yZzRjXjPiPBtFaoZT6OFGZ0ZAsSADLt4mW/rqmXG1P6LJM+duZDrcSJDm0RAgJcu74AYrFIsDe3h0f/b77s0+QzBqU1/Rbafz04ZnSmuKzYDvluI3Ua+ntYANXfmJiYoJ8Pn8s8Os/9p85cm3fl1+ceTZbfjA7M0M5yqJIUBJ/+A3Dw8Pa87z1IyP/nG1qytDR2flna67VGms3au1pJUkCVAEH+EAFmAOmZWhoKA1s8TyvWymVM8ZsiJOkRaD5nZAQqL2Wl4BJYPzlAKO+L7lvWnFqAAAAAElFTkSuQmCC"
    
    return_data = ""
    if !$whowish_word_admin
      return_data = content
    elsif  id.to_s.match("default") or id.to_s.match("whowish_box_title")
      
      edit = "<span style='"+css+"' onclick=\"change_whowish_word(this,'#{word_id}',{},arguments[0] );return false;\"><img src='#{edit_icon}'/></span>"

      
      return_data = content.gsub("\"", "\"")+"\",({whowish_word_class:\"#{word_id}\",edit:\"" + edit.gsub('"', '\\"') + "\"}),\""
    else
      
      arg_id = "whowish_word_arg_" + word_id.gsub('.','_').gsub('/','__')
      
      edit = "<span style='"+css+"' onclick=\"change_whowish_word(this,'#{word_id}',{},arguments[0] );return false;\"><img src='#{edit_icon}'/></span>"

      
      return_data = "<span style='position:relative;'><span class='#{word_id}'>" + content + "</span>" + edit + "</span>"
    end
    
    return return_data.html_safe
    
  end
  
  def global_word_for(namespace, id, *p)
    ActionView::Base.whowish_word_for(namespace,id,*p)
  end

  def word_for(id, *p)
    page_id = @last_template.identifier.sub("#{Rails.root}/app/views/", '')
    ActionView::Base.whowish_word_for(page_id,id,*p)
  end
end

class ActionController::Base
  
  def word_for(namespace,id,*p)
     ActionView::Base.whowish_word_for(namespace,id,*p)
  end
  
  def self.word_for(namespace,id,*p)
     ActionView::Base.whowish_word_for(namespace,id,*p)
  end
 
  
end


module ActionView::Rendering 
  alias_method :_render_template_original, :_render_template
  def _render_template(template, layout = nil, options = {}) 
    @last_template = template
    _render_template_original(template, layout, options)
  end
end

module ActionView::Layouts
  alias_method :_render_layout_original, :_render_layout
  # Contains the logic that actually renders the layout.
    def _render_layout(layout, locals, &block) #:nodoc:
      @last_template = layout
      
      _render_layout_original(layout, locals, &block)
    end
end

module ActionView::Partials
  alias_method :_render_partial_original, :_render_partial

  def _render_partial(options, &block) #:nodoc:
    
    @last_template ||= nil
    
    previous_template = @last_template
    prefix = self.controller_path unless options[:partial].include?(?/)
    @last_template = self.find_template(options[:partial], prefix, true)
    
    html = _render_partial_original(options, &block)
    
    @last_template = previous_template
    
    return html
  end
  
end


# init all words
ActionView::Base.init_whowish_word

class ActionMailer::Base
  
  def word_for(id, *p)
    
    ActionView::Base.whowish_word_for(mailer_name + "/" + @template+".html.erb",id,*p)
  end
end