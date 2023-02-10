
module Queries::Concerns::Polymorphic
  extend ActiveSupport::Concern

  def self.permit(params)
    params.permit(
      :keyword_id_and,
      :keyword_id_or,
      :tags,
      keyword_id_and: [],
      keyword_id_or: []
    )
  end

  included do
    attr_accessor :polymorphic_id

    attr_accessor :object_global_id

    attr_accessor :global_object

    def self.polymorphic_klass(klass)
      define_singleton_method(:annotating_class){klass}
    end

    def polymorphic_id=(hash)
      set_polymorphic_id(hash)
    end

    def object_global_id=(value)
      @object_global_id = value
    end
  end

  def set_polymorphic_id(hash)
    @polymorphic_id = hash.select{|k,v| self.class.annotating_class.related_foreign_keys.include?(k.to_s)}
    @polymorphic_id ||= {}
  end

  # @return [ActiveRecord object, nil]
  def object_for
    if @global_object = GlobalID::Locator.locate(object_global_id)
      @global_object
    else
      nil
    end
  end

  def global_object_id
    object_for&.id
  end

  def global_object_type
    if object_for
      object_for&.class.base_class.name
    else
      nil
    end
  end

  # TODO: Dry with polymorphic_params
  # @return [Arel::Node, nil]
  def matching_polymorphic_id
    nodes = Queries::Annotator.polymorphic_nodes(polymorphic_id, self.class.annotating_class)
    return nil if nodes.nil?
    a = nodes.shift
    nodes.each do |b|
      a = a.and(b)
    end
    a
  end

  # Not necessary, handled by splitting out id/type
  # TODO: remove paradigm from Notes facets
  def object_global_id_facet
    return nil if object_global_id.nil?
    o = GlobalID::Locator.locate(object_global_id)
    k = o.class.base_class.name
    id = o.id
    t = self.class.annotating_class.table_name.singularize + '_object'
    table["#{t}_id".to_sym].eq(o.id).and(table["#{t}_type".to_sym].eq(k))
  end

end
