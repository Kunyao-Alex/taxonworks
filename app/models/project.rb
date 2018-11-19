# A project is a team's wrapper for a group of data.  Most data is project specific, with a few exceptions.  A project has many users, and one or more project administrators.
# With the exception of "Workers" who can only see and therefore use certain elements of the workbench all members of a project share the same privileges.  A projects
# members are therefor well trained and trusted contributors to the project.
#
# @!attribute name
#   @return [String]
#     The name of the project
#
# @!attribute preferences
#   @return [Hash]
#     Settings for the project (for all users)
#
# @!attribute api_access_token
#   @return [String, nil]
#      The token is not intended to be private.  Generating one is akin to indicating that your project's data are public, and they will be exposed in the general API to all.  The token is primarily for tracking "anonymous" use. 
#
class Project < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Housekeeping::AssociationHelpers

   NUKE_ORDER = %w{
     DwcOccurrence
     ProtocolRelationship
     CharacterState
     Protocol
     AlternateValue
     DataAttribute
     CitationTopic
     Citation
     SqedDepiction
     Depiction
     Documentation
     Document
     CollectionObjectObservation
     DerivedCollectionObject
     Note
     PinboardItem
     TaggedSectionKeyword
     Tag
     Confidence
     Role
     AssertedDistribution
     BiocurationClassification
     BiologicalRelationshipType
     BiologicalAssociationsBiologicalAssociationsGraph
     BiologicalAssociation
     BiologicalRelationship
     BiologicalAssociationsGraph
     CollectionProfile
     ContainerItem
     Container
     PublicContent
     Content
     Georeference
     Identifier
     LoanItem
     Loan
     OtuPageLayoutSection
     OtuPageLayout
     ProjectSource
     TaxonDetermination
     TypeMaterial
     CollectionObject
     CollectingEvent
     RangedLotCategory
     Image
     CommonName
     Otu
     TaxonNameClassification
     TaxonNameRelationship
     TaxonName
     ControlledVocabularyTerm
     OriginRelationship
     Sequence
     SequenceRelationship
     Observation
     Extract
     GeneAttribute
     ObservationMatrixColumnItem
     ObservationMatrixColumn
     ObservationMatrixRowItem
     ObservationMatrixRow
     ObservationMatrix
     Descriptor
     ProjectMember
   }.freeze


  PREFERENCES = [
    'workbench_starting_path',  # like '/hub'
  ]

  DEFAULT_WORKBENCH_STARTING_PATH = '/hub'.freeze

  DEFAULT_WORKBENCH_SETTINGS = {
    'workbench_starting_path' =>  DEFAULT_WORKBENCH_STARTING_PATH
  }

  store :preferences, accessors: PREFERENCES, coder: JSON

  # When true no Root taxon name is built 
  attr_accessor :without_root_taxon_name

  # When true a the api token is (re)set
  attr_accessor :set_new_api_access_token
  attr_accessor :clear_api_access_token

  has_many :project_members, dependent: :restrict_with_error
  has_many :users, through: :project_members
  has_many :project_sources, dependent: :restrict_with_error
  has_many :sources, through: :project_sources

  before_save :generate_api_access_token, if: -> { self.set_new_api_access_token } # any value is true
  before_save :destroy_api_access_token, if: -> { self.clear_api_access_token} # any value is true
  before_save :set_default_preferences, unless: -> { self.preferences.any? }
  after_create :create_root_taxon_name, unless: -> { self.without_root_taxon_name == true}

  validates_presence_of :name
  validates_uniqueness_of :name

  def clear_preferences
    update_column(:preferences, DEFAULT_WORKBENCH_SETTINGS)
  end

  # !! This is not production ready.
  # @return [Boolean]
  #   based on whether the project has successfully been deleted.  Can also raise on detected problems with configuration.
  def nuke
    known = ApplicationRecord.subclasses.select {|a| a.column_names.include?('project_id')}.map(&:name)

    known.each do |k|
      next if k.constantize.table_name == 'test_classes' # TODO: a kludge to ignore stubbed classes in testing
      if !NUKE_ORDER.include?(k)
        raise "#{k} has not been added to Project#NUKE_ORDER."
      end
    end

    begin
      NUKE_ORDER.each do |o|
        klass = o.constantize
        klass.where(project_id: id).delete_all
      end

      self.destroy

      true
    rescue => e
      raise e
    end
  end

  # TODO: boot load checks
  def root_taxon_name
    # Calling TaxonName is a hack to load the required has_many into Project,
    # "has_many :taxon_names" is invoked through TaxonName within Housekeeping::Project
    # Within TaxonName closure_tree (appears to?) require a database connection. 

    # Since we shouldn't (can't?) initiate a connection prior to a require_dependency
    # we simply load TaxonName for the first time here.
    TaxonName.tap {} # TODO: move to require_dependency?
    TaxonNameRelationship.tap {}
    taxon_names.root
  end

  def self.find_for_autocomplete(params)
    where('name LIKE ?', "#{params[:term]}%")
  end

  protected

  def set_default_preferences
    PREFERENCES.each do |p|
      send(p + '=',  DEFAULT_WORKBENCH_SETTINGS[p]) if send(p).nil?
    end
  end

  def create_root_taxon_name
    p = Protonym.stub_root(project_id: id, by: creator)
    p.save!
    p
  end

  # @return [String]
  def generate_api_access_token
    self.api_access_token = Utilities::RandomToken.generate
  end

  def destroy_api_access_token
    self.api_access_token = nil 
  end

end
