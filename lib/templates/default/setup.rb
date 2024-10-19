include YARD::Templates::Helpers::HtmlHelper

def init
  serializer.extension = "mdx"
  super
end

def param_component(tag)
  param_idx = object.parameters.to_h if object.respond_to?(:parameters)

  props = {}
  props[:name] = h(tag.name.to_s) unless @no_names
  props[:type] = format_types(tag.types, false) unless @no_types
  props[:default] = param_idx["#{tag.name}"] || param_idx["#{tag.name}:"] if param_idx
  props[:default] &&= h(props[:default])

  propstr = props.filter_map { |k, v| "#{k}=#{v.inspect}" if v }.join(" ")

  if propstr.empty?
    "#{resolve_links(tag.text).strip}\n"
  elsif props.key?(:type) && !props.key?(:name)
    "<Type name=#{props[:type].inspect} /> &mdash;\n#{resolve_links(tag.text.strip)}\n"
  elsif tag.text && !tag.text.empty?
    "<Param #{propstr}>\n#{indent(resolve_links(tag.text).strip)}\n</Param>\n"
  else
    "<Param #{propstr} />\n"
  end
end

def link_url(url, title = nil, params = {})
  title ||= url
  if title == url && url.match?(%r{://})
    url
  else
    "[#{title.strip}](#{url})"
  end
end

def icon_for(object)
  case object.type
  when :class
    object.is_exception? ? "bomb" : "cube"
  when :module
    "box-open"
  when :root
    "diagram-project"
  end
end

def erb_with(content, filename = nil)
  erb = ERB.new(content, trim_mode: '-')
  erb.filename = filename if filename
  erb
end

def indent(text, len = 2)
  text.strip!
  return "" if text.empty?
  text.gsub(/^/, " " * len)
end

def html_syntax_highlight(str)
  return str
end
