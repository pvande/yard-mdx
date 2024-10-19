require "json"

def init
  super
  options.objects = run_verifier(options.objects)

  generate_docs_config
  generate_homepage

  options.objects.each { |x| serialize(x) }
  # options.files.each { |x| serialize(x) }
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
  config["sidebar"] << {
    group: "API Docs",
    pages: [
      *sidebar_for(Registry.root)
    ]
  }

  serializer.serialize("config.json", JSON.pretty_generate(config))
end

def generate_homepage
  return unless options.readme
  serializer.serialize("index.mdx", T("readme").run(options))
end

def generate_assets
  Array(assets).each { |asset| serialize(asset) }
end

def sidebar_for(object)
  config = {}
  namespaces = object.children.grep(YARD::CodeObjects::NamespaceObject)
  config[:icon] = icon_for(object)
  if namespaces.any?
    config[:group] = object.type == :root ? object.title : object.name
    config[:href] = serializer.serialized_path(object).delete_suffix(".mdx") if has_documentation?(object)
    config[:pages] = namespaces.flat_map { |child| sidebar_for(child) }
  else
    config[:title] = object.type == :root ? object.title : object.name
    config[:href] = serializer.serialized_path(object).delete_suffix(".mdx")
  end
  [config]
end

def serialize(obj)
  contents = case obj
  when String
    file(obj)
  when YARD::CodeObjects::ExtraFileObject
    obj.contents
  else
    obj.format(options.to_hash.slice(:format, :template))
  end

  options.serializer.serialize(obj, contents)
end

def has_documentation?(obj)
  return true unless obj.docstring.blank?(true)
  return true unless obj.children.empty?
  return false
end
