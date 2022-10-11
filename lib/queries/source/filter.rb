module Queries
  module Source
    class Filter < Queries::Query

      # TODO: move to model replicated in CollectingEvent
      # TOOD: confirm cached should not be a target
      ATTRIBUTES = (::Source.column_names - %w{id project_id created_by_id updated_by_id created_at updated_at cached})
      #  ATTRIBUTES.each do |a|
      #    class_eval { attr_accessor a.to_sym }
      #  end

      PARAMS = %w{
        in_project
        author
        ids
        exact_author
        author_ids
        author_ids_or
        topic_ids
        year_start
        year_end
        title
        exact_title
        citations
        recent
        roles
        documents
        nomenclature
        with_doi
        citation_object_type
        notes
        source_type
        serial_ids
        ancestor_id
        citations_on_otus
      }

      include Queries::Concerns::Tags
      include Queries::Concerns::Users
      include Queries::Concerns::Empty

      # @project_id from Queries::Query
      #   used in context of in_project when provided
      #   must also include `in_project=true|false`

      # @return [Boolean, nil]
      # @params in_project ['true', 'false', nil]
      # ! requires `project_id`
      attr_accessor :in_project

      # @return author [String, nil]
      attr_accessor :author

      # TODO: Change to source_id
      # @return ids [Array of Integer, nil]
      attr_accessor :ids

      # @return [Boolean, nil]
      # @params exact_author ['true', 'false', nil]
      attr_accessor :exact_author

      # @params author [Array of Integer, Person#id]
      attr_accessor :author_ids

      # @params author [Boolean, nil]
      attr_accessor :author_ids_or

      # @params author [Array of Integer, Topic#id]
      attr_accessor :topic_ids

      # @params year_start [Integer, nil]
      attr_accessor :year_start

      # @params year_end [Integer, nil]
      attr_accessor :year_end

      # @params title [String, nil]
      attr_accessor :title

      # @return [Boolean, nil]
      # @params exact_title ['true', 'false', nil]
      attr_accessor :exact_title

      # @return [Boolean, nil]
      # @params citations ['true', 'false', nil]
      attr_accessor :citations

      # @return [Boolean, nil]
      # @params recent ['true', 'false', nil]
      attr_accessor :recent

      # @return [Boolean, nil]
      # @params roles ['true', 'false', nil]
      attr_accessor :roles

      # @return [Boolean, nil]
      # @params documentation ['true', 'false', nil]
      attr_accessor :documents

      # @return [Boolean, nil]
      # @params nomenclature ['true', 'false', nil]
      attr_accessor :nomenclature

      # @return [Boolean, nil]
      # @params with_doi ['true', 'false', nil]
      attr_accessor :with_doi

      # TODO: move tc citations concern
      # @return [Array, nil]
      # @params citation_object_type  [Array of ObjectType]
      attr_accessor :citation_object_type

      # From lib/queries/concerns/tags.rb
      # attr_accessor :tags

      # @return [Boolean, nil]
      # @params notes ['true', 'false', nil]
      attr_accessor :notes

      # @return [String, nil]
      # @params source_type ['Source::Bibtex', 'Source::Human', 'Source::Verbatim']
      attr_accessor :source_type

      # @params author [Array of Integer, Serial#id]
      attr_accessor :serial_ids

      # @return [Protonym.id, nil]
      #   return all sources in Citations linked to this name or descendants
      #   to this TaxonName
      attr_accessor :ancestor_id

      # @return [Boolean]
      # @params citations_on_otus ['false', 'true']
      #   ignored if ancestor_id is not provided; if true then also include sources linked to OTUs that are in the scope of ancestor_id
      attr_accessor :citations_on_otus

      # @param [Hash] params
      def initialize(params)
        @query_string = params[:query_term]&.delete("\u0000") # TODO, we need to sanitize params in general.

        @author = params[:author]
        @author_ids = params[:author_ids] || []

        @author_ids_or = (params[:author_ids_or]&.to_s&.downcase == 'true' ? true : false) if !params[:author_ids_or].nil?

        @ids = params[:ids] || []
        @topic_ids = params[:topic_ids] || []
        @serial_ids = params[:serial_ids] || []
        @citation_object_type = params[:citation_object_type] || []
        @citations = (params[:citations]&.to_s&.downcase == 'true' ? true : false) if !params[:citations].nil?
        @documents = (params[:documents]&.to_s&.downcase == 'true' ? true : false) if !params[:documents].nil?
        @exact_author = (params[:exact_author]&.to_s&.downcase == 'true' ? true : false) if !params[:exact_author].nil?
        @exact_title = (params[:exact_title]&.to_s&.downcase == 'true' ? true : false) if !params[:exact_title].nil?
        @in_project = (params[:in_project]&.to_s&.downcase == 'true' ? true : false) if !params[:in_project].nil?
        @nomenclature = (params[:nomenclature]&.to_s&.downcase == 'true' ? true : false) if !params[:nomenclature].nil?
        @notes = (params[:notes]&.to_s&.downcase == 'true' ? true : false) if !params[:notes].nil?
        @project_id = params[:project_id] # TODO: also in Queries::Query
        @roles = (params[:roles]&.to_s&.downcase == 'true' ? true : false) if !params[:roles].nil?
        @source_type = params[:source_type]
        @title = params[:title]
        @with_doi = (params[:with_doi]&.to_s&.downcase == 'true' ? true : false) if !params[:with_doi].nil?
        @year_end = params[:year_end]
        @year_start = params[:year_start]
        @recent = (params[:recent]&.to_s&.downcase == 'true' ? true : false) if !params[:recent].nil?

        @citations_on_otus = (params[:citations_on_otus]&.to_s&.downcase == 'true' ? true : false) if !params[:citations_on_otus].nil?
        @ancestor_id = params[:ancestor_id]

        build_terms
        set_identifier(params)
        set_tags_params(params)
        set_user_dates(params)

        set_empty_params(params)
      end

      # @return [Arel::Table]
      def table
        ::Source.arel_table
      end

      # @return [Arel::Table]
      def project_sources_table
        ::ProjectSource.arel_table
      end

      def base_query
        ::Source.select('sources.*')
      end

      # @return [ActiveRecord::Relation, nil]
      #   if user provides 5 or fewer strings and any number of years look for any string && year
      def fragment_year_matches
        if fragments.any?
          s = table[:cached].matches_any(fragments)
          s = s.and(table[:year].eq_any(years)) if !years.empty?
          s
        else
          nil
        end
      end

      # Return all citations on Taxon names and descendants,
      # and optionally OTUs.
      def ancestors_facet
        return nil if ancestor_id.nil?

        joins = [
          ancestor_taxon_names_join,
          ancestor_taxon_name_classifications_join,
          ancestor_taxon_name_relationship_join(:subject_taxon_name_id),
          ancestor_taxon_name_relationship_join(:object_taxon_name_id)
        ]

        joins.push ancestor_otus_join if citations_on_otus

        union = joins.collect{|j| '(' + ::Source.joins(:citations).joins( j.join_sources).to_sql + ')'}.join(' UNION ')

        ::Source.from("( #{union} ) as sources")
      end

      def source_type_facet
        return nil if source_type.blank?
        table[:type].eq(source_type)
      end

      def year_facet
        return nil if year_start.blank?
        if year_start && !year_end.blank?
          table[:year].gteq(year_start)
            .and(table[:year].lteq(year_end))
        else # only start
          table[:year].eq(year_start)
        end
      end

      def source_ids_facet
        ids.empty? ? nil : table[:id].eq_any(ids)
      end

      def serial_ids_facet
        serial_ids.empty? ? nil : table[:serial_id].eq_any(serial_ids)
      end

      def author_ids_facet
        return nil if author_ids.empty?
        o = table
        r = ::Role.arel_table

        a = o.alias("a_")
        b = o.project(a[Arel.star]).from(a)

        c = r.alias('r1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:role_object_id])
          .and(c[:role_object_type].eq('Source'))
          .and(c[:type].eq('SourceAuthor'))
          )

        e = c[:id].not_eq(nil)
        f = c[:person_id].eq_any(author_ids)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.having(a['id'].count.eq(author_ids.length)) unless author_ids_or
        b = b.as('aut_z1_')

        ::Source.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end

      def topic_ids_facet
        ::Source.joins(:citation_topics).where(citation_topics: { topic_id: topic_ids }).distinct unless topic_ids.empty?
      end

      def in_project_facet
        return nil if project_id.nil? || in_project.nil?

        if in_project
          ::Source.joins(:project_sources)
            .where(project_sources: {project_id: project_id})
        else
          ::Source.left_outer_joins(:project_sources)
            .where("project_sources.project_id != ? OR project_sources.id IS NULL", Current.project_id)
            .distinct
        end
      end

      # TODO: move to a concern
      def citation_facet
        return nil if citations.nil?

        if citations
          ::Source.joins(:citations).distinct
        else
          ::Source.left_outer_joins(:citations)
            .where(citations: {id: nil})
            .distinct
        end
      end

      # TODO: move to generalized code in identifiers concern
      def with_doi_facet
        return nil if with_doi.nil?

        # See lib/queries/concerns/identifiers.rb
        @identifier_type.push 'Identifier::Global::Doi'
        @identifier_type.uniq!

        if with_doi
          identifier_type_facet
        else
          ::Source.left_outer_joins(:identifiers)
            .where("(identifiers.type != 'Identifier::Global::Doi') OR (identifiers.identifier_object_id is null)")
        end
      end

      # TODO: move to a concern
      def role_facet
        return nil if roles.nil?

        if roles
          ::Source.joins(:roles).distinct
        else
          ::Source.left_outer_joins(:roles)
            .where(roles: {id: nil})
        end
      end

      # TODO: move to a concern
      def note_facet
        return nil if notes.nil?

        if notes
          ::Source.joins(:notes).distinct
        else
          ::Source.left_outer_joins(:notes)
            .where(notes: {id: nil})
        end
      end

      # TODO: move to a concern
      def document_facet
        return nil if documents.nil?

        if documents
          ::Source.joins(:documents).distinct
        else
          ::Source.left_outer_joins(:documents)
            .where(documents: {id: nil})
            .distinct
        end
      end

      # TODO: move to citation concern
      def citation_object_type_facet
        return nil if citation_object_type.empty?
        ::Source.joins(:citations)
          .where(citations: {citation_object_type: citation_object_type}).distinct
      end

      def nomenclature_facet
        return nil if nomenclature.nil?

        if nomenclature
          ::Source.joins(:citations)
            .where(citations: {citation_object_type: ['TaxonName', 'TaxonNameRelationship', 'TaxonNameClassification', 'TypeMaterial']})
            .distinct
        else
          ::Source.left_outer_joins(:citations)
            .where("(citations.citation_object_type NOT IN ('TaxonName','TaxonNameRelationship','TaxonNameClassification','TypeMaterial')) OR (citations.id is null)")
            .distinct
        end
      end

      def base_merge_clauses
        clauses = []

        clauses += [
          ancestors_facet,
          author_ids_facet,
          topic_ids_facet,
          citation_facet,
          citation_object_type_facet,
          document_facet,
          in_project_facet,
          nomenclature_facet,
          role_facet,
          with_doi_facet,
          keyword_id_facet,
          tag_facet,
          note_facet,
          identifier_between_facet,
          identifier_facet,
          identifier_namespace_facet,
          match_identifiers_facet,
          created_updated_facet, # See Queries::Concerns::Users
          empty_fields_facet,    # See Queries::Concerns::Empty
          not_empty_fields_facet,
        ]
        clauses.compact!
        clauses
      end

      # @return [ActiveRecord::Relation]
      def merge_clauses
        clauses = base_merge_clauses
        return nil if clauses.empty?
        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = []

        clauses += [
          cached,
          source_ids_facet,
          serial_ids_facet,
          attribute_exact_facet(:author),
          attribute_exact_facet(:title),
          source_type_facet,
          year_facet
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses

        q = nil
        if a && b
          q = b.where(a)
        elsif a
          q = ::Source.where(a)
        elsif b
          q = b
        else
          q = ::Source.all
        end

        q = q.order(updated_at: :desc) if recent
        q
      end

      private

      def ancestor_otus_join
        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        o = ::Otu.arel_table

        c.join(o, Arel::Nodes::InnerJoin).on(
          o[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('Otu'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          o[:taxon_name_id].eq(h[:descendant_id]).and(h[:ancestor_id].eq(ancestor_id))
        )
      end

      def ancestor_taxon_names_join
        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        t = ::TaxonName.arel_table

        c.join(t, Arel::Nodes::InnerJoin).on(
          t[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('TaxonName'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          t[:id].eq(h[:descendant_id]).and(h[:ancestor_id].eq(ancestor_id))
        )
      end

      def ancestor_taxon_name_classifications_join
        return nil if ancestor_id.nil?

        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        t = ::TaxonNameClassification.arel_table

        c.join(t, Arel::Nodes::InnerJoin).on(
          t[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('TaxonNameClassification'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          t[:taxon_name_id].eq(h[:descendant_id]).and(h[:ancestor_id].eq(ancestor_id))
        )
      end

      def ancestor_taxon_name_relationship_join(join_on = :subject_taxon_name_id)
        return nil if ancestor_id.nil?

        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        t = ::TaxonNameRelationship.arel_table

        c.join(t, Arel::Nodes::InnerJoin).on(
          t[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('TaxonNameRelationship'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          t[join_on].eq(h[:descendant_id]).and(h[:ancestor_id].eq(ancestor_id))
        )
      end

    end
  end
end
