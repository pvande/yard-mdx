include T("default/module/html")

def init
  sections(
    :header, [:box_info],
    T('docstring'),
    :constant_summary, [T('docstring')],
    # :inherited_constants,
    # :attribute_summary, [:item_summary],
    # :inherited_attributes,
    # :method_summary, [:item_summary],
    # :inherited_methods,

    :methodmissing, [T('method')],
    :attribute_details, [T('method')],
    :method_details, [T('method')]
  )
end

def box_info
  @intrinsics = []
  @extrinsics = []
  @children = []

  klass = object.superclass if object.is_a?(CodeObjects::ClassObject)
  @intrinsics << [ "Inherits From", linkify(klass) ] if klass

  mixins = run_verifier(object.mixins(:class)).dup
  mixins.sort_by!(&:path).map! { |o| linkify(o) }
  @intrinsics << [ "Extended By", mixins.join(", ") ] if mixins.any?

  mixins = run_verifier(object.mixins(:instance)).dup
  mixins.sort_by!(&:path).map! { |o| linkify(o) }
  @intrinsics << [ "Includes", mixins.join(", ") ] if mixins.any?

  mods = mixed_into(object)
  mods.sort_by!(&:path).map! { |o| linkify(o) }
  @extrinsics << [ "Included In", mods.join(", ") ] if mods.any?

  classes = subclasses(object) || []
  classes.sort_by!(&:path).map! { |o| linkify(o, object.relative_path(o)) }
  @extrinsics << [ "Known Subclasses", classes.join(", ") ] if classes.any?

  children = object.children.group_by(&:type)
  child_modules = run_verifier(children.fetch(:module, []).sort_by!(&:path)).map! { |o| linkify(o, object.relative_path(o)) }
  child_classes = run_verifier(children.fetch(:class, []).sort_by!(&:path)).map! { |o| linkify(o, object.relative_path(o)) }
  @children << [ "Namespaced Modules", child_modules.join(", ") ] if child_modules.any?
  @children << [ "Namespaced Classes", child_classes.join(", ") ] if child_classes.any?

  erb("box_info")
end

def constant_summary
  erb("constant_summary") unless constant_listing.empty?
end

def mixed_into(object)
  unless globals.mixed_into
    globals.mixed_into = {}
    list = run_verifier(Registry.all(:class, :module))
    list.each { |o| o.mixins.each { |m| (globals.mixed_into[m] ||= []) << o } }
  end

  globals.mixed_into[object.path] || []
end

def subclasses(object)
  return if object.type != :class
  return if object.path == "Object" # don't show subclasses for Object
  unless globals.subclasses
    globals.subclasses = {}
    list = run_verifier(Registry.all(:class))
    list.each do |o|
      (globals.subclasses[o.superclass.path] ||= []) << o if o.superclass
    end
  end

  globals.subclasses[object.path]
end
