include T("default/tags/html")
# include YARD::Templates::Helpers::HtmlHelper

def init
  super
  sections[:index][:param] << [:options_for_param]
  sections[:index].delete(:option)
end

def index
  yieldall
end

def see
  erb("see") if object.has_tag?(:see)
end

def param
  erb("param") if object.type == :method && object.has_tag?(:param)
end

def yield
end

def nonparam_options
  return [] unless object.respond_to?(:parameters)
  options = object.tags(:option).map(&:name).uniq.map(&:to_s)
  params = object.tags(:param).map(&:name).uniq.map(&:to_s)
  object.parameters.map(&:first).select do |param|
    param = param.to_s.sub(/^\*+|:$/, "")
    options.any?(param) && params.none?(param)
  end
end

def format_types(typelist, brackets = true)
  return unless typelist.is_a?(Array)
  list = typelist.map do |type|
    type = type.gsub(/([<>])/) { h($1) }
    type = type.gsub(/([\w:]+)/) { $1 == "lt" || $1 == "gt" ? $1 : linkify($1, $1) }
    type
  end
  list.empty? ? "" : (brackets ? "(#{list.join(", ")})" : list.join(", "))
end
