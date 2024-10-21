require "json"

def init
  super
  options.objects = run_verifier(options.objects)

  generate_docs_config

  options.objects.each { |x| serialize(x) }
  options.files.each { |x| serialize(x) }
end

def generate_docs_config
  config = {
    "$schema" => "https://docs.page/schema.json",
    "name" => options.title
  }

  if YARD::Tags::Library.labels[:config]
    config.merge!(JSON.load(File.new(YARD::Tags::Library.labels[:config])))
  end

  config["sidebar"] ||= []

  group = config["sidebar"].shift
  if group.nil?
    config["sidebar"].unshift(group = {})
  elsif group["group"]
    config["sidebar"].unshift(group)
    config["sidebar"].unshift(group = {})
  end
  sidebar_docs(group["pages"] ||= [])

  config["sidebar"] << {
    group: "API Docs",
    pages: sidebar_api(Registry.root)
  }

  serializer.serialize("config.json", JSON.pretty_generate(config))
end

def generate_assets
  Array(assets).each { |asset| serialize(asset) }
end

def sidebar_docs(pages)
  if options.readme
    pages << { title: "Home", href: "/index" }
  end

  return { pages: [] }
end

def sidebar_api(object)
  config = {}
  namespaces = object.children.grep(YARD::CodeObjects::NamespaceObject)
  config[:icon] = icon_for(object)
  if namespaces.any?
    config[:group] = object.type == :root ? object.title : object.name
    config[:href] = serializer.serialized_path(object).delete_suffix(".mdx") if has_documentation?(object)
    config[:pages] = namespaces.flat_map { |child| sidebar_api(child) }
  else
    config[:title] = object.type == :root ? object.title : object.name
    config[:href] = serializer.serialized_path(object).delete_suffix(".mdx")
  end

  return [config]
end

def serialize(obj)
  if obj == options.readme
    options.serializer.serialize("index.mdx", format_file(obj.contents))
    return
  end

  contents = case obj
  when String
    file(obj)
  when YARD::CodeObjects::ExtraFileObject
    format_file(obj.contents)
  else
    erb("page_header") + obj.format(options.to_hash.slice(:format, :template))
  end

  options.serializer.serialize(obj, contents)
end

def format_file(contents)
  erb("page_header") +
  resolve_alerts(resolve_links(contents))
end

def has_documentation?(obj)
  return true unless obj.docstring.blank?(true)
  # return true unless obj.children.empty?
  return false
end
