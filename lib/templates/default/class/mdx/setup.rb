include T("default/module/mdx")

def init
  super
  sections.place(:constructor_details, [T('method')]).before(:methodmissing)
end

def constructor_details
  ctors = object.meths(:inherited => true, :included => true)
  @ctor = ctors.find { |x| x.name(true) == "#initialize" }
  return unless @ctor
  return if prune_method_listing([@ctor]).empty?
  erb(:constructor_details)
end
