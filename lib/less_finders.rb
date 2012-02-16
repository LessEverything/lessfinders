require "less_finders/version"

module LessFinders
  
  def initialize params, default_scope = nil, default_scope_id = :business_id
    @params = params
    @default_scope = default_scope
    @default_scope_id = default_scope_id
  end

  def plural_instance
    pare = parent
    if pare
      {object_name.pluralize.to_sym => add_scope( object_class, parent_id_name, parent_id)}.merge(pare)
    else
      {object_name.pluralize.to_sym => add_scope( object_class, @default_scope_id, @default_scope.id)}
    end
  end

  def singular_instance
    raise "Please add support for nested params deeper than 2 (size = #{scopes.size})"  if scopes.size > 2
    if nested?
      nested_singular_instance
    else
      not_nested_singular_instance
    end
  end

  def new_instance
    if nested?
      child = object_class.new object_params_or_empty_hash.merge(parent_id_name => parent_id)
      {object_name.to_sym => child}.merge(parent)
    else
      inst = object_class.new object_params_or_empty_hash.merge(@default_scope_id => @default_scope.id)
      {object_name.to_sym => inst}
    end
  end
  
  
  private

  def object_params_or_empty_hash
    return {} unless @params.has_key? object_name
    @params[object_name]
  end

  def not_nested_singular_instance
    if id
      o = add_scope( object_class, :id, id)
      o = add_scope( o, @default_scope_id, @default_scope.id).first
      {object_name.to_sym => o}
    else
      return new_instance
    end
  end

  def nested_singular_instance
    if id
      child = add_scope( object_class, :id,          id)
      child = add_scope( child, parent_id_name, parent_id).first
      {object_name.to_sym => child}.merge(parent)
    else
      new_instance
    end
  end

  def parent
    return nil if parent_name.blank?
    o = add_scope( parent_class, @default_scope_id, @default_scope.id).first
    {parent_name.to_sym  => o}
  end
  
  
  def parent_class
    return nil if parent_name.blank?
    parent_name.classify.constantize  
  end

  def parent_name
    scopes.select {|k,v| k.to_s =~ /_id$/}[0][0].to_s.gsub(/_id$/, '')
  end
  
  def parent_id_name
    scopes.select {|k,v| k.to_s =~ /_id$/}[0][0]
  end
  
  def parent_id
    scopes.select {|k,v| k.to_s =~ /_id$/}[0][1]
  end

  def id
    scopes[:id]
  end
  
  def object_name
    @params[:controller].classify.underscore
  end
  
  def object_class
    @params[:controller].classify.constantize
  end
  
  def scopes
    HashWithIndifferentAccess[@params.select {|k,v| k.to_s =~ /_id$/ || k.to_s == "id"}]
  end

  def add_scope o, attribute, value
    o.scoped :conditions => {attribute => value}
  end
  
  def nested?
    !parent_id_name.blank?
  end


end
