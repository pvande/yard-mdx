include T("default/docstring/html")

def init
  return if object.docstring.blank? && !object.has_tag?(:api)
  sections :index, [:returns_void, :private, :deprecated, :abstract, :todo, :note, :text], T('tags')
end
