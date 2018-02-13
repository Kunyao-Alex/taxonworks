# See
#  http://www.slideshare.net/camerondutro/advanced-arel-when-activerecord-just-isnt-enough
#  https://github.com/rails/arel
#  http://robots.thoughtbot.com/using-arel-to-compose-sql-queries
#  https://github.com/rails/arel/blob/master/lib/arel/predications.rb
#  And this:
#    http://blog.arkency.com/2013/12/rails4-preloading/
#    User.includes(:addresses).where("addresses.country = ?", "Poland").references(:addresses)
#  
# TODO: Define #all as a stub (Array or AR)
#
class Queries::Query
  include Arel::Nodes

  attr_accessor :query_string
  attr_accessor :terms
  attr_accessor :project_id

  # limit based on size and potentially properties of terms
  attr_accessor :dynamic_limit

  def initialize(string, project_id: nil, **keyword_args)
    @query_string = string
    @project_id = project_id
    build_terms
  end

  # @return [Array]
  #   the results of the query as ActiveRecord objects 
  def result
    []
  end

  # @return [Scope]
  # stub
  def scope
    where('1 = 2') 
  end

  # @return [Array]
  def terms=(string)
    @query_string = string
    build_terms
    terms 
  end

  # @return [Array]
  def terms
    @terms ||= build_terms
  end

  # @return [Array]  
  #   a reasonable (starting) interpretation of any query string
  # Ultimately we should replace this concept with full text indexing.
  def build_terms
    @terms = @query_string.blank? ? [] : [end_wildcard, start_and_end_wildcard]  
  end

  # @return [String]
  def start_wildcard
    '%' + query_string 
  end

  # @return [String]
  def end_wildcard
    query_string + '%'
  end

  # @return [String]
  def start_and_end_wildcard
    '%' + query_string + '%'
  end

  # @return [Array]
  def alphabetic_strings
    Utilities::Strings.alphabetic_strings(query_string)
  end

  # @return [Array]
  #   those strings that represent years
  def years
    query_string.scan(/\d{4}/).to_a.uniq
  end

  # @return [String, nil]
  #    the first letter recognized as coming directly past the first year
  #      `Smith, 1920a. ... ` returns `a` 
  def year_letter
    query_string.match(/\d{4}([a-zAZ]+)/).to_a.last
  end

  # @return [Array]
  #   of strings representing integers
  def integers
    return [] if query_string.blank?
    query_string.split(/\s+/).select{|t| Utilities::Strings.is_i?(t)}
  end

  # @return [Boolean]
  #   true if the query string only contains integers
  def only_integers?
    !(query_string =~ /[^\d\s]/i) && !integers.empty? 
  end

  # @return [Array]
  #   if 5 or fewer alphabetic_strings, those alphabetic_strings wrapped in wildcards, else none.
  #  Used in *unordered* AND searchs 
  def fragments
    a = alphabetic_strings
    if a.size > 0 && a.size < 6
      a.collect{|a| "%#{a}%"}
    else
      []
    end
  end
 
  # @return [Array]
  #   split on whitespace
  def pieces
    query_string.split(/\s+/)
  end

  # @return [Array]
  def wildcard_wrapped_integers
    integers.collect{|i| "%#{i}%"}
  end

  # @return [String]
  #   if `foo, and 123 and stuff` then %foo%and%123%and%stuff%
  def wildcard_pieces
   '%' + query_string.gsub(/[\s\W]+/, '%') + '%'
  end

  def no_digits 
    query_string.gsub(/\d/, '').strip
  end

  # @return [Integer]
  def dynamic_limit
    limit = 10 
    case query_string.length
    when 0..3
      limit = 20 
    else
      limit = 100 
    end
    limit
  end


  # generic multi-use bits
  #   table is defined in each query, it is the class of instances being returned

  def parent_child_join
    table.join(parent).on(table[:parent_id].eq(parent[:id])).join_sources # !! join_sources ftw
  end

  # Match at two levels, for example, 'wa te" will match "Washington Co., Texas"
  def parent_child_where
    a,b = query_string.split(/\s+/, 2)
    return table[:id].eq(-1) if a.nil? || b.nil?
    table[:name].matches("#{a}%").and(parent[:name].matches("#{b}%"))
  end

  # @return [Query, nil]
  #   used in or_clauses
  def with_id
    if integers.any?
      table[:id].eq_any(integers)
    else
      nil
    end
  end

  # @return [Query, nil]
  #   used in or_clauses, match on id only if integers alone provided.
  def only_ids
    if only_integers?
      with_id
    else
      nil
    end 
  end

  def named
    table[:name].matches_any(terms)
  end

  def exactly_named
    table[:name].eq(query_string)
  end

  def parent 
    table.alias 
  end

  # TODO: nil/or clause this
  def with_project_id
    if project_id 
      table[:project_id].eq(project_id)
    else
      nil      
    end
  end

  def identifier_table
    Identifier.arel_table
  end

  # @return [Arel::Nodes::Grouping]
  def with_identifier_like
    a = [ start_and_end_wildcard ]
    a = a + wildcard_wrapped_integers
    identifier_table[:cached].matches_any(a)
  end

  def with_identifier
    identifier_table[:cached].eq(query_string)
  end

  # @return [ActiveRecord::Relation, nil]
  # cached matches full query string wildcarded
  def cached
    if !terms.empty?
      table[:cached].matches_any(terms)
    else
      nil
    end
  end

  def combine_or_clauses(clauses)
    clauses.compact!
    raise TaxonWorks::Error, 'combine_or_clauses called without a clause, ensure at least one exists' unless !clauses.empty?
    a = clauses.shift
    clauses.each do |b|
      a = a.or(b)
    end
    a
  end

  # @return [Array]
  #   default the autocomplete result to all
  def autocomplete
    all.to_a
  end

end
