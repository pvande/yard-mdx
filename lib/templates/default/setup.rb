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
  elsif props.key?(:type) && !props.key?(:name) && tag.text.strip.empty?
    "<Type name=#{props[:type].inspect} />\n"
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

def format_types(list, brackets = true)
  list.nil? || list.empty? ? "" : (brackets ? "(#{list.join(", ")})" : list.join(", "))
end

def format_block(object)
  if object.has_tag?(:yield) && object.tag(:yield).types
    params = object.tag(:yield).types
  elsif object.has_tag?(:yieldparam)
    params = object.tags(:yieldparam).map(&:name)
  elsif object.has_tag?(:yield)
    return "{ ... }"
  else
    params = nil
  end

  params && h("{|" + params.join(", ") + "| ... }")
end

def signature(meth, full_attr_name = true)
  meth = convert_method_to_overload(meth)

  type = signature_types(meth)
  type = "# => #{type}" if type && !type.empty?
  name = full_attr_name ? meth.name : meth.name.to_s.gsub(/^(\w+)=$/, '\1')
  blk = format_block(meth)
  args = !full_attr_name && meth.writer? ? "" : format_args(meth)
  ["#{h(name)}#{args}", blk, type].compact.join(" ")
end

def signature_types(meth, link = true)
  meth = convert_method_to_overload(meth)
  if meth.respond_to?(:object) && !meth.has_tag?(:return)
    meth = meth.object
  end

  type = options.default_return || ""
  if meth.tag(:return) && meth.tag(:return).types
    types = meth.tags(:return).map {|t| t.types ? t.types : [] }.flatten.uniq
    first = format_types([types.first], false)
    if types.size == 2 && types.last == 'nil'
      type = first + '?'
    elsif types.size == 2 && types.last =~ /^(Array)?<#{Regexp.quote types.first}>$/
      type = first + '+'
    elsif types.size > 2
      type = [first, '...'].join(', ')
    elsif types == ['void'] && options.hide_void_return
      type = ""
    else
      type = format_types(types, false)
    end
  elsif !type.empty?
    type = format_types([type], false)
  end
  type = "#{type} " unless type.empty?
  type
end

def resolve_alerts(source)
  source.gsub(/^> \[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\n((?:^>(?: .*|$)\n)+)/) do |*args|
    type = $1
    content = indent($2.gsub(/^> /, ""))
    case type
    when "NOTE"
      <<~MDX
        <Callout className="border bg-black/5 dark:bg-white/5">
        #{content}
        </Callout>
      MDX
    when "TIP"
      <<~MDX
        <Success>
        #{content}
        </Success>
      MDX
    when "IMPORTANT"
      <<~MDX
        <Info>
        #{content}
        </Info>
      MDX
    when "WARNING"
      <<~MDX
        <Warning>
        #{content}
        </Warning>
      MDX
    when "CAUTION"
      <<~MDX
        <Error>
        #{content}
        </Error>
      MDX
    end
  end
end

def html_syntax_highlight(str)
  return str
end
